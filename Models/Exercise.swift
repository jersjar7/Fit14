//
//  Exercise.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//

import Foundation

// MARK: - Exercise Unit Enum
enum ExerciseUnit: String, Codable, CaseIterable {
    case reps = "reps"
    case seconds = "seconds"
    case minutes = "minutes"
    
    var displayName: String {
        switch self {
        case .reps:
            return "reps"
        case .seconds:
            return "seconds"
        case .minutes:
            return "minutes"
        }
    }
    
    var shortDisplayName: String {
        switch self {
        case .reps:
            return "reps"
        case .seconds:
            return "sec"
        case .minutes:
            return "min"
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
    
    // Formatted display text for sets and quantity
    var formattedDescription: String {
        return "\(sets) sets × \(quantity) \(unit.shortDisplayName)"
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
