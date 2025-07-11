//
//  Day.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//  UPDATED: Added missed day detection logic
//

import Foundation

struct Day: Identifiable, Codable, Equatable {
    let id: UUID
    let dayNumber: Int
    let date: Date
    let focus: String?  // NEW: AI-provided focus description (e.g., "Upper body strength")
    var exercises: [Exercise]
    
    var isCompleted: Bool {
        !exercises.isEmpty && exercises.allSatisfy { $0.isCompleted }
    }
    
    // MARK: - Missed Day Detection (NEW)
    
    /// Whether this day is missed (past date and not completed)
    var isMissed: Bool {
        return isPastDue && !isCompleted
    }
    
    /// Whether this day is past due (date has passed)
    var isPastDue: Bool {
        let calendar = Calendar.current
        let today = Date()
        return date < calendar.startOfDay(for: today)
    }
    
    /// Whether this day is today
    var isToday: Bool {
        Calendar.current.isDate(date, inSameDayAs: Date())
    }
    
    /// Whether this day is in the future
    var isFuture: Bool {
        let calendar = Calendar.current
        let today = Date()
        return date > calendar.startOfDay(for: today)
    }
    
    /// Days ago this day was (positive number if in the past, 0 if today, negative if future)
    var daysFromToday: Int {
        let calendar = Calendar.current
        let today = Date()
        return calendar.dateComponents([.day], from: calendar.startOfDay(for: date), to: calendar.startOfDay(for: today)).day ?? 0
    }
    
    /// Whether this day is available for catch-up (missed but within reasonable timeframe)
    var isAvailableForCatchUp: Bool {
        // Must be missed first
        guard isMissed else { return false }
        
        // Allow catch-up within 7 days of the missed date
        let daysSinceMissed = daysFromToday
        return daysSinceMissed <= 7
    }
    // Note: The plan-level logic in the ViewModel will also check if the overall
    // 14-day challenge period has ended, providing an additional time boundary.
    
    // MARK: - Initializers
    
    // Main initializer with automatic ID generation
    init(dayNumber: Int, date: Date, focus: String? = nil, exercises: [Exercise] = []) {
        self.id = UUID()
        self.dayNumber = dayNumber
        self.date = date
        self.focus = focus  // NEW: Include focus
        self.exercises = exercises
    }
    
    // Enhanced initializer that allows ID preservation
    init(id: UUID = UUID(), dayNumber: Int, date: Date, focus: String? = nil, exercises: [Exercise] = []) {
        self.id = id
        self.dayNumber = dayNumber
        self.date = date
        self.focus = focus  // NEW: Include focus
        self.exercises = exercises
    }
    
    // MARK: - Update Methods
    
    // Convenience method to create an updated version with the same ID
    func updated(dayNumber: Int? = nil, date: Date? = nil, focus: String? = nil, exercises: [Exercise]? = nil) -> Day {
        return Day(
            id: self.id,
            dayNumber: dayNumber ?? self.dayNumber,
            date: date ?? self.date,
            focus: focus ?? self.focus,  // NEW: Include focus in updates
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
    
    // MARK: - Equatable Conformance
    
    // Equatable conformance
    static func == (lhs: Day, rhs: Day) -> Bool {
        return lhs.id == rhs.id &&
               lhs.dayNumber == rhs.dayNumber &&
               lhs.date == rhs.date &&
               lhs.focus == rhs.focus &&  // NEW: Include focus in equality check
               lhs.exercises == rhs.exercises
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension Day {
    /// Create a sample missed day for testing
    static func sampleMissedDay() -> Day {
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date()
        return Day(
            dayNumber: 3,
            date: threeDaysAgo,
            focus: "Cardio workout",
            exercises: [
                Exercise(name: "Running", sets: 1, quantity: 20, unit: .minutes),
                Exercise(name: "Stretching", sets: 1, quantity: 10, unit: .minutes)
            ]
        )
    }
    
    /// Create a sample past completed day for testing
    static func sampleCompletedPastDay() -> Day {
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date()
        var day = Day(
            dayNumber: 4,
            date: twoDaysAgo,
            focus: "Strength training",
            exercises: [
                Exercise(name: "Push-ups", sets: 3, quantity: 12, unit: .reps),
                Exercise(name: "Squats", sets: 3, quantity: 15, unit: .reps)
            ]
        )
        
        // Mark exercises as completed
        day.exercises = day.exercises.map { exercise in
            var completedExercise = exercise
            completedExercise.isCompleted = true
            return completedExercise
        }
        
        return day
    }
    
    /// Create a sample today day for testing
    static func sampleTodayDay() -> Day {
        return Day(
            dayNumber: 5,
            date: Date(),
            focus: "Core workout",
            exercises: [
                Exercise(name: "Plank", sets: 3, quantity: 30, unit: .seconds),
                Exercise(name: "Crunches", sets: 3, quantity: 20, unit: .reps)
            ]
        )
    }
}
#endif
