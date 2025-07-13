//
//  DayRowView.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//  UPDATED: Added day of week functionality matching DayPreviewRow
//  UPDATED: Added missed day visual indicators
//

import SwiftUI

struct DayRowView: View {
    let day: Day
    
    var body: some View {
        HStack {
            // Day circle
            ZStack {
                Circle()
                    .fill(dayCircleColor)
                    .frame(width: 40, height: 40)
                
                Text("\(day.dayNumber)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // UPDATED: Show focus instead of "Day X"
                Text((day.focus ?? "Day \(day.dayNumber)").capitalized)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                // UPDATED: Add day of week with date (matching DayPreviewRow)
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
                    
                    // Smart date indicators (matching DayPreviewRow logic)
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
                }
                
                Text("\(day.exercises.count) exercise\(day.exercises.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // UPDATED: Status indicator with missed day support
            if day.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            } else if day.isMissed {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.title3)
            } else {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
    
    // MARK: - Computed Properties (matching DayPreviewRow)
    
    private var dayCircleColor: Color {
        if isToday {
            return Color.green // Today
        } else if day.isMissed {
            return Color.orange // Missed days - orange to indicate attention needed
        } else if isPastDay {
            return Color.blue.opacity(0.7) // Past completed days
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
        } else if day.isMissed {
            return Color.orange // Missed days - orange to match circle
        } else if isPastDay {
            return Color.secondary // Past days - subdued
        } else {
            return Color.primary // Future days - normal
        }
    }
    
    // MARK: - Date Logic (matching DayPreviewRow logic)
    
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
        let today = calendar.startOfDay(for: Date())  // ← Fix: Use startOfDay
        let targetDay = calendar.startOfDay(for: day.date)  // ← Fix: Use startOfDay
        let daysUntilStart = calendar.dateComponents([.day], from: today, to: targetDay).day ?? 0
        return daysUntilStart <= 3
    }
    
    /// Text for the start soon indicator
    private var startSoonText: String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())  // ← Fix: Use startOfDay
        let targetDay = calendar.startOfDay(for: day.date)  // ← Fix: Use startOfDay
        let daysUntilStart = calendar.dateComponents([.day], from: today, to: targetDay).day ?? 0
        
        switch daysUntilStart {
        case 1:
            return "TOMORROW"
        case 2:
            return "STARTS"
        case 3:
            return "STARTS"
        default:
            return "STARTS"
        }
    }}

#Preview("Day Row States") {
    VStack(spacing: 12) {
        // Today example
        DayRowView(day: Day(
            dayNumber: 5,
            date: Date(),
            exercises: Array(SampleData.sampleExercises.prefix(3))
        ))
        
        // Completed past day example
        DayRowView(day: {
            var day = Day(
                dayNumber: 3,
                date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
                exercises: Array(SampleData.sampleExercises.prefix(4))
            )
            // Mark exercises as completed
            day.exercises = day.exercises.map { exercise in
                var completedExercise = exercise
                completedExercise.isCompleted = true
                return completedExercise
            }
            return day
        }())
        
        // Missed day example (past and incomplete)
        DayRowView(day: Day(
            dayNumber: 4,
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            exercises: Array(SampleData.sampleExercises.prefix(2))
        ))
        
        // Future day example
        DayRowView(day: Day(
            dayNumber: 8,
            date: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
            exercises: Array(SampleData.sampleExercises.prefix(2))
        ))
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Missed Day Focus") {
    VStack(spacing: 12) {
        // Show different missed day states
        DayRowView(day: Day.sampleMissedDay())
        DayRowView(day: Day.sampleCompletedPastDay())
        DayRowView(day: Day.sampleTodayDay())
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
