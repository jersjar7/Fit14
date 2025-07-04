//
//  Exercise.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//

import Foundation

struct Exercise: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let sets: Int
    let reps: Int
    var isCompleted: Bool = false
    
    // Main initializer with automatic ID generation
    init(name: String, sets: Int, reps: Int) {
        self.id = UUID()
        self.name = name
        self.sets = sets
        self.reps = reps
        self.isCompleted = false
    }
    
    // Enhanced initializer that allows ID preservation
    init(id: UUID = UUID(), name: String, sets: Int, reps: Int, isCompleted: Bool = false) {
        self.id = id
        self.name = name
        self.sets = sets
        self.reps = reps
        self.isCompleted = isCompleted
    }
    
    // Convenience method to create an updated version with the same ID
    func updated(name: String? = nil, sets: Int? = nil, reps: Int? = nil, isCompleted: Bool? = nil) -> Exercise {
        return Exercise(
            id: self.id,
            name: name ?? self.name,
            sets: sets ?? self.sets,
            reps: reps ?? self.reps,
            isCompleted: isCompleted ?? self.isCompleted
        )
    }
    
    // Equatable conformance
    static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.sets == rhs.sets &&
               lhs.reps == rhs.reps &&
               lhs.isCompleted == rhs.isCompleted
    }
}
