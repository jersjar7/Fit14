//
//  CompletedChallenge.swift
//  Fit14
//
//  Created by Jerson on 7/8/25.
//

import Foundation

// MARK: - Completed Challenge Model
struct CompletedChallenge: Identifiable, Codable, Equatable {
    let id: UUID // ✅ Fixed: Changed from `let id = UUID()` to persistent UUID
    
    // MARK: - Basic Challenge Info
    let originalPlanId: UUID           // Reference to original plan
    let challengeTitle: String         // AI-generated summary from original plan
    let userGoals: String             // Original goals that created this challenge
    
    // MARK: - Date Tracking
    let startDate: Date               // When challenge was started
    let completionDate: Date          // When challenge was completed/archived
    let createdDate: Date             // When this record was created
    
    // MARK: - Completion Statistics
    let totalDays: Int                // Total days in the challenge (should be 14)
    let completedDays: Int            // Number of days marked as complete
    let totalExercises: Int           // Total exercises across all days
    let completedExercises: Int       // Total exercises marked as complete
    
    // MARK: - Daily Completion Record
    let dailyCompletionRecord: [DayCompletionRecord]
    
    // MARK: - Computed Properties for Stats Display
    
    /// Success rate as percentage (0-100)
    var successRate: Double {
        guard totalDays > 0 else { return 0.0 }
        
        let rate = (Double(completedDays) / Double(totalDays)) * 100.0
        return min(max(rate, 0.0), 100.0)
    }
    
    /// Exercise completion percentage (0-100)
    var exerciseCompletionPercentage: Double {
        guard totalExercises > 0 else { return 0.0 }
        
        let percentage = (Double(completedExercises) / Double(totalExercises)) * 100.0
        return min(max(percentage, 0.0), 100.0)
    }
    
    /// Number of perfect days (days where all exercises were completed)
    var perfectDays: Int {
        return dailyCompletionRecord.filter { $0.isPerfectDay }.count
    }
    
    /// Number of days with partial completion
    var partialDays: Int {
        return dailyCompletionRecord.filter { $0.isPartialDay }.count
    }
    
    /// Number of days with no completion
    var missedDays: Int {
        return dailyCompletionRecord.filter { $0.isMissedDay }.count
    }
    
    /// Longest consecutive day streak
    var longestStreak: Int {
        var currentStreak = 0
        var maxStreak = 0
        
        for record in dailyCompletionRecord.sorted(by: { $0.dayNumber < $1.dayNumber }) {
            if record.isCompleted {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 0
            }
        }
        
        return maxStreak
    }
    
    /// Most consistent week (week with highest completion rate)
    var mostConsistentWeek: Int {
        let week1Days = dailyCompletionRecord.filter { $0.dayNumber <= 7 }
        let week2Days = dailyCompletionRecord.filter { $0.dayNumber > 7 }
        
        let week1Rate = week1Days.isEmpty ? 0.0 : Double(week1Days.filter { $0.isCompleted }.count) / Double(week1Days.count)
        let week2Rate = week2Days.isEmpty ? 0.0 : Double(week2Days.filter { $0.isCompleted }.count) / Double(week2Days.count)
        
        return week1Rate >= week2Rate ? 1 : 2
    }
    
    /// Whether the entire challenge was completed (all days done)
    var isFullyCompleted: Bool {
        return completedDays == totalDays
    }
    
    /// Duration of the challenge in days
    var challengeDuration: Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: startDate, to: completionDate).day ?? 0
        return max(days, 0)
    }
    
    // MARK: - Initialization
    
    init(from workoutPlan: WorkoutPlan, completionDate: Date = Date()) {
        self.id = UUID() // ✅ Create UUID once during initialization
        self.originalPlanId = workoutPlan.id
        self.challengeTitle = workoutPlan.summary ?? workoutPlan.userGoals // This will be replaced with AI summary when available
        self.userGoals = workoutPlan.userGoals
        self.startDate = workoutPlan.createdDate
        self.completionDate = completionDate
        self.createdDate = Date()
        
        // Calculate statistics from the workout plan
        self.totalDays = workoutPlan.totalDays
        self.completedDays = workoutPlan.completedDays
        self.totalExercises = workoutPlan.totalExercises
        self.completedExercises = workoutPlan.completedExercises
        
        // Create daily completion records from workout plan days
        self.dailyCompletionRecord = workoutPlan.days.map { day in
            DayCompletionRecord(from: day)
        }
    }
    
    // MARK: - Custom initializer for manual creation (backward compatibility)
    init(
        originalPlanId: UUID,
        challengeTitle: String,
        userGoals: String,
        startDate: Date,
        completionDate: Date = Date(),
        totalDays: Int,
        completedDays: Int,
        totalExercises: Int,
        completedExercises: Int,
        dailyCompletionRecord: [DayCompletionRecord]
    ) {
        self.id = UUID() // ✅ Generate new UUID for backward compatibility
        self.originalPlanId = originalPlanId
        self.challengeTitle = challengeTitle
        self.userGoals = userGoals
        self.startDate = startDate
        self.completionDate = completionDate
        self.createdDate = Date()
        self.totalDays = totalDays
        self.completedDays = completedDays
        self.totalExercises = totalExercises
        self.completedExercises = completedExercises
        self.dailyCompletionRecord = dailyCompletionRecord
    }
    
    // MARK: - Advanced initializer with custom ID
    init(
        id: UUID,
        originalPlanId: UUID,
        challengeTitle: String,
        userGoals: String,
        startDate: Date,
        completionDate: Date = Date(),
        totalDays: Int,
        completedDays: Int,
        totalExercises: Int,
        completedExercises: Int,
        dailyCompletionRecord: [DayCompletionRecord]
    ) {
        self.id = id
        self.originalPlanId = originalPlanId
        self.challengeTitle = challengeTitle
        self.userGoals = userGoals
        self.startDate = startDate
        self.completionDate = completionDate
        self.createdDate = Date()
        self.totalDays = totalDays
        self.completedDays = completedDays
        self.totalExercises = totalExercises
        self.completedExercises = completedExercises
        self.dailyCompletionRecord = dailyCompletionRecord
    }
}

// MARK: - Day Completion Record
struct DayCompletionRecord: Identifiable, Codable, Equatable {
    let id: UUID // ✅ Fixed: Changed from `let id = UUID()` to persistent UUID
    let dayNumber: Int
    let date: Date
    let focus: String?  // NEW: AI-provided focus description (e.g., "Upper body strength")
    let totalExercises: Int
    let completedExercises: Int
    let exerciseCompletionRecord: [ExerciseCompletionRecord]
    
    /// Whether this day was marked as completed
    var isCompleted: Bool {
        return completedExercises == totalExercises && totalExercises > 0
    }
    
    /// Whether this day had no completion
    var isMissedDay: Bool {
        return completedExercises == 0
    }
    
    /// Whether this day had partial completion
    var isPartialDay: Bool {
        return completedExercises > 0 && completedExercises < totalExercises
    }
    
    /// Whether this day had perfect completion (all exercises done)
    var isPerfectDay: Bool {
        return isCompleted
    }
    
    /// Completion percentage for this day
    var completionPercentage: Double {
        guard totalExercises > 0 else { return 0.0 }
        return (Double(completedExercises) / Double(totalExercises)) * 100.0
    }
    
    // MARK: - Initialization from Day model
    init(from day: Day) {
        self.id = UUID() // ✅ Create UUID once during initialization
        self.dayNumber = day.dayNumber
        self.date = day.date
        self.focus = day.focus  // NEW: Include focus from Day model
        self.totalExercises = day.exercises.count
        self.completedExercises = day.exercises.filter { $0.isCompleted }.count
        self.exerciseCompletionRecord = day.exercises.map { exercise in
            ExerciseCompletionRecord(from: exercise)
        }
    }
    
    // MARK: - Manual initialization (backward compatibility)
    init(
        dayNumber: Int,
        date: Date,
        focus: String? = nil,  // NEW: Add focus parameter with default nil
        totalExercises: Int,
        completedExercises: Int,
        exerciseCompletionRecord: [ExerciseCompletionRecord]
    ) {
        self.id = UUID() // ✅ Generate new UUID for backward compatibility
        self.dayNumber = dayNumber
        self.date = date
        self.focus = focus  // NEW: Include focus
        self.totalExercises = totalExercises
        self.completedExercises = completedExercises
        self.exerciseCompletionRecord = exerciseCompletionRecord
    }
    
    // MARK: - Advanced initialization with custom ID
    init(
        id: UUID,
        dayNumber: Int,
        date: Date,
        focus: String? = nil,  // NEW: Add focus parameter with default nil
        totalExercises: Int,
        completedExercises: Int,
        exerciseCompletionRecord: [ExerciseCompletionRecord]
    ) {
        self.id = id
        self.dayNumber = dayNumber
        self.date = date
        self.focus = focus  // NEW: Include focus
        self.totalExercises = totalExercises
        self.completedExercises = completedExercises
        self.exerciseCompletionRecord = exerciseCompletionRecord
    }
}

// MARK: - Exercise Completion Record
struct ExerciseCompletionRecord: Identifiable, Codable, Equatable {
    let id: UUID // ✅ Fixed: Changed from `let id = UUID()` to persistent UUID
    let exerciseName: String
    let sets: Int
    let quantity: Int
    let unit: ExerciseUnit
    let isCompleted: Bool
    
    /// Formatted display string for the exercise
    var displayString: String {
        return "\(sets) x \(quantity) \(unit.rawValue) \(exerciseName)"
    }
    
    // MARK: - Initialization from Exercise model
    init(from exercise: Exercise) {
        self.id = UUID() // ✅ Create UUID once during initialization
        self.exerciseName = exercise.name
        self.sets = exercise.sets
        self.quantity = exercise.quantity
        self.unit = exercise.unit
        self.isCompleted = exercise.isCompleted
    }
    
    // MARK: - Manual initialization (backward compatibility)
    init(
        exerciseName: String,
        sets: Int,
        quantity: Int,
        unit: ExerciseUnit,
        isCompleted: Bool
    ) {
        self.id = UUID() // ✅ Generate new UUID for backward compatibility
        self.exerciseName = exerciseName
        self.sets = sets
        self.quantity = quantity
        self.unit = unit
        self.isCompleted = isCompleted
    }
    
    // MARK: - Advanced initialization with custom ID
    init(
        id: UUID,
        exerciseName: String,
        sets: Int,
        quantity: Int,
        unit: ExerciseUnit,
        isCompleted: Bool
    ) {
        self.id = id
        self.exerciseName = exerciseName
        self.sets = sets
        self.quantity = quantity
        self.unit = unit
        self.isCompleted = isCompleted
    }
}

// MARK: - Sample Data for Previews
extension CompletedChallenge {
    /// Sample completed challenge for previews
    static let sampleCompletedChallenge: CompletedChallenge = {
        let startDate = Calendar.current.date(byAdding: .day, value: -16, to: Date()) ?? Date()
        let completionDate = Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date()
        
        // Sample focus descriptions for realistic data
        let focusDescriptions = [
            "Upper body strength", "Lower body power", "Cardio conditioning", "Full body workout",
            "Core strengthening", "Strength building", "Active recovery", "Upper body endurance",
            "Lower body stability", "High intensity training", "Dynamic movement", "Advanced strength",
            "Cardio & balance", "Complete conditioning"
        ]
        
        // Create sample daily records
        var dailyRecords: [DayCompletionRecord] = []
        for i in 1...14 {
            let dayDate = Calendar.current.date(byAdding: .day, value: i-1, to: startDate) ?? Date()
            let exerciseRecords = [
                ExerciseCompletionRecord(exerciseName: "Push-ups", sets: 3, quantity: 12, unit: .reps, isCompleted: true),
                ExerciseCompletionRecord(exerciseName: "Squats", sets: 3, quantity: 15, unit: .reps, isCompleted: i <= 12), // Miss last 2 days
                ExerciseCompletionRecord(exerciseName: "Plank", sets: 1, quantity: 30, unit: .seconds, isCompleted: i <= 10) // Miss last 4 days
            ]
            
            let record = DayCompletionRecord(
                dayNumber: i,
                date: dayDate,
                focus: focusDescriptions[(i - 1) % focusDescriptions.count],  // NEW: Include focus
                totalExercises: 3,
                completedExercises: exerciseRecords.filter { $0.isCompleted }.count,
                exerciseCompletionRecord: exerciseRecords
            )
            dailyRecords.append(record)
        }
        
        return CompletedChallenge(
            originalPlanId: UUID(),
            challengeTitle: "14-Day Home Strength Builder",
            userGoals: "Build muscle strength with progressive bodyweight exercises at home",
            startDate: startDate,
            completionDate: completionDate,
            totalDays: 14,
            completedDays: 10,
            totalExercises: 42,
            completedExercises: 32,
            dailyCompletionRecord: dailyRecords
        )
    }()
    
    /// Sample perfect challenge for previews
    static let samplePerfectChallenge: CompletedChallenge = {
        let startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let completionDate = Calendar.current.date(byAdding: .day, value: -16, to: Date()) ?? Date()
        
        var dailyRecords: [DayCompletionRecord] = []
        for i in 1...14 {
            let dayDate = Calendar.current.date(byAdding: .day, value: i-1, to: startDate) ?? Date()
            let exerciseRecords = [
                ExerciseCompletionRecord(exerciseName: "Cardio Walk", sets: 1, quantity: 20, unit: .minutes, isCompleted: true),
                ExerciseCompletionRecord(exerciseName: "Stretching", sets: 1, quantity: 10, unit: .minutes, isCompleted: true)
            ]
            
            let record = DayCompletionRecord(
                dayNumber: i,
                date: dayDate,
                focus: i <= 7 ? "Morning cardio routine" : "Cardio endurance building",  // NEW: Include focus
                totalExercises: 2,
                completedExercises: 2,
                exerciseCompletionRecord: exerciseRecords
            )
            dailyRecords.append(record)
        }
        
        return CompletedChallenge(
            originalPlanId: UUID(),
            challengeTitle: "14-Day Morning Cardio Challenge",
            userGoals: "Establish a consistent morning cardio routine",
            startDate: startDate,
            completionDate: completionDate,
            totalDays: 14,
            completedDays: 14,
            totalExercises: 28,
            completedExercises: 28,
            dailyCompletionRecord: dailyRecords
        )
    }()
}
