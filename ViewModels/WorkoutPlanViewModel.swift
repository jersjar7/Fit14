//
//  WorkoutPlanViewModel.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//  Updated to use Google Gemini API and structured UserGoalData with essential chips only
//  Enhanced with start date support and challenge history management
//  UPDATED: Cleaned up completion flow - removed UI timing logic, single archiving responsibility
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
    
    // MARK: - Challenge History Properties
    @Published var completedChallenges: [CompletedChallenge] = []
    @Published var isLoadingHistory = false
    
    // MARK: - Goal Input Management
    @Published var userGoalData = UserGoalData() // Structured goal data with essential chips
    @Published var isGoalInputActive = false     // Whether user is actively inputting goals
    
    // MARK: - Services
    private let storageService = LocalStorageService()
    private let aiService = AIWorkoutGenerationService()
    
    init() {
        loadSavedPlan()
        loadChallengeHistory()
    }
    
    // MARK: - Challenge History Management
    
    /// Load completed challenges from storage
    func loadChallengeHistory() {
        isLoadingHistory = true
        
        Task { @MainActor in
            do {
                let challenges = storageService.loadCompletedChallenges()
                self.completedChallenges = challenges.sorted { $0.completionDate > $1.completionDate }
                print("📚 Loaded \(challenges.count) completed challenges")
            } catch {
                print("❌ Failed to load challenge history: \(error)")
                // Don't show error to user for history loading failure
                self.completedChallenges = []
            }
            
            self.isLoadingHistory = false
        }
    }
    
    /// Archive the current completed plan as a challenge (PURE DATA OPERATION)
    func archiveCompletedPlan() {
        guard let plan = currentPlan, plan.isCompleted else {
            print("❌ Cannot archive plan - plan is not completed")
            return
        }
        
        print("📁 Archiving completed plan...")
        
        // Create completed challenge from the plan
        let completedChallenge = CompletedChallenge(from: plan)
        
        // Add to memory
        completedChallenges.insert(completedChallenge, at: 0) // Add at beginning (most recent first)
        
        // Save to storage
        do {
            try storageService.saveCompletedChallenge(completedChallenge)
            print("✅ Successfully archived challenge: \(completedChallenge.challengeTitle)")
            print("📊 Final stats: \(completedChallenge.completedDays)/\(completedChallenge.totalDays) days (\(Int(completedChallenge.successRate))%)")
        } catch {
            print("❌ Failed to save archived challenge: \(error)")
            // Remove from memory if save failed
            completedChallenges.removeFirst()
            showErrorMessage("Failed to save your completed challenge")
        }
    }
    
    /// Clear current plan (separate operation from archiving)
    func clearCurrentPlan() {
        currentPlan = nil
        storageService.clearWorkoutPlan()
        print("🗑️ Cleared current plan")
    }
    
    /// Force archive current plan (even if not 100% complete) - for edge cases
    func forceArchiveCurrentPlan() {
        guard let plan = currentPlan else {
            print("❌ No current plan to archive")
            return
        }
        
        print("🔄 Force archiving current plan...")
        
        // Create completed challenge from current state
        let completedChallenge = CompletedChallenge(from: plan)
        
        // Add to memory
        completedChallenges.insert(completedChallenge, at: 0)
        
        // Save to storage
        do {
            try storageService.saveCompletedChallenge(completedChallenge)
            print("✅ Force archived challenge with \(completedChallenge.completedDays)/\(completedChallenge.totalDays) days completed")
        } catch {
            print("❌ Failed to force archive challenge: \(error)")
            // Remove from memory if save failed
            completedChallenges.removeFirst()
            showErrorMessage("Failed to archive your challenge")
        }
    }
    
    /// Delete a completed challenge from history
    func deleteCompletedChallenge(_ challenge: CompletedChallenge) {
        print("🔍 Starting deletion for challenge: \(challenge.challengeTitle)")
        print("🔍 Challenge ID: \(challenge.id)")
        
        guard let index = completedChallenges.firstIndex(where: { $0.id == challenge.id }) else {
            print("❌ Challenge not found in history")
            showErrorMessage("Challenge not found in history")
            return
        }
        
        // Remove from memory
        completedChallenges.remove(at: index)
        print("✅ Removed from memory, new count: \(completedChallenges.count)")
        
        // Remove from storage
        do {
            try storageService.deleteCompletedChallenge(challenge.id)
            print("✅ Successfully deleted from storage: \(challenge.challengeTitle)")
            
        } catch {
            print("❌ Failed to delete challenge from storage: \(error)")
            // Re-add to memory if delete failed
            completedChallenges.insert(challenge, at: index)
            showErrorMessage("Failed to delete challenge: \(error.localizedDescription)")
        }
    }
    
    /// Get a specific completed challenge by ID
    func getCompletedChallenge(by id: UUID) -> CompletedChallenge? {
        return completedChallenges.first { $0.id == id }
    }
    
    /// Get challenge history statistics
    var historyStats: (totalChallenges: Int, averageSuccessRate: Double, totalDaysCompleted: Int) {
        let totalChallenges = completedChallenges.count
        guard totalChallenges > 0 else { return (0, 0.0, 0) }
        
        let totalSuccessRate = completedChallenges.reduce(0.0) { $0 + $1.successRate }
        let averageSuccessRate = totalSuccessRate / Double(totalChallenges)
        
        let totalDaysCompleted = completedChallenges.reduce(0) { $0 + $1.completedDays }
        
        return (totalChallenges, averageSuccessRate, totalDaysCompleted)
    }
    
    /// Check if user has any completed challenges
    var hasCompletedChallenges: Bool {
        return !completedChallenges.isEmpty
    }
    
    /// Get most recent completed challenge
    var mostRecentChallenge: CompletedChallenge? {
        return completedChallenges.first
    }
    
    /// Get challenges completed in the last 30 days
    var recentChallenges: [CompletedChallenge] {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return completedChallenges.filter { $0.completionDate >= thirtyDaysAgo }
    }
    
    /// Check if current plan should show completion prompt. Handles both completion and finish scenarios
    var shouldShowCompletionPrompt: Bool {
        guard let plan = currentPlan else { return false }
        return (plan.isCompleted || plan.isFinished) && plan.isActive
    }
    
    // MARK: - Enhanced Completion Calculations
    
    /// Get detailed progress for current plan including exercise-level completion
    var detailedProgress: (dayProgress: Double, exerciseProgress: Double, overallHealth: String) {
        guard let plan = currentPlan else { return (0.0, 0.0, "No Active Plan") }
        
        let dayProgress = plan.progressPercentage
        let exerciseProgress = plan.exerciseCompletionPercentage
        
        // Calculate overall health message
        let overallHealth: String
        if dayProgress >= 90 && exerciseProgress >= 90 {
            overallHealth = "Excellent Progress!"
        } else if dayProgress >= 70 && exerciseProgress >= 70 {
            overallHealth = "Good Progress"
        } else if dayProgress >= 50 || exerciseProgress >= 50 {
            overallHealth = "Making Progress"
        } else {
            overallHealth = "Getting Started"
        }
        
        return (dayProgress, exerciseProgress, overallHealth)
    }
    
    /// Get current streak information
    var currentStreak: (days: Int, isActive: Bool) {
        guard let plan = currentPlan else { return (0, false) }
        
        // Count consecutive completed days from the beginning
        var streak = 0
        for day in plan.days.sorted(by: { $0.dayNumber < $1.dayNumber }) {
            if day.isCompleted {
                streak += 1
            } else {
                break
            }
        }
        
        let isActive = streak > 0
        return (streak, isActive)
    }
    
    /// Get completion momentum (trend over last few days)
    var completionMomentum: String {
        guard let plan = currentPlan, plan.days.count >= 3 else { return "Not enough data" }
        
        let sortedDays = plan.days.sorted { $0.dayNumber < $1.dayNumber }
        let recentDays = Array(sortedDays.suffix(3))
        let completedRecent = recentDays.filter { $0.isCompleted }.count
        
        switch completedRecent {
        case 3: return "Strong momentum! 🔥"
        case 2: return "Good momentum 📈"
        case 1: return "Building momentum"
        default: return "Need to rebuild momentum"
        }
    }
    
    /// Check if current plan has finished its time period and auto-archive
    @MainActor
    func checkForFinishedPlan() {
        guard let plan = currentPlan,
              plan.isActive,
              plan.isFinished else { return }
        
        print("📅 Plan time period ended - auto-archiving with \(plan.completedDays)/\(plan.totalDays) days completed")
        
        // Auto-archive the finished plan (regardless of completion percentage)
        archiveCompletedPlan()
        
        // Show a different message for auto-archived vs manually completed plans
        if plan.isCompleted {
            print("🏆 Plan completed with 100% success!")
        } else {
            let percentage = Int(plan.progressPercentage)
            print("📊 Plan finished with \(percentage)% completion")
        }
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
            print("🚀 Starting Gemini AI plan generation with essential chip data...")
            print("📊 Data completeness: \(Int(userGoalData.completenessScore * 100))%")
            print("📝 Selected essential chips: \(userGoalData.selectedChips.count)")
            print("📅 Start date: \(userGoalData.hasExplicitStartDate ? userGoalData.startDateDisplayText + " (explicit)" : "No explicit date - will parse from text")")
            
            // Build enhanced prompt with structured data
            let prompt = AIPrompts.buildWorkoutPrompt(from: userGoalData)
            let newPlan = try await aiService.generateWorkoutPlan(from: prompt)
            
            print("✅ Successfully generated plan using essential chip data")
            
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
        print("💰 Updated essential chip: \(chipData.type.displayTitle) -> \(chipData.selectedText ?? "none")")
    }
    
    // MARK: - Start Date Management
    
    /// Update the explicit start date in goal data
    func updateStartDate(_ date: Date?) {
        userGoalData.updateStartDate(date)
        if let date = date {
            print("📅 Updated start date: \(userGoalData.startDateDisplayText) (\(userGoalData.startDateForPrompt))")
        } else {
            print("📅 Cleared explicit start date")
        }
    }
    
    /// Clear the explicit start date
    func clearStartDate() {
        updateStartDate(nil)
    }
    
    /// Get the selected start date (or default to today)
    var selectedStartDate: Date {
        return userGoalData.getSelectedStartDate()
    }
    
    /// Whether user has explicitly selected a start date
    var hasExplicitStartDate: Bool {
        return userGoalData.hasExplicitStartDate
    }
    
    /// Get user-friendly display text for start date
    var startDateDisplayText: String {
        return userGoalData.startDateDisplayText
    }
    
    /// Get formatted start date for AI prompt
    var startDateForPrompt: String {
        return userGoalData.startDateForPrompt
    }
    
    // MARK: - Smart Suggestions & Data Quality
    
    /// Get smart suggestions for essential chips based on current text
    var suggestedChips: [ChipType] {
        let smartDefaults = userGoalData.getSmartSuggestions()
        return Array(smartDefaults.keys)
    }
    
    /// Get smart chip defaults for auto-filling
    var smartChipDefaults: [ChipType: ChipOption] {
        return userGoalData.getSmartSuggestions()
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
    
    /// Get visible chips for display (all essential chips are visible)
    var visibleChips: [ChipData] {
        return userGoalData.visibleChips.sortedForDisplay
    }
    
    /// Get selected chips for display
    var selectedChips: [ChipData] {
        return userGoalData.selectedChips
    }
    
    /// Get natural language info that's mentioned in the goal text
    var naturallyMentionedInfo: [String] {
        return userGoalData.naturallyMentionedInfo
    }
    
    /// Check if goal text contains important constraints that will help the AI
    var hasImportantConstraints: Bool {
        return userGoalData.containsImportantConstraints
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
        
        print("🔄 Regenerating plan using essential chip data...")
        print("📅 Start date for regeneration: \(startDateDisplayText)")
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
            
            // Check if plan is now completed and should be archived
            if plan.isCompleted {
                print("🎉 Plan completed! Ready for archiving.")
                // Note: We don't auto-archive here, let the UI handle the completion flow
            }
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
    
    /// Start a new challenge - UI should handle archiving first
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
    
    // MARK: - Essential Chip Management Helpers
    
    /// Apply smart defaults to essential chips based on current text
    func applySmartDefaults() {
        let smartDefaults = ChipConfiguration.getSmartDefaults(for: userGoalData.freeFormText)
        
        for (chipType, option) in smartDefaults {
            // Only apply if chip isn't already selected
            if !userGoalData.isChipSelected(chipType) {
                let chipData = ChipConfiguration.createChipData(for: chipType)
                var updatedChip = chipData
                updatedChip.select(option: option)
                userGoalData.updateChip(updatedChip)
                print("🤖 Applied smart default for \(chipType.displayTitle): \(option.displayText)")
            }
        }
    }
    
    /// Get critical chips that need immediate attention
    var criticalChipsNeeded: [ChipType] {
        return ChipType.criticalTypes.filter { !userGoalData.isChipSelected($0) }
    }
    
    /// Check if all critical essential chips are completed
    var hasCriticalChips: Bool {
        return criticalChipsNeeded.isEmpty
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
        - Completed Challenges: \(completedChallenges.count)
        
        Challenge History:
        - Total Challenges: \(historyStats.totalChallenges)
        - Average Success Rate: \(String(format: "%.1f", historyStats.averageSuccessRate))%
        - Total Days Completed: \(historyStats.totalDaysCompleted)
        - Has Recent Challenges: \(recentChallenges.count)
        
        Current Plan Progress:
        - Day Progress: \(String(format: "%.1f", detailedProgress.dayProgress))%
        - Exercise Progress: \(String(format: "%.1f", detailedProgress.exerciseProgress))%
        - Health Status: \(detailedProgress.overallHealth)
        - Current Streak: \(currentStreak.days) days (\(currentStreak.isActive ? "active" : "inactive"))
        - Momentum: \(completionMomentum)
        
        Start Date Information:
        - Has Explicit Start Date: \(hasExplicitStartDate)
        - Start Date Display: \(startDateDisplayText)
        - Start Date for Prompt: \(startDateForPrompt)
        - Selected Date: \(selectedStartDate)
        
        Essential Chip Data:
        - Completeness: \(Int(userGoalData.completenessScore * 100))%
        - Selected Chips: \(userGoalData.selectedChips.count)
        - Critical Chips Needed: \(criticalChipsNeeded.count)
        - Sufficient for AI: \(userGoalData.isSufficientForAI)
        - Has Important Constraints: \(hasImportantConstraints)
        - Text Length: \(userGoalData.freeFormText.count) chars
        
        Natural Info Mentioned: \(naturallyMentionedInfo.joined(separator: ", "))
        
        \(AIPrompts.debugPromptGeneration(from: userGoalData))
        """
    }
    
    // MARK: - Sheets Helpers
    
      /// Get contextual completion message based on user's challenge history
      var contextualCompletionMessage: String {
          let completionCount = completedChallenges.count

          switch completionCount {
          case 1:
              return "🎉 Congratulations on completing your first 2-week challenge!\n\n You've just proven to yourself that you can commit to and achieve your fitness goals. This is just the beginning of your journey!"
          case 2:
              return "🔥 Amazing! You've completed your second challenge!\n\n You're building real momentum now. Consistency is the key to lasting results, and you're proving you have what it takes."
          case 3:
              return "💪 Incredible! Three challenges completed!\n\n You're developing serious fitness habits. Each challenge builds on the last - you're becoming unstoppable!"
          case 4...5:
              return "🏆 Outstanding! You've completed \(completionCount) challenges!\n\n You're officially a fitness champion. Your dedication is inspiring - keep this incredible streak going!"
          default: // 6+
              return "🌟 WOW! \(completionCount) challenges completed!\n\n You're a true fitness warrior! Your consistency and dedication are exceptional. You've built habits that will last a lifetime!"
          }
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
