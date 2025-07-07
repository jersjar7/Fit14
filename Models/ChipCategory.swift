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
    case contextual = "contextual"   // Appear based on text analysis - smart suggestions
    
    var displayName: String {
        switch self {
        case .universal:
            return "Essential Info"
        case .contextual:
            return "Smart Suggestions"
        }
    }
    
    var description: String {
        switch self {
        case .universal:
            return "Basic information needed for any workout plan"
        case .contextual:
            return "Additional details suggested based on your goals"
        }
    }
    
    var priority: Int {
        switch self {
        case .universal:
            return 100  // High priority - always shown first
        case .contextual:
            return 50   // Lower priority - shown after universal
        }
    }
}

// MARK: - Specific Chip Types

/// All available chip types in the Fit14 goal input system
enum ChipType: String, Codable, CaseIterable {
    // MARK: Universal Chips (Essential Information)
    case fitnessLevel = "fitness_level"
    case sex = "sex"
    case physicalStats = "physical_stats"      // Weight & Height combined
    case timeAvailable = "time_available"
    case workoutLocation = "workout_location"
    case weeklyFrequency = "weekly_frequency"
    
    // MARK: Contextual Chips (Smart Suggestions)
    case timeline = "timeline"
    case limitations = "limitations"
    case schedule = "schedule"
    case equipment = "equipment"
    case experience = "experience"             // Previous workout experience
    case preferences = "preferences"           // Exercise preferences/dislikes
    
    // MARK: - Category Assignment
    var category: ChipCategory {
        switch self {
        case .fitnessLevel, .sex, .physicalStats, .timeAvailable, .workoutLocation, .weeklyFrequency:
            return .universal
        case .timeline, .limitations, .schedule, .equipment, .experience, .preferences:
            return .contextual
        }
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
        case .timeline:
            return "Your Timeline"
        case .limitations:
            return "Injuries/Limitations"
        case .schedule:
            return "Schedule Restrictions"
        case .equipment:
            return "Available Equipment"
        case .experience:
            return "Past Experience"
        case .preferences:
            return "Exercise Preferences"
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
        case .timeline:
            return "Timeline"
        case .limitations:
            return "Limitations"
        case .schedule:
            return "Schedule"
        case .equipment:
            return "Equipment"
        case .experience:
            return "Experience"
        case .preferences:
            return "Preferences"
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
        case .timeline:
            return "target"
        case .limitations:
            return "cross.case"
        case .schedule:
            return "calendar.badge.clock"
        case .equipment:
            return "dumbbell"
        case .experience:
            return "star.fill"
        case .preferences:
            return "heart"
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
        case .timeline:
            return .medium       // Helps with goal-specific planning
        case .limitations:
            return .high         // Very important for safety
        case .schedule:
            return .low          // Nice to have for optimization
        case .equipment:
            return .medium       // Important if mentioned in goals
        case .experience:
            return .low          // Supplementary information
        case .preferences:
            return .low          // Helps with exercise selection
        }
    }
    
    var isRequired: Bool {
        return importance == .critical
    }
    
    // MARK: - Smart Suggestion Keywords
    /// Keywords that trigger this contextual chip to appear
    var triggerKeywords: [String] {
        switch self {
        case .timeline:
            return [
                "2 weeks", "2-weeks", "two weeks",
                "month", "months", "3 months", "6 months",
                "quickly", "fast", "asap", "soon",
                "deadline", "by", "before",
                "timeline", "time frame", "timeframe",
                "goal date", "target date",
                "urgent", "rush"
            ]
        case .limitations:
            return [
                "injury", "injured", "hurt", "pain",
                "back pain", "knee", "shoulder", "ankle", "wrist",
                "can't", "cannot", "unable", "avoid",
                "limitation", "limited", "restrict", "restricted",
                "medical", "doctor", "physician",
                "physical therapy", "pt", "rehab",
                "arthritis", "surgery", "recovery"
            ]
        case .schedule:
            return [
                "busy", "schedule", "time", "available",
                "work", "job", "office", "shift",
                "weekends", "weekdays", "week days",
                "sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday",
                "morning", "afternoon", "evening", "night",
                "free time", "spare time",
                "travel", "vacation", "trip"
            ]
        case .equipment:
            return [
                "no gym", "home", "house", "apartment",
                "weights", "dumbbells", "barbells",
                "equipment", "gear", "machines",
                "kettlebell", "resistance bands", "bands",
                "treadmill", "bike", "bicycle",
                "pull up bar", "yoga mat",
                "bodyweight", "no equipment"
            ]
        case .experience:
            return [
                "used to", "before", "previously", "past",
                "experience", "experienced", "trained",
                "athlete", "athletic", "sports",
                "beginner", "new to", "never", "first time",
                "years ago", "months ago",
                "college", "high school", "university",
                "competitive", "team", "coach"
            ]
        case .preferences:
            return [
                "hate", "love", "enjoy", "like",
                "dislike", "don't like", "prefer",
                "favorite", "favourite", "best",
                "boring", "fun", "exciting", "challenging",
                "cardio", "strength", "yoga", "pilates",
                "running", "swimming", "cycling",
                "outdoor", "indoor"
            ]
        default:
            return []  // Universal chips don't have trigger keywords
        }
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
        case .timeline:
            return "goal achievement timeline"
        case .limitations:
            return "physical limitations or injuries"
        case .schedule:
            return "time constraints and availability"
        case .equipment:
            return "available exercise equipment"
        case .experience:
            return "previous fitness experience"
        case .preferences:
            return "exercise preferences and dislikes"
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
    /// All universal chip types (always shown)
    static var universalTypes: [ChipType] {
        return allCases.filter { $0.category == .universal }
    }
    
    /// All contextual chip types (keyword-triggered)
    static var contextualTypes: [ChipType] {
        return allCases.filter { $0.category == .contextual }
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
            // If same importance, sort universal before contextual
            if first.category != second.category {
                return first.category == .universal
            }
            // Finally sort by display title
            return first.displayTitle < second.displayTitle
        }
    }
    
    /// Check if this chip type should be suggested based on keyword analysis
    func shouldSuggest(for text: String) -> Bool {
        guard category == .contextual else { return false }
        
        let lowercaseText = text.lowercased()
        return triggerKeywords.contains { keyword in
            lowercaseText.contains(keyword.lowercased())
        }
    }
    
    /// Get relevance score for text (0.0 to 1.0)
    func relevanceScore(for text: String) -> Double {
        guard category == .contextual else { return 0.0 }
        
        let lowercaseText = text.lowercased()
        let matchingKeywords = triggerKeywords.filter { keyword in
            lowercaseText.contains(keyword.lowercased())
        }
        
        guard !matchingKeywords.isEmpty else { return 0.0 }
        
        // Base score from keyword matches
        let keywordScore = Double(matchingKeywords.count) / Double(triggerKeywords.count)
        
        // Boost score based on importance
        let importanceMultiplier = Double(importance.rawValue) / 100.0
        
        return min(1.0, keywordScore * importanceMultiplier)
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

// MARK: - Smart Suggestion Helpers

extension Array where Element == ChipType {
    /// Filter to only contextual chips that should be suggested for the given text
    func suggestedChips(for text: String) -> [ChipType] {
        return self.filter { $0.shouldSuggest(for: text) }
    }
    
    /// Sort by relevance score for the given text (highest relevance first)
    func sortedByRelevance(for text: String) -> [ChipType] {
        return self.sorted { first, second in
            let firstScore = first.relevanceScore(for: text)
            let secondScore = second.relevanceScore(for: text)
            
            if firstScore != secondScore {
                return firstScore > secondScore
            }
            
            // If same relevance, sort by importance
            return first.importance.rawValue > second.importance.rawValue
        }
    }
}
