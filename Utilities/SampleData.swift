//
//  File.swift
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
        
        for i in 1...14 {
            let dayDate = Calendar.current.date(byAdding: .day, value: i-1, to: startDate) ?? startDate
            let exercisesForDay = Array(sampleExercises.shuffled().prefix(3))
            let day = Day(dayNumber: i, date: dayDate, exercises: exercisesForDay)
            days.append(day)
        }
        
        return WorkoutPlan(userGoals: "Build muscle and lose weight", days: days)
    }()
}
