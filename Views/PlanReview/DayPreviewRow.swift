//
//  DayPreviewRow.swift
//  Fit14
//
//  Created by Jerson on 7/3/25.
//

import SwiftUI

struct DayPreviewRow: View {
    let day: Day
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Day Number Circle
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 50, height: 50)
                    
                    Text("\(day.dayNumber)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                // Day Info
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Day \(day.dayNumber)")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(day.exercises.count) exercise\(day.exercises.count == 1 ? "" : "s")")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                    }
                    
                    Text(day.date, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Exercise Preview
                    if !day.exercises.isEmpty {
                        let exerciseNames = day.exercises.prefix(3).map { $0.name }
                        let preview = exerciseNames.joined(separator: " • ")
                        let hasMore = day.exercises.count > 3
                        
                        Text(hasMore ? "\(preview) • +\(day.exercises.count - 3) more" : preview)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .opacity(0.6)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle()) // Make entire area tappable
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 12) {
        DayPreviewRow(day: SampleData.sampleDay) {
            print("Day 1 tapped")
        }
        
        DayPreviewRow(day: SampleData.samplePartialDay) {
            print("Day 3 tapped")
        }
        
        DayPreviewRow(day: SampleData.sampleCompletedDay) {
            print("Day 5 tapped")
        }
        
        // Example with many exercises
        DayPreviewRow(day: Day(
            dayNumber: 7,
            date: Date(),
            exercises: Array(SampleData.sampleExercises.prefix(6))
        )) {
            print("Day 7 tapped")
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
