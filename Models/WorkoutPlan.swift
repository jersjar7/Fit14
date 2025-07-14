//
//  WorkoutPlan.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//

import Foundation

// MARK: - Plan Status Enum
enum PlanStatus: String, Codable, CaseIterable {
    case suggested = "suggested"
    case active = "active"
    
    var description: String {
        switch self {
        case .suggested:
            return "Suggested Plan"
        case .active:
            return "Active Plan"
        }
    }
}

struct WorkoutPlan: Identifiable, Codable, Equatable {
    let id = UUID()
    let userGoals: String
    let createdDate: Date
    let planTitle: String?   // NEW: AI-generated 7-9 word plan title
    let summary: String?     // AI-generated summary from response
    var status: PlanStatus
    var days: [Day]
    
    // MARK: - Progress Calculations (Robust & NaN-Safe)
    
    /// Number of completed days (always returns non-negative value)
    var completedDays: Int {
        guard !days.isEmpty else { return 0 }
        let completed = days.filter { $0.isCompleted }.count
        return max(0, completed) // Ensure never negative
    }
    
    /// Total number of days in the plan
    var totalDays: Int {
        return max(0, days.count)
    }
    
    /// Progress percentage (0-100, never NaN or infinite)
    var progressPercentage: Double {
        guard totalDays > 0 else { return 0.0 }
        
        let completed = Double(completedDays)
        let total = Double(totalDays)
        
        // Ensure we have valid numbers
        guard completed.isFinite && total.isFinite && total > 0 else { return 0.0 }
        
        let percentage = (completed / total) * 100.0
        
        // Ensure result is finite and within expected range
        guard percentage.isFinite else { return 0.0 }
        
        // Clamp to 0-100 range
        return min(max(percentage, 0.0), 100.0)
    }
    
    /// Number of remaining days
    var remainingDays: Int {
        return max(0, totalDays - completedDays)
    }
    
    /// Whether the 14-day time period has elapsed (regardless of completion)
    var isFinished: Bool {
        guard let lastDay = days.max(by: { $0.date < $1.date }) else { return false }
        let dayAfterLastDay = Calendar.current.date(byAdding: .day, value: 1, to: lastDay.date) ?? lastDay.date
        return Date() >= Calendar.current.startOfDay(for: dayAfterLastDay)
    }
    
    /// Whether the entire plan is completed (all days done within the 14-day period)
    var isCompleted: Bool {
        guard totalDays > 0 else { return false }
        return completedDays >= totalDays
    }
    
    /// Progress as a decimal (0.0 to 1.0) for use with ProgressView
    var progressDecimal: Double {
        return progressPercentage / 100.0
    }
    
    // MARK: - Plan Status Properties
    
    var isSuggested: Bool {
        return status == .suggested
    }
    
    var isActive: Bool {
        return status == .active
    }
    
    /// Whether the plan has valid data structure
    var isValid: Bool {
        guard !userGoals.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        guard !days.isEmpty else { return false }
        
        // Ensure all days have valid day numbers
        for (index, day) in days.enumerated() {
            if day.dayNumber != index + 1 {
                return false
            }
            
            // Ensure each day has at least one exercise
            if day.exercises.isEmpty {
                return false
            }
        }
        
        return true
    }
    
    // MARK: - Initialization
    
    init(userGoals: String, planTitle: String? = nil, summary: String? = nil, days: [Day] = [], status: PlanStatus = .suggested) {
        self.userGoals = userGoals
        self.planTitle = planTitle  // NEW: Store AI-generated plan title
        self.summary = summary      // Store AI summary
        self.createdDate = Date()
        self.days = days
        self.status = status
    }
    
    // MARK: - Display Properties
        
    /// Get the best available title for display (planTitle preferred, summary as fallback)
    var displayTitle: String {
        return planTitle ?? summary ?? userGoals
    }
    
    /// Get the best available description for display (summary preferred, userGoals as fallback)
    var displayDescription: String {
        return summary ?? userGoals
    }
    
    /// Get a shorter version for compact displays
    var compactDescription: String {
        let description = displayDescription
        return description.count > 100 ? String(description.prefix(97)) + "..." : description
    }
    
    /// Get a compact title for UI elements where space is limited
    var compactTitle: String {
        let title = displayTitle
        return title.count > 50 ? String(title.prefix(47)) + "..." : title
    }
    
    // MARK: - Plan Modification Methods
    
    /// Create an active version of this plan
    func makeActive() -> WorkoutPlan {
        var activePlan = self
        activePlan.status = .active
        return activePlan
    }
    
    /// Create a copy with modified days
    func withModifiedDays(_ newDays: [Day]) -> WorkoutPlan {
        var modifiedPlan = self
        modifiedPlan.days = newDays
        return modifiedPlan
    }
    
    /// Create a copy with a specific day modified
    func withModifiedDay(_ dayId: UUID, newDay: Day) -> WorkoutPlan {
        var modifiedPlan = self
        if let dayIndex = modifiedPlan.days.firstIndex(where: { $0.id == dayId }) {
            // Preserve the original day's ID and structure while updating content
            modifiedPlan.days[dayIndex] = newDay.updated(
                dayNumber: modifiedPlan.days[dayIndex].dayNumber,
                date: modifiedPlan.days[dayIndex].date
            )
        }
        return modifiedPlan
    }
    
    /// Create a copy with an exercise added to a specific day
    func withExerciseAdded(to dayId: UUID, exercise: Exercise) -> WorkoutPlan {
        var modifiedPlan = self
        if let dayIndex = modifiedPlan.days.firstIndex(where: { $0.id == dayId }) {
            modifiedPlan.days[dayIndex] = modifiedPlan.days[dayIndex].addingExercise(exercise)
        }
        return modifiedPlan
    }
    
    /// Create a copy with an exercise removed from a specific day
    func withExerciseRemoved(from dayId: UUID, exerciseId: UUID) -> WorkoutPlan {
        var modifiedPlan = self
        if let dayIndex = modifiedPlan.days.firstIndex(where: { $0.id == dayId }) {
            modifiedPlan.days[dayIndex] = modifiedPlan.days[dayIndex].removingExercise(withId: exerciseId)
        }
        return modifiedPlan
    }
    
    // MARK: - Plan Analysis Methods
    
    /// Get days by completion status
    func getDays(completed: Bool) -> [Day] {
        return days.filter { $0.isCompleted == completed }
    }
    
    /// Get the next incomplete day (useful for "continue workout" features)
    func getNextIncompleteDay() -> Day? {
        return days.first { !$0.isCompleted }
    }
    
    /// Get the current day based on date (if plan started)
    func getCurrentDay() -> Day? {
        let calendar = Calendar.current
        let today = Date()
        
        return days.first { day in
            calendar.isDate(day.date, inSameDayAs: today)
        }
    }
    
    /// Get total number of exercises across all days
    var totalExercises: Int {
        return days.reduce(0) { total, day in
            total + day.exercises.count
        }
    }
    
    /// Get total number of completed exercises across all days
    var completedExercises: Int {
        return days.reduce(0) { total, day in
            total + day.exercises.filter { $0.isCompleted }.count
        }
    }
    
    /// Exercise completion percentage across the entire plan
    var exerciseCompletionPercentage: Double {
        guard totalExercises > 0 else { return 0.0 }
        
        let completed = Double(completedExercises)
        let total = Double(totalExercises)
        
        guard completed.isFinite && total.isFinite && total > 0 else { return 0.0 }
        
        let percentage = (completed / total) * 100.0
        guard percentage.isFinite else { return 0.0 }
        
        return min(max(percentage, 0.0), 100.0)
    }
    
    // MARK: - Equatable Conformance
    static func == (lhs: WorkoutPlan, rhs: WorkoutPlan) -> Bool {
        return lhs.id == rhs.id &&
               lhs.userGoals == rhs.userGoals &&
               lhs.createdDate == rhs.createdDate &&
               lhs.planTitle == rhs.planTitle &&
               lhs.summary == rhs.summary &&
               lhs.status == rhs.status &&
               lhs.days == rhs.days
    }
}
