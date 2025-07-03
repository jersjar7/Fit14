//
//  LocalStorageService.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//

import Foundation

class LocalStorageService: ObservableObject {
    private let userDefaults = UserDefaults.standard
    private let workoutPlanKey = "currentWorkoutPlan"
    
    // Save workout plan to local storage
    func saveWorkoutPlan(_ plan: WorkoutPlan) {
        do {
            let encoded = try JSONEncoder().encode(plan)
            userDefaults.set(encoded, forKey: workoutPlanKey)
            print("✅ Workout plan saved successfully")
        } catch {
            print("❌ Failed to save workout plan: \(error)")
        }
    }
    
    // Load workout plan from local storage
    func loadWorkoutPlan() -> WorkoutPlan? {
        guard let data = userDefaults.data(forKey: workoutPlanKey) else {
            print("📱 No saved workout plan found")
            return nil
        }
        
        do {
            let plan = try JSONDecoder().decode(WorkoutPlan.self, from: data)  // ← FIXED THIS LINE
            print("✅ Workout plan loaded successfully")
            return plan
        } catch {
            print("❌ Failed to load workout plan: \(error)")
            return nil
        }
    }
    
    // Update specific exercise completion
    func updateExerciseCompletion(planId: UUID, dayId: UUID, exerciseId: UUID, isCompleted: Bool) {
        guard var plan = loadWorkoutPlan(), plan.id == planId else { return }
        
        // Find and update the exercise
        for dayIndex in plan.days.indices {
            if plan.days[dayIndex].id == dayId {
                for exerciseIndex in plan.days[dayIndex].exercises.indices {
                    if plan.days[dayIndex].exercises[exerciseIndex].id == exerciseId {
                        plan.days[dayIndex].exercises[exerciseIndex].isCompleted = isCompleted
                        saveWorkoutPlan(plan)
                        return
                    }
                }
            }
        }
    }
    
    // Check if user has an active plan
    func hasActivePlan() -> Bool {
        return loadWorkoutPlan() != nil
    }
    
    // Clear saved plan (for starting fresh)
    func clearWorkoutPlan() {
        userDefaults.removeObject(forKey: workoutPlanKey)
        print("🗑️ Workout plan cleared")
    }
}
