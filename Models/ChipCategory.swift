//
//  ChipCategory.swift
//  Fit14
//
//  Created by Jerson on 7/6/25.
//

import Foundation

// MARK: - Chip Category Classification

/// Defines the behavioral category of chips in the goal input system
enum ChipCategory: String, Codable, CaseIterable {
    case universal = "universal"     // Always visible - essential information
    
    var displayName: String {
        switch self {
        case .universal:
            return "Essential Info"
        }
    }
    
    var description: String {
        switch self {
        case .universal:
            return "Basic information needed for any workout plan"
        }
    }
    
    var priority: Int {
        switch self {
        case .universal:
            return 100  // High priority - always shown first
        }
    }
}

// MARK: - Specific Chip Types

/// All available chip types in the Fit14 goal input system
enum ChipType: String, Codable, CaseIterable {
    // MARK: Essential Information Chips
    case fitnessLevel = "fitness_level"
    case sex = "sex"
    case physicalStats = "physical_stats"      // Weight & Height combined
    case timeAvailable = "time_available"
    case workoutLocation = "workout_location"
    case weeklyFrequency = "weekly_frequency"
    
    // MARK: - Category Assignment
    var category: ChipCategory {
        // All remaining chips are universal/essential
        return .universal
    }
    
    // MARK: - Display Properties
    var displayTitle: String {
        switch self {
        case .fitnessLevel:
            return "Fitness Level"
        case .sex:
            return "Sex"
        case .physicalStats:
            return "Height & Weight"
        case .timeAvailable:
            return "Time Per Workout"
        case .workoutLocation:
            return "Where You'll Work Out"
        case .weeklyFrequency:
            return "Days Per Week"
        }
    }
    
    var shortTitle: String {
        switch self {
        case .fitnessLevel:
            return "Level"
        case .sex:
            return "Sex"
        case .physicalStats:
            return "Stats"
        case .timeAvailable:
            return "Time"
        case .workoutLocation:
            return "Location"
        case .weeklyFrequency:
            return "Frequency"
        }
    }
    
    var systemIcon: String {
        switch self {
        case .fitnessLevel:
            return "figure.strengthtraining.traditional"
        case .sex:
            return "person.2"
        case .physicalStats:
            return "ruler.fill"
        case .timeAvailable:
            return "clock"
        case .workoutLocation:
            return "location"
        case .weeklyFrequency:
            return "calendar"
        }
    }
    
    // MARK: - Importance and Requirements
    var importance: ChipImportance {
        switch self {
        case .fitnessLevel:
            return .critical     // Essential for AI to generate appropriate difficulty
        case .timeAvailable:
            return .critical     // Essential for workout duration planning
        case .sex:
            return .high         // Important for calorie calculations and some exercises
        case .workoutLocation:
            return .high         // Important for equipment-based planning
        case .physicalStats:
            return .medium       // Helpful but not always necessary
        case .weeklyFrequency:
            return .medium       // Helpful for rest day planning
        }
    }
    
    var isRequired: Bool {
        return importance == .critical
    }
    
    // MARK: - AI Prompt Context
    var promptContext: String {
        switch self {
        case .fitnessLevel:
            return "fitness experience level"
        case .sex:
            return "biological sex for exercise planning"
        case .physicalStats:
            return "height and weight for personalization"
        case .timeAvailable:
            return "available workout duration"
        case .workoutLocation:
            return "workout environment and space"
        case .weeklyFrequency:
            return "preferred workout frequency"
        }
    }
}

// MARK: - Chip Importance Levels

/// Defines the importance level of different chip types for AI generation quality
enum ChipImportance: Int, Codable, CaseIterable {
    case critical = 100    // Must have for good AI results
    case high = 75         // Very helpful for AI quality
    case medium = 50       // Helpful but not essential
    case low = 25          // Nice to have
    
    var displayName: String {
        switch self {
        case .critical:
            return "Essential"
        case .high:
            return "Important"
        case .medium:
            return "Helpful"
        case .low:
            return "Optional"
        }
    }
    
    var description: String {
        switch self {
        case .critical:
            return "Required for optimal workout plan generation"
        case .high:
            return "Significantly improves plan quality and safety"
        case .medium:
            return "Helps personalize the workout plan"
        case .low:
            return "Provides additional customization options"
        }
    }
}

// MARK: - Chip Type Collections and Utilities

extension ChipType {
    /// All essential chip types (always shown)
    static var essentialTypes: [ChipType] {
        return allCases // All remaining chips are essential
    }
    
    /// Critical chips that should be prioritized in UI
    static var criticalTypes: [ChipType] {
        return allCases.filter { $0.importance == .critical }
    }
    
    /// High importance chips
    static var highImportanceTypes: [ChipType] {
        return allCases.filter { $0.importance == .high }
    }
    
    /// Get chips sorted by importance (critical first)
    static var sortedByImportance: [ChipType] {
        return allCases.sorted { first, second in
            if first.importance.rawValue != second.importance.rawValue {
                return first.importance.rawValue > second.importance.rawValue
            }
            // Finally sort by display title
            return first.displayTitle < second.displayTitle
        }
    }
}

// MARK: - Category Extensions

extension ChipCategory {
    /// Get all chip types for this category
    var chipTypes: [ChipType] {
        return ChipType.allCases.filter { $0.category == self }
    }
    
    /// Get chip types sorted by importance
    var chipTypesByImportance: [ChipType] {
        return chipTypes.sorted { $0.importance.rawValue > $1.importance.rawValue }
    }
}
