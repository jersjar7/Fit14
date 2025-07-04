//
//  Exercise.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//

import Foundation

struct Exercise: Identifiable, Codable, Equatable {
    let id = UUID()
    let name: String
    let sets: Int
    let reps: Int
    var isCompleted: Bool = false
    
    init(name: String, sets: Int, reps: Int) {
        self.name = name
        self.sets = sets
        self.reps = reps
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
