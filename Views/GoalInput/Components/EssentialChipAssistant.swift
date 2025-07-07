//
//  EssentialChipAssistant.swift
//  Fit14
//
//  Created by Jerson on 7/7/25.
//  Manages essential chip state and text generation for goal input assistance
//

import Foundation
import SwiftUI

// MARK: - Essential Chip Definition

/// Represents an essential information chip with its prompt template and options
struct EssentialChip: Identifiable, Equatable {
    let id = UUID()
    let type: ChipType
    let title: String
    let icon: String
    let promptTemplate: String  // e.g., "My fitness level is "
    let options: [ChipSelectionOption]
    var isCompleted: Bool = false
    var selectedOption: ChipSelectionOption?
    
    /// The text that gets inserted when user taps the "+" button
    var insertionText: String {
        return promptTemplate
    }
    
    /// The final completed text after user makes a selection
    var completedText: String? {
        guard let selectedOption = selectedOption else { return nil }
        return promptTemplate + selectedOption.displayText
    }
}

// MARK: - Chip Selection Option

/// Represents a selectable option for an essential chip
struct ChipSelectionOption: Identifiable, Equatable {
    let id = UUID()
    let value: String           // Internal value
    let displayText: String     // Text shown to user and inserted
    let description: String?    // Optional tooltip/help text
    
    init(value: String, displayText: String, description: String? = nil) {
        self.value = value
        self.displayText = displayText
        self.description = description
    }
    
    /// Convenience initializer for simple options
    init(_ displayText: String) {
        self.value = displayText.lowercased()
        self.displayText = displayText
        self.description = nil
    }
}

// MARK: - Essential Chip Assistant

/// Manages the state and logic for essential information chips in goal input
class EssentialChipAssistant: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published private(set) var chips: [EssentialChip] = []
    @Published var goalText: String = "" {
        didSet {
            updateCompletionStates()
        }
    }
    
    // MARK: - Computed Properties
    
    /// Number of completed essential chips
    var completedCount: Int {
        chips.filter { $0.isCompleted }.count
    }
    
    /// Total number of essential chips
    var totalCount: Int {
        chips.count
    }
    
    /// Completion percentage (0.0 to 1.0)
    var completionPercentage: Double {
        guard totalCount > 0 else { return 0.0 }
        return Double(completedCount) / Double(totalCount)
    }
    
    /// Whether all essential chips are completed
    var allCompleted: Bool {
        completedCount == totalCount
    }
    
    /// Get chips sorted by importance and completion status
    var sortedChips: [EssentialChip] {
        chips.sorted { first, second in
            // Completed chips go to bottom
            if first.isCompleted != second.isCompleted {
                return !first.isCompleted
            }
            // Sort by chip type importance
            return first.type.importance.rawValue > second.type.importance.rawValue
        }
    }
    
    // MARK: - Initialization
    
    init() {
        setupEssentialChips()
    }
    
    // MARK: - Public Methods
    
    /// Get a specific chip by type
    func getChip(for type: ChipType) -> EssentialChip? {
        return chips.first { $0.type == type }
    }
    
    /// Mark a chip as completed with the selected option
    func completeChip(type: ChipType, selectedOption: ChipSelectionOption) {
        guard let index = chips.firstIndex(where: { $0.type == type }) else { return }
        
        chips[index].selectedOption = selectedOption
        chips[index].isCompleted = true
        
        // Update the goal text with the completed phrase
        updateGoalTextWithCompletion(for: chips[index])
        
        print("✅ Completed chip: \(type.displayTitle) -> \(selectedOption.displayText)")
    }
    
    /// Reset a chip to uncompleted state
    func resetChip(type: ChipType) {
        guard let index = chips.firstIndex(where: { $0.type == type }) else { return }
        
        // Remove the completed text from goal text if present
        if let completedText = chips[index].completedText {
            goalText = goalText.replacingOccurrences(of: completedText, with: "")
                .replacingOccurrences(of: "  ", with: " ") // Clean up double spaces
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        chips[index].selectedOption = nil
        chips[index].isCompleted = false
        
        print("🔄 Reset chip: \(type.displayTitle)")
    }
    
    /// Insert prompt text for a chip into the goal text
    func insertPromptForChip(type: ChipType) {
        guard let chip = getChip(for: type), !chip.isCompleted else { return }
        
        // Add the prompt template to the goal text
        let insertion = chip.insertionText
        
        // Smart insertion - add proper spacing and punctuation
        if goalText.isEmpty {
            goalText = insertion
        } else {
            // Ensure proper sentence structure
            let trimmed = goalText.trimmingCharacters(in: .whitespacesAndNewlines)
            let needsPeriod = !trimmed.isEmpty && !trimmed.hasSuffix(".") && !trimmed.hasSuffix("!")
            let separator = needsPeriod ? ". " : " "
            goalText = trimmed + separator + insertion
        }
        
        print("➕ Inserted prompt for: \(type.displayTitle)")
    }
    
    /// Get available options for inline selection
    func getInlineOptions(for type: ChipType) -> [ChipSelectionOption] {
        return getChip(for: type)?.options ?? []
    }
    
    /// Update goal text externally (from text field changes)
    func updateGoalText(_ newText: String) {
        goalText = newText
    }
    
    /// Reset all chips and clear goal text
    func reset() {
        for index in chips.indices {
            chips[index].isCompleted = false
            chips[index].selectedOption = nil
        }
        goalText = ""
        print("🔄 Reset all essential chips")
    }
    
    // MARK: - Private Methods
    
    /// Set up the essential chips with their options
    private func setupEssentialChips() {
        chips = [
            // Fitness Level (Critical)
            EssentialChip(
                type: .fitnessLevel,
                title: "Fitness Level",
                icon: "figure.strengthtraining.traditional",
                promptTemplate: "My fitness level is ",
                options: [
                    ChipSelectionOption("beginner", displayText: "beginner", description: "New to fitness or returning after a long break"),
                    ChipSelectionOption("intermediate", displayText: "intermediate", description: "Exercise regularly, comfortable with basic movements"),
                    ChipSelectionOption("advanced", displayText: "advanced", description: "Very experienced, ready for challenging workouts")
                ]
            ),
            
            // Sex (High Importance)
            EssentialChip(
                type: .sex,
                title: "Sex",
                icon: "person.2",
                promptTemplate: "I am ",
                options: [
                    ChipSelectionOption("male", displayText: "male"),
                    ChipSelectionOption("female", displayText: "female"),
                    ChipSelectionOption("prefer not to say", displayText: "prefer not to specify")
                ]
            ),
            
            // Physical Stats (Medium Importance)
            EssentialChip(
                type: .physicalStats,
                title: "Height & Weight",
                icon: "ruler.fill",
                promptTemplate: "I am ",
                options: [
                    ChipSelectionOption("5'0\", 120 lbs", displayText: "5'0\", 120 lbs"),
                    ChipSelectionOption("5'3\", 130 lbs", displayText: "5'3\", 130 lbs"),
                    ChipSelectionOption("5'6\", 140 lbs", displayText: "5'6\", 140 lbs"),
                    ChipSelectionOption("5'9\", 160 lbs", displayText: "5'9\", 160 lbs"),
                    ChipSelectionOption("6'0\", 180 lbs", displayText: "6'0\", 180 lbs"),
                    ChipSelectionOption("custom", displayText: "enter my measurements", description: "Tap to enter custom height and weight")
                ]
            ),
            
            // Time Available (Critical)
            EssentialChip(
                type: .timeAvailable,
                title: "Time Per Workout",
                icon: "clock",
                promptTemplate: "I can work out for ",
                options: [
                    ChipSelectionOption("15-30 minutes", displayText: "15-30 minutes", description: "Quick, efficient workouts"),
                    ChipSelectionOption("30-45 minutes", displayText: "30-45 minutes", description: "Standard workout duration"),
                    ChipSelectionOption("45-60 minutes", displayText: "45-60 minutes", description: "Longer, comprehensive sessions"),
                    ChipSelectionOption("60+ minutes", displayText: "60+ minutes", description: "Extended training sessions")
                ]
            ),
            
            // Workout Location (High Importance)
            EssentialChip(
                type: .workoutLocation,
                title: "Workout Location",
                icon: "location",
                promptTemplate: "I will be working out ",
                options: [
                    ChipSelectionOption("at home", displayText: "at home", description: "Bodyweight and minimal equipment exercises"),
                    ChipSelectionOption("at the gym", displayText: "at the gym", description: "Full equipment access"),
                    ChipSelectionOption("outdoors", displayText: "outdoors", description: "Running, hiking, outdoor activities"),
                    ChipSelectionOption("at home and gym", displayText: "at home and the gym", description: "Flexible between locations")
                ]
            ),
            
            // Weekly Frequency (Medium Importance)
            EssentialChip(
                type: .weeklyFrequency,
                title: "Days Per Week",
                icon: "calendar",
                promptTemplate: "I can work out ",
                options: [
                    ChipSelectionOption("3 days per week", displayText: "3 days per week", description: "Balanced approach with recovery time"),
                    ChipSelectionOption("4-5 days per week", displayText: "4-5 days per week", description: "Regular, consistent training"),
                    ChipSelectionOption("6+ days per week", displayText: "6+ days per week", description: "High-frequency training"),
                    ChipSelectionOption("on a flexible schedule", displayText: "on a flexible schedule", description: "Adapt based on availability")
                ]
            )
        ]
        
        print("🎯 Initialized \(chips.count) essential chips")
    }
    
    /// Update the goal text with a completed chip phrase
    private func updateGoalTextWithCompletion(for chip: EssentialChip) {
        guard let completedText = chip.completedText else { return }
        
        // Replace the prompt template with the completed text
        goalText = goalText.replacingOccurrences(of: chip.promptTemplate, with: completedText)
        
        // Clean up any formatting issues
        goalText = goalText
            .replacingOccurrences(of: "  ", with: " ") // Remove double spaces
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Ensure proper sentence ending
        if !goalText.hasSuffix(".") && !goalText.hasSuffix("!") && !goalText.hasSuffix("?") {
            goalText += "."
        }
    }
    
    /// Update completion states based on current goal text content
    private func updateCompletionStates() {
        for index in chips.indices {
            let chip = chips[index]
            
            // Check if any of this chip's completed text appears in the goal text
            let wasCompleted = chip.isCompleted
            var isNowCompleted = false
            var matchingOption: ChipSelectionOption?
            
            for option in chip.options {
                let completedPhrase = chip.promptTemplate + option.displayText
                if goalText.contains(completedPhrase) {
                    isNowCompleted = true
                    matchingOption = option
                    break
                }
            }
            
            // Update state if changed
            if wasCompleted != isNowCompleted {
                chips[index].isCompleted = isNowCompleted
                chips[index].selectedOption = matchingOption
            }
        }
    }
    
    // MARK: - Debug Helpers
    
    /// Get debug information about current state
    func getDebugInfo() -> String {
        return """
        Essential Chip Assistant Debug:
        - Total chips: \(totalCount)
        - Completed: \(completedCount)
        - Completion: \(Int(completionPercentage * 100))%
        - Goal text length: \(goalText.count)
        
        Chip States:
        \(chips.map { "- \($0.title): \($0.isCompleted ? "✅" : "❌") \($0.selectedOption?.displayText ?? "none")" }.joined(separator: "\n"))
        """
    }
}
