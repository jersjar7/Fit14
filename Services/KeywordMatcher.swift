//
//  KeywordMatcher.swift
//  Fit14
//
//  Created by Jerson on 7/6/25.
//  Simplified for essential chips only approach
//

import Foundation

// MARK: - Analysis Result Models

/// Simplified analysis result for basic text processing
struct TextAnalysisResult: Equatable {
    let originalText: String
    let normalizedText: String
    let suggestedChips: [ChipType]
    let confidence: Double
    let processingTime: TimeInterval
    
    init(originalText: String, normalizedText: String, suggestedChips: [ChipType] = [], confidence: Double = 0.0, processingTime: TimeInterval = 0.0) {
        self.originalText = originalText
        self.normalizedText = normalizedText
        self.suggestedChips = suggestedChips
        self.confidence = confidence
        self.processingTime = processingTime
    }
}

// MARK: - Simplified Keyword Matcher Service

/// Simplified text analysis service for essential chips approach
class KeywordMatcher: ObservableObject {
    
    // MARK: - Configuration
    
    struct Configuration {
        let cacheSize: Int = 50
        let debounceInterval: TimeInterval = 0.3
    }
    
    private let configuration: Configuration
    
    // MARK: - Caching
    
    private var analysisCache: NSCache<NSString, CachedAnalysisResult> = NSCache()
    private let analysisQueue = DispatchQueue(label: "keyword.matcher.analysis", qos: .userInitiated)
    
    /// Cached analysis result with metadata
    private class CachedAnalysisResult: NSObject {
        let result: TextAnalysisResult
        let timestamp: Date
        
        init(result: TextAnalysisResult) {
            self.result = result
            self.timestamp = Date()
        }
    }
    
    // MARK: - Initialization
    
    init(configuration: Configuration = Configuration()) {
        self.configuration = configuration
        self.setupCache()
    }
    
    private func setupCache() {
        analysisCache.countLimit = configuration.cacheSize
        analysisCache.name = "KeywordMatcher.AnalysisCache"
    }
    
    // MARK: - Public API
    
    /// Simplified text analysis that focuses on essential chip smart defaults
    func analyzeText(_ text: String) async -> TextAnalysisResult {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Check cache first
        let cacheKey = NSString(string: text)
        if let cached = analysisCache.object(forKey: cacheKey) {
            // Return cached result if still fresh (within 5 minutes)
            if Date().timeIntervalSince(cached.timestamp) < 300 {
                return cached.result
            }
        }
        
        return await withCheckedContinuation { continuation in
            analysisQueue.async { [weak self] in
                guard let self = self else {
                    continuation.resume(returning: TextAnalysisResult(
                        originalText: text,
                        normalizedText: ""
                    ))
                    return
                }
                
                let normalizedText = Self.normalizeText(text)
                let suggestedChips = self.generateSmartDefaults(for: text)
                let confidence = self.calculateConfidence(for: text, suggestedChips: suggestedChips)
                let processingTime = CFAbsoluteTimeGetCurrent() - startTime
                
                let result = TextAnalysisResult(
                    originalText: text,
                    normalizedText: normalizedText,
                    suggestedChips: suggestedChips,
                    confidence: confidence,
                    processingTime: processingTime
                )
                
                // Cache the result
                let cachedResult = CachedAnalysisResult(result: result)
                self.analysisCache.setObject(cachedResult, forKey: cacheKey)
                
                continuation.resume(returning: result)
            }
        }
    }
    
    /// Check if text contains relevant information for essential chips
    func containsKeywords(for chipType: ChipType, in text: String) -> Bool {
        let smartDefaults = ChipConfiguration.getSmartDefaults(for: text)
        return smartDefaults.keys.contains(chipType)
    }
    
    /// Get relevance score for essential chip smart defaults
    func relevanceScore(for chipType: ChipType, in text: String) async -> Double {
        let smartDefaults = ChipConfiguration.getSmartDefaults(for: text)
        return smartDefaults.keys.contains(chipType) ? 0.8 : 0.0
    }
    
    /// Get suggested essential chips based on text content
    func getSuggestedChips(for text: String) async -> [ChipType] {
        let smartDefaults = ChipConfiguration.getSmartDefaults(for: text)
        return Array(smartDefaults.keys)
    }
    
    // MARK: - Smart Defaults Logic
    
    private func generateSmartDefaults(for text: String) -> [ChipType] {
        let smartDefaults = ChipConfiguration.getSmartDefaults(for: text)
        return Array(smartDefaults.keys)
    }
    
    private func calculateConfidence(for text: String, suggestedChips: [ChipType]) -> Double {
        let textLength = text.trimmingCharacters(in: .whitespacesAndNewlines).count
        let hasContent = textLength > 10
        let hasSmartSuggestions = !suggestedChips.isEmpty
        
        var confidence = 0.0
        
        if hasContent {
            confidence += 0.5
        }
        
        if hasSmartSuggestions {
            confidence += 0.3
        }
        
        // Additional confidence for specific fitness-related content
        let lowercaseText = text.lowercased()
        let fitnessKeywords = ["workout", "exercise", "fitness", "training", "gym", "strength", "cardio", "muscle"]
        let containsFitnessTerms = fitnessKeywords.contains { lowercaseText.contains($0) }
        
        if containsFitnessTerms {
            confidence += 0.2
        }
        
        return min(1.0, confidence)
    }
    
    // MARK: - Helper Methods
    
    /// Normalize text for consistent processing
    static func normalizeText(_ text: String) -> String {
        return text
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "'", with: "")  // Remove apostrophes
            .replacingOccurrences(of: "-", with: " ") // Replace hyphens with spaces
    }
    
    /// Analyze text for fitness-related content quality
    func analyzeTextQuality(_ text: String) -> (hasGoal: Bool, hasConstraints: Bool, hasSpecifics: Bool) {
        let lowercaseText = text.lowercased()
        
        // Check for goal-oriented language
        let goalKeywords = ["want", "goal", "achieve", "build", "lose", "gain", "improve", "get", "become"]
        let hasGoal = goalKeywords.contains { lowercaseText.contains($0) }
        
        // Check for constraints or limitations
        let constraintKeywords = ["injury", "pain", "can't", "cannot", "limited", "busy", "schedule", "equipment"]
        let hasConstraints = constraintKeywords.contains { lowercaseText.contains($0) }
        
        // Check for specific details (numbers, timelines, etc.)
        let hasNumbers = lowercaseText.rangeOfCharacter(from: .decimalDigits) != nil
        let timelineKeywords = ["week", "month", "day", "quickly", "soon"]
        let hasTimeline = timelineKeywords.contains { lowercaseText.contains($0) }
        let hasSpecifics = hasNumbers || hasTimeline
        
        return (hasGoal, hasConstraints, hasSpecifics)
    }
    
    // MARK: - Cache Management
    
    /// Clear analysis cache
    func clearCache() {
        analysisCache.removeAllObjects()
    }
    
    /// Get cache statistics for debugging
    func getCacheStats() -> (count: Int, size: String) {
        let count = analysisCache.totalCostLimit
        let size = ByteCountFormatter.string(fromByteCount: Int64(count * 1024), countStyle: .memory)
        return (count, size)
    }
    
    // MARK: - Legacy Compatibility
    
    /// Legacy method for backward compatibility - now uses smart defaults
    @available(*, deprecated, message: "Use ChipConfiguration.getSmartDefaults() directly")
    func getKeywordMatches(for text: String) -> [ChipType: String] {
        let smartDefaults = ChipConfiguration.getSmartDefaults(for: text)
        return smartDefaults.mapValues { $0.value }
    }
}
