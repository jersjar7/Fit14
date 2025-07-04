//
//  DayRowView.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//

import SwiftUI

struct DayRowView: View {
    let day: Day
    
    var body: some View {
        HStack {
            // Day circle
            ZStack {
                Circle()
                    .fill(day.isCompleted ? Color.green : Color.blue)
                    .frame(width: 40, height: 40)
                
                Text("\(day.dayNumber)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Day \(day.dayNumber)")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(day.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("\(day.exercises.count) exercises")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Status indicator
            if day.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            } else {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

#Preview {
    DayRowView(day: SampleData.sampleWorkoutPlan.days[0])
        .padding()
}
