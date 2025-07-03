//
//  SampleData.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//

import Foundation

struct SampleData {
    static let sampleExercises: [Exercise] = [
        Exercise(name: "Push-ups", sets: 3, reps: 10),
        Exercise(name: "Squats", sets: 3, reps: 15),
        Exercise(name: "Plank", sets: 1, reps: 30),
        Exercise(name: "Jumping Jacks", sets: 2, reps: 20)
    ]
    
    static let sampleWorkoutPlan: WorkoutPlan = {
        let startDate = Date()
        var days: [Day] = []
        
        // Pre-defined exercise combinations to avoid shuffled() randomness
        let exerciseCombinations: [[Exercise]] = [
            [sampleExercises[0], sampleExercises[1], sampleExercises[2]], // Push-ups, Squats, Plank
            [sampleExercises[1], sampleExercises[2], sampleExercises[3]], // Squats, Plank, Jumping Jacks
            [sampleExercises[0], sampleExercises[2], sampleExercises[3]], // Push-ups, Plank, Jumping Jacks
            [sampleExercises[0], sampleExercises[1], sampleExercises[3]], // Push-ups, Squats, Jumping Jacks
            [sampleExercises[1], sampleExercises[0], sampleExercises[2]], // Squats, Push-ups, Plank
            [sampleExercises[2], sampleExercises[3], sampleExercises[0]], // Plank, Jumping Jacks, Push-ups
            [sampleExercises[3], sampleExercises[1], sampleExercises[2]], // Jumping Jacks, Squats, Plank
        ]
        
        for i in 1...14 {
            let dayDate = Calendar.current.date(byAdding: .day, value: i-1, to: startDate) ?? startDate
            
            // Cycle through the predefined combinations
            let combinationIndex = (i - 1) % exerciseCombinations.count
            let exercisesForDay = exerciseCombinations[combinationIndex]
            
            let day = Day(dayNumber: i, date: dayDate, exercises: exercisesForDay)
            days.append(day)
        }
        
        return WorkoutPlan(userGoals: "Build muscle and lose weight", days: days)
    }()
}
