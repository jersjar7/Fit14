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
    private let dataVersionKey = "dataSchemaVersion"
    
    // Current data schema version - increment when making breaking changes
    private let currentDataVersion = 2
    
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
        userDefaults.removeObject(forKey: dataVersionKey)
        print("🔄 All data reset - next launch will reinitialize")
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
}
