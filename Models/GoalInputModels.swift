//
//  GoalInputModels.swift
//  Fit14
//
//  Created by Jerson on 7/6/25.
//

import Foundation

// MARK: - Chip Option Models

/// Represents a selectable option within a chip
struct ChipOption: Identifiable, Codable, Equatable {
    let id = UUID()
    let value: String           // Internal value
    let displayText: String     // User-facing text
    let description: String?    // Optional detailed description
    let isCustom: Bool         // Whether this allows custom input
    
    init(value: String, displayText: String, description: String? = nil, isCustom: Bool = false) {
        self.value = value
        self.displayText = displayText
        self.description = description
        self.isCustom = isCustom
    }
    
    /// Quick initializer for simple options
    init(_ value: String) {
        self.value = value
        self.displayText = value
        self.description = nil
        self.isCustom = false
    }
    
    /// Custom input option
    static let customInput = ChipOption(value: "custom", displayText: "Other...", isCustom: true)
}

// MARK: - Chip Selection Model

/// Represents a user's selection for a specific chip
struct ChipSelection: Identifiable, Codable, Equatable {
    let id = UUID()
    let chipType: ChipType
    let selectedOption: ChipOption?
    let customValue: String?       // For custom input
    let timestamp: Date
    
    init(chipType: ChipType, selectedOption: ChipOption? = nil, customValue: String? = nil) {
        self.chipType = chipType
        self.selectedOption = selectedOption
        self.customValue = customValue
        self.timestamp = Date()
    }
    
    /// The final value to use (either option value or custom value)
    var effectiveValue: String? {
        if let custom = customValue, !custom.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return custom
        }
        return selectedOption?.value
    }
    
    /// The display text for the selection
    var displayText: String? {
        if let custom = customValue, !custom.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return custom
        }
        return selectedOption?.displayText
    }
    
    /// Whether this selection has a valid value
    var isValid: Bool {
        return effectiveValue != nil
    }
    
    /// Convert selection to natural language for AI prompt
    var naturalLanguagePhrase: String? {
        guard let value = effectiveValue else { return nil }
        
        switch chipType {
        case .fitnessLevel:
            return "I'm a \(value)"
        case .sex:
            return "I'm \(value)"
        case .physicalStats:
            return "My physical stats: \(value)"
        case .timeAvailable:
            return "I can work out for \(value) per session"
        case .workoutLocation:
            return "I'll be working out \(value)"
        case .weeklyFrequency:
            return "I can work out \(value) per week"
        case .timeline:
            return "My timeline: \(value)"
        case .limitations:
            return "Limitations: \(value)"
        case .schedule:
            return "Schedule: \(value)"
        case .equipment:
            return "Equipment available: \(value)"
        case .experience:
            return "My experience: \(value)"
        case .preferences:
            return "My preferences: \(value)"
        }
    }
}

// MARK: - Chip Data Model

/// Represents a chip in the UI with its current state and available options
struct ChipData: Identifiable, Codable, Equatable {
    let id = UUID()
    let type: ChipType
    let options: [ChipOption]
    var selection: ChipSelection?
    var isVisible: Bool = false        // For contextual chips
    var isHighlighted: Bool = false    // Visual emphasis
    
    init(type: ChipType, options: [ChipOption], selection: ChipSelection? = nil) {
        self.type = type
        self.options = options
        self.selection = selection
        // Universal chips are always visible
        self.isVisible = type.category == .universal
    }
    
    /// Convenience computed properties
    var title: String { type.displayTitle }
    var icon: String { type.systemIcon }
    var category: ChipCategory { type.category }
    var isRequired: Bool { type.isRequired }
    var isSelected: Bool { selection?.isValid == true }
    
    /// Selected display text
    var selectedText: String? {
        return selection?.displayText
    }
    
    /// Create a selection for this chip
    mutating func select(option: ChipOption, customValue: String? = nil) {
        self.selection = ChipSelection(chipType: type, selectedOption: option, customValue: customValue)
    }
    
    /// Clear the selection
    mutating func clearSelection() {
        self.selection = nil
    }
    
    /// Show this chip (for contextual chips)
    mutating func show() {
        self.isVisible = true
    }
    
    /// Hide this chip (for contextual chips)
    mutating func hide() {
        self.isVisible = false
    }
}

// MARK: - User Goal Data Model

/// Complete user goal data combining free-form text and structured chip selections
struct UserGoalData: Codable, Equatable {
    var freeFormText: String = ""
    var chips: [ChipType: ChipData] = [:]
    let createdAt: Date
    var lastModified: Date
    
    init() {
        let now = Date()
        self.createdAt = now
        self.lastModified = now
    }
    
    // MARK: - Chip Management
    
    /// Add or update a chip
    mutating func updateChip(_ chipData: ChipData) {
        chips[chipData.type] = chipData
        lastModified = Date()
    }
    
    /// Get chip data for a specific type
    func getChip(_ type: ChipType) -> ChipData? {
        return chips[type]
    }
    
    /// Check if a chip is selected
    func isChipSelected(_ type: ChipType) -> Bool {
        return chips[type]?.isSelected == true
    }
    
    /// Get all selected chips
    var selectedChips: [ChipData] {
        return chips.values.filter { $0.isSelected }
    }
    
    /// Get all visible chips
    var visibleChips: [ChipData] {
        return chips.values.filter { $0.isVisible }
    }
    
    // MARK: - Data Quality
    
    /// Calculate completeness score (0.0 to 1.0)
    var completenessScore: Double {
        let totalUniversalChips = ChipType.allCases.filter { $0.category == .universal }.count
        let selectedUniversalChips = chips.values.filter { $0.category == .universal && $0.isSelected }.count
        
        let textScore = freeFormText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.0 : 0.3
        let chipScore = totalUniversalChips > 0 ? Double(selectedUniversalChips) / Double(totalUniversalChips) * 0.7 : 0.0
        
        return min(1.0, textScore + chipScore)
    }
    
    /// Whether the data is sufficient for AI generation
    var isSufficientForAI: Bool {
        let hasText = !freeFormText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasMinimumChips = selectedChips.count >= 2
        return hasText && hasMinimumChips
    }
    
    /// Get validation issues
    var validationIssues: [String] {
        var issues: [String] = []
        
        if freeFormText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            issues.append("Please describe your fitness goal")
        }
        
        let requiredChips = chips.values.filter { $0.isRequired && !$0.isSelected }
        for chip in requiredChips {
            issues.append("Please select your \(chip.title.lowercased())")
        }
        
        return issues
    }
    
    // MARK: - Natural Language Conversion
    
    /// Convert all chip selections to natural language
    var chipSelectionsAsText: String {
        let phrases = selectedChips.compactMap { $0.selection?.naturalLanguagePhrase }
        return phrases.joined(separator: ". ")
    }
    
    /// Combined text for AI prompt (structured + free-form)
    var completeGoalText: String {
        let chipText = chipSelectionsAsText
        let userText = freeFormText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if chipText.isEmpty {
            return userText
        } else if userText.isEmpty {
            return chipText
        } else {
            return "\(chipText). \(userText)"
        }
    }
    
    /// Get structured data for enhanced AI prompts
    var structuredData: [String: String] {
        var data: [String: String] = [:]
        
        for chip in selectedChips {
            if let value = chip.selection?.effectiveValue {
                data[chip.type.rawValue] = value
            }
        }
        
        data["free_form_goal"] = freeFormText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return data
    }
    
    // MARK: - Text Analysis Helpers
    
    /// Update the free-form text and trigger analysis
    mutating func updateFreeFormText(_ text: String) {
        freeFormText = text
        lastModified = Date()
    }
    
    /// Check if text contains any of the keywords for a chip type
    func textContainsKeywords(for chipType: ChipType) -> Bool {
        return chipType.shouldSuggest(for: freeFormText)
    }
    
    /// Get all chip types that should be suggested based on current text
    var suggestedChipTypes: [ChipType] {
        return ChipType.contextualTypes.filter { chipType in
            !isChipSelected(chipType) && chipType.shouldSuggest(for: freeFormText)
        }
    }
    
    /// Get chip types sorted by relevance to current text
    var suggestedChipTypesByRelevance: [ChipType] {
        return ChipType.contextualTypes
            .filter { !isChipSelected($0) }
            .sortedByRelevance(for: freeFormText)
            .filter { $0.relevanceScore(for: freeFormText) > 0.0 }
    }
}

// MARK: - Extensions for Convenience

extension Array where Element == ChipData {
    /// Sort chips by category, importance, and selection status for optimal display
    var sortedForDisplay: [ChipData] {
        return self.sorted { first, second in
            // Universal chips first
            if first.category != second.category {
                return first.category == .universal
            }
            
            // Within same category, sort by importance
            if first.type.importance.rawValue != second.type.importance.rawValue {
                return first.type.importance.rawValue > second.type.importance.rawValue
            }
            
            // Selected chips before unselected
            if first.isSelected != second.isSelected {
                return first.isSelected
            }
            
            // Finally by display title for consistency
            return first.type.displayTitle < second.type.displayTitle
        }
    }
    
    /// Filter to only visible chips
    var visibleChips: [ChipData] {
        return self.filter { $0.isVisible }
    }
    
    /// Filter to only selected chips
    var selectedChips: [ChipData] {
        return self.filter { $0.isSelected }
    }
    
    /// Filter by category
    func chips(in category: ChipCategory) -> [ChipData] {
        return self.filter { $0.category == category }
    }
    
    /// Filter by importance level
    func chips(withImportance importance: ChipImportance) -> [ChipData] {
        return self.filter { $0.type.importance == importance }
    }
}
