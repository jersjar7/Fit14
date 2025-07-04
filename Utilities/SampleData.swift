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
        Exercise(name: "Push-ups", sets: 3, reps: 12),
        Exercise(name: "Tricep Dips", sets: 2, reps: 10),
        Exercise(name: "Pike Push-ups", sets: 2, reps: 8),
        Exercise(name: "Diamond Push-ups", sets: 2, reps: 6),
        
        // Lower Body
        Exercise(name: "Squats", sets: 3, reps: 15),
        Exercise(name: "Lunges", sets: 2, reps: 12),
        Exercise(name: "Wall Sit", sets: 1, reps: 45),
        Exercise(name: "Calf Raises", sets: 3, reps: 20),
        Exercise(name: "Single Leg Glute Bridges", sets: 2, reps: 10),
        
        // Core
        Exercise(name: "Plank", sets: 1, reps: 60),
        Exercise(name: "Side Plank", sets: 2, reps: 30),
        Exercise(name: "Russian Twists", sets: 3, reps: 20),
        Exercise(name: "Bicycle Crunches", sets: 3, reps: 15),
        Exercise(name: "Dead Bug", sets: 2, reps: 10),
        
        // Cardio
        Exercise(name: "Jumping Jacks", sets: 3, reps: 30),
        Exercise(name: "High Knees", sets: 3, reps: 20),
        Exercise(name: "Mountain Climbers", sets: 3, reps: 15),
        Exercise(name: "Burpees", sets: 2, reps: 8),
        Exercise(name: "Jump Squats", sets: 2, reps: 12)
    ]
    
    // MARK: - Exercise Categories for Better Planning
    
    static let upperBodyExercises = Array(sampleExercises[0...3])
    static let lowerBodyExercises = Array(sampleExercises[4...8])
    static let coreExercises = Array(sampleExercises[9...13])
    static let cardioExercises = Array(sampleExercises[14...18])
    
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
        [lowerBodyExercises[2], coreExercises[0]], // Wall Sit, Plank (lighter day)
        
        // Week 2 variations
        [upperBodyExercises[2], cardioExercises[2], coreExercises[1]], // Pike Push-ups, Mountain Climbers, Side Plank
        [lowerBodyExercises[3], lowerBodyExercises[0], coreExercises[4]], // Calf Raises, Squats, Dead Bug
        [cardioExercises[3], upperBodyExercises[0], coreExercises[2]], // Burpees, Push-ups, Russian Twists
        [lowerBodyExercises[1], cardioExercises[4], coreExercises[0]], // Lunges, Jump Squats, Plank
        [upperBodyExercises[3], coreExercises[3], lowerBodyExercises[2]], // Diamond Push-ups, Bicycle Crunches, Wall Sit
        [cardioExercises[1], lowerBodyExercises[4], coreExercises[1]], // High Knees, Glute Bridges, Side Plank
        [upperBodyExercises[1], lowerBodyExercises[0], cardioExercises[0]] // Tricep Dips, Squats, Jumping Jacks
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
            
            let day = Day(dayNumber: i, date: dayDate, exercises: exercisesForDay)
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
            
            let day = Day(dayNumber: i, date: dayDate, exercises: exercisesForDay)
            days.append(day)
        }
        
        return WorkoutPlan(
            userGoals: "I want to lose 5 pounds in 2 weeks. I'm 28, female, 140 lbs, 5'4\", and can work out 30-45 minutes daily except Sunday.",
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
            
            // Mark some exercises as completed for first few days
            if i <= 3 {
                for index in exercisesForDay.indices {
                    exercisesForDay[index] = exercisesForDay[index].updated(isCompleted: true)
                }
            } else if i == 4 {
                // Partially complete day 4
                exercisesForDay[0] = exercisesForDay[0].updated(isCompleted: true)
            }
            
            let day = Day(dayNumber: i, date: dayDate, exercises: exercisesForDay)
            days.append(day)
        }
        
        return WorkoutPlan(
            userGoals: "Build strength and endurance with bodyweight exercises",
            days: days,
            status: .active
        )
    }()
    
    /// Sample completed plan for progress showcase
    static let sampleCompletedWorkoutPlan: WorkoutPlan = {
        let startDate = Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date() // Completed plan
        var days: [Day] = []
        
        for i in 1...14 {
            let dayDate = Calendar.current.date(byAdding: .day, value: i-1, to: startDate) ?? startDate
            let combinationIndex = (i - 1) % exerciseCombinations.count
            var exercisesForDay = exerciseCombinations[combinationIndex]
            
            // Mark most exercises as completed (90% completion rate)
            for index in exercisesForDay.indices {
                let isCompleted = i < 13 || (i == 13 && index < exercisesForDay.count - 1) || (i == 14 && index == 0)
                exercisesForDay[index] = exercisesForDay[index].updated(isCompleted: isCompleted)
            }
            
            let day = Day(dayNumber: i, date: dayDate, exercises: exercisesForDay)
            days.append(day)
        }
        
        return WorkoutPlan(
            userGoals: "Complete a 14-day fitness challenge and build healthy habits",
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
            [cardioExercises[0], cardioExercises[1], coreExercises[0]], // High cardio
            [cardioExercises[2], lowerBodyExercises[0], cardioExercises[3]], // More cardio
            [upperBodyExercises[0], cardioExercises[0], coreExercises[2]], // Mixed
            [cardioExercises[1], cardioExercises[4], coreExercises[1]], // Cardio focus
        ]
        
        for i in 1...14 {
            let dayDate = Calendar.current.date(byAdding: .day, value: i-1, to: startDate) ?? startDate
            let combinationIndex = (i - 1) % weightLossCombinations.count
            let exercisesForDay = weightLossCombinations[combinationIndex]
            
            let day = Day(dayNumber: i, date: dayDate, exercises: exercisesForDay)
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
            [upperBodyExercises[0], upperBodyExercises[1], coreExercises[0]], // Upper strength
            [lowerBodyExercises[0], lowerBodyExercises[1], lowerBodyExercises[4]], // Lower strength
            [upperBodyExercises[2], coreExercises[2], upperBodyExercises[3]], // Upper + core
            [lowerBodyExercises[2], lowerBodyExercises[3], coreExercises[3]], // Lower + core
        ]
        
        for i in 1...14 {
            let dayDate = Calendar.current.date(byAdding: .day, value: i-1, to: startDate) ?? startDate
            let combinationIndex = (i - 1) % strengthCombinations.count
            let exercisesForDay = strengthCombinations[combinationIndex]
            
            let day = Day(dayNumber: i, date: dayDate, exercises: exercisesForDay)
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
        return Day(dayNumber: 1, date: Date(), exercises: exercises)
    }()
    
    /// Sample completed day for previews
    static let sampleCompletedDay: Day = {
        var exercises = [sampleExercises[0], sampleExercises[4], sampleExercises[9]]
        for index in exercises.indices {
            exercises[index] = exercises[index].updated(isCompleted: true)
        }
        return Day(dayNumber: 5, date: Date(), exercises: exercises)
    }()
    
    /// Sample partially completed day for previews
    static let samplePartialDay: Day = {
        var exercises = [sampleExercises[0], sampleExercises[4], sampleExercises[9]]
        exercises[0] = exercises[0].updated(isCompleted: true)
        exercises[1] = exercises[1].updated(isCompleted: true)
        // Leave last exercise incomplete
        return Day(dayNumber: 3, date: Date(), exercises: exercises)
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
            sampleDay,           // Not started
            samplePartialDay,    // Partially complete
            sampleCompletedDay   // Fully complete
        ]
    }
}
