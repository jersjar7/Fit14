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
        guard let plan = currentPlan else { return }
        
        // Update in memory
        for dayIndex in currentPlan!.days.indices {
            if currentPlan!.days[dayIndex].id == dayId {
                for exerciseIndex in currentPlan!.days[dayIndex].exercises.indices {
                    if currentPlan!.days[dayIndex].exercises[exerciseIndex].id == exerciseId {
                        currentPlan!.days[dayIndex].exercises[exerciseIndex].isCompleted.toggle()
                        
                        // Save to storage
                        storageService.saveWorkoutPlan(currentPlan!)
                        return
                    }
                }
            }
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
}
