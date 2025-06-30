//
//  Day.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//

import Foundation

struct Day: Identifiable, Codable {
    let id = UUID()
    let dayNumber: Int
    let date: Date
    var exercises: [Exercise]
    
    var isCompleted: Bool {
        !exercises.isEmpty && exercises.allSatisfy { $0.isCompleted }
    }
    
    init(dayNumber: Int, date: Date, exercises: [Exercise] = []) {
        self.dayNumber = dayNumber
        self.date = date
        self.exercises = exercises
    }
}
