//
//  WorkoutPlanViewModel.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//

import Foundation
import SwiftUI

class WorkoutPlanViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentPlan: WorkoutPlan? // Active plan only
    @Published var suggestedPlan: WorkoutPlan? // AI-generated suggested plan
    @Published var originalPlan: WorkoutPlan? // Original AI plan for reset functionality
    @Published var isLoading = false
    @Published var isGenerating = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    // MARK: - Services
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
            
            // Set as suggested plan (NOT current plan)
            suggestedPlan = newPlan
            // Keep a copy of the original for reset functionality
            originalPlan = newPlan
            
            print("✅ Successfully generated suggested workout plan")
            
        } catch let error as AIServiceError {
            print("❌ AI Service Error: \(error.localizedDescription)")
            showErrorMessage(error.localizedDescription)
        } catch {
            print("❌ Unexpected Error: \(error.localizedDescription)")
            showErrorMessage("Failed to generate workout plan. Please try again.")
        }
        
        isGenerating = false
    }
    
    // MARK: - Plan State Management
    
    /// Accept the suggested plan and make it active
    func acceptSuggestedPlan() {
        guard let suggested = suggestedPlan else {
            print("❌ No suggested plan to accept")
            showErrorMessage("No plan available to accept")
            return
        }
        
        let activePlan = suggested.makeActive()
        currentPlan = activePlan
        
        // Clear suggested and original plans
        suggestedPlan = nil
        originalPlan = nil
        
        // Save the active plan
        storageService.saveWorkoutPlan(activePlan)
        
        print("✅ Accepted suggested plan and made it active")
    }
    
    /// Reject the suggested plan and clear it
    func rejectSuggestedPlan() {
        suggestedPlan = nil
        originalPlan = nil
        print("🗑️ Rejected suggested plan")
    }
    
    /// Start over - clear both suggested and active plans
    func startOver() {
        suggestedPlan = nil
        originalPlan = nil
        currentPlan = nil
        storageService.clearWorkoutPlan()
        errorMessage = nil
        print("🔄 Started over - cleared all plans")
    }
    
    /// Regenerate plan with smart preservation of user changes
    @MainActor
    func regeneratePlan() async {
        guard let suggested = suggestedPlan else {
            print("❌ No suggested plan to regenerate")
            showErrorMessage("No plan available to regenerate")
            return
        }
        
        // Store user goals before regeneration
        let userGoals = suggested.userGoals
        
        // For MVP: Simple regeneration (replace entire plan)
        // TODO: In future versions, preserve user-modified days
        
        print("🔄 Regenerating plan...")
        isGenerating = true
        
        do {
            // Generate new plan
            let newPlan: WorkoutPlan
            
            #if DEBUG
            newPlan = aiService.generateMockWorkoutPlan(from: userGoals)
            try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
            #else
            newPlan = try await aiService.generateWorkoutPlan(from: userGoals)
            #endif
            
            // Replace suggested plan with new generation
            suggestedPlan = newPlan
            originalPlan = newPlan
            
            print("✅ Successfully regenerated workout plan")
            
        } catch let error as AIServiceError {
            print("❌ AI Service Error during regeneration: \(error.localizedDescription)")
            showErrorMessage("Failed to regenerate plan: \(error.localizedDescription)")
        } catch {
            print("❌ Unexpected Error during regeneration: \(error.localizedDescription)")
            showErrorMessage("Failed to regenerate plan. Please try again.")
        }
        
        isGenerating = false
    }
    
    /// Regenerate plan preserving user modifications (Advanced feature)
    @MainActor
    func regeneratePlanPreservingChanges() async {
        guard let suggested = suggestedPlan,
              let original = originalPlan else {
            print("❌ No plans available for smart regeneration")
            await regeneratePlan() // Fallback to simple regeneration
            return
        }
        
        // Identify user-modified days by comparing with original
        var modifiedDayIds: Set<UUID> = []
        
        for (index, day) in suggested.days.enumerated() {
            if index < original.days.count {
                let originalDay = original.days[index]
                if !daysAreEqual(day, originalDay) {
                    modifiedDayIds.insert(day.id)
                }
            }
        }
        
        print("🔍 Found \(modifiedDayIds.count) user-modified days to preserve")
        
        // For MVP, this is the same as simple regeneration
        // In a full implementation, we would regenerate only unmodified days
        await regeneratePlan()
    }
    
    // MARK: - Plan Modification Methods
    
    /// Update a day in the suggested plan
    func updateSuggestedDay(_ dayId: UUID, with newDay: Day) {
        guard let suggested = suggestedPlan else {
            print("❌ No suggested plan to update")
            return
        }
        
        suggestedPlan = suggested.withModifiedDay(dayId, newDay: newDay)
        print("✅ Updated day \(newDay.dayNumber) in suggested plan")
    }
    
    /// Delete an exercise from a day in the suggested plan
    func deleteExerciseFromSuggestedDay(dayId: UUID, exerciseId: UUID) {
        guard var suggested = suggestedPlan else {
            print("❌ No suggested plan to update")
            return
        }
        
        // Find and update the day
        for dayIndex in suggested.days.indices {
            if suggested.days[dayIndex].id == dayId {
                suggested.days[dayIndex].exercises.removeAll { $0.id == exerciseId }
                
                // Prevent empty days
                if suggested.days[dayIndex].exercises.isEmpty {
                    print("⚠️ Cannot delete last exercise from day")
                    showErrorMessage("Each day must have at least one exercise")
                    return
                }
                
                suggestedPlan = suggested
                print("✅ Deleted exercise from suggested plan")
                return
            }
        }
    }
    
    /// Add an exercise to a day in the suggested plan
    func addExerciseToSuggestedDay(dayId: UUID, exercise: Exercise) {
        guard var suggested = suggestedPlan else {
            print("❌ No suggested plan to update")
            return
        }
        
        // Find and update the day
        for dayIndex in suggested.days.indices {
            if suggested.days[dayIndex].id == dayId {
                suggested.days[dayIndex].exercises.append(exercise)
                suggestedPlan = suggested
                print("✅ Added exercise to suggested plan")
                return
            }
        }
    }
    
    /// Update an exercise in a day in the suggested plan
    func updateExerciseInSuggestedDay(dayId: UUID, oldExerciseId: UUID, newExercise: Exercise) {
        guard var suggested = suggestedPlan else {
            print("❌ No suggested plan to update")
            return
        }
        
        // Find and update the exercise
        for dayIndex in suggested.days.indices {
            if suggested.days[dayIndex].id == dayId {
                for exerciseIndex in suggested.days[dayIndex].exercises.indices {
                    if suggested.days[dayIndex].exercises[exerciseIndex].id == oldExerciseId {
                        // Replace with new exercise (keeping the same ID would be complex)
                        suggested.days[dayIndex].exercises[exerciseIndex] = Exercise(
                            name: newExercise.name,
                            sets: newExercise.sets,
                            reps: newExercise.reps
                        )
                        
                        suggestedPlan = suggested
                        print("✅ Updated exercise in suggested plan")
                        return
                    }
                }
            }
        }
        
        print("❌ Failed to find exercise to update")
    }
    
    /// Reset a day to its original AI-generated state
    func resetSuggestedDayToOriginal(dayId: UUID) {
        guard let suggested = suggestedPlan,
              let original = originalPlan else {
            print("❌ No plans available for day reset")
            showErrorMessage("Cannot reset day - original plan not available")
            return
        }
        
        // Find the corresponding day in the original plan
        guard let dayIndex = suggested.days.firstIndex(where: { $0.id == dayId }),
              dayIndex < original.days.count else {
            print("❌ Cannot find day to reset")
            showErrorMessage("Cannot find the original version of this day")
            return
        }
        
        let originalDay = original.days[dayIndex]
        
        // Create a new day with the original exercises but keeping the same ID
        let resetDay = Day(
            dayNumber: originalDay.dayNumber,
            date: originalDay.date,
            exercises: originalDay.exercises
        )
        
        // Update the suggested plan
        suggestedPlan = suggested.withModifiedDay(dayId, newDay: resetDay)
        
        print("🔄 Reset day \(originalDay.dayNumber) to original AI suggestion")
    }
    
    // MARK: - Active Plan Management
    
    /// Load plan from storage
    func loadSavedPlan() {
        if let savedPlan = storageService.loadWorkoutPlan() {
            // Only load if it's an active plan
            if savedPlan.isActive {
                currentPlan = savedPlan
                print("📱 Loaded saved active workout plan")
            } else {
                print("📱 Found suggested plan in storage, clearing it")
                storageService.clearWorkoutPlan()
            }
        } else {
            print("📱 No saved plan found")
        }
    }
    
    /// Update exercise completion in active plan
    func toggleExerciseCompletion(dayId: UUID, exerciseId: UUID) {
        guard var plan = currentPlan, plan.isActive else {
            print("❌ No active plan found")
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
        let newPlan = WorkoutPlan(userGoals: goals, days: days, status: .active)
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
        let samplePlan = SampleData.sampleWorkoutPlan.makeActive()
        currentPlan = samplePlan
        storageService.saveWorkoutPlan(samplePlan)
        print("🧪 Loaded sample data for testing")
    }
    
    // MARK: - Helper Methods
    
    /// Get a specific day from active plan
    func getDay(by id: UUID) -> Day? {
        return currentPlan?.days.first { $0.id == id }
    }
    
    /// Get a specific day from suggested plan
    func getSuggestedDay(by id: UUID) -> Day? {
        return suggestedPlan?.days.first { $0.id == id }
    }
    
    /// Get a specific exercise from active plan
    func getExercise(dayId: UUID, exerciseId: UUID) -> Exercise? {
        guard let day = getDay(by: dayId) else { return nil }
        return day.exercises.first { $0.id == exerciseId }
    }
    
    /// Check if user has an active plan
    var hasActivePlan: Bool {
        return currentPlan?.isActive == true
    }
    
    /// Check if user has a suggested plan
    var hasSuggestedPlan: Bool {
        return suggestedPlan?.isSuggested == true
    }
    
    /// Get progress information for active plan
    var progressInfo: (completed: Int, total: Int, percentage: Double) {
        guard let plan = currentPlan, plan.isActive else { return (0, 0, 0) }
        return (plan.completedDays, plan.days.count, plan.progressPercentage)
    }
    
    /// Compare two days for equality (for detecting user modifications)
    private func daysAreEqual(_ day1: Day, _ day2: Day) -> Bool {
        guard day1.exercises.count == day2.exercises.count else { return false }
        
        for (index, exercise1) in day1.exercises.enumerated() {
            let exercise2 = day2.exercises[index]
            if exercise1.name != exercise2.name ||
               exercise1.sets != exercise2.sets ||
               exercise1.reps != exercise2.reps {
                return false
            }
        }
        
        return true
    }
    
    // MARK: - Error Handling
    
    func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    /// Clear error state
    func clearError() {
        errorMessage = nil
        showError = false
    }
}
