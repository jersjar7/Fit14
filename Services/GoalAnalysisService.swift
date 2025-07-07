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

/// Real-time analysis update with quality assessment
struct AnalysisUpdate: Equatable {
    let text: String
    let state: AnalysisState
    let qualityScore: Double
    let processingTime: TimeInterval
    let timestamp: Date
    
    init(text: String, state: AnalysisState, qualityScore: Double = 0.0, processingTime: TimeInterval = 0.0) {
        self.text = text
        self.state = state
        self.qualityScore = qualityScore
        self.processingTime = processingTime
        self.timestamp = Date()
    }
}

/// Configuration for the analysis service
struct AnalysisConfiguration {
    let debounceInterval: TimeInterval = 0.5
    let minTextLength: Int = 3
    let enableRealTimeAnalysis: Bool = true
}

// MARK: - Goal Analysis Service

/// Service that provides real-time text analysis and goal quality assessment
@MainActor
class GoalAnalysisService: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published private(set) var currentAnalysis: AnalysisUpdate?
    @Published private(set) var analysisHistory: [AnalysisUpdate] = []
    @Published private(set) var isAnalyzing: Bool = false
    
    // MARK: - Private Properties
    
    private let configuration: AnalysisConfiguration
    private var cancellables = Set<AnyCancellable>()
    private var analysisTask: Task<Void, Never>?
    
    // Debouncing
    private let textSubject = PassthroughSubject<String, Never>()
    private var lastAnalysisText: String = ""
    
    // State tracking
    private var currentUserGoalData: UserGoalData?
    
    // Performance tracking
    private var analysisCount: Int = 0
    private var totalProcessingTime: TimeInterval = 0
    
    // MARK: - Initialization
    
    init(configuration: AnalysisConfiguration = AnalysisConfiguration()) {
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
    
    /// Analyze text input for quality assessment
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
            
            // Calculate quality score
            let qualityScore = calculateTextQualityScore(text)
            
            let processingTime = CFAbsoluteTimeGetCurrent() - startTime
            
            // Create analysis update
            let update = AnalysisUpdate(
                text: text,
                state: .completed(confidence: qualityScore),
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
        let update = AnalysisUpdate(
            text: text,
            state: .idle
        )
        
        currentAnalysis = update
        isAnalyzing = false
        lastAnalysisText = text
    }
    
    // MARK: - Quality Assessment
    
    private func calculateTextQualityScore(_ text: String) -> Double {
        let textLength = text.count
        let wordCount = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
        
        // Base score from text length and detail
        var score = 0.0
        
        // Text length score (0.0 to 0.5)
        if textLength >= 20 { score += 0.1 }
        if textLength >= 50 { score += 0.15 }
        if textLength >= 100 { score += 0.15 }
        if textLength >= 200 { score += 0.1 }
        
        // Word diversity score (0.0 to 0.3)
        if wordCount >= 5 { score += 0.1 }
        if wordCount >= 10 { score += 0.1 }
        if wordCount >= 20 { score += 0.1 }
        
        // Content quality indicators (0.0 to 0.2)
        let lowercaseText = text.lowercased()
        if lowercaseText.contains(where: { "0123456789".contains($0) }) { score += 0.05 } // Contains numbers
        if lowercaseText.contains("week") || lowercaseText.contains("month") || lowercaseText.contains("day") { score += 0.05 } // Timeline mentions
        if lowercaseText.contains("pound") || lowercaseText.contains("lb") || lowercaseText.contains("kg") || lowercaseText.contains("minutes") { score += 0.05 } // Specific targets
        if lowercaseText.contains("home") || lowercaseText.contains("gym") || lowercaseText.contains("park") { score += 0.05 } // Location context
        
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
                feedback.append("Consider adding specific targets (e.g., '5 pounds', 'beat my 25-minute 5K time')")
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
        
        // Critical chips score (most important)
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
            feedback.append("Fill in more essential information chips")
        }
        
        return QualityComponent(score: min(1.0, score), feedback: feedback)
    }
    
    private func generateImprovementSuggestions(_ userGoalData: UserGoalData) -> [String] {
        var suggestions: [String] = []
        
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
        
        if !selectedChipTypes.contains(.physicalStats) {
            suggestions.append("📏 Add your height and weight for personalized recommendations")
        }
        
        // Text improvements
        if userGoalData.freeFormText.count < 50 {
            suggestions.append("📝 Add more details about your specific goals and any constraints")
        }
        
        if !userGoalData.freeFormText.lowercased().contains(where: { "0123456789".contains($0) }) {
            suggestions.append("🎯 Include specific targets or numbers in your goal description")
        }
        
        return suggestions
    }
    
    // MARK: - Analytics and Debugging
    
    func getAnalyticsData() -> AnalyticsData {
        return AnalyticsData(
            totalAnalyses: analysisCount,
            averageProcessingTime: analysisCount > 0 ? totalProcessingTime / Double(analysisCount) : 0.0,
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
    let lastAnalysisConfidence: Double
}
