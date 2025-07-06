//
//  Exercise.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//

import Foundation

// MARK: - Exercise Unit Enum
enum ExerciseUnit: String, Codable, CaseIterable {
    // Count-based units
    case reps = "reps"
    case steps = "steps"
    case laps = "laps"
    
    // Time-based units
    case seconds = "seconds"
    case minutes = "minutes"
    case hours = "hours"
    
    // Distance-based units
    case meters = "meters"
    case yards = "yards"
    case feet = "feet"
    case kilometers = "kilometers"
    case miles = "miles"
    
    var displayName: String {
        switch self {
        // Count-based
        case .reps:
            return "reps"
        case .steps:
            return "steps"
        case .laps:
            return "laps"
            
        // Time-based
        case .seconds:
            return "seconds"
        case .minutes:
            return "minutes"
        case .hours:
            return "hours"
            
        // Distance-based
        case .meters:
            return "meters"
        case .yards:
            return "yards"
        case .feet:
            return "feet"
        case .kilometers:
            return "kilometers"
        case .miles:
            return "miles"
        }
    }
    
    var shortDisplayName: String {
        switch self {
        // Count-based
        case .reps:
            return "reps"
        case .steps:
            return "steps"
        case .laps:
            return "laps"
            
        // Time-based
        case .seconds:
            return "sec"
        case .minutes:
            return "min"
        case .hours:
            return "hr"
            
        // Distance-based
        case .meters:
            return "m"
        case .yards:
            return "yd"
        case .feet:
            return "ft"
        case .kilometers:
            return "km"
        case .miles:
            return "mi"
        }
    }
    
    // MARK: - Unit Type Information
    
    /// Get the category this unit belongs to (references CategoryUnitPicker's UnitCategory)
    var unitCategory: String {
        switch self {
        case .reps, .steps, .laps:
            return "Count"
        case .seconds, .minutes, .hours:
            return "Time"
        case .meters, .yards, .feet, .kilometers, .miles:
            return "Distance"
        }
    }
    
    var isCountBased: Bool {
        switch self {
        case .reps, .steps, .laps:
            return true
        default:
            return false
        }
    }
    
    var isTimeBased: Bool {
        switch self {
        case .seconds, .minutes, .hours:
            return true
        default:
            return false
        }
    }
    
    var isDistanceBased: Bool {
        switch self {
        case .meters, .yards, .feet, .kilometers, .miles:
            return true
        default:
            return false
        }
    }
    
    // MARK: - Display Helpers
    
    /// Get appropriate system icon for the unit
    var systemIcon: String {
        if isCountBased {
            switch self {
            case .reps:
                return "number"
            case .steps:
                return "figure.walk"
            case .laps:
                return "arrow.clockwise"
            default:
                return "number"
            }
        } else if isTimeBased {
            return "clock"
        } else if isDistanceBased {
            return "location"
        } else {
            return "questionmark"
        }
    }
    
    /// Get unit with appropriate pluralization
    func displayName(for quantity: Int) -> String {
        // Most units are already plural or don't change
        // But we could add special cases if needed
        switch self {
        case .hours:
            return quantity == 1 ? "hour" : "hours"
        case .feet:
            return quantity == 1 ? "foot" : "feet"
        default:
            return displayName
        }
    }
    
    /// Get short unit with appropriate pluralization
    func shortDisplayName(for quantity: Int) -> String {
        // Short names typically don't pluralize
        return shortDisplayName
    }
    
    // MARK: - Validation Helpers
    
    /// Check if a quantity value makes sense for this unit
    func isValidQuantity(_ quantity: Int) -> Bool {
        guard quantity > 0 else { return false }
        
        switch self {
        case .reps:
            return quantity <= 1000 // Reasonable max reps
        case .steps:
            return quantity <= 100000 // Max daily steps
        case .laps:
            return quantity <= 200 // Max pool/track laps
        case .seconds:
            return quantity <= 3600 // Max 1 hour in seconds
        case .minutes:
            return quantity <= 180 // Max 3 hours in minutes
        case .hours:
            return quantity <= 12 // Max 12 hours
        case .meters:
            return quantity <= 10000 // Max 10km in meters
        case .yards:
            return quantity <= 10000 // Max reasonable yards
        case .feet:
            return quantity <= 10000 // Max reasonable feet
        case .kilometers:
            return quantity <= 100 // Max 100km
        case .miles:
            return quantity <= 50 // Max 50 miles
        }
    }
    
    /// Get suggested range for this unit type
    var suggestedRange: ClosedRange<Int> {
        switch self {
        case .reps:
            return 1...50
        case .steps:
            return 100...20000
        case .laps:
            return 1...50
        case .seconds:
            return 10...300
        case .minutes:
            return 1...120
        case .hours:
            return 1...4
        case .meters:
            return 50...5000
        case .yards:
            return 50...3000
        case .feet:
            return 10...1000
        case .kilometers:
            return 1...25
        case .miles:
            return 1...15
        }
    }
}

struct Exercise: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let sets: Int
    let quantity: Int
    let unit: ExerciseUnit
    var isCompleted: Bool = false
    
    // Main initializer with automatic ID generation
    init(name: String, sets: Int, quantity: Int, unit: ExerciseUnit = .reps) {
        self.id = UUID()
        self.name = name
        self.sets = sets
        self.quantity = quantity
        self.unit = unit
        self.isCompleted = false
    }
    
    // Enhanced initializer that allows ID preservation
    init(id: UUID = UUID(), name: String, sets: Int, quantity: Int, unit: ExerciseUnit = .reps, isCompleted: Bool = false) {
        self.id = id
        self.name = name
        self.sets = sets
        self.quantity = quantity
        self.unit = unit
        self.isCompleted = isCompleted
    }
    
    // Convenience method to create an updated version with the same ID
    func updated(name: String? = nil, sets: Int? = nil, quantity: Int? = nil, unit: ExerciseUnit? = nil, isCompleted: Bool? = nil) -> Exercise {
        return Exercise(
            id: self.id,
            name: name ?? self.name,
            sets: sets ?? self.sets,
            quantity: quantity ?? self.quantity,
            unit: unit ?? self.unit,
            isCompleted: isCompleted ?? self.isCompleted
        )
    }
    
    // MARK: - Display Properties
    
    // Formatted display text for sets and quantity
    var formattedDescription: String {
        return "\(sets) sets × \(quantity) \(unit.shortDisplayName)"
    }
    
    /// Enhanced formatted description with context-aware display
    var detailedDescription: String {
        if sets == 1 {
            return "\(quantity) \(unit.displayName(for: quantity))"
        } else {
            return "\(sets) sets × \(quantity) \(unit.displayName(for: quantity))"
        }
    }
    
    /// Short format for compact displays
    var compactDescription: String {
        if sets == 1 {
            return "\(quantity) \(unit.shortDisplayName)"
        } else {
            return "\(sets)×\(quantity) \(unit.shortDisplayName)"
        }
    }
    
    // MARK: - Validation
    
    /// Check if the exercise has valid data
    var isValid: Bool {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        guard sets > 0 && sets <= 20 else { return false }
        guard unit.isValidQuantity(quantity) else { return false }
        return true
    }
    
    /// Get validation issues for this exercise
    var validationIssues: [String] {
        var issues: [String] = []
        
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            issues.append("Exercise name cannot be empty")
        }
        
        if sets <= 0 {
            issues.append("Sets must be greater than 0")
        } else if sets > 20 {
            issues.append("Sets should be 20 or fewer")
        }
        
        if quantity <= 0 {
            issues.append("Quantity must be greater than 0")
        } else if !unit.isValidQuantity(quantity) {
            issues.append("Quantity seems too high for \(unit.displayName)")
        }
        
        return issues
    }
    
    // MARK: - Exercise Type Helpers
    
    /// Determine if this is likely a strength exercise
    var isStrengthExercise: Bool {
        let strengthKeywords = ["push", "pull", "squat", "lunge", "lift", "press", "curl", "row"]
        let lowercaseName = name.lowercased()
        return strengthKeywords.contains { lowercaseName.contains($0) } && unit.isCountBased
    }
    
    /// Determine if this is likely a cardio exercise
    var isCardioExercise: Bool {
        let cardioKeywords = ["run", "jog", "bike", "cycle", "swim", "walk", "cardio"]
        let lowercaseName = name.lowercased()
        return cardioKeywords.contains { lowercaseName.contains($0) } || unit.isDistanceBased
    }
    
    /// Determine if this is likely a flexibility/mobility exercise
    var isFlexibilityExercise: Bool {
        let flexKeywords = ["stretch", "yoga", "mobility", "foam", "massage"]
        let lowercaseName = name.lowercased()
        return flexKeywords.contains { lowercaseName.contains($0) } && unit.isTimeBased
    }
    
    // Equatable conformance
    static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.sets == rhs.sets &&
               lhs.quantity == rhs.quantity &&
               lhs.unit == rhs.unit &&
               lhs.isCompleted == rhs.isCompleted
    }
}
