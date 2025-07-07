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
        return selectedOption.displayText
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

/// Manages the state and logic for the 6 essential information chips required for workout planning
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
    
    /// Total number of essential chips (always 6)
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
            // Incomplete chips go to top for better UX
            if first.isCompleted != second.isCompleted {
                return !first.isCompleted
            }
            // Sort by chip type importance (critical first)
            return first.type.importance.rawValue > second.type.importance.rawValue
        }
    }
    
    /// Get only critical essential chips that need immediate attention
    var criticalChips: [EssentialChip] {
        chips.filter { $0.type.importance == .critical && !$0.isCompleted }
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
        
        print("✅ Completed essential chip: \(type.displayTitle) -> \(selectedOption.displayText)")
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
        
        print("🔄 Reset essential chip: \(type.displayTitle)")
    }
    
    /// Insert prompt text for a chip into the goal text
    func insertPromptForChip(type: ChipType) {
        guard let chip = getChip(for: type), !chip.isCompleted else { return }
        
        // Add the placeholder token to the goal text (this will trigger inline options in the UI)
        let insertion = chip.promptTemplate
        
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
        
        print("➕ Inserted placeholder for essential chip: \(type.displayTitle)")
    }
    
    /// Get available options for inline selection
    func getInlineOptions(for type: ChipType) -> [ChipSelectionOption] {
        return getChip(for: type)?.options ?? []
    }
    
    /// Update goal text externally (from text field changes)
    func updateGoalText(_ newText: String) {
        goalText = newText
    }
    
    /// Reset all essential chips and clear goal text
    func reset() {
        for index in chips.indices {
            chips[index].isCompleted = false
            chips[index].selectedOption = nil
        }
        goalText = ""
        print("🔄 Reset all essential chips")
    }
    
    /// Check if minimum essential information is provided for AI generation
    var hasMinimumInformation: Bool {
        // At least one critical chip must be completed
        let criticalCompleted = chips.filter { $0.type.importance == .critical && $0.isCompleted }.count
        return criticalCompleted >= 1 && !goalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Check if optimal information is provided for best AI results
    var hasOptimalInformation: Bool {
        let criticalCompleted = chips.filter { $0.type.importance == .critical && $0.isCompleted }.count
        let highCompleted = chips.filter { $0.type.importance == .high && $0.isCompleted }.count
        return criticalCompleted >= 2 && highCompleted >= 1
    }
    
    // MARK: - Private Methods
    
    /// Set up the 6 essential chips with their options
    private func setupEssentialChips() {
        chips = [
            // Fitness Level (Critical)
            EssentialChip(
                type: .fitnessLevel,
                title: "Fitness Level",
                icon: "figure.strengthtraining.traditional",
                promptTemplate: "{{FITNESS_LEVEL_PLACEHOLDER}}",
                options: [
                    ChipSelectionOption(value: "beginner", displayText: "My fitness level is beginner", description: "New to fitness or returning after a long break"),
                    ChipSelectionOption(value: "intermediate", displayText: "My fitness level is intermediate", description: "Exercise regularly, comfortable with basic movements"),
                    ChipSelectionOption(value: "advanced", displayText: "My fitness level is advanced", description: "Very experienced, ready for challenging workouts")
                ]
            ),
            
            // Sex (High Importance)
            EssentialChip(
                type: .sex,
                title: "Sex",
                icon: "person.2",
                promptTemplate: "{{SEX_PLACEHOLDER}}",
                options: [
                    ChipSelectionOption(value: "male", displayText: "I am a male"),
                    ChipSelectionOption(value: "female", displayText: "I am a female"),
                    ChipSelectionOption(value: "prefer not to say", displayText: "I am a person who prefers not to specify")
                ]
            ),
            
            // Physical Stats (Medium Importance)
            EssentialChip(
                type: .physicalStats,
                title: "Height & Weight",
                icon: "ruler.fill",
                promptTemplate: "{{PHYSICAL_STATS_PLACEHOLDER}}",
                options: [
                    ChipSelectionOption(value: "5'0\", 120 lbs", displayText: "My height and weight are 5'0\", 120 lbs"),
                    ChipSelectionOption(value: "5'3\", 130 lbs", displayText: "My height and weight are 5'3\", 130 lbs"),
                    ChipSelectionOption(value: "5'6\", 140 lbs", displayText: "My height and weight are 5'6\", 140 lbs"),
                    ChipSelectionOption(value: "5'9\", 160 lbs", displayText: "My height and weight are 5'9\", 160 lbs"),
                    ChipSelectionOption(value: "6'0\", 180 lbs", displayText: "My height and weight are 6'0\", 180 lbs"),
                    ChipSelectionOption(value: "custom", displayText: "My height and weight are ", description: "Tap to enter custom height and weight")
                ]
            ),
            
            // Time Available (Critical)
            EssentialChip(
                type: .timeAvailable,
                title: "Time Per Workout",
                icon: "clock",
                promptTemplate: "{{TIME_AVAILABLE_PLACEHOLDER}}",
                options: [
                    ChipSelectionOption(value: "15-30 minutes", displayText: "I can work out for 15-30 minutes", description: "Quick, efficient workouts"),
                    ChipSelectionOption(value: "30-45 minutes", displayText: "I can work out for 30-45 minutes", description: "Standard workout duration"),
                    ChipSelectionOption(value: "45-60 minutes", displayText: "I can work out for 45-60 minutes", description: "Longer, comprehensive sessions"),
                    ChipSelectionOption(value: "60+ minutes", displayText: "I can work out for 60+ minutes", description: "Extended training sessions")
                ]
            ),
            
            // Workout Location (High Importance)
            EssentialChip(
                type: .workoutLocation,
                title: "Workout Location",
                icon: "location",
                promptTemplate: "{{WORKOUT_LOCATION_PLACEHOLDER}}",
                options: [
                    ChipSelectionOption(value: "at home", displayText: "I will be working out at home", description: "Bodyweight and minimal equipment exercises"),
                    ChipSelectionOption(value: "at the gym", displayText: "I will be working out at the gym", description: "Full equipment access"),
                    ChipSelectionOption(value: "outdoors", displayText: "I will be working out outdoors", description: "Running, hiking, outdoor activities"),
                    ChipSelectionOption(value: "at home and gym", displayText: "I will be working out at home and the gym", description: "Flexible between locations")
                ]
            ),
            
            // Weekly Frequency (Medium Importance)
            EssentialChip(
                type: .weeklyFrequency,
                title: "Days Per Week",
                icon: "calendar",
                promptTemplate: "{{WEEKLY_FREQUENCY_PLACEHOLDER}}",
                options: [
                    ChipSelectionOption(value: "3 days per week", displayText: "I can exercise 3 days per week", description: "Balanced approach with recovery time"),
                    ChipSelectionOption(value: "4-5 days per week", displayText: "I can exercise 4-5 days per week", description: "Regular, consistent training"),
                    ChipSelectionOption(value: "6+ days per week", displayText: "I can exercise 6+ days per week", description: "High-frequency training"),
                    ChipSelectionOption(value: "daily except Sunday", displayText: "I can exercise daily except Sunday", description: "6 days per week with Sunday rest")
                ]
            )
        ]
        
        print("🎯 Initialized \(chips.count) essential information chips")
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
        let lowercaseText = goalText.lowercased()
        
        for index in chips.indices {
            let chip = chips[index]
            
            var isNowCompleted = false
            var matchingOption: ChipSelectionOption?
            
            // Use custom detection logic based on chip type
            switch chip.type {
            case .fitnessLevel:
                // Only check for actual completed text, not placeholder
                if lowercaseText.contains("fitness level") && !lowercaseText.contains("{{fitness_level_placeholder}}") {
                    print("🔍 Detected fitness level pattern")
                    // Look for specific levels in text
                    if lowercaseText.contains("beginner") {
                        matchingOption = chip.options.first { $0.value.contains("beginner") }
                    } else if lowercaseText.contains("intermediate") {
                        matchingOption = chip.options.first { $0.value.contains("intermediate") }
                    } else if lowercaseText.contains("advanced") {
                        matchingOption = chip.options.first { $0.value.contains("advanced") }
                    } else {
                        matchingOption = chip.options.first
                    }
                    isNowCompleted = true
                    print("🔍 Fitness level completed: \(matchingOption?.displayText ?? "none")")
                }
                
            case .sex:
                if (lowercaseText.contains("male") || lowercaseText.contains("female")) && !lowercaseText.contains("{{sex_placeholder}}") {
                    print("🔍 Detected sex pattern")
                    if lowercaseText.contains("female") {
                        matchingOption = chip.options.first { $0.value.contains("female") }
                    } else if lowercaseText.contains("male") && !lowercaseText.contains("female") {
                        matchingOption = chip.options.first { $0.value.contains("male") }
                    } else {
                        matchingOption = chip.options.first
                    }
                    isNowCompleted = true
                    print("🔍 Sex completed: \(matchingOption?.displayText ?? "none")")
                }
                
            case .physicalStats:
                if lowercaseText.contains("height and weight") && !lowercaseText.contains("{{physical_stats_placeholder}}") {
                    print("🔍 Detected physical stats pattern")
                    matchingOption = chip.options.first
                    isNowCompleted = true
                    print("🔍 Physical stats completed: \(matchingOption?.displayText ?? "none")")
                }
                
            case .timeAvailable:
                if lowercaseText.contains("work out for") && !lowercaseText.contains("{{time_available_placeholder}}") {
                    print("🔍 Detected time available pattern")
                    // Look for time indicators
                    if lowercaseText.contains("15-30") || (lowercaseText.contains("15") && lowercaseText.contains("30")) {
                        matchingOption = chip.options.first { $0.value.contains("15-30") }
                    } else if lowercaseText.contains("30-45") || (lowercaseText.contains("30") && lowercaseText.contains("45")) {
                        matchingOption = chip.options.first { $0.value.contains("30-45") }
                    } else if lowercaseText.contains("45-60") || (lowercaseText.contains("45") && lowercaseText.contains("60")) {
                        matchingOption = chip.options.first { $0.value.contains("45-60") }
                    } else if lowercaseText.contains("60+") || lowercaseText.contains("hour") {
                        matchingOption = chip.options.first { $0.value.contains("60+") }
                    } else {
                        matchingOption = chip.options.first
                    }
                    isNowCompleted = true
                    print("🔍 Time available completed: \(matchingOption?.displayText ?? "none")")
                }
                
            case .workoutLocation:
                if lowercaseText.contains("be working out") && !lowercaseText.contains("{{workout_location_placeholder}}") {
                    print("🔍 Detected workout location pattern")
                    if lowercaseText.contains("home") {
                        matchingOption = chip.options.first { $0.value.contains("home") }
                    } else if lowercaseText.contains("gym") {
                        matchingOption = chip.options.first { $0.value.contains("gym") }
                    } else if lowercaseText.contains("outdoor") {
                        matchingOption = chip.options.first { $0.value.contains("outdoor") }
                    } else {
                        matchingOption = chip.options.first
                    }
                    isNowCompleted = true
                    print("🔍 Workout location completed: \(matchingOption?.displayText ?? "none")")
                }
                
            case .weeklyFrequency:
                if lowercaseText.contains("can exercise") && !lowercaseText.contains("{{weekly_frequency_placeholder}}") {
                    print("🔍 Detected weekly frequency pattern")
                    if lowercaseText.contains("3 days") || lowercaseText.contains("three days") {
                        matchingOption = chip.options.first { $0.value.contains("3 days") }
                    } else if lowercaseText.contains("4-5") || lowercaseText.contains("4") || lowercaseText.contains("5") {
                        matchingOption = chip.options.first { $0.value.contains("4-5") }
                    } else if lowercaseText.contains("daily except sunday") || lowercaseText.contains("6") {
                        matchingOption = chip.options.first { $0.value.contains("daily except Sunday") }
                    } else if lowercaseText.contains("6+") || lowercaseText.contains("daily") {
                        matchingOption = chip.options.first { $0.value.contains("6+") }
                    } else {
                        matchingOption = chip.options.first
                    }
                    isNowCompleted = true
                    print("🔍 Weekly frequency completed: \(matchingOption?.displayText ?? "none")")
                }
            }
            
            // Always update state
            chips[index].isCompleted = isNowCompleted
            chips[index].selectedOption = matchingOption
            
            if isNowCompleted {
                print("✅ Chip \(chip.title) marked as completed")
            }
        }
        
        print("📊 Total completed: \(completedCount)/\(totalCount)")
    }
    
    // MARK: - Debug Helpers
    
    /// Get debug information about current state
    func getDebugInfo() -> String {
        return """
        Essential Chip Assistant Debug:
        - Total essential chips: \(totalCount)
        - Completed: \(completedCount)
        - Completion: \(Int(completionPercentage * 100))%
        - Has minimum info: \(hasMinimumInformation)
        - Has optimal info: \(hasOptimalInformation)
        - Goal text length: \(goalText.count)
        
        Essential Chip States:
        \(chips.map { "- \($0.title) (\($0.type.importance.displayName)): \($0.isCompleted ? "✅" : "❌") \($0.selectedOption?.displayText ?? "none")" }.joined(separator: "\n"))
        """
    }
    
    // MARK: - Detection Helper Methods

    private func findMatchingFitnessLevelOption() -> ChipSelectionOption? {
        let text = goalText.lowercased()
        let chip = chips.first { $0.type == .fitnessLevel }
        
        if text.contains("beginner") || text.contains("new to") {
            return chip?.options.first { $0.value == "beginner" }
        } else if text.contains("intermediate") {
            return chip?.options.first { $0.value == "intermediate" }
        } else if text.contains("advanced") || text.contains("experienced") {
            return chip?.options.first { $0.value == "advanced" }
        }
        
        // Default to first option if pattern is detected but specific level isn't clear
        return chip?.options.first
    }

    private func findMatchingSexOption() -> ChipSelectionOption? {
        let text = goalText.lowercased()
        let chip = chips.first { $0.type == .sex }
        
        if text.contains("male") && !text.contains("female") {
            return chip?.options.first { $0.value == "male" }
        } else if text.contains("female") {
            return chip?.options.first { $0.value == "female" }
        }
        
        return chip?.options.first
    }

    private func findMatchingPhysicalStatsOption() -> ChipSelectionOption? {
        let chip = chips.first { $0.type == .physicalStats }
        // Since this is usually custom input, return the custom option
        return chip?.options.first { $0.value == "custom" }
    }

    private func findMatchingTimeOption() -> ChipSelectionOption? {
        let text = goalText.lowercased()
        let chip = chips.first { $0.type == .timeAvailable }
        
        if text.contains("15") || text.contains("30") {
            if text.contains("30") && (text.contains("45") || text.contains("40")) {
                return chip?.options.first { $0.value == "30-45 minutes" }
            } else {
                return chip?.options.first { $0.value == "15-30 minutes" }
            }
        } else if text.contains("45") || text.contains("60") {
            if text.contains("45") && text.contains("60") {
                return chip?.options.first { $0.value == "45-60 minutes" }
            } else {
                return chip?.options.first { $0.value == "30-45 minutes" }
            }
        } else if text.contains("hour") || text.contains("60+") {
            return chip?.options.first { $0.value == "60+ minutes" }
        }
        
        return chip?.options.first
    }

    private func findMatchingLocationOption() -> ChipSelectionOption? {
        let text = goalText.lowercased()
        let chip = chips.first { $0.type == .workoutLocation }
        
        if text.contains("home") {
            return chip?.options.first { $0.value == "at home" }
        } else if text.contains("gym") {
            return chip?.options.first { $0.value == "at the gym" }
        } else if text.contains("outdoor") || text.contains("outside") {
            return chip?.options.first { $0.value == "outdoors" }
        }
        
        return chip?.options.first
    }

    private func findMatchingFrequencyOption() -> ChipSelectionOption? {
        let text = goalText.lowercased()
        let chip = chips.first { $0.type == .weeklyFrequency }
        
        if text.contains("3 days") || text.contains("three days") {
            return chip?.options.first { $0.value == "3 days per week" }
        } else if text.contains("4") || text.contains("5") || text.contains("four") || text.contains("five") {
            return chip?.options.first { $0.value == "4-5 days per week" }
        } else if text.contains("6") || text.contains("daily except sunday") || text.contains("six") {
            return chip?.options.first { $0.value == "daily except Sunday" }
        } else if text.contains("daily") || text.contains("every day") {
            return chip?.options.first { $0.value == "6+ days per week" }
        }
        
        return chip?.options.first
    }
}
