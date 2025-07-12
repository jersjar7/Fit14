//
//  SampleData.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//

import Foundation

struct SampleData {
    
    // MARK: - Sample Exercises with More Variety
    
    static let sampleExercises: [Exercise] = [
        // Upper Body
        Exercise(name: "Push-ups", sets: 3, quantity: 12, unit: .reps),
        Exercise(name: "Tricep Dips", sets: 2, quantity: 10, unit: .reps),
        Exercise(name: "Pike Push-ups", sets: 2, quantity: 8, unit: .reps),
        Exercise(name: "Diamond Push-ups", sets: 2, quantity: 6, unit: .reps),
        
        // Lower Body
        Exercise(name: "Squats", sets: 3, quantity: 15, unit: .reps),
        Exercise(name: "Lunges", sets: 2, quantity: 12, unit: .reps),
        Exercise(name: "Wall Sit", sets: 1, quantity: 45, unit: .seconds),
        Exercise(name: "Calf Raises", sets: 3, quantity: 20, unit: .reps),
        Exercise(name: "Single Leg Glute Bridges", sets: 2, quantity: 10, unit: .reps),
        
        // Core
        Exercise(name: "Plank", sets: 1, quantity: 60, unit: .seconds),
        Exercise(name: "Side Plank", sets: 2, quantity: 30, unit: .seconds),
        Exercise(name: "Russian Twists", sets: 3, quantity: 20, unit: .reps),
        Exercise(name: "Bicycle Crunches", sets: 3, quantity: 15, unit: .reps),
        Exercise(name: "Dead Bug", sets: 2, quantity: 10, unit: .reps),
        
        // Cardio
        Exercise(name: "Jumping Jacks", sets: 3, quantity: 30, unit: .seconds),
        Exercise(name: "High Knees", sets: 3, quantity: 20, unit: .seconds),
        Exercise(name: "Mountain Climbers", sets: 3, quantity: 15, unit: .reps),
        Exercise(name: "Burpees", sets: 2, quantity: 8, unit: .reps),
        Exercise(name: "Jump Squats", sets: 2, quantity: 12, unit: .reps),
        
        // Additional time-based exercises
        Exercise(name: "Cardio Intervals", sets: 1, quantity: 5, unit: .minutes),
        Exercise(name: "Rest and Stretch", sets: 1, quantity: 3, unit: .minutes)
    ]
    
    // MARK: - Exercise Categories for Better Planning
    
    static let upperBodyExercises = Array(sampleExercises[0...3])
    static let lowerBodyExercises = Array(sampleExercises[4...8])
    static let coreExercises = Array(sampleExercises[9...13])
    static let cardioExercises = Array(sampleExercises[14...18])
    static let timeBased = Array(sampleExercises[19...20])
    
    // MARK: - Pre-defined Exercise Combinations by Focus
    
    static let exerciseCombinations: [[Exercise]] = [
        // Day 1: Upper Body Focus
        [upperBodyExercises[0], coreExercises[0], cardioExercises[0]], // Push-ups, Plank, Jumping Jacks
        
        // Day 2: Lower Body Focus
        [lowerBodyExercises[0], lowerBodyExercises[1], coreExercises[1]], // Squats, Lunges, Side Plank
        
        // Day 3: Cardio Focus
        [cardioExercises[0], cardioExercises[1], coreExercises[2]], // Jumping Jacks, High Knees, Russian Twists
        
        // Day 4: Full Body
        [upperBodyExercises[0], lowerBodyExercises[0], coreExercises[0]], // Push-ups, Squats, Plank
        
        // Day 5: Core Focus
        [coreExercises[0], coreExercises[2], lowerBodyExercises[2]], // Plank, Russian Twists, Wall Sit
        
        // Day 6: Strength Focus
        [upperBodyExercises[1], lowerBodyExercises[4], coreExercises[3]], // Tricep Dips, Glute Bridges, Bicycle Crunches
        
        // Day 7: Active Recovery
        [lowerBodyExercises[2], timeBased[1]], // Wall Sit, Rest and Stretch (lighter day)
        
        // Week 2 variations
        [upperBodyExercises[2], cardioExercises[2], coreExercises[1]], // Pike Push-ups, Mountain Climbers, Side Plank
        [lowerBodyExercises[3], lowerBodyExercises[0], coreExercises[4]], // Calf Raises, Squats, Dead Bug
        [cardioExercises[3], upperBodyExercises[0], coreExercises[2]], // Burpees, Push-ups, Russian Twists
        [lowerBodyExercises[1], cardioExercises[4], coreExercises[0]], // Lunges, Jump Squats, Plank
        [upperBodyExercises[3], coreExercises[3], lowerBodyExercises[2]], // Diamond Push-ups, Bicycle Crunches, Wall Sit
        [cardioExercises[1], lowerBodyExercises[4], coreExercises[1]], // High Knees, Glute Bridges, Side Plank
        [upperBodyExercises[1], lowerBodyExercises[0], timeBased[0]] // Tricep Dips, Squats, Cardio Intervals
    ]
    
    // MARK: - Focus Descriptions (NEW)
    
    static let focusDescriptions: [String] = [
        "Upper body strength",           // Day 1
        "Lower body power",              // Day 2
        "Cardio conditioning",           // Day 3
        "Full body workout",             // Day 4
        "Core strengthening",            // Day 5
        "Strength building",             // Day 6
        "Active recovery",               // Day 7
        "Upper body endurance",          // Day 8
        "Lower body stability",          // Day 9
        "High intensity training",       // Day 10
        "Dynamic movement",              // Day 11
        "Advanced strength",             // Day 12
        "Cardio & balance",             // Day 13
        "Complete conditioning"          // Day 14
    ]
    
    // MARK: - Sample Workout Plans
    
    /// Basic sample workout plan (suggested status)
    static let sampleWorkoutPlan: WorkoutPlan = {
        let startDate = Date()
        var days: [Day] = []
        
        for i in 1...14 {
            let dayDate = Calendar.current.date(byAdding: .day, value: i-1, to: startDate) ?? startDate
            let combinationIndex = (i - 1) % exerciseCombinations.count
            let exercisesForDay = exerciseCombinations[combinationIndex]
            let focusForDay = focusDescriptions[(i - 1) % focusDescriptions.count] // NEW: Add focus
            
            let day = Day(dayNumber: i, date: dayDate, focus: focusForDay, exercises: exercisesForDay) // NEW: Include focus
            days.append(day)
        }
        
        return WorkoutPlan(
            userGoals: "Build muscle and lose weight with home workouts",
            days: days,
            status: .suggested
        )
    }()
    
    /// Sample suggested plan for plan review
    static let sampleSuggestedPlan: WorkoutPlan = {
        let startDate = Date()
        var days: [Day] = []
        
        for i in 1...14 {
            let dayDate = Calendar.current.date(byAdding: .day, value: i-1, to: startDate) ?? startDate
            let combinationIndex = (i - 1) % exerciseCombinations.count
            let exercisesForDay = exerciseCombinations[combinationIndex]
            let focusForDay = focusDescriptions[(i - 1) % focusDescriptions.count] // NEW: Add focus
            
            let day = Day(dayNumber: i, date: dayDate, focus: focusForDay, exercises: exercisesForDay) // NEW: Include focus
            days.append(day)
        }
        
        return WorkoutPlan(
                userGoals: "I want to lose 5 pounds in 2 weeks. I'm 28, female, 140 lbs, 5'4\", and can work out 30-45 minutes daily except Sunday.",
                summary: "Balanced cardio and strength plan to support healthy weight loss for a male user who has an intermeditate fitness level. This plan will help to reach their goals as long as it is followed with discipline.",  // ADDED: AI-style summary
                days: days,
                status: .suggested
            )
    }()
    
    /// Sample active plan for daily tracking
    static let sampleActiveWorkoutPlan: WorkoutPlan = {
        let startDate = Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date() // Started 3 days ago
        var days: [Day] = []
        
        for i in 1...14 {
            let dayDate = Calendar.current.date(byAdding: .day, value: i-1, to: startDate) ?? startDate
            let combinationIndex = (i - 1) % exerciseCombinations.count
            var exercisesForDay = exerciseCombinations[combinationIndex]
            let focusForDay = focusDescriptions[(i - 1) % focusDescriptions.count] // NEW: Add focus
            
            // Mark some exercises as completed for first few days
            if i <= 3 {
                for index in exercisesForDay.indices {
                    exercisesForDay[index] = exercisesForDay[index].updated(isCompleted: true)
                }
            } else if i == 4 {
                // Partially complete day 4
                exercisesForDay[0] = exercisesForDay[0].updated(isCompleted: true)
            }
            
            let day = Day(dayNumber: i, date: dayDate, focus: focusForDay, exercises: exercisesForDay) // NEW: Include focus
            days.append(day)
        }
        
        return WorkoutPlan(
                userGoals: "Build strength and endurance with bodyweight exercises",
                summary: "Progressive bodyweight training program focused on building functional strength and cardiovascular endurance for a male user who has an intermeditate fitness level. This plan will help to reach their goals as long as it is followed with discipline.",  // ADDED: AI-style summary
                days: days,
                status: .active
            )    }()
    
    /// Sample completed plan for progress showcase
    static let sampleCompletedWorkoutPlan: WorkoutPlan = {
        let startDate = Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date() // Completed plan
        var days: [Day] = []
        
        for i in 1...14 {
            let dayDate = Calendar.current.date(byAdding: .day, value: i-1, to: startDate) ?? startDate
            let combinationIndex = (i - 1) % exerciseCombinations.count
            var exercisesForDay = exerciseCombinations[combinationIndex]
            let focusForDay = focusDescriptions[(i - 1) % focusDescriptions.count] // NEW: Add focus
            
            // Mark most exercises as completed (90% completion rate)
            for index in exercisesForDay.indices {
                let isCompleted = i < 13 || (i == 13 && index < exercisesForDay.count - 1) || (i == 14 && index == 0)
                exercisesForDay[index] = exercisesForDay[index].updated(isCompleted: isCompleted)
            }
            
            let day = Day(dayNumber: i, date: dayDate, focus: focusForDay, exercises: exercisesForDay) // NEW: Include focus
            days.append(day)
        }
        
        return WorkoutPlan(
                userGoals: "Complete a full-body fitness transformation in 14 days",
                summary: "Comprehensive full-body program combining strength training, cardio, and flexibility work",  // ADDED: AI-style summary
                days: days,
                status: .active
            )
    }()
    
    // MARK: - Sample Plan Variations for Different Goals
    
    /// Weight loss focused plan
    static let weightLossPlan: WorkoutPlan = {
        let startDate = Date()
        var days: [Day] = []
        
        // More cardio-heavy combinations for weight loss
        let weightLossCombinations = [
            [cardioExercises[0], cardioExercises[1], coreExercises[0]], // High cardio + core
            [cardioExercises[2], lowerBodyExercises[0], cardioExercises[3]], // More cardio + squats
            [upperBodyExercises[0], timeBased[0], coreExercises[2]], // Mixed with cardio intervals
            [cardioExercises[1], cardioExercises[4], coreExercises[1]], // Cardio focus + core
        ]
        
        let weightLossFocus = ["High intensity cardio", "Fat burning circuit", "Cardio strength combo", "Metabolic conditioning"]
        
        for i in 1...14 {
            let dayDate = Calendar.current.date(byAdding: .day, value: i-1, to: startDate) ?? startDate
            let combinationIndex = (i - 1) % weightLossCombinations.count
            let exercisesForDay = weightLossCombinations[combinationIndex]
            let focusForDay = weightLossFocus[combinationIndex] // NEW: Add focus
            
            let day = Day(dayNumber: i, date: dayDate, focus: focusForDay, exercises: exercisesForDay) // NEW: Include focus
            days.append(day)
        }
        
        return WorkoutPlan(
            userGoals: "Lose 10 pounds through high-intensity cardio workouts",
            days: days,
            status: .suggested
        )
    }()
    
    /// Strength building focused plan
    static let strengthPlan: WorkoutPlan = {
        let startDate = Date()
        var days: [Day] = []
        
        // More strength-focused combinations
        let strengthCombinations = [
            [upperBodyExercises[0], upperBodyExercises[1], coreExercises[0]], // Upper strength + core holds
            [lowerBodyExercises[0], lowerBodyExercises[1], lowerBodyExercises[4]], // Lower strength focus
            [upperBodyExercises[2], coreExercises[2], upperBodyExercises[3]], // Upper + core variety
            [lowerBodyExercises[2], lowerBodyExercises[3], coreExercises[3]], // Lower + core holds
        ]
        
        let strengthFocus = ["Upper body power", "Lower body strength", "Advanced upper body", "Lower body endurance"]
        
        for i in 1...14 {
            let dayDate = Calendar.current.date(byAdding: .day, value: i-1, to: startDate) ?? startDate
            let combinationIndex = (i - 1) % strengthCombinations.count
            let exercisesForDay = strengthCombinations[combinationIndex]
            let focusForDay = strengthFocus[combinationIndex] // NEW: Add focus
            
            let day = Day(dayNumber: i, date: dayDate, focus: focusForDay, exercises: exercisesForDay) // NEW: Include focus
            days.append(day)
        }
        
        return WorkoutPlan(
            userGoals: "Build muscle strength with progressive bodyweight exercises",
            days: days,
            status: .suggested
        )
    }()
    
    // MARK: - Individual Sample Data for Components
    
    /// Sample day for previews
    static let sampleDay: Day = {
        let exercises = [sampleExercises[0], sampleExercises[4], sampleExercises[9]]
        return Day(dayNumber: 1, date: Date(), focus: "Upper body strength", exercises: exercises) // NEW: Add focus
    }()
    
    /// Sample completed day for previews
    static let sampleCompletedDay: Day = {
        var exercises = [sampleExercises[0], sampleExercises[4], sampleExercises[9]]
        for index in exercises.indices {
            exercises[index] = exercises[index].updated(isCompleted: true)
        }
        return Day(dayNumber: 5, date: Date(), focus: "Core strengthening", exercises: exercises) // NEW: Add focus
    }()
    
    /// Sample partially completed day for previews
    static let samplePartialDay: Day = {
        var exercises = [sampleExercises[0], sampleExercises[4], sampleExercises[9]]
        exercises[0] = exercises[0].updated(isCompleted: true)
        exercises[1] = exercises[1].updated(isCompleted: true)
        // Leave last exercise incomplete
        return Day(dayNumber: 3, date: Date(), focus: "Cardio conditioning", exercises: exercises) // NEW: Add focus
    }()
    
    /// Sample day with mixed units for preview
    static let sampleMixedUnitsDay: Day = {
        let exercises = [
            Exercise(name: "Push-ups", sets: 3, quantity: 12, unit: .reps),
            Exercise(name: "Plank Hold", sets: 1, quantity: 45, unit: .seconds),
            Exercise(name: "Cardio Walk", sets: 1, quantity: 10, unit: .minutes)
        ]
        return Day(dayNumber: 8, date: Date(), focus: "Mixed training", exercises: exercises) // NEW: Add focus
    }()
    
    // MARK: - Preview Helpers
    
    /// Get a sample plan by type for previews
    static func samplePlan(type: PlanStatus) -> WorkoutPlan {
        switch type {
        case .suggested:
            return sampleSuggestedPlan
        case .active:
            return sampleActiveWorkoutPlan
        }
    }
    
    /// Get sample days with different completion states
    static var sampleDaysVariety: [Day] {
        return [
            sampleDay,              // Not started
            samplePartialDay,       // Partially complete
            sampleCompletedDay,     // Fully complete
            sampleMixedUnitsDay     // Mixed unit types
        ]
    }
    
    /// Get exercises by unit type for testing
    static var exercisesByUnit: [ExerciseUnit: [Exercise]] {
        let groupedExercises = Dictionary(grouping: sampleExercises) { $0.unit }
        return groupedExercises
    }
}
