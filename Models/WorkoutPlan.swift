//
//  WorkoutPlan.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//

import Foundation

struct WorkoutPlan: Identifiable, Codable {
    let id = UUID()
    let userGoals: String
    let createdDate: Date
    var days: [Day]
    
    var completedDays: Int {
        days.filter { $0.isCompleted }.count
    }
    
    var progressPercentage: Double {
        guard !days.isEmpty else { return 0 }
        return Double(completedDays) / Double(days.count) * 100
    }
    
    init(userGoals: String, days: [Day] = []) {
        self.userGoals = userGoals
        self.createdDate = Date()
        self.days = days
    }
}
