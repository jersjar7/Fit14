//
//  DayPreviewRow.swift
//  Fit14
//
//  Created by Jerson on 7/3/25.
//  Enhanced with day of week for better temporal awareness
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
                        .fill(dayCircleColor)
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
                    
                    // Space-efficient date with day of week
                    HStack(spacing: 4) {
                        Text(dayOfWeekText)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(dayOfWeekColor)
                        
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(shortDateText)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        
                        // Today indicator
                        if isToday {
                            Text("TODAY")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green)
                                .cornerRadius(4)
                        }
                        
                        Spacer()
                    }
                    
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
    
    // MARK: - Computed Properties
    
    private var dayCircleColor: Color {
        if isToday {
            return Color.green // Today
        } else if isPastDay {
            return Color.blue.opacity(0.7) // Past days
        } else {
            return Color.blue // Future days
        }
    }
    
    private var dayOfWeekText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE" // Short day name (Mon, Tue, Wed)
        return formatter.string(from: day.date)
    }
    
    private var shortDateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d" // "Jan 15" (no year needed for 2-week plans)
        return formatter.string(from: day.date)
    }
    
    private var dayOfWeekColor: Color {
        if isToday {
            return Color.green // Today - highlighted
        } else if isPastDay {
            return Color.secondary // Past days - subdued
        } else {
            return Color.primary // Future days - normal
        }
    }
    
    private var isToday: Bool {
        Calendar.current.isDate(day.date, inSameDayAs: Date())
    }
    
    private var isPastDay: Bool {
        day.date < Calendar.current.startOfDay(for: Date())
    }
    
    // Alternative formats available if needed:
    // Full day names: formatter.dateFormat = "EEEE" // Monday, Tuesday
    // With year: formatter.dateFormat = "MMM d, yyyy" // Jan 15, 2025
    // Compact: formatter.dateFormat = "M/d" // 1/15
}

// MARK: - Preview
#Preview("Space-Efficient Temporal Awareness") {
    VStack(spacing: 12) {
        // Yesterday (past day)
        DayPreviewRow(day: Day(
            dayNumber: 1,
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            exercises: Array(SampleData.sampleExercises.prefix(3))
        )) {
            print("Yesterday tapped")
        }
        
        // Today (highlighted)
        DayPreviewRow(day: Day(
            dayNumber: 2,
            date: Date(),
            exercises: Array(SampleData.sampleExercises.prefix(4))
        )) {
            print("Today tapped")
        }
        
        // Tomorrow (future day)
        DayPreviewRow(day: Day(
            dayNumber: 3,
            date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
            exercises: Array(SampleData.sampleExercises.prefix(2))
        )) {
            print("Tomorrow tapped")
        }
        
        // Weekend day example
        DayPreviewRow(day: Day(
            dayNumber: 7,
            date: Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date(),
            exercises: Array(SampleData.sampleExercises.prefix(3))
        )) {
            print("Weekend day tapped")
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
