//
//  WorkoutPlanViewModel.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//

import Foundation
import SwiftUI

class WorkoutPlanViewModel: ObservableObject {
    @Published var currentPlan: WorkoutPlan?
    @Published var isLoading = false
    
    private let storageService = LocalStorageService()
    
    init() {
        loadSavedPlan()
    }
    
    // Load plan from storage or create sample plan
    func loadSavedPlan() {
        if let savedPlan = storageService.loadWorkoutPlan() {
            currentPlan = savedPlan
        } else {
            // If no saved plan, load sample data for testing
            currentPlan = SampleData.sampleWorkoutPlan
            storageService.saveWorkoutPlan(SampleData.sampleWorkoutPlan)
        }
    }
    
    // Update exercise completion and save
    func toggleExerciseCompletion(dayId: UUID, exerciseId: UUID) {
        guard var plan = currentPlan else {
            print("❌ No current plan found")
            return
        }
        
        print("🔄 Toggling exercise \(exerciseId) in day \(dayId)")
        
        // Update in memory
        var updated = false
        for dayIndex in plan.days.indices {
            if plan.days[dayIndex].id == dayId {
                for exerciseIndex in plan.days[dayIndex].exercises.indices {
                    if plan.days[dayIndex].exercises[exerciseIndex].id == exerciseId {
                        plan.days[dayIndex].exercises[exerciseIndex].isCompleted.toggle()
                        updated = true
                        print("✅ Exercise completion toggled to: \(plan.days[dayIndex].exercises[exerciseIndex].isCompleted)")
                        break
                    }
                }
                if updated { break }
            }
        }
        
        if updated {
            // Update the published property to trigger UI refresh
            currentPlan = plan
            
            // Save to storage
            storageService.saveWorkoutPlan(plan)
            print("💾 Plan saved to storage")
        } else {
            print("❌ Failed to find exercise to toggle")
        }
    }
    
    // Create new plan (for when AI integration is added)
    func createNewPlan(from goals: String, with days: [Day]) {
        let newPlan = WorkoutPlan(userGoals: goals, days: days)
        currentPlan = newPlan
        storageService.saveWorkoutPlan(newPlan)
    }
    
    // Start fresh (clear current plan)
    func startFresh() {
        storageService.clearWorkoutPlan()
        currentPlan = nil
    }
    
    // Helper method to get a specific day
    func getDay(by id: UUID) -> Day? {
        return currentPlan?.days.first { $0.id == id }
    }
    
    // Helper method to get a specific exercise
    func getExercise(dayId: UUID, exerciseId: UUID) -> Exercise? {
        guard let day = getDay(by: dayId) else { return nil }
        return day.exercises.first { $0.id == exerciseId }
    }
}
