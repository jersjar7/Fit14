//
//  EssentialChipAssistant.swift
//  Fit14
//
//  Created by Jerson on 7/6/25.
//  Updated with enhanced chip system and completion tracking
//

import SwiftUI
import Combine

// MARK: - Essential Chip Model

struct EssentialChip: Identifiable {
    let id = UUID()
    let type: ChipType
    let title: String
    let icon: String
    var isCompleted: Bool
    var selectedOption: ChipOption?
    
    init(id: UUID = UUID(), type: ChipType, title: String, icon: String, isCompleted: Bool = false, selectedOption: ChipOption? = nil) {
        self.type = type
        self.title = title
        self.icon = icon
        self.isCompleted = isCompleted
        self.selectedOption = selectedOption
    }
}

// MARK: - Essential Chip Assistant

class EssentialChipAssistant: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var goalText: String = ""
    @Published private var chips: [ChipType: EssentialChip] = [:]
    
    // MARK: - Computed Properties
    
    var sortedChips: [EssentialChip] {
        let allChips = Array(chips.values)
        return allChips.sorted { first, second in
            // Sort by importance first (critical chips first)
            if first.type.importance.rawValue != second.type.importance.rawValue {
                return first.type.importance.rawValue > second.type.importance.rawValue
            }
            
            // Uncompleted chips before completed for better UX
            if first.isCompleted != second.isCompleted {
                return !first.isCompleted
            }
            
            // Finally by display title for consistency
            return first.title < second.title
        }
    }
    
    var completedCount: Int {
        chips.values.filter { $0.isCompleted }.count
    }
    
    var totalCount: Int {
        chips.count
    }
    
    var completionPercentage: Double {
        guard totalCount > 0 else { return 0.0 }
        return Double(completedCount) / Double(totalCount)
    }
    
    var allEssentialChips: [EssentialChip] {
        Array(chips.values)
    }
    
    var uncompletedChips: [EssentialChip] {
        chips.values.filter { !$0.isCompleted }
    }
    
    var completedChips: [EssentialChip] {
        chips.values.filter { $0.isCompleted }
    }
    
    // MARK: - Initialization
    
    init() {
        setupEssentialChips()
    }
    
    // MARK: - Setup Methods
    
    private func setupEssentialChips() {
        // Define the essential chips needed for workout plan generation
        let essentialChipTypes: [ChipType] = [
            .fitnessLevel,
            .timeAvailable,
            .workoutLocation,
            .physicalStats,
            .sex,
            .weeklyFrequency
        ]
        
        for chipType in essentialChipTypes {
            let chipConfig = getChipConfiguration(for: chipType)
            chips[chipType] = EssentialChip(
                type: chipType,
                title: chipConfig.title,
                icon: chipConfig.icon,
                isCompleted: false,
                selectedOption: nil
            )
        }
    }
    
    private func getChipConfiguration(for type: ChipType) -> (title: String, icon: String) {
        switch type {
        case .fitnessLevel:
            return ("Fitness Level", "figure.run")
        case .timeAvailable:
            return ("Time Available", "clock")
        case .workoutLocation:
            return ("Location", "location")
        case .physicalStats:
            return ("Height & Weight", "ruler.fill")
        case .sex:
            return ("Sex", "person.2")
        case .weeklyFrequency:
            return ("Days Per Week", "calendar")
        }
    }
    
    // MARK: - Text Management
    
    func updateGoalText(_ newText: String) {
        goalText = newText
        analyzeTextForChipCompletion(newText)
    }
    
    private func analyzeTextForChipCompletion(_ text: String) {
        let lowercaseText = text.lowercased()
        
        // Analyze text to auto-complete chips where possible
        for (chipType, chip) in chips {
            if !chip.isCompleted {
                if let autoCompletedOption = getAutoCompletedOption(for: chipType, from: lowercaseText) {
                    markChipAsCompleted(type: chipType, with: autoCompletedOption)
                }
            }
        }
    }
    
    private func getAutoCompletedOption(for chipType: ChipType, from text: String) -> ChipOption? {
        // Auto-detection logic for different chip types
        switch chipType {
        case .fitnessLevel:
            if text.contains("beginner") || text.contains("new to") || text.contains("just starting") {
                return ChipOption(value: "beginner", displayText: "Beginner")
            } else if text.contains("intermediate") || text.contains("some experience") {
                return ChipOption(value: "intermediate", displayText: "Intermediate")
            } else if text.contains("advanced") || text.contains("experienced") || text.contains("athlete") {
                return ChipOption(value: "advanced", displayText: "Advanced")
            }
            
        case .timeAvailable:
            if text.contains("15 min") || text.contains("15 minutes") || text.contains("quarter hour") {
                return ChipOption(value: "15-30 minutes", displayText: "15-30 minutes")
            } else if text.contains("30 min") || text.contains("30 minutes") || text.contains("half hour") {
                return ChipOption(value: "30-45 minutes", displayText: "30-45 minutes")
            } else if text.contains("45 min") || text.contains("45 minutes") {
                return ChipOption(value: "45-60 minutes", displayText: "45-60 minutes")
            } else if text.contains("1 hour") || text.contains("60 min") || text.contains("60 minutes") {
                return ChipOption(value: "60+ minutes", displayText: "60+ minutes")
            }
            
        case .workoutLocation:
            if text.contains("home") || text.contains("at home") || text.contains("my house") {
                return ChipOption(value: "at home", displayText: "At Home")
            } else if text.contains("gym") || text.contains("fitness center") || text.contains("health club") {
                return ChipOption(value: "at the gym", displayText: "At the Gym")
            } else if text.contains("outdoor") || text.contains("outside") || text.contains("park") {
                return ChipOption(value: "outdoors", displayText: "Outdoors")
            }
            
        case .sex:
            if text.contains("male") && !text.contains("female") {
                return ChipOption(value: "male", displayText: "Male")
            } else if text.contains("female") {
                return ChipOption(value: "female", displayText: "Female")
            }
            
        case .weeklyFrequency:
            if text.contains("3 days") || text.contains("three days") {
                return ChipOption(value: "3 days", displayText: "3 days per week")
            } else if text.contains("4") || text.contains("5") {
                return ChipOption(value: "4-5 days", displayText: "4-5 days per week")
            } else if text.contains("daily") || text.contains("every day") {
                return ChipOption(value: "6+ days", displayText: "6+ days per week")
            }
            
        default:
            break
        }
        
        return nil
    }
    
    // MARK: - Chip Management
    
    func markChipAsCompleted(type: ChipType, with option: ChipOption) {
        chips[type]?.isCompleted = true
        chips[type]?.selectedOption = option
    }
    
    func resetChip(type: ChipType) {
        chips[type]?.isCompleted = false
        chips[type]?.selectedOption = nil
        
        // Remove chip-related text from goal text if needed
        removeChipTextFromGoal(for: type)
    }
    
    private func removeChipTextFromGoal(for chipType: ChipType) {
        // Logic to remove chip-specific text from goal
        // This is a simplified version - you might want more sophisticated text manipulation
        guard let chip = chips[chipType],
              let selectedOption = chip.selectedOption else { return }
        
        let chipText = "\(chip.title): \(selectedOption.displayText)"
        goalText = goalText.replacingOccurrences(of: chipText, with: "")
        goalText = goalText.replacingOccurrences(of: ", , ", with: ", ")
        goalText = goalText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if goalText.hasPrefix(", ") {
            goalText = String(goalText.dropFirst(2))
        }
        if goalText.hasSuffix(", ") {
            goalText = String(goalText.dropLast(2))
        }
    }
    
    func insertPromptForChip(type: ChipType) {
        guard let chip = chips[type] else { return }
        
        // Insert a prompt to encourage the user to specify this chip type
        let prompt = getPromptText(for: type)
        let currentText = goalText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !currentText.isEmpty && !currentText.hasSuffix(".") && !currentText.hasSuffix("?") && !currentText.hasSuffix("!") {
            goalText = currentText + ". " + prompt
        } else if currentText.isEmpty {
            goalText = prompt
        } else {
            goalText = currentText + " " + prompt
        }
    }
    
    private func getPromptText(for chipType: ChipType) -> String {
        switch chipType {
        case .fitnessLevel:
            return "Please specify your current fitness level (beginner, intermediate, or advanced)."
        case .timeAvailable:
            return "How much time can you dedicate to each workout?"
        case .workoutLocation:
            return "Where will you be working out (home, gym, outdoor)?"
        case .physicalStats:
            return "What are your height and weight?"
        case .sex:
            return "Please specify your sex for exercise planning."
        case .weeklyFrequency:
            return "How many days per week can you work out?"
        }
    }
    
    // MARK: - Chip Queries
    
    func getChip(for type: ChipType) -> EssentialChip? {
        return chips[type]
    }
    
    func isChipCompleted(_ type: ChipType) -> Bool {
        return chips[type]?.isCompleted ?? false
    }
    
    func getSelectedOption(for type: ChipType) -> ChipOption? {
        return chips[type]?.selectedOption
    }
    
    // MARK: - Reset and Validation
    
    func reset() {
        goalText = ""
        for chipType in chips.keys {
            chips[chipType]?.isCompleted = false
            chips[chipType]?.selectedOption = nil
        }
    }
    
    func validateCompleteness() -> (isComplete: Bool, missingChips: [EssentialChip]) {
        let uncompletedCriticalChips = chips.values.filter {
            !$0.isCompleted && $0.type.importance == .critical
        }
        
        return (
            isComplete: uncompletedCriticalChips.isEmpty,
            missingChips: uncompletedCriticalChips
        )
    }
    
    // MARK: - Text Analysis Support
    
    func getGoalAnalysisInfo(hasExplicitStartDate: Bool = false) -> [String] {
        var info: [String] = []
        
        // Add completion status
        if completedCount > 0 {
            info.append("\(completedCount) of \(totalCount) essential details provided")
        }
        
        // Add specific completed items
        for chip in completedChips {
            if let option = chip.selectedOption {
                info.append("\(chip.title): \(option.displayText)")
            }
        }
        
        // Add text analysis
        let lowercaseText = goalText.lowercased()
        
        if lowercaseText.contains("injury") || lowercaseText.contains("pain") || lowercaseText.contains("hurt") {
            info.append("Physical limitations mentioned")
        }
        
        if lowercaseText.contains("equipment") || lowercaseText.contains("weights") || lowercaseText.contains("bands") {
            info.append("Equipment preferences specified")
        }
        
        if lowercaseText.contains("schedule") || lowercaseText.contains("busy") || lowercaseText.contains("time") {
            info.append("Schedule constraints noted")
        }
        
        if lowercaseText.contains("experience") || lowercaseText.contains("beginner") || lowercaseText.contains("athlete") {
            info.append("Experience level indicated")
        }
        
        if lowercaseText.contains("week") || lowercaseText.contains("month") || lowercaseText.contains("day") {
            info.append("Timeline specified")
        }
        
        if hasExplicitStartDate {
            info.append("Start date explicitly selected")
        }
        
        return info
    }
}
