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
    @Published var isGenerating = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    private let storageService = LocalStorageService()
    private let aiService = AIWorkoutGenerationService()
    
    init() {
        loadSavedPlan()
    }
    
    // MARK: - AI Plan Generation
    
    /// Generate workout plan from user goals using AI
    @MainActor
    func generatePlanFromGoals(_ userGoals: String) async {
        guard !userGoals.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showErrorMessage("Please enter your fitness goals")
            return
        }
        
        isGenerating = true
        errorMessage = nil
        
        do {
            print("🚀 Starting AI plan generation...")
            
            // For development/testing - use mock first, then switch to real AI
            let newPlan: WorkoutPlan
            
            #if DEBUG
            // Use mock for testing - change this to real AI call when ready
            newPlan = aiService.generateMockWorkoutPlan(from: userGoals)
            
            // Simulate network delay for realistic testing
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            #else
            // Production: use real AI service
            newPlan = try await aiService.generateWorkoutPlan(from: userGoals)
            #endif
            
            // Save and set as current plan
            currentPlan = newPlan
            storageService.saveWorkoutPlan(newPlan)
            
            print("✅ Successfully generated and saved workout plan")
            
        } catch let error as AIServiceError {
            print("❌ AI Service Error: \(error.localizedDescription)")
            showErrorMessage(error.localizedDescription)
        } catch {
            print("❌ Unexpected Error: \(error.localizedDescription)")
            showErrorMessage("Failed to generate workout plan. Please try again.")
        }
        
        isGenerating = false
    }
    
    // MARK: - Plan Management
    
    /// Load plan from storage or create sample plan
    func loadSavedPlan() {
        if let savedPlan = storageService.loadWorkoutPlan() {
            currentPlan = savedPlan
            print("📱 Loaded saved workout plan")
        } else {
            print("📱 No saved plan found")
            // Don't auto-create sample data - let user generate their own plan
        }
    }
    
    /// Update exercise completion and save
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
    
    /// Create new plan (alternative to AI generation)
    func createNewPlan(from goals: String, with days: [Day]) {
        let newPlan = WorkoutPlan(userGoals: goals, days: days)
        currentPlan = newPlan
        storageService.saveWorkoutPlan(newPlan)
    }
    
    /// Start fresh (clear current plan)
    func startFresh() {
        storageService.clearWorkoutPlan()
        currentPlan = nil
        errorMessage = nil
        print("🗑️ Started fresh - cleared current plan")
    }
    
    /// Load sample data for testing
    func loadSampleData() {
        currentPlan = SampleData.sampleWorkoutPlan
        storageService.saveWorkoutPlan(SampleData.sampleWorkoutPlan)
        print("🧪 Loaded sample data for testing")
    }
    
    // MARK: - Helper Methods
    
    /// Get a specific day
    func getDay(by id: UUID) -> Day? {
        return currentPlan?.days.first { $0.id == id }
    }
    
    /// Get a specific exercise
    func getExercise(dayId: UUID, exerciseId: UUID) -> Exercise? {
        guard let day = getDay(by: dayId) else { return nil }
        return day.exercises.first { $0.id == exerciseId }
    }
    
    /// Check if user has an active plan
    var hasActivePlan: Bool {
        return currentPlan != nil
    }
    
    /// Get progress information
    var progressInfo: (completed: Int, total: Int, percentage: Double) {
        guard let plan = currentPlan else { return (0, 0, 0) }
        return (plan.completedDays, plan.days.count, plan.progressPercentage)
    }
    
    // MARK: - Error Handling
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    /// Clear error state
    func clearError() {
        errorMessage = nil
        showError = false
    }
}
