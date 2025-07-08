//
//  ChallengeDetailView.swift
//  Fit14
//
//  Created by Jerson on 7/8/25.
//

import SwiftUI

struct ChallengeDetailView: View {
    let challenge: CompletedChallenge
    @ObservedObject var viewModel: WorkoutPlanViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDay: DayCompletionRecord?
    @State private var showDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Section
                headerSection
                
                // Progress Visualization
                progressSection
                
                // Achievement Highlights
                achievementSection
                
                // Workout Calendar Grid
                workoutCalendarSection
                
                // Workout Summary
                workoutSummarySection
                
                // Action Buttons
                actionButtonsSection
                
                // Bottom padding
                Color.clear.frame(height: 20)
            }
            .padding(.horizontal)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(challenge.challengeTitle)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                moreOptionsMenu
            }
        }
        .sheet(item: $selectedDay) { day in
            DayDetailSheet(day: day, challenge: challenge)
        }
        .alert("Delete Challenge", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteChallenge()
            }
        } message: {
            Text("This will permanently delete this challenge from your history. This action cannot be undone.")
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Completion Badge
            completionBadge
            
            // Date Range and Duration
            VStack(spacing: 4) {
                Text(dateRangeText)
                    .font(.title3)
                    .fontWeight(.medium)
                
                Text(durationText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Main Stats
            HStack(spacing: 24) {
                statCard(
                    title: "Days Completed",
                    value: "\(challenge.completedDays)/\(challenge.totalDays)",
                    subtitle: "\(Int(challenge.successRate))% Success",
                    color: .blue,
                    icon: "calendar.circle.fill"
                )
                
                statCard(
                    title: "Exercises Done",
                    value: "\(challenge.completedExercises)/\(challenge.totalExercises)",
                    subtitle: "\(Int(challenge.exerciseCompletionPercentage))% Complete",
                    color: .green,
                    icon: "figure.strengthtraining.traditional"
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private var completionBadge: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(challenge.isFullyCompleted ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: challenge.isFullyCompleted ? "trophy.fill" : "clock.badge.checkmark")
                    .font(.system(size: 36))
                    .foregroundColor(challenge.isFullyCompleted ? .green : .orange)
            }
            
            Text(challenge.isFullyCompleted ? "Challenge Completed!" : "Challenge Finished")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(challenge.isFullyCompleted ? .green : .orange)
        }
    }
    
    private func statCard(title: String, value: String, subtitle: String, color: Color, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(color)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(8)
    }
    
    // MARK: - Progress Section
    
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress Overview")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Overall Progress Bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Overall Completion")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("\(Int(challenge.successRate))%")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(progressColor)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(.systemGray5))
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(progressColor)
                            .frame(width: geometry.size.width * (challenge.successRate / 100), height: 12)
                    }
                }
                .frame(height: 12)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private var progressColor: Color {
        switch challenge.successRate {
        case 90...100: return .green
        case 70..<90: return .orange
        case 50..<70: return .yellow
        default: return .red
        }
    }
    
    // MARK: - Achievement Section
    
    private var achievementSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Achievements")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                
                achievementCard(
                    title: "Perfect Days",
                    value: "\(challenge.perfectDays)",
                    icon: "star.fill",
                    color: .yellow
                )
                
                achievementCard(
                    title: "Longest Streak",
                    value: "\(challenge.longestStreak) days",
                    icon: "flame.fill",
                    color: .red
                )
                
                achievementCard(
                    title: "Most Consistent",
                    value: "Week \(challenge.mostConsistentWeek)",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .blue
                )
                
                achievementCard(
                    title: "Partial Days",
                    value: "\(challenge.partialDays)",
                    icon: "circle.righthalf.filled",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private func achievementCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 80)
        .padding(.vertical, 8)
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(8)
    }
    
    // MARK: - Workout Calendar Section
    
    private var workoutCalendarSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("14-Day Calendar")
                .font(.headline)
                .fontWeight(.semibold)
            
            let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
            
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(challenge.dailyCompletionRecord.sorted(by: { $0.dayNumber < $1.dayNumber }), id: \.id) { day in
                    dayCalendarCell(day: day)
                }
            }
            
            // Legend
            HStack(spacing: 16) {
                legendItem(color: .green, text: "Completed", icon: "checkmark.circle.fill")
                legendItem(color: .orange, text: "Partial", icon: "circle.righthalf.filled")
                legendItem(color: .gray, text: "Missed", icon: "circle")
                
                Spacer()
            }
            .font(.caption)
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private func dayCalendarCell(day: DayCompletionRecord) -> some View {
        Button(action: {
            selectedDay = day
        }) {
            VStack(spacing: 4) {
                Text("\(day.dayNumber)")
                    .font(.caption)
                    .fontWeight(.medium)
                
                Image(systemName: day.isCompleted ? "checkmark.circle.fill" :
                      day.isPartialDay ? "circle.righthalf.filled" : "circle")
                    .font(.title3)
                    .foregroundColor(day.isCompleted ? .green :
                                   day.isPartialDay ? .orange : .gray)
            }
            .frame(width: 40, height: 50)
            .background(Color(.tertiarySystemGroupedBackground))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(day.isCompleted ? Color.green : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func legendItem(color: Color, text: String, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
            
            Text(text)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Workout Summary Section
    
    private var workoutSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Workout Summary")
                .font(.headline)
                .fontWeight(.semibold)
            
            ForEach(challenge.dailyCompletionRecord.sorted(by: { $0.dayNumber < $1.dayNumber }), id: \.id) { day in
                workoutSummaryRow(day: day)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private func workoutSummaryRow(day: DayCompletionRecord) -> some View {
        HStack(spacing: 12) {
            // Day indicator
            VStack {
                Text("Day")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text("\(day.dayNumber)")
                    .font(.caption)
                    .fontWeight(.bold)
            }
            .frame(width: 30)
            
            // Status icon
            Image(systemName: day.isCompleted ? "checkmark.circle.fill" :
                  day.isPartialDay ? "circle.righthalf.filled" : "circle")
                .foregroundColor(day.isCompleted ? .green :
                               day.isPartialDay ? .orange : .gray)
                .font(.title3)
            
            // Exercise summary
            VStack(alignment: .leading, spacing: 2) {
                Text("\(day.completedExercises)/\(day.totalExercises) exercises completed")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if !day.exerciseCompletionRecord.isEmpty {
                    Text(day.exerciseCompletionRecord.map { $0.exerciseName }.joined(separator: " • "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Completion percentage
            Text("\(Int(day.completionPercentage))%")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(day.isCompleted ? .green : .secondary)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            selectedDay = day
        }
    }
    
    // MARK: - Action Buttons Section
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            if !viewModel.hasActivePlan {
                Button(action: {
                    startNewChallengeBasedOnThis()
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Start Similar Challenge")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(12)
                }
            }
            
            Button(action: {
                shareChallenge()
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Achievement")
                }
                .font(.subheadline)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    // MARK: - More Options Menu
    
    private var moreOptionsMenu: some View {
        Menu {
            Button(action: shareChallenge) {
                Label("Share Achievement", systemImage: "square.and.arrow.up")
            }
            
            Button(action: {
                // Future: Export data
            }) {
                Label("Export Data", systemImage: "doc.text")
            }
            .disabled(true)
            
            Divider()
            
            Button(role: .destructive, action: {
                showDeleteAlert = true
            }) {
                Label("Delete Challenge", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.title3)
        }
    }
    
    // MARK: - Helper Methods
    
    private var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        let startText = formatter.string(from: challenge.startDate)
        let endText = formatter.string(from: challenge.completionDate)
        
        return "\(startText) - \(endText)"
    }
    
    private var durationText: String {
        let duration = challenge.challengeDuration
        return duration == 14 ? "Completed in 14 days" : "Completed in \(duration) days"
    }
    
    private func startNewChallengeBasedOnThis() {
        // Set up similar goals and start input
        viewModel.userGoalData.updateFreeFormText("Create a similar challenge to my previous: \(challenge.challengeTitle)")
        viewModel.startGoalInput()
        dismiss()
    }
    
    private func shareChallenge() {
        let shareText = """
        🏆 Completed my Fit14 Challenge!
        
        Challenge: \(challenge.challengeTitle)
        Days Completed: \(challenge.completedDays)/\(challenge.totalDays) (\(Int(challenge.successRate))%)
        Perfect Days: \(challenge.perfectDays)
        Longest Streak: \(challenge.longestStreak) days
        
        #Fit14 #FitnessChallenge #WorkoutComplete
        """
        
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first,
           let rootVC = window.rootViewController {
            activityVC.popoverPresentationController?.sourceView = window
            rootVC.present(activityVC, animated: true)
        }
    }
    
    private func deleteChallenge() {
        viewModel.deleteCompletedChallenge(challenge)
        dismiss()
    }
}

// MARK: - Day Detail Sheet

struct DayDetailSheet: View {
    let day: DayCompletionRecord
    let challenge: CompletedChallenge
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Day Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Day \(day.dayNumber)")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(DateFormatter().apply {
                            $0.dateStyle = .full
                            $0.timeStyle = .none
                        }.string(from: day.date))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        
                        // Completion Status
                        HStack {
                            Image(systemName: day.isCompleted ? "checkmark.circle.fill" :
                                  day.isPartialDay ? "circle.righthalf.filled" : "circle")
                                .foregroundColor(day.isCompleted ? .green :
                                               day.isPartialDay ? .orange : .gray)
                            
                            Text("\(day.completedExercises)/\(day.totalExercises) exercises completed")
                                .fontWeight(.medium)
                        }
                        .font(.headline)
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    
                    // Exercise List
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Exercises")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        ForEach(day.exerciseCompletionRecord, id: \.id) { exercise in
                            exerciseRow(exercise: exercise)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Day Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func exerciseRow(exercise: ExerciseCompletionRecord) -> some View {
        HStack(spacing: 12) {
            Image(systemName: exercise.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(exercise.isCompleted ? .green : .gray)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.exerciseName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(exercise.displayString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

struct ChallengeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChallengeDetailView(
                challenge: CompletedChallenge.sampleCompletedChallenge,
                viewModel: WorkoutPlanViewModel()
            )
        }
    }
}
