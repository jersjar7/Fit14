//
//  KeywordMatcher.swift
//  Fit14
//
//  Created by Jerson on 7/6/25.
//

import Foundation

// MARK: - Match Result Models

/// Represents a keyword match with confidence and context
struct KeywordMatch: Identifiable, Equatable {
    let id = UUID()
    let keyword: String
    let chipType: ChipType
    let matchType: MatchType
    let confidence: Double      // 0.0 to 1.0
    let range: Range<String.Index>?
    let context: String        // Surrounding text for context
    
    enum MatchType: Codable, CaseIterable {
        case exact          // Perfect match
        case contains       // Keyword found within word
        case wordBoundary   // Keyword as complete word
        case fuzzy          // Close match with typos
        case semantic       // Related meaning
        
        var baseConfidence: Double {
            switch self {
            case .exact:
                return 1.0
            case .wordBoundary:
                return 0.95
            case .contains:
                return 0.8
            case .fuzzy:
                return 0.7
            case .semantic:
                return 0.6
            }
        }
    }
}

/// Analysis result for a text input
struct TextAnalysisResult: Equatable {
    let originalText: String
    let normalizedText: String
    let matches: [KeywordMatch]
    let suggestedChips: [ChipType]
    let confidence: Double
    let processingTime: TimeInterval
    
    /// Get matches grouped by chip type
    var matchesByChipType: [ChipType: [KeywordMatch]] {
        return Dictionary(grouping: matches, by: { $0.chipType })
    }
    
    /// Get the highest confidence match for each chip type
    var bestMatchesByChipType: [ChipType: KeywordMatch] {
        var bestMatches: [ChipType: KeywordMatch] = [:]
        
        for (chipType, chipMatches) in matchesByChipType {
            if let bestMatch = chipMatches.max(by: { $0.confidence < $1.confidence }) {
                bestMatches[chipType] = bestMatch
            }
        }
        
        return bestMatches
    }
}

// MARK: - Keyword Matcher Service

/// High-performance keyword detection and text analysis service
class KeywordMatcher: ObservableObject {
    
    // MARK: - Configuration
    
    struct Configuration {
        let minKeywordLength: Int = 2
        let maxFuzzyDistance: Int = 2
        let enableFuzzyMatching: Bool = true
        let enableSemanticMatching: Bool = false  // Future feature
        let cacheSize: Int = 100
        let debounceInterval: TimeInterval = 0.3
        
        /// Minimum confidence threshold for matches
        let minConfidenceThreshold: Double = 0.5
        
        /// Word boundary characters for accurate matching
        let wordBoundaryCharacters: CharacterSet = .alphanumerics.inverted
    }
    
    private let configuration: Configuration
    
    // MARK: - Caching and Performance
    
    private var analysisCache: NSCache<NSString, CachedAnalysisResult> = NSCache()
    private var keywordCache: [ChipType: [ProcessedKeyword]] = [:]
    private let cacheQueue = DispatchQueue(label: "keyword.matcher.cache", qos: .utility)
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
    
    /// Preprocessed keyword for efficient matching
    private struct ProcessedKeyword {
        let original: String
        let normalized: String
        let words: [String]
        let chipType: ChipType
        let importance: Double  // Based on chip importance and keyword specificity
        
        init(keyword: String, chipType: ChipType) {
            self.original = keyword
            self.normalized = KeywordMatcher.normalizeText(keyword)
            self.words = self.normalized.components(separatedBy: .whitespacesAndNewlines.union(.punctuationCharacters))
                .filter { !$0.isEmpty }
            self.chipType = chipType
            
            // Calculate importance based on chip importance and keyword length/specificity
            let chipImportance = Double(chipType.importance.rawValue) / 100.0
            let keywordSpecificity = min(1.0, Double(keyword.count) / 15.0) // Longer keywords are more specific
            self.importance = (chipImportance + keywordSpecificity) / 2.0
        }
    }
    
    // MARK: - Initialization
    
    init(configuration: Configuration = Configuration()) {
        self.configuration = configuration
        self.setupCache()
        self.preprocessKeywords()
    }
    
    private func setupCache() {
        analysisCache.countLimit = configuration.cacheSize
        analysisCache.name = "KeywordMatcher.AnalysisCache"
    }
    
    /// Preprocess all keywords for efficient matching
    private func preprocessKeywords() {
        cacheQueue.async { [weak self] in
            guard let self = self else { return }
            
            var processedKeywords: [ChipType: [ProcessedKeyword]] = [:]
            
            for chipType in ChipType.allCases {
                let keywords = chipType.triggerKeywords.map {
                    ProcessedKeyword(keyword: $0, chipType: chipType)
                }
                processedKeywords[chipType] = keywords
            }
            
            DispatchQueue.main.async {
                self.keywordCache = processedKeywords
            }
        }
    }
    
    // MARK: - Public API
    
    /// Analyze text for keyword matches with full result details
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
                        normalizedText: "",
                        matches: [],
                        suggestedChips: [],
                        confidence: 0.0,
                        processingTime: 0.0
                    ))
                    return
                }
                
                let normalizedText = Self.normalizeText(text)
                let matches = self.performKeywordMatching(text: text, normalizedText: normalizedText)
                let suggestedChips = self.generateSuggestions(from: matches)
                let confidence = self.calculateOverallConfidence(matches: matches)
                let processingTime = CFAbsoluteTimeGetCurrent() - startTime
                
                let result = TextAnalysisResult(
                    originalText: text,
                    normalizedText: normalizedText,
                    matches: matches,
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
    
    /// Quick boolean check if text contains keywords for a specific chip type
    func containsKeywords(for chipType: ChipType, in text: String) -> Bool {
        guard let keywords = keywordCache[chipType] else { return false }
        
        let normalizedText = Self.normalizeText(text)
        
        return keywords.contains { keyword in
            performQuickMatch(keyword: keyword, in: normalizedText)
        }
    }
    
    /// Get relevance score for a specific chip type (0.0 to 1.0)
    func relevanceScore(for chipType: ChipType, in text: String) async -> Double {
        let analysis = await analyzeText(text)
        let matches = analysis.matches.filter { $0.chipType == chipType }
        
        guard !matches.isEmpty else { return 0.0 }
        
        // Calculate score based on best match confidence and chip importance
        let bestConfidence = matches.map { $0.confidence }.max() ?? 0.0
        let importanceMultiplier = Double(chipType.importance.rawValue) / 100.0
        
        return min(1.0, bestConfidence * importanceMultiplier)
    }
    
    /// Get suggested chip types sorted by relevance
    func getSuggestedChips(for text: String) async -> [ChipType] {
        let analysis = await analyzeText(text)
        return analysis.suggestedChips
    }
    
    // MARK: - Core Matching Logic
    
    private func performKeywordMatching(text: String, normalizedText: String) -> [KeywordMatch] {
        var allMatches: [KeywordMatch] = []
        
        for (chipType, keywords) in keywordCache {
            let chipMatches = findMatches(for: keywords, in: text, normalizedText: normalizedText)
            allMatches.append(contentsOf: chipMatches)
        }
        
        // Sort by confidence (highest first) and remove duplicates
        return allMatches
            .filter { $0.confidence >= configuration.minConfidenceThreshold }
            .sorted { $0.confidence > $1.confidence }
    }
    
    private func findMatches(for keywords: [ProcessedKeyword], in originalText: String, normalizedText: String) -> [KeywordMatch] {
        var matches: [KeywordMatch] = []
        
        for keyword in keywords {
            // Try different matching strategies
            if let match = findExactMatch(keyword: keyword, in: originalText, normalizedText: normalizedText) {
                matches.append(match)
            } else if let match = findWordBoundaryMatch(keyword: keyword, in: originalText, normalizedText: normalizedText) {
                matches.append(match)
            } else if let match = findContainsMatch(keyword: keyword, in: originalText, normalizedText: normalizedText) {
                matches.append(match)
            } else if configuration.enableFuzzyMatching,
                      let match = findFuzzyMatch(keyword: keyword, in: originalText, normalizedText: normalizedText) {
                matches.append(match)
            }
        }
        
        return matches
    }
    
    private func findExactMatch(keyword: ProcessedKeyword, in originalText: String, normalizedText: String) -> KeywordMatch? {
        guard normalizedText == keyword.normalized else { return nil }
        
        return KeywordMatch(
            keyword: keyword.original,
            chipType: keyword.chipType,
            matchType: .exact,
            confidence: KeywordMatch.MatchType.exact.baseConfidence * keyword.importance,
            range: originalText.startIndex..<originalText.endIndex,
            context: originalText
        )
    }
    
    private func findWordBoundaryMatch(keyword: ProcessedKeyword, in originalText: String, normalizedText: String) -> KeywordMatch? {
        let pattern = "\\b\(NSRegularExpression.escapedPattern(for: keyword.normalized))\\b"
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: normalizedText, range: NSRange(normalizedText.startIndex..., in: normalizedText)) else {
            return nil
        }
        
        let range = Range(match.range, in: normalizedText)
        let context = extractContext(from: originalText, around: range)
        
        return KeywordMatch(
            keyword: keyword.original,
            chipType: keyword.chipType,
            matchType: .wordBoundary,
            confidence: KeywordMatch.MatchType.wordBoundary.baseConfidence * keyword.importance,
            range: range,
            context: context
        )
    }
    
    private func findContainsMatch(keyword: ProcessedKeyword, in originalText: String, normalizedText: String) -> KeywordMatch? {
        guard let range = normalizedText.range(of: keyword.normalized, options: .caseInsensitive) else {
            return nil
        }
        
        let context = extractContext(from: originalText, around: range)
        
        return KeywordMatch(
            keyword: keyword.original,
            chipType: keyword.chipType,
            matchType: .contains,
            confidence: KeywordMatch.MatchType.contains.baseConfidence * keyword.importance,
            range: range,
            context: context
        )
    }
    
    private func findFuzzyMatch(keyword: ProcessedKeyword, in originalText: String, normalizedText: String) -> KeywordMatch? {
        // Simple fuzzy matching using Levenshtein distance
        let words = normalizedText.components(separatedBy: .whitespacesAndNewlines.union(.punctuationCharacters))
            .filter { !$0.isEmpty }
        
        for word in words {
            let distance = levenshteinDistance(keyword.normalized, word)
            if distance <= configuration.maxFuzzyDistance && distance < keyword.normalized.count / 2 {
                let confidence = KeywordMatch.MatchType.fuzzy.baseConfidence * keyword.importance * (1.0 - Double(distance) / Double(keyword.normalized.count))
                
                if let range = normalizedText.range(of: word, options: .caseInsensitive) {
                    return KeywordMatch(
                        keyword: keyword.original,
                        chipType: keyword.chipType,
                        matchType: .fuzzy,
                        confidence: confidence,
                        range: range,
                        context: extractContext(from: originalText, around: range)
                    )
                }
            }
        }
        
        return nil
    }
    
    private func performQuickMatch(keyword: ProcessedKeyword, in normalizedText: String) -> Bool {
        // Fast path for boolean checks
        return normalizedText.contains(keyword.normalized)
    }
    
    // MARK: - Helper Methods
    
    /// Normalize text for consistent matching
    static func normalizeText(_ text: String) -> String {
        return text
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "'", with: "")  // Remove apostrophes
            .replacingOccurrences(of: "-", with: " ") // Replace hyphens with spaces
    }
    
    /// Extract context around a match for better relevance
    private func extractContext(from text: String, around range: Range<String.Index>?) -> String {
        guard let range = range else { return text }
        
        let contextLength = 30
        let startIndex = text.index(range.lowerBound, offsetBy: -contextLength, limitedBy: text.startIndex) ?? text.startIndex
        let endIndex = text.index(range.upperBound, offsetBy: contextLength, limitedBy: text.endIndex) ?? text.endIndex
        
        return String(text[startIndex..<endIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Calculate Levenshtein distance between two strings
    private func levenshteinDistance(_ string1: String, _ string2: String) -> Int {
        let len1 = string1.count
        let len2 = string2.count
        
        if len1 == 0 { return len2 }
        if len2 == 0 { return len1 }
        
        var matrix = Array(repeating: Array(repeating: 0, count: len2 + 1), count: len1 + 1)
        
        for i in 0...len1 { matrix[i][0] = i }
        for j in 0...len2 { matrix[0][j] = j }
        
        let chars1 = Array(string1)
        let chars2 = Array(string2)
        
        for i in 1...len1 {
            for j in 1...len2 {
                let cost = chars1[i-1] == chars2[j-1] ? 0 : 1
                matrix[i][j] = min(
                    matrix[i-1][j] + 1,      // deletion
                    matrix[i][j-1] + 1,      // insertion
                    matrix[i-1][j-1] + cost  // substitution
                )
            }
        }
        
        return matrix[len1][len2]
    }
    
    /// Generate chip suggestions from matches
    private func generateSuggestions(from matches: [KeywordMatch]) -> [ChipType] {
        let matchesByChip = Dictionary(grouping: matches, by: { $0.chipType })
        
        return matchesByChip
            .map { (chipType, chipMatches) in
                let totalConfidence = chipMatches.reduce(0) { $0 + $1.confidence }
                return (chipType, totalConfidence)
            }
            .sorted { $0.1 > $1.1 }  // Sort by total confidence
            .map { $0.0 }            // Extract chip types
    }
    
    /// Calculate overall confidence score for the analysis
    private func calculateOverallConfidence(matches: [KeywordMatch]) -> Double {
        guard !matches.isEmpty else { return 0.0 }
        
        let totalConfidence = matches.reduce(0) { $0 + $1.confidence }
        let averageConfidence = totalConfidence / Double(matches.count)
        
        // Boost confidence if multiple different chip types are matched
        let uniqueChipTypes = Set(matches.map { $0.chipType }).count
        let diversityBonus = min(0.2, Double(uniqueChipTypes) * 0.05)
        
        return min(1.0, averageConfidence + diversityBonus)
    }
    
    // MARK: - Cache Management
    
    /// Clear analysis cache (useful for memory management)
    func clearCache() {
        analysisCache.removeAllObjects()
    }
    
    /// Get cache statistics for debugging
    func getCacheStats() -> (count: Int, size: String) {
        let count = analysisCache.totalCostLimit
        let size = ByteCountFormatter.string(fromByteCount: Int64(count * 1024), countStyle: .memory)
        return (count, size)
    }
}
