//
//  GoalAnalysisService.swift
//  Fit14
//
//  Created by Jerson on 7/6/25.
//

import Foundation
import Combine

// MARK: - Analysis State Models

/// Current state of the goal analysis
enum AnalysisState: Equatable {
    case idle
    case analyzing
    case completed(confidence: Double)
    case error(String)
    
    var isAnalyzing: Bool {
        if case .analyzing = self { return true }
        return false
    }
    
    var confidence: Double {
        if case .completed(let confidence) = self { return confidence }
        return 0.0
    }
}

/// Real-time analysis update with suggestions
struct AnalysisUpdate: Equatable {
    let text: String
    let state: AnalysisState
    let suggestedChips: [ChipType]
    let chipVisibilityChanges: [ChipType: Bool]  // ChipType -> shouldBeVisible
    let qualityScore: Double
    let processingTime: TimeInterval
    let timestamp: Date
    
    init(text: String, state: AnalysisState, suggestedChips: [ChipType] = [], chipVisibilityChanges: [ChipType: Bool] = [:], qualityScore: Double = 0.0, processingTime: TimeInterval = 0.0) {
        self.text = text
        self.state = state
        self.suggestedChips = suggestedChips
        self.chipVisibilityChanges = chipVisibilityChanges
        self.qualityScore = qualityScore
        self.processingTime = processingTime
        self.timestamp = Date()
    }
}

/// Configuration for the analysis service
struct AnalysisConfiguration {
    let debounceInterval: TimeInterval = 0.5
    let minTextLength: Int = 3
    let maxSuggestedChips: Int = 3
    let minConfidenceThreshold: Double = 0.3
    let enableRealTimeAnalysis: Bool = true
    let enableSmartSuggestions: Bool = true
    let enableProgressiveDisclosure: Bool = true  // Show chips gradually
}

// MARK: - Goal Analysis Service

/// Service that provides real-time text analysis and contextual chip suggestions
@MainActor
class GoalAnalysisService: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published private(set) var currentAnalysis: AnalysisUpdate?
    @Published private(set) var analysisHistory: [AnalysisUpdate] = []
    @Published private(set) var isAnalyzing: Bool = false
    
    // MARK: - Private Properties
    
    private let keywordMatcher: KeywordMatcher
    private let configuration: AnalysisConfiguration
    private var cancellables = Set<AnyCancellable>()
    private var analysisTask: Task<Void, Never>?
    
    // Debouncing
    private let textSubject = PassthroughSubject<String, Never>()
    private var lastAnalysisText: String = ""
    
    // State tracking
    private var currentUserGoalData: UserGoalData?
    private var visibleChipTypes: Set<ChipType> = Set(ChipType.universalTypes)
    
    // Performance tracking
    private var analysisCount: Int = 0
    private var totalProcessingTime: TimeInterval = 0
    
    // MARK: - Initialization
    
    init(keywordMatcher: KeywordMatcher = KeywordMatcher(), configuration: AnalysisConfiguration = AnalysisConfiguration()) {
        self.keywordMatcher = keywordMatcher
        self.configuration = configuration
        
        setupTextAnalysisStream()
    }
    
    deinit {
        analysisTask?.cancel()
    }
    
    // MARK: - Setup
    
    private func setupTextAnalysisStream() {
        guard configuration.enableRealTimeAnalysis else { return }
        
        textSubject
            .debounce(for: .seconds(configuration.debounceInterval), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] text in
                Task { @MainActor in
                    await self?.performAnalysis(for: text)
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public API
    
    /// Analyze text input and update chip suggestions
    func analyzeText(_ text: String, with userGoalData: UserGoalData? = nil) {
        // Update current goal data
        if let goalData = userGoalData {
            currentUserGoalData = goalData
        }
        
        // Skip if text hasn't changed significantly
        guard text != lastAnalysisText else { return }
        
        // Update state immediately
        isAnalyzing = true
        
        // Send to debounced stream
        textSubject.send(text)
    }
    
    /// Get current chip suggestions based on latest analysis
    func getCurrentSuggestions() -> [ChipType] {
        return currentAnalysis?.suggestedChips ?? []
    }
    
    /// Check if a specific chip type should be visible
    func shouldShowChip(_ chipType: ChipType) -> Bool {
        // Universal chips are always visible
        if chipType.category == .universal {
            return true
        }
        
        // Contextual chips depend on analysis
        return visibleChipTypes.contains(chipType)
    }
    
    /// Get quality assessment for current goal data
    func getQualityAssessment(for userGoalData: UserGoalData) -> GoalQualityAssessment {
        let textQuality = assessTextQuality(userGoalData.freeFormText)
        let chipQuality = assessChipQuality(userGoalData)
        let overallScore = (textQuality.score + chipQuality.score) / 2.0
        
        return GoalQualityAssessment(
            overallScore: overallScore,
            textQuality: textQuality,
            chipQuality: chipQuality,
            suggestions: generateImprovementSuggestions(userGoalData),
            isReadyForAI: overallScore >= 0.7
        )
    }
    
    /// Force immediate analysis (bypasses debouncing)
    func forceAnalysis(for text: String, with userGoalData: UserGoalData? = nil) async {
        if let goalData = userGoalData {
            currentUserGoalData = goalData
        }
        
        await performAnalysis(for: text)
    }
    
    /// Reset analysis state
    func reset() {
        analysisTask?.cancel()
        currentAnalysis = nil
        analysisHistory.removeAll()
        isAnalyzing = false
        lastAnalysisText = ""
        visibleChipTypes = Set(ChipType.universalTypes)
        currentUserGoalData = nil
    }
    
    // MARK: - Core Analysis Logic
    
    private func performAnalysis(for text: String) async {
        guard text.count >= configuration.minTextLength else {
            // Handle short text
            await handleShortText(text)
            return
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        do {
            // Update state
            isAnalyzing = true
            lastAnalysisText = text
            
            // Perform keyword analysis
            let keywordResult = await keywordMatcher.analyzeText(text)
            
            // Generate contextual chip suggestions
            let suggestedChips = generateContextualSuggestions(from: keywordResult)
            
            // Calculate quality score
            let qualityScore = calculateQualityScore(text: text, keywordResult: keywordResult)
            
            // Determine chip visibility changes
            let visibilityChanges = determineChipVisibilityChanges(from: suggestedChips)
            
            // Update visible chips
            updateVisibleChips(with: visibilityChanges)
            
            let processingTime = CFAbsoluteTimeGetCurrent() - startTime
            
            // Create analysis update
            let update = AnalysisUpdate(
                text: text,
                state: .completed(confidence: keywordResult.confidence),
                suggestedChips: suggestedChips,
                chipVisibilityChanges: visibilityChanges,
                qualityScore: qualityScore,
                processingTime: processingTime
            )
            
            // Update published properties
            currentAnalysis = update
            analysisHistory.append(update)
            isAnalyzing = false
            
            // Update performance metrics
            analysisCount += 1
            totalProcessingTime += processingTime
            
            // Limit history size
            if analysisHistory.count > 20 {
                analysisHistory.removeFirst()
            }
            
        } catch {
            // Handle analysis error
            let update = AnalysisUpdate(
                text: text,
                state: .error(error.localizedDescription)
            )
            
            currentAnalysis = update
            isAnalyzing = false
        }
    }
    
    private func handleShortText(_ text: String) async {
        // For short text, hide contextual chips and reset state
        let visibilityChanges = ChipType.contextualTypes.reduce(into: [ChipType: Bool]()) { result, chipType in
            result[chipType] = false
        }
        
        updateVisibleChips(with: visibilityChanges)
        
        let update = AnalysisUpdate(
            text: text,
            state: .idle,
            chipVisibilityChanges: visibilityChanges
        )
        
        currentAnalysis = update
        isAnalyzing = false
        lastAnalysisText = text
    }
    
    // MARK: - Suggestion Logic
    
    private func generateContextualSuggestions(from keywordResult: TextAnalysisResult) -> [ChipType] {
        guard configuration.enableSmartSuggestions else { return [] }
        
        // Get chip types that should be suggested
        var candidateChips = keywordResult.suggestedChips
        
        // Filter out already selected chips
        if let currentData = currentUserGoalData {
            candidateChips = candidateChips.filter { !currentData.isChipSelected($0) }
        }
        
        // Apply progressive disclosure if enabled
        if configuration.enableProgressiveDisclosure {
            candidateChips = applyProgressiveDisclosure(to: candidateChips)
        }
        
        // Limit to max suggested chips
        candidateChips = Array(candidateChips.prefix(configuration.maxSuggestedChips))
        
        return candidateChips
    }
    
    private func applyProgressiveDisclosure(to chipTypes: [ChipType]) -> [ChipType] {
        // Show high-importance chips first, gradually reveal others
        let criticalChips = chipTypes.filter { $0.importance == .critical }
        let highChips = chipTypes.filter { $0.importance == .high }
        let mediumChips = chipTypes.filter { $0.importance == .medium }
        let lowChips = chipTypes.filter { $0.importance == .low }
        
        // Determine how many to show based on current text length and existing selections
        let textLength = lastAnalysisText.count
        let selectedCount = currentUserGoalData?.selectedChips.count ?? 0
        
        var maxToShow = 1
        if textLength > 50 || selectedCount > 2 { maxToShow = 2 }
        if textLength > 100 || selectedCount > 4 { maxToShow = 3 }
        
        // Prioritize by importance
        var result: [ChipType] = []
        result.append(contentsOf: criticalChips)
        result.append(contentsOf: highChips)
        result.append(contentsOf: mediumChips)
        result.append(contentsOf: lowChips)
        
        return Array(result.prefix(maxToShow))
    }
    
    private func determineChipVisibilityChanges(from suggestedChips: [ChipType]) -> [ChipType: Bool] {
        var changes: [ChipType: Bool] = [:]
        
        // Show suggested chips
        for chipType in suggestedChips {
            if !visibleChipTypes.contains(chipType) {
                changes[chipType] = true
            }
        }
        
        // Hide chips that are no longer relevant
        let currentContextualChips = visibleChipTypes.filter { $0.category == .contextual }
        for chipType in currentContextualChips {
            if !suggestedChips.contains(chipType) {
                changes[chipType] = false
            }
        }
        
        return changes
    }
    
    private func updateVisibleChips(with changes: [ChipType: Bool]) {
        for (chipType, shouldBeVisible) in changes {
            if shouldBeVisible {
                visibleChipTypes.insert(chipType)
            } else {
                visibleChipTypes.remove(chipType)
            }
        }
    }
    
    // MARK: - Quality Assessment
    
    private func calculateQualityScore(text: String, keywordResult: TextAnalysisResult) -> Double {
        let textLength = text.count
        let wordCount = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
        
        // Base score from text length and detail
        var score = 0.0
        
        // Text length score (0.0 to 0.4)
        if textLength >= 20 { score += 0.1 }
        if textLength >= 50 { score += 0.1 }
        if textLength >= 100 { score += 0.1 }
        if textLength >= 200 { score += 0.1 }
        
        // Word diversity score (0.0 to 0.2)
        if wordCount >= 5 { score += 0.05 }
        if wordCount >= 10 { score += 0.05 }
        if wordCount >= 20 { score += 0.1 }
        
        // Keyword relevance score (0.0 to 0.4)
        score += keywordResult.confidence * 0.4
        
        return min(1.0, score)
    }
    
    private func assessTextQuality(_ text: String) -> QualityComponent {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let wordCount = trimmedText.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
        
        var score = 0.0
        var feedback: [String] = []
        
        if trimmedText.isEmpty {
            feedback.append("Please describe your fitness goal")
        } else {
            if trimmedText.count >= 20 { score += 0.25 }
            if trimmedText.count >= 50 { score += 0.25 }
            if wordCount >= 10 { score += 0.25 }
            if trimmedText.contains("week") || trimmedText.contains("month") { score += 0.25 }
            
            if score < 0.5 {
                feedback.append("Add more details about your specific goals")
            }
            if !trimmedText.lowercased().contains(where: { "0123456789".contains($0) }) {
                feedback.append("Consider adding specific targets (e.g., '5 pounds', '3 times per week')")
            }
        }
        
        return QualityComponent(score: score, feedback: feedback)
    }
    
    private func assessChipQuality(_ userGoalData: UserGoalData) -> QualityComponent {
        let selectedCount = userGoalData.selectedChips.count
        let criticalSelected = userGoalData.selectedChips.filter { $0.type.importance == .critical }.count
        let highSelected = userGoalData.selectedChips.filter { $0.type.importance == .high }.count
        
        var score = 0.0
        var feedback: [String] = []
        
        // Critical chips score
        if criticalSelected >= 1 { score += 0.4 }
        if criticalSelected >= 2 { score += 0.2 }
        
        // High importance chips score
        if highSelected >= 1 { score += 0.2 }
        if highSelected >= 2 { score += 0.1 }
        
        // Overall selection score
        if selectedCount >= 3 { score += 0.1 }
        
        // Generate feedback
        if criticalSelected == 0 {
            feedback.append("Select your fitness level and available time")
        }
        if selectedCount < 3 {
            feedback.append("Add more details using the suggestion chips")
        }
        
        return QualityComponent(score: min(1.0, score), feedback: feedback)
    }
    
    private func generateImprovementSuggestions(_ userGoalData: UserGoalData) -> [String] {
        var suggestions: [String] = []
        
        let criticalSelected = userGoalData.selectedChips.filter { $0.type.importance == .critical }
        let selectedChipTypes = Set(userGoalData.selectedChips.map { $0.type })
        
        // Check for missing critical information
        if !selectedChipTypes.contains(.fitnessLevel) {
            suggestions.append("💪 Add your fitness level for better exercise recommendations")
        }
        
        if !selectedChipTypes.contains(.timeAvailable) {
            suggestions.append("⏰ Specify how much time you have for workouts")
        }
        
        // Suggest high-value additions
        if !selectedChipTypes.contains(.workoutLocation) {
            suggestions.append("📍 Tell us where you'll be working out")
        }
        
        if !selectedChipTypes.contains(.limitations) && userGoalData.freeFormText.lowercased().contains(where: { "pain injury hurt can't".contains($0) }) {
            suggestions.append("⚠️ Add any injuries or limitations for safety")
        }
        
        // Text improvements
        if userGoalData.freeFormText.count < 50 {
            suggestions.append("📝 Add more details about your specific goals")
        }
        
        return suggestions
    }
    
    // MARK: - Analytics and Debugging
    
    func getAnalyticsData() -> AnalyticsData {
        return AnalyticsData(
            totalAnalyses: analysisCount,
            averageProcessingTime: analysisCount > 0 ? totalProcessingTime / Double(analysisCount) : 0.0,
            currentVisibleChips: Array(visibleChipTypes),
            lastAnalysisConfidence: currentAnalysis?.state.confidence ?? 0.0
        )
    }
}

// MARK: - Supporting Models

struct QualityComponent {
    let score: Double        // 0.0 to 1.0
    let feedback: [String]   // Improvement suggestions
}

struct GoalQualityAssessment {
    let overallScore: Double
    let textQuality: QualityComponent
    let chipQuality: QualityComponent
    let suggestions: [String]
    let isReadyForAI: Bool
    
    var scoreCategory: String {
        switch overallScore {
        case 0.8...1.0: return "Excellent"
        case 0.6..<0.8: return "Good"
        case 0.4..<0.6: return "Fair"
        case 0.2..<0.4: return "Needs Work"
        default: return "Just Getting Started"
        }
    }
}

struct AnalyticsData {
    let totalAnalyses: Int
    let averageProcessingTime: TimeInterval
    let currentVisibleChips: [ChipType]
    let lastAnalysisConfidence: Double
}
