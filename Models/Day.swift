//
//  Day.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//

import Foundation

struct Day: Identifiable, Codable, Equatable {
    let id: UUID
    let dayNumber: Int
    let date: Date
    var exercises: [Exercise]
    
    var isCompleted: Bool {
        !exercises.isEmpty && exercises.allSatisfy { $0.isCompleted }
    }
    
    // Main initializer with automatic ID generation
    init(dayNumber: Int, date: Date, exercises: [Exercise] = []) {
        self.id = UUID()
        self.dayNumber = dayNumber
        self.date = date
        self.exercises = exercises
    }
    
    // Enhanced initializer that allows ID preservation
    init(id: UUID = UUID(), dayNumber: Int, date: Date, exercises: [Exercise] = []) {
        self.id = id
        self.dayNumber = dayNumber
        self.date = date
        self.exercises = exercises
    }
    
    // Convenience method to create an updated version with the same ID
    func updated(dayNumber: Int? = nil, date: Date? = nil, exercises: [Exercise]? = nil) -> Day {
        return Day(
            id: self.id,
            dayNumber: dayNumber ?? self.dayNumber,
            date: date ?? self.date,
            exercises: exercises ?? self.exercises
        )
    }
    
    // Convenience method to add an exercise
    func addingExercise(_ exercise: Exercise) -> Day {
        var newExercises = self.exercises
        newExercises.append(exercise)
        return updated(exercises: newExercises)
    }
    
    // Convenience method to remove an exercise
    func removingExercise(withId exerciseId: UUID) -> Day {
        let newExercises = exercises.filter { $0.id != exerciseId }
        return updated(exercises: newExercises)
    }
    
    // Convenience method to update an exercise
    func updatingExercise(withId exerciseId: UUID, to newExercise: Exercise) -> Day {
        let newExercises = exercises.map { exercise in
            exercise.id == exerciseId ? newExercise : exercise
        }
        return updated(exercises: newExercises)
    }
    
    // Equatable conformance
    static func == (lhs: Day, rhs: Day) -> Bool {
        return lhs.id == rhs.id &&
               lhs.dayNumber == rhs.dayNumber &&
               lhs.date == rhs.date &&
               lhs.exercises == rhs.exercises
    }
}
