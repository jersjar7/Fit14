//
//  DayPreviewRow.swift
//  Fit14
//
//  Created by Jerson on 7/3/25.
//  Enhanced with day of week for better temporal awareness and AI-determined start date support
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
                    
                    // Space-efficient date with day of week and smart indicators
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
                        
                        // Smart date indicators (AI-determined dates compatible)
                        if isToday {
                            Text("TODAY")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green)
                                .cornerRadius(4)
                        } else if isFirstDayAndStartingSoon {
                            Text(startSoonText)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue)
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
    
    // MARK: - Date Logic (AI-Determined Date Compatible)
    
    /// Checks if this day is today - works with any AI-determined start date
    private var isToday: Bool {
        Calendar.current.isDate(day.date, inSameDayAs: Date())
    }
    
    /// Checks if this day is in the past - works with any AI-determined start date
    private var isPastDay: Bool {
        day.date < Calendar.current.startOfDay(for: Date())
    }
    
    /// Checks if this is Day 1 and it's starting soon (within next 3 days)
    private var isFirstDayAndStartingSoon: Bool {
        guard day.dayNumber == 1 && !isToday && !isPastDay else { return false }
        
        let calendar = Calendar.current
        let today = Date()
        let daysUntilStart = calendar.dateComponents([.day], from: today, to: day.date).day ?? 0
        
        return daysUntilStart > 0 && daysUntilStart <= 3
    }
    
    /// Smart text for "starting soon" indicator
    private var startSoonText: String {
        guard day.dayNumber == 1 else { return "" }
        
        let calendar = Calendar.current
        let today = Date()
        
        if calendar.isDate(day.date, inSameDayAs: calendar.date(byAdding: .day, value: 1, to: today) ?? today) {
            return "TOMORROW"
        } else {
            let daysUntilStart = calendar.dateComponents([.day], from: today, to: day.date).day ?? 0
            if daysUntilStart <= 3 {
                return "STARTS"
            }
        }
        
        return ""
    }
    
    // MARK: - Alternative Date Formats (Available if needed)
    
    // Full day names: formatter.dateFormat = "EEEE" // Monday, Tuesday
    // With year: formatter.dateFormat = "MMM d, yyyy" // Jan 15, 2025
    // Compact: formatter.dateFormat = "M/d" // 1/15
    
    /// Alternative formatter for different date display needs
    private func formatDate(_ date: Date, style: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        return formatter.string(from: date)
    }
    
    /// Get relative date description (e.g., "Tomorrow", "In 3 days")
    private func getRelativeDateDescription() -> String? {
        let calendar = Calendar.current
        let today = Date()
        
        if calendar.isDate(day.date, inSameDayAs: today) {
            return "Today"
        } else if calendar.isDate(day.date, inSameDayAs: calendar.date(byAdding: .day, value: 1, to: today) ?? today) {
            return "Tomorrow"
        } else if calendar.isDate(day.date, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: today) ?? today) {
            return "Yesterday"
        } else {
            let daysAway = calendar.dateComponents([.day], from: today, to: day.date).day ?? 0
            if abs(daysAway) <= 7 {
                return daysAway > 0 ? "In \(daysAway) days" : "\(-daysAway) days ago"
            }
        }
        
        return nil
    }
}

// MARK: - Preview
#Preview("AI-Determined Start Date Examples") {
    VStack(spacing: 12) {
        // Yesterday (past day) - works with any AI start date
        DayPreviewRow(day: Day(
            dayNumber: 1,
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            exercises: Array(SampleData.sampleExercises.prefix(3))
        )) {
            print("Yesterday tapped")
        }
        
        // Today (highlighted) - works regardless of which day number it is
        DayPreviewRow(day: Day(
            dayNumber: 2,
            date: Date(),
            exercises: Array(SampleData.sampleExercises.prefix(4))
        )) {
            print("Today tapped")
        }
        
        // Tomorrow - if this is Day 1, shows "TOMORROW" indicator
        DayPreviewRow(day: Day(
            dayNumber: 1,
            date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
            exercises: Array(SampleData.sampleExercises.prefix(2))
        )) {
            print("Tomorrow (Day 1) tapped")
        }
        
        // Day 1 starting in 2 days - shows "STARTS" indicator
        DayPreviewRow(day: Day(
            dayNumber: 1,
            date: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date(),
            exercises: Array(SampleData.sampleExercises.prefix(3))
        )) {
            print("Day 1 in 2 days tapped")
        }
        
        // Weekend day example - standard future day
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
