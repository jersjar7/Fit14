//
//  LocalStorageService.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//  Enhanced with completed challenge storage management
//  UPDATED: Strengthened duplicate prevention and archiving safety
//

import Foundation

class LocalStorageService: ObservableObject {
    private let userDefaults = UserDefaults.standard
    private let workoutPlanKey = "currentWorkoutPlan"
    private let completedChallengesKey = "completedChallenges"
    private let dataVersionKey = "dataSchemaVersion"
    
    // Current data schema version - increment when making breaking changes
    private let currentDataVersion = 2
    
    // Thread safety for challenge archiving
    private let archivingQueue = DispatchQueue(label: "com.fit14.archiving", qos: .userInitiated)
    
    init() {
        checkAndMigrateData()
    }
    
    // MARK: - Data Migration and Compatibility
    
    /// Check if stored data is compatible and migrate/clear if needed
    private func checkAndMigrateData() {
        let storedVersion = userDefaults.integer(forKey: dataVersionKey)
        
        if storedVersion == 0 {
            // First launch or very old version - clear everything to be safe
            print("🔧 First launch or legacy data detected - clearing storage")
            clearAllData()
            userDefaults.set(currentDataVersion, forKey: dataVersionKey)
        } else if storedVersion < currentDataVersion {
            // Data format changed - clear incompatible data
            print("🔧 Data schema upgraded from v\(storedVersion) to v\(currentDataVersion) - clearing storage")
            clearAllData()
            userDefaults.set(currentDataVersion, forKey: dataVersionKey)
        } else if storedVersion > currentDataVersion {
            // Somehow we have newer data than current app version - clear to be safe
            print("⚠️ Found newer data version (\(storedVersion)) than supported (\(currentDataVersion)) - clearing storage")
            clearAllData()
            userDefaults.set(currentDataVersion, forKey: dataVersionKey)
        } else {
            print("✅ Data schema version \(currentDataVersion) is current")
        }
    }
    
    /// Clear all app data (for major migrations)
    private func clearAllData() {
        userDefaults.removeObject(forKey: workoutPlanKey)
        userDefaults.removeObject(forKey: completedChallengesKey)
        print("🗑️ All workout data cleared due to compatibility issues")
    }
    
    // MARK: - Workout Plan Storage
    
    /// Save workout plan to local storage
    func saveWorkoutPlan(_ plan: WorkoutPlan) {
        do {
            let encoded = try JSONEncoder().encode(plan)
            userDefaults.set(encoded, forKey: workoutPlanKey)
            print("✅ Workout plan saved successfully")
        } catch {
            print("❌ Failed to save workout plan: \(error)")
        }
    }
    
    /// Load workout plan from local storage with compatibility checking
    func loadWorkoutPlan() -> WorkoutPlan? {
        guard let data = userDefaults.data(forKey: workoutPlanKey) else {
            print("📱 No saved workout plan found")
            return nil
        }
        
        do {
            let plan = try JSONDecoder().decode(WorkoutPlan.self, from: data)
            print("✅ Workout plan loaded successfully")
            
            // Validate the loaded plan has the expected structure
            if validateWorkoutPlan(plan) {
                return plan
            } else {
                print("⚠️ Loaded plan failed validation - clearing incompatible data")
                clearWorkoutPlan()
                return nil
            }
            
        } catch let decodingError as DecodingError {
            print("❌ Failed to load workout plan due to format change: \(decodingError)")
            handleDecodingError(decodingError)
            return nil
        } catch {
            print("❌ Failed to load workout plan: \(error)")
            clearWorkoutPlan()
            return nil
        }
    }
    
    /// Validate that a loaded workout plan has the expected structure
    private func validateWorkoutPlan(_ plan: WorkoutPlan) -> Bool {
        // Check if plan has basic required structure
        guard !plan.days.isEmpty else {
            print("⚠️ Plan validation failed: no days")
            return false
        }
        
        // Check if exercises have the new "quantity" field structure
        for day in plan.days {
            for exercise in day.exercises {
                // Basic validation - ensure exercises have positive values
                if exercise.sets <= 0 || exercise.quantity <= 0 {
                    print("⚠️ Plan validation failed: invalid exercise values")
                    return false
                }
                
                // Ensure unit is valid
                if !["reps", "seconds", "minutes"].contains(exercise.unit.rawValue) {
                    print("⚠️ Plan validation failed: invalid exercise unit")
                    return false
                }
            }
        }
        
        print("✅ Workout plan validation passed")
        return true
    }
    
    /// Handle specific decoding errors and clear data if it's incompatible
    private func handleDecodingError(_ error: DecodingError) {
        switch error {
        case .keyNotFound(let key, _):
            if key.stringValue == "quantity" {
                print("🔧 Old data format detected (missing 'quantity' field) - clearing storage")
                clearWorkoutPlan()
            } else {
                print("❌ Missing key '\(key.stringValue)' - data may be corrupted")
                clearWorkoutPlan()
            }
        case .typeMismatch(_, let context):
            print("❌ Type mismatch in stored data at \(context.codingPath) - clearing storage")
            clearWorkoutPlan()
        case .valueNotFound(_, let context):
            print("❌ Missing value in stored data at \(context.codingPath) - clearing storage")
            clearWorkoutPlan()
        case .dataCorrupted(let context):
            print("❌ Data corrupted: \(context.debugDescription) - clearing storage")
            clearWorkoutPlan()
        @unknown default:
            print("❌ Unknown decoding error - clearing storage")
            clearWorkoutPlan()
        }
    }
    
    // MARK: - Completed Challenges Storage (Thread-Safe Archiving)
    
    /// Save a completed challenge to storage with enhanced duplicate prevention
    func saveCompletedChallenge(_ challenge: CompletedChallenge) throws {
        return try archivingQueue.sync {
            do {
                print("📁 Starting challenge archiving process for: \(challenge.challengeTitle)")
                
                // Load existing challenges
                var challenges = loadCompletedChallenges()
                let originalCount = challenges.count
                
                // Enhanced duplicate checking - check both ID and completion date to be extra safe
                if let existingIndex = challenges.firstIndex(where: { $0.id == challenge.id }) {
                    let existingChallenge = challenges[existingIndex]
                    
                    // Check if it's truly the same challenge completion
                    if abs(existingChallenge.completionDate.timeIntervalSince(challenge.completionDate)) < 60 {
                        print("🔄 Updating existing challenge (same completion): \(challenge.challengeTitle)")
                        challenges[existingIndex] = challenge
                    } else {
                        print("⚠️ Found challenge with same ID but different completion date - this may indicate a duplicate archiving attempt")
                        print("   Existing: \(existingChallenge.completionDate)")
                        print("   New: \(challenge.completionDate)")
                        // Still update to be safe, but log the potential issue
                        challenges[existingIndex] = challenge
                    }
                } else {
                    // Double-check for duplicates by comparing multiple fields
                    let potentialDuplicates = challenges.filter { existing in
                        existing.challengeTitle == challenge.challengeTitle &&
                        abs(existing.completionDate.timeIntervalSince(challenge.completionDate)) < 3600 && // Within 1 hour
                        existing.totalDays == challenge.totalDays &&
                        existing.completedDays == challenge.completedDays
                    }
                    
                    if !potentialDuplicates.isEmpty {
                        print("🚨 Potential duplicate challenge detected - preventing archiving")
                        print("   Found \(potentialDuplicates.count) similar challenges")
                        throw StorageError.duplicateChallenge
                    }
                    
                    // Add new challenge
                    challenges.append(challenge)
                    print("➕ Added new challenge: \(challenge.challengeTitle)")
                }
                
                // Validate the challenge before saving
                guard validateCompletedChallenge(challenge) else {
                    print("❌ Challenge validation failed - not saving")
                    throw StorageError.invalidData
                }
                
                // Sort challenges by completion date (most recent first) for consistency
                challenges.sort { $0.completionDate > $1.completionDate }
                
                // Encode and save
                let encoded = try JSONEncoder().encode(challenges)
                userDefaults.set(encoded, forKey: completedChallengesKey)
                
                print("✅ Challenge archiving completed successfully")
                print("📊 Storage updated: \(originalCount) → \(challenges.count) challenges")
                
                // Verify the save worked by attempting to decode
                if let _ = try? JSONDecoder().decode([CompletedChallenge].self, from: encoded) {
                    print("✅ Archive integrity verified")
                } else {
                    print("❌ Archive integrity check failed")
                    throw StorageError.saveFailed("Data integrity check failed")
                }
                
            } catch {
                print("❌ Challenge archiving failed: \(error)")
                throw error
            }
        }
    }
    
    /// Mark a specific challenge as viewed by the user
    func markChallengeAsViewed(_ challengeId: UUID) throws {
        return try archivingQueue.sync {
            do {
                var challenges = loadCompletedChallenges()
                
                guard let index = challenges.firstIndex(where: { $0.id == challengeId }) else {
                    print("⚠️ Challenge to mark as viewed not found: \(challengeId)")
                    throw StorageError.challengeNotFound
                }
                
                // Update the viewed status
                challenges[index].markAsViewed()
                
                // Save updated challenges array
                let encoded = try JSONEncoder().encode(challenges)
                userDefaults.set(encoded, forKey: completedChallengesKey)
                
                print("👁️ Marked challenge as viewed: \(challenges[index].challengeTitle)")
                
            } catch {
                print("❌ Failed to mark challenge as viewed: \(error)")
                throw error
            }
        }
    }
    
    /// Check if a challenge already exists (for pre-archiving verification)
    func challengeExists(_ challengeId: UUID) -> Bool {
        let challenges = loadCompletedChallenges()
        return challenges.contains { $0.id == challengeId }
    }
    
    /// Check if a similar challenge was recently archived (additional safety check)
    func hasSimilarRecentChallenge(title: String, completionDate: Date, tolerance: TimeInterval = 3600) -> Bool {
        let challenges = loadCompletedChallenges()
        return challenges.contains { existing in
            existing.challengeTitle.lowercased() == title.lowercased() &&
            abs(existing.completionDate.timeIntervalSince(completionDate)) < tolerance
        }
    }
    
    /// Load all completed challenges from storage
    func loadCompletedChallenges() -> [CompletedChallenge] {
        guard let data = userDefaults.data(forKey: completedChallengesKey) else {
            print("📚 No completed challenges found in storage")
            return []
        }
        
        do {
            let challenges = try JSONDecoder().decode([CompletedChallenge].self, from: data)
            
            // Validate loaded challenges and remove any invalid ones
            let validChallenges = challenges.filter { validateCompletedChallenge($0) }
            
            if validChallenges.count != challenges.count {
                print("⚠️ Filtered out \(challenges.count - validChallenges.count) invalid challenges")
                // Save the cleaned data back
                saveFilteredChallenges(validChallenges)
            }
            
            // Check for any potential ID duplicates and log them
            let challengeIds = validChallenges.map { $0.id }
            let uniqueIds = Set(challengeIds)
            if challengeIds.count != uniqueIds.count {
                print("🚨 WARNING: Duplicate challenge IDs detected in storage!")
                print("   Total challenges: \(challengeIds.count), Unique IDs: \(uniqueIds.count)")
                // Remove duplicates, keeping the most recent
                let deduplicatedChallenges = Dictionary(grouping: validChallenges, by: { $0.id })
                    .compactMapValues { $0.max(by: { $0.completionDate < $1.completionDate }) }
                    .values
                    .sorted { $0.completionDate > $1.completionDate }
                
                print("🔧 Deduplicated to \(deduplicatedChallenges.count) challenges")
                saveFilteredChallenges(Array(deduplicatedChallenges))
                return Array(deduplicatedChallenges)
            }
            
            print("✅ Loaded \(validChallenges.count) valid completed challenges")
            return validChallenges.sorted { $0.completionDate > $1.completionDate }
            
        } catch let decodingError as DecodingError {
            print("❌ Failed to decode completed challenges: \(decodingError)")
            handleChallengeDecodingError(decodingError)
            return []
        } catch {
            print("❌ Failed to load completed challenges: \(error)")
            return []
        }
    }
    
    /// Delete a specific completed challenge
    func deleteCompletedChallenge(_ challengeId: UUID) throws {
        return try archivingQueue.sync {
            do {
                var challenges = loadCompletedChallenges()
                
                guard let index = challenges.firstIndex(where: { $0.id == challengeId }) else {
                    print("⚠️ Challenge to delete not found: \(challengeId)")
                    throw StorageError.challengeNotFound
                }
                
                let deletedChallenge = challenges.remove(at: index)
                
                // Save updated challenges array
                let encoded = try JSONEncoder().encode(challenges)
                userDefaults.set(encoded, forKey: completedChallengesKey)
                
                print("🗑️ Deleted challenge: \(deletedChallenge.challengeTitle)")
                print("📊 Remaining challenges: \(challenges.count)")
                
            } catch {
                print("❌ Failed to delete completed challenge: \(error)")
                throw error
            }
        }
    }
    
    /// Get count of completed challenges without loading full data
    func getCompletedChallengeCount() -> Int {
        guard let data = userDefaults.data(forKey: completedChallengesKey) else { return 0 }
        
        do {
            let challenges = try JSONDecoder().decode([CompletedChallenge].self, from: data)
            return challenges.count
        } catch {
            print("❌ Failed to get challenge count: \(error)")
            return 0
        }
    }
    
    /// Check if user has any completed challenges
    func hasCompletedChallenges() -> Bool {
        return getCompletedChallengeCount() > 0
    }
    
    /// Get the most recent completed challenge (for quick access)
    func getMostRecentChallenge() -> CompletedChallenge? {
        let challenges = loadCompletedChallenges()
        return challenges.max(by: { $0.completionDate < $1.completionDate })
    }
    
    /// Clear all completed challenges
    func clearCompletedChallenges() {
        userDefaults.removeObject(forKey: completedChallengesKey)
        print("🗑️ All completed challenges cleared")
    }
    
    // MARK: - Challenge Validation
    
    /// Validate a completed challenge has required data
    private func validateCompletedChallenge(_ challenge: CompletedChallenge) -> Bool {
        // Basic validation checks
        guard !challenge.challengeTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("⚠️ Challenge validation failed: empty title")
            return false
        }
        
        guard challenge.totalDays > 0 && challenge.totalDays <= 30 else {
            print("⚠️ Challenge validation failed: invalid total days (\(challenge.totalDays))")
            return false
        }
        
        guard challenge.completedDays >= 0 && challenge.completedDays <= challenge.totalDays else {
            print("⚠️ Challenge validation failed: invalid completed days (\(challenge.completedDays)/\(challenge.totalDays))")
            return false
        }
        
        guard challenge.totalExercises >= 0 && challenge.completedExercises >= 0 && challenge.completedExercises <= challenge.totalExercises else {
            print("⚠️ Challenge validation failed: invalid exercise counts")
            return false
        }
        
        guard challenge.startDate <= challenge.completionDate else {
            print("⚠️ Challenge validation failed: completion date before start date")
            return false
        }
        
        // Validate daily completion records match the totals
        let recordsCompletedDays = challenge.dailyCompletionRecord.filter { $0.isCompleted }.count
        if recordsCompletedDays != challenge.completedDays {
            print("⚠️ Challenge validation warning: daily records mismatch (\(recordsCompletedDays) vs \(challenge.completedDays))")
            // Don't fail validation for this - just warn
        }
        
        print("✅ Challenge validation passed: \(challenge.challengeTitle)")
        return true
    }
    
    /// Handle challenge decoding errors
    private func handleChallengeDecodingError(_ error: DecodingError) {
        switch error {
        case .keyNotFound(let key, _):
            print("❌ Missing key '\(key.stringValue)' in challenge data - clearing storage")
            clearCompletedChallenges()
        case .typeMismatch(_, let context):
            print("❌ Type mismatch in challenge data at \(context.codingPath) - clearing storage")
            clearCompletedChallenges()
        case .valueNotFound(_, let context):
            print("❌ Missing value in challenge data at \(context.codingPath) - clearing storage")
            clearCompletedChallenges()
        case .dataCorrupted(let context):
            print("❌ Challenge data corrupted: \(context.debugDescription) - clearing storage")
            clearCompletedChallenges()
        @unknown default:
            print("❌ Unknown challenge decoding error - clearing storage")
            clearCompletedChallenges()
        }
    }
    
    /// Save filtered/cleaned challenges array
    private func saveFilteredChallenges(_ challenges: [CompletedChallenge]) {
        do {
            let encoded = try JSONEncoder().encode(challenges)
            userDefaults.set(encoded, forKey: completedChallengesKey)
            print("🔧 Saved filtered challenges: \(challenges.count)")
        } catch {
            print("❌ Failed to save filtered challenges: \(error)")
        }
    }
    
    // MARK: - Exercise Management
    
    /// Update specific exercise completion
    func updateExerciseCompletion(planId: UUID, dayId: UUID, exerciseId: UUID, isCompleted: Bool) {
        guard var plan = loadWorkoutPlan(), plan.id == planId else {
            print("❌ Cannot update exercise - no matching plan found")
            return
        }
        
        // Find and update the exercise
        var exerciseFound = false
        for dayIndex in plan.days.indices {
            if plan.days[dayIndex].id == dayId {
                for exerciseIndex in plan.days[dayIndex].exercises.indices {
                    if plan.days[dayIndex].exercises[exerciseIndex].id == exerciseId {
                        plan.days[dayIndex].exercises[exerciseIndex].isCompleted = isCompleted
                        saveWorkoutPlan(plan)
                        exerciseFound = true
                        print("✅ Exercise completion updated")
                        return
                    }
                }
            }
        }
        
        if !exerciseFound {
            print("❌ Exercise not found for completion update")
        }
    }
    
    // MARK: - Plan Status Checking
    
    /// Check if user has an active plan
    func hasActivePlan() -> Bool {
        guard let plan = loadWorkoutPlan() else { return false }
        return plan.isActive
    }
    
    /// Check if user has any saved plan (active or suggested)
    func hasSavedPlan() -> Bool {
        return loadWorkoutPlan() != nil
    }
    
    // MARK: - Data Clearing
    
    /// Clear saved plan (for starting fresh)
    func clearWorkoutPlan() {
        userDefaults.removeObject(forKey: workoutPlanKey)
        print("🗑️ Workout plan cleared")
    }
    
    /// Force clear all data and reset version (for debugging/troubleshooting)
    func resetAllData() {
        userDefaults.removeObject(forKey: workoutPlanKey)
        userDefaults.removeObject(forKey: completedChallengesKey)
        userDefaults.removeObject(forKey: dataVersionKey)
        print("🔄 All data reset - next launch will reinitialize")
    }
    
    // MARK: - Storage Statistics
    
    /// Get storage usage information for debugging
    func getStorageInfo() -> (activePlanSize: Int, challengesSize: Int, totalChallenges: Int) {
        let planData = userDefaults.data(forKey: workoutPlanKey)
        let challengesData = userDefaults.data(forKey: completedChallengesKey)
        
        let planSize = planData?.count ?? 0
        let challengesSize = challengesData?.count ?? 0
        let challengeCount = getCompletedChallengeCount()
        
        return (planSize, challengesSize, challengeCount)
    }
    
    // MARK: - Debugging Helpers
    
    /// Get current data version for debugging
    func getCurrentDataVersion() -> Int {
        return userDefaults.integer(forKey: dataVersionKey)
    }
    
    /// Check if there's any stored workout data
    func hasStoredData() -> Bool {
        return userDefaults.data(forKey: workoutPlanKey) != nil
    }
    
    /// Check if there's any stored challenge data
    func hasStoredChallengeData() -> Bool {
        return userDefaults.data(forKey: completedChallengesKey) != nil
    }
    
    /// Get debug information about storage state
    func getDebugInfo() -> String {
        let storageInfo = getStorageInfo()
        return """
        === STORAGE DEBUG INFO ===
        Data Version: \(getCurrentDataVersion())
        Has Active Plan: \(hasActivePlan())
        Has Saved Plan: \(hasSavedPlan())
        Has Challenge Data: \(hasStoredChallengeData())
        
        Storage Sizes:
        - Active Plan: \(storageInfo.activePlanSize) bytes
        - Challenges: \(storageInfo.challengesSize) bytes
        - Total Challenges: \(storageInfo.totalChallenges)
        
        Keys in UserDefaults:
        - \(workoutPlanKey): \(hasStoredData() ? "✅" : "❌")
        - \(completedChallengesKey): \(hasStoredChallengeData() ? "✅" : "❌")
        - \(dataVersionKey): \(userDefaults.object(forKey: dataVersionKey) != nil ? "✅" : "❌")
        """
    }
}

// MARK: - Storage Errors
enum StorageError: LocalizedError {
    case saveFailed(String)
    case challengeNotFound
    case invalidData
    case duplicateChallenge
    
    var errorDescription: String? {
        switch self {
        case .saveFailed(let message):
            return "Failed to save data: \(message)"
        case .challengeNotFound:
            return "Challenge not found"
        case .invalidData:
            return "Invalid data format"
        case .duplicateChallenge:
            return "Duplicate challenge detected"
        }
    }
}
