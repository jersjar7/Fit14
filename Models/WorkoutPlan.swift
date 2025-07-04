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
    var status: PlanStatus
    var days: [Day]
    
    var completedDays: Int {
        days.filter { $0.isCompleted }.count
    }
    
    var progressPercentage: Double {
        guard !days.isEmpty else { return 0 }
        return Double(completedDays) / Double(days.count) * 100
    }
    
    var isSuggested: Bool {
        return status == .suggested
    }
    
    var isActive: Bool {
        return status == .active
    }
    
    init(userGoals: String, days: [Day] = [], status: PlanStatus = .suggested) {
        self.userGoals = userGoals
        self.createdDate = Date()
        self.days = days
        self.status = status
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
    
    // MARK: - Equatable Conformance
    static func == (lhs: WorkoutPlan, rhs: WorkoutPlan) -> Bool {
        return lhs.id == rhs.id &&
               lhs.userGoals == rhs.userGoals &&
               lhs.createdDate == rhs.createdDate &&
               lhs.status == rhs.status &&
               lhs.days == rhs.days
    }
}
