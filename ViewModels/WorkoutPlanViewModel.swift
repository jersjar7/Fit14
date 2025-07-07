//
//  WorkoutPlanViewModel.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//  Updated to use Google Gemini API and structured UserGoalData
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
    
    // MARK: - Goal Input Management
    @Published var userGoalData = UserGoalData() // Structured goal data with chips
    @Published var isGoalInputActive = false     // Whether user is actively inputting goals
    
    // MARK: - Services
    private let storageService = LocalStorageService()
    private let aiService = AIWorkoutGenerationService()
    
    init() {
        loadSavedPlan()
    }
    
    // MARK: - AI Plan Generation
    
    /// Generate workout plan from structured UserGoalData
    @MainActor
    func generatePlanFromGoals() async {
        // Validate that we have sufficient data
        guard userGoalData.isSufficientForAI else {
            let issues = userGoalData.validationIssues
            showGoalInputError("Please complete your goal information:", suggestions: issues)
            return
        }
        
        isGenerating = true
        errorMessage = nil
        
        do {
            print("🚀 Starting Gemini AI plan generation with structured data...")
            print("📊 Data completeness: \(Int(userGoalData.completenessScore * 100))%")
            print("📝 Selected chips: \(userGoalData.selectedChips.count)")
            
            // Build enhanced prompt with structured data
            let prompt = AIPrompts.buildWorkoutPrompt(from: userGoalData)
            let newPlan = try await aiService.generateWorkoutPlan(from: prompt)
            
            print("✅ Successfully generated plan using structured data")
            
            // Set as suggested plan (NOT current plan)
            suggestedPlan = newPlan
            // Keep a copy of the original for reset functionality
            originalPlan = newPlan
            
            print("✅ Successfully generated suggested workout plan")
            
        } catch let aiError as AIServiceError {
            print("❌ Gemini API failed: \(aiError.localizedDescription)")
            showErrorMessage(aiError.localizedDescription ?? "Failed to generate workout plan. Please try again.")
        } catch {
            print("❌ Unexpected Error in plan generation: \(error.localizedDescription)")
            showErrorMessage("An unexpected error occurred while generating your workout plan. Please check your internet connection and try again.")
        }
        
        isGenerating = false
    }
    
    // MARK: - Goal Input Management
    
    /// Start the goal input process
    func startGoalInput() {
        userGoalData = UserGoalData()
        isGoalInputActive = true
        clearError()
        print("🎯 Started goal input process")
    }
    
    /// Update the free-form text in goal data
    func updateGoalText(_ text: String) {
        userGoalData.updateFreeFormText(text)
        print("📝 Updated goal text: \(text.count) characters")
    }
    
    /// Update a chip selection in goal data
    func updateChipSelection(_ chipData: ChipData) {
        userGoalData.updateChip(chipData)
        print("💰 Updated chip: \(chipData.type.displayTitle) -> \(chipData.selectedText ?? "none")")
    }
    
    /// Get suggested chips based on current text
    var suggestedChips: [ChipType] {
        return userGoalData.suggestedChipTypesByRelevance
    }
    
    /// Get data quality for current goals
    var goalDataQuality: DataQualityAssessment {
        return AIPrompts.assessDataQuality(userGoalData)
    }
    
    /// Check if ready to generate plan
    var canGeneratePlan: Bool {
        return userGoalData.isSufficientForAI && !isGenerating
    }
    
    /// Get completion status for goal input
    var goalInputCompletion: (percentage: Int, message: String) {
        let percentage = Int(userGoalData.completenessScore * 100)
        let quality = goalDataQuality
        return (percentage, quality.displayMessage)
    }
    
    /// Get visible chips for display
    var visibleChips: [ChipData] {
        return userGoalData.visibleChips.sortedForDisplay
    }
    
    /// Get selected chips for display
    var selectedChips: [ChipData] {
        return userGoalData.selectedChips
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
        
        // Reset goal input state since plan is now active
        isGoalInputActive = false
        
        // Save the active plan
        storageService.saveWorkoutPlan(activePlan)
        
        print("✅ Accepted suggested plan and made it active")
    }
    
    /// Reject the suggested plan and clear it
    func rejectSuggestedPlan() {
        suggestedPlan = nil
        originalPlan = nil
        // Keep goal data for potential regeneration
        print("🗑️ Rejected suggested plan")
    }
    
    /// Start over - clear both suggested and active plans
    func startOver() {
        suggestedPlan = nil
        originalPlan = nil
        currentPlan = nil
        userGoalData = UserGoalData()
        isGoalInputActive = false
        storageService.clearWorkoutPlan()
        errorMessage = nil
        print("🔄 Started over - cleared all plans and goal data")
    }
    
    /// Enhanced regeneration with structured data
    @MainActor
    func regeneratePlan() async {
        guard suggestedPlan != nil else {
            print("❌ No suggested plan to regenerate")
            showErrorMessage("No plan available to regenerate")
            return
        }
        
        guard userGoalData.isSufficientForAI else {
            showErrorMessage("Cannot regenerate - insufficient goal data")
            return
        }
        
        print("🔄 Regenerating plan using structured data...")
        isGenerating = true
        
        do {
            let prompt = AIPrompts.regenerationPrompt(from: userGoalData)
            let newPlan = try await aiService.generateWorkoutPlan(from: prompt)
            print("✅ Successfully regenerated plan")
            
            // Replace suggested plan with new generation
            suggestedPlan = newPlan
            originalPlan = newPlan
            
            print("✅ Successfully regenerated workout plan")
            
        } catch let aiError as AIServiceError {
            print("❌ Gemini API failed during regeneration: \(aiError.localizedDescription)")
            showErrorMessage(aiError.localizedDescription ?? "Failed to regenerate workout plan. Please try again.")
        } catch {
            print("❌ Unexpected Error during regeneration: \(error.localizedDescription)")
            showErrorMessage("An unexpected error occurred while regenerating your workout plan. Please check your internet connection and try again.")
        }
        
        isGenerating = false
    }
    
    /// Regenerate plan preserving user modifications
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
        guard let suggested = suggestedPlan else {
            print("❌ No suggested plan to update")
            return
        }
        
        // Check if this would leave the day empty
        if let day = suggested.days.first(where: { $0.id == dayId }),
           day.exercises.count <= 1 {
            print("⚠️ Cannot delete last exercise from day")
            showErrorMessage("Each day must have at least one exercise")
            return
        }
        
        // Remove the exercise using the WorkoutPlan method
        suggestedPlan = suggested.withExerciseRemoved(from: dayId, exerciseId: exerciseId)
        print("✅ Deleted exercise from suggested plan")
    }
    
    /// Add an exercise to a day in the suggested plan
    func addExerciseToSuggestedDay(dayId: UUID, exercise: Exercise) {
        guard let suggested = suggestedPlan else {
            print("❌ No suggested plan to update")
            return
        }
        
        // Add the exercise using the WorkoutPlan method
        suggestedPlan = suggested.withExerciseAdded(to: dayId, exercise: exercise)
        print("✅ Added exercise to suggested plan")
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
                        // Update exercise while preserving the original ID
                        let originalExercise = suggested.days[dayIndex].exercises[exerciseIndex]
                        suggested.days[dayIndex].exercises[exerciseIndex] = originalExercise.updated(
                            name: newExercise.name,
                            sets: newExercise.sets,
                            quantity: newExercise.quantity,
                            unit: newExercise.unit
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
        
        // Find the corresponding day in both plans
        guard let suggestedDayIndex = suggested.days.firstIndex(where: { $0.id == dayId }),
              suggestedDayIndex < original.days.count else {
            print("❌ Cannot find day to reset")
            showErrorMessage("Cannot find the original version of this day")
            return
        }
        
        let originalDay = original.days[suggestedDayIndex]
        let currentDay = suggested.days[suggestedDayIndex]
        
        // Create reset day preserving the current day's ID and structure
        let resetDay = currentDay.updated(exercises: originalDay.exercises)
        
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
    
    /// Start fresh (clear current plan)
    func startFresh() {
        storageService.clearWorkoutPlan()
        currentPlan = nil
        errorMessage = nil
        print("🗑️ Started fresh - cleared current plan")
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
               exercise1.quantity != exercise2.quantity ||
               exercise1.unit != exercise2.unit {
                return false
            }
        }
        
        return true
    }
    
    // MARK: - 2-Week Focus & Plan Completion
    
    /// Get next challenge suggestions when a plan is completed
    func getNextChallengeSuggestions() -> [String] {
        guard let completedPlan = currentPlan, completedPlan.isCompleted else {
            return ["Complete your current plan first to unlock next challenge suggestions!"]
        }
        
        return AIPrompts.getNextChallengeSuggestions(from: userGoalData)
    }
    
    /// Start a new challenge based on completed plan
    func startNewChallenge() {
        guard let completedPlan = currentPlan, completedPlan.isCompleted else {
            showErrorMessage("Complete your current plan before starting a new challenge")
            return
        }
        
        // Keep some context from the completed plan for progression
        let previousGoalData = userGoalData
        userGoalData = UserGoalData()
        userGoalData.updateFreeFormText("Building on my previous 2-week challenge success...")
        
        // Clear current plan and start goal input
        currentPlan = nil
        storageService.clearWorkoutPlan()
        startGoalInput()
        
        print("🎯 Started new challenge based on completed plan")
    }
    
    /// Get motivational message for plan completion
    var planCompletionMessage: String? {
        guard let plan = currentPlan, plan.isCompleted else { return nil }
        return AIPrompts.getTwoWeekCompletionMessage()
    }
    
    // MARK: - Debug and Analytics
    
    /// Get debug information about current state
    var debugInfo: String {
        return """
        === WORKOUT PLAN VIEW MODEL DEBUG ===
        
        State:
        - Has Active Plan: \(hasActivePlan)
        - Has Suggested Plan: \(hasSuggestedPlan)
        - Is Generating: \(isGenerating)
        - Goal Input Active: \(isGoalInputActive)
        
        Goal Data:
        - Completeness: \(Int(userGoalData.completenessScore * 100))%
        - Selected Chips: \(userGoalData.selectedChips.count)
        - Sufficient for AI: \(userGoalData.isSufficientForAI)
        - Text Length: \(userGoalData.freeFormText.count) chars
        
        \(AIPrompts.debugPromptGeneration(from: userGoalData))
        """
    }
    
    // MARK: - Error Handling
    
    func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
        print("❌ Error: \(message)")
    }
    
    /// Clear error state
    func clearError() {
        errorMessage = nil
        showError = false
    }
    
    /// Show goal-specific error with suggestions
    func showGoalInputError(_ message: String, suggestions: [String] = []) {
        var fullMessage = message
        if !suggestions.isEmpty {
            fullMessage += "\n\n• " + suggestions.joined(separator: "\n• ")
        }
        showErrorMessage(fullMessage)
    }
}
