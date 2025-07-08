//
//  ChallengeCard.swift
//  Fit14
//
//  Created by Jerson on 7/8/25.
//

import SwiftUI

// MARK: - Challenge Card Component

struct ChallengeCard: View {
    let challenge: CompletedChallenge
    var showDetailedStats: Bool = true
    var cardStyle: CardStyle = .standard
    
    enum CardStyle {
        case standard
        case compact
        case featured
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: cardSpacing) {
            // Header Section
            headerSection
            
            // Progress Section
            progressSection
            
            // Additional Stats (conditional)
            if showDetailedStats && (challenge.perfectDays > 0 || challenge.longestStreak > 1) {
                additionalStatsSection
            }
        }
        .padding(cardPadding)
        .background(backgroundColor)
        .cornerRadius(cornerRadius)
        .overlay(borderOverlay)
        .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowOffset)
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Challenge Title
            Text(challenge.challengeTitle)
                .font(titleFont)
                .fontWeight(.semibold)
                .lineLimit(titleLineLimit)
                .multilineTextAlignment(.leading)
                .foregroundColor(.primary)
            
            // Date Range
            Text(dateRangeText)
                .font(subtitleFont)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Progress Section
    
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Progress Bar
            progressBar
            
            // Stats Row
            HStack {
                // Completion Stats
                completionStats
                
                Text("•")
                    .foregroundColor(.secondary)
                    .font(.caption)
                
                // Success Rate
                Text("\(Int(challenge.successRate))% Success Rate")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Completion Badge
                completionBadge
            }
        }
    }
    
    private var completionStats: some View {
        HStack(spacing: 4) {
            Image(systemName: completionIcon)
                .foregroundColor(completionIconColor)
                .font(.caption)
            
            Text("\(challenge.completedDays)/\(challenge.totalDays) Days")
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
    
    private var completionIcon: String {
        if challenge.isFullyCompleted {
            return "checkmark.circle.fill"
        } else if challenge.successRate >= 70 {
            return "checkmark.circle"
        } else {
            return "clock.circle"
        }
    }
    
    private var completionIconColor: Color {
        if challenge.isFullyCompleted {
            return .green
        } else if challenge.successRate >= 70 {
            return .orange
        } else {
            return .gray
        }
    }
    
    // MARK: - Progress Bar
    
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: progressBarCornerRadius)
                    .fill(Color(.systemGray5))
                    .frame(height: progressBarHeight)
                
                // Progress Fill
                RoundedRectangle(cornerRadius: progressBarCornerRadius)
                    .fill(progressColor)
                    .frame(
                        width: geometry.size.width * (challenge.successRate / 100),
                        height: progressBarHeight
                    )
                    .animation(.easeInOut(duration: 0.3), value: challenge.successRate)
            }
        }
        .frame(height: progressBarHeight)
    }
    
    private var progressColor: Color {
        switch challenge.successRate {
        case 95...100: return .green
        case 80..<95: return Color.green.opacity(0.8)
        case 70..<80: return .orange
        case 50..<70: return .yellow
        case 25..<50: return Color.orange.opacity(0.7)
        default: return .red
        }
    }
    
    // MARK: - Completion Badge
    
    private var completionBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: badgeIcon)
                .font(.caption2)
            
            Text(badgeText)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(badgeColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(badgeBackgroundColor)
        .cornerRadius(6)
    }
    
    private var badgeIcon: String {
        challenge.isFullyCompleted ? "trophy.fill" : "clock.fill"
    }
    
    private var badgeText: String {
        challenge.isFullyCompleted ? "Completed" : "Finished"
    }
    
    private var badgeColor: Color {
        challenge.isFullyCompleted ? .yellow : .secondary
    }
    
    private var badgeBackgroundColor: Color {
        challenge.isFullyCompleted ? Color.yellow.opacity(0.15) : Color(.systemGray6)
    }
    
    // MARK: - Additional Stats Section
    
    private var additionalStatsSection: some View {
        HStack(spacing: 12) {
            if challenge.perfectDays > 0 {
                statBadge(
                    icon: "star.fill",
                    text: "\(challenge.perfectDays) Perfect Day\(challenge.perfectDays == 1 ? "" : "s")",
                    color: .yellow
                )
            }
            
            if challenge.longestStreak > 1 {
                statBadge(
                    icon: "flame.fill",
                    text: "\(challenge.longestStreak) Day Streak",
                    color: .red
                )
            }
            
            if challenge.exerciseCompletionPercentage >= 90 && challenge.exerciseCompletionPercentage < 100 {
                statBadge(
                    icon: "figure.strengthtraining.traditional",
                    text: "\(Int(challenge.exerciseCompletionPercentage))% Exercises",
                    color: .blue
                )
            }
            
            Spacer()
        }
    }
    
    private func statBadge(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(color)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(4)
    }
    
    // MARK: - Date Range Text
    
    private var dateRangeText: String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        // If same month, show abbreviated format
        if calendar.isDate(challenge.startDate, equalTo: challenge.completionDate, toGranularity: .month) {
            let startDay = calendar.component(.day, from: challenge.startDate)
            let endDay = calendar.component(.day, from: challenge.completionDate)
            
            let monthYearFormatter = DateFormatter()
            monthYearFormatter.dateFormat = "MMM yyyy"
            let monthYear = monthYearFormatter.string(from: challenge.startDate)
            
            return "\(monthYear) (\(startDay)-\(endDay))"
        } else {
            // Different months - show full range
            formatter.dateFormat = "MMM d"
            let startText = formatter.string(from: challenge.startDate)
            let endText = formatter.string(from: challenge.completionDate)
            
            let yearFormatter = DateFormatter()
            yearFormatter.dateFormat = "yyyy"
            let year = yearFormatter.string(from: challenge.completionDate)
            
            return "\(startText) - \(endText), \(year)"
        }
    }
    
    // MARK: - Style Configuration
    
    private var titleFont: Font {
        switch cardStyle {
        case .standard:
            return .headline
        case .compact:
            return .subheadline
        case .featured:
            return .title3
        }
    }
    
    private var subtitleFont: Font {
        switch cardStyle {
        case .standard:
            return .subheadline
        case .compact:
            return .caption
        case .featured:
            return .subheadline
        }
    }
    
    private var titleLineLimit: Int {
        cardStyle == .compact ? 1 : 2
    }
    
    private var cardSpacing: CGFloat {
        switch cardStyle {
        case .standard:
            return 12
        case .compact:
            return 8
        case .featured:
            return 16
        }
    }
    
    private var cardPadding: CGFloat {
        switch cardStyle {
        case .standard:
            return 16
        case .compact:
            return 12
        case .featured:
            return 20
        }
    }
    
    private var backgroundColor: Color {
        switch cardStyle {
        case .standard, .compact:
            return Color(.secondarySystemGroupedBackground)
        case .featured:
            return Color(.secondarySystemGroupedBackground)
        }
    }
    
    private var cornerRadius: CGFloat {
        switch cardStyle {
        case .standard, .compact:
            return 12
        case .featured:
            return 16
        }
    }
    
    private var borderOverlay: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .stroke(borderColor, lineWidth: borderWidth)
    }
    
    private var borderColor: Color {
        switch cardStyle {
        case .standard, .compact:
            return Color(.separator)
        case .featured:
            return challenge.isFullyCompleted ? Color.green.opacity(0.3) : Color(.separator)
        }
    }
    
    private var borderWidth: CGFloat {
        switch cardStyle {
        case .standard, .compact:
            return 0.5
        case .featured:
            return challenge.isFullyCompleted ? 1.5 : 0.5
        }
    }
    
    private var shadowColor: Color {
        switch cardStyle {
        case .standard, .compact:
            return Color.black.opacity(0.05)
        case .featured:
            return Color.black.opacity(0.1)
        }
    }
    
    private var shadowRadius: CGFloat {
        switch cardStyle {
        case .standard, .compact:
            return 2
        case .featured:
            return 4
        }
    }
    
    private var shadowOffset: CGFloat {
        switch cardStyle {
        case .standard, .compact:
            return 1
        case .featured:
            return 2
        }
    }
    
    private var progressBarHeight: CGFloat {
        switch cardStyle {
        case .standard, .featured:
            return 8
        case .compact:
            return 6
        }
    }
    
    private var progressBarCornerRadius: CGFloat {
        switch cardStyle {
        case .standard, .featured:
            return 4
        case .compact:
            return 3
        }
    }
}

// MARK: - Card Modifiers

extension ChallengeCard {
    /// Apply compact style for smaller displays
    func compact() -> ChallengeCard {
        var card = self
        card.cardStyle = .compact
        return card
    }
    
    /// Apply featured style for highlighting
    func featured() -> ChallengeCard {
        var card = self
        card.cardStyle = .featured
        return card
    }
    
    /// Hide detailed statistics
    func hideDetailedStats() -> ChallengeCard {
        var card = self
        card.showDetailedStats = false
        return card
    }
    
    /// Show detailed statistics
    func showDetailedStats(_ show: Bool = true) -> ChallengeCard {
        var card = self
        card.showDetailedStats = show
        return card
    }
}

// MARK: - Accessibility

extension ChallengeCard {
    private var accessibilityLabel: String {
        var label = "Challenge: \(challenge.challengeTitle). "
        label += "Completed \(challenge.completedDays) out of \(challenge.totalDays) days. "
        label += "Success rate: \(Int(challenge.successRate)) percent. "
        
        if challenge.isFullyCompleted {
            label += "Challenge fully completed. "
        }
        
        if challenge.perfectDays > 0 {
            label += "\(challenge.perfectDays) perfect days. "
        }
        
        if challenge.longestStreak > 1 {
            label += "Longest streak: \(challenge.longestStreak) days. "
        }
        
        return label
    }
    
    private var accessibilityHint: String {
        "Double tap to view detailed challenge information"
    }
}

// MARK: - Preview

struct ChallengeCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Standard Style
            VStack(spacing: 16) {
                ChallengeCard(challenge: CompletedChallenge.sampleCompletedChallenge)
                    .previewDisplayName("Standard Style")
                
                ChallengeCard(challenge: CompletedChallenge.samplePerfectChallenge)
                    .previewDisplayName("Perfect Challenge")
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            
            // Compact Style
            VStack(spacing: 12) {
                ChallengeCard(challenge: CompletedChallenge.sampleCompletedChallenge)
                    .compact()
                
                ChallengeCard(challenge: CompletedChallenge.samplePerfectChallenge)
                    .compact()
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .previewDisplayName("Compact Style")
            
            // Featured Style
            ChallengeCard(challenge: CompletedChallenge.samplePerfectChallenge)
                .featured()
                .padding()
                .background(Color(.systemGroupedBackground))
                .previewDisplayName("Featured Style")
            
            // Without Detailed Stats
            ChallengeCard(challenge: CompletedChallenge.sampleCompletedChallenge)
                .hideDetailedStats()
                .padding()
                .background(Color(.systemGroupedBackground))
                .previewDisplayName("No Detailed Stats")
        }
        .previewLayout(.sizeThatFits)
    }
}

// MARK: - Sample Data Extension

extension CompletedChallenge {
    /// Sample challenge with poor performance for testing
    static let samplePoorPerformanceChallenge: CompletedChallenge = {
        let startDate = Calendar.current.date(byAdding: .day, value: -20, to: Date()) ?? Date()
        let completionDate = Calendar.current.date(byAdding: .day, value: -6, to: Date()) ?? Date()
        
        var dailyRecords: [DayCompletionRecord] = []
        for i in 1...14 {
            let dayDate = Calendar.current.date(byAdding: .day, value: i-1, to: startDate) ?? Date()
            let exerciseRecords = [
                ExerciseCompletionRecord(exerciseName: "Push-ups", sets: 3, quantity: 10, unit: .reps, isCompleted: i <= 4),
                ExerciseCompletionRecord(exerciseName: "Squats", sets: 3, quantity: 15, unit: .reps, isCompleted: i <= 3),
                ExerciseCompletionRecord(exerciseName: "Plank", sets: 1, quantity: 30, unit: .seconds, isCompleted: i <= 2)
            ]
            
            let record = DayCompletionRecord(
                dayNumber: i,
                date: dayDate,
                totalExercises: 3,
                completedExercises: exerciseRecords.filter { $0.isCompleted }.count,
                exerciseCompletionRecord: exerciseRecords
            )
            dailyRecords.append(record)
        }
        
        return CompletedChallenge(
            originalPlanId: UUID(),
            challengeTitle: "14-Day Getting Started Challenge",
            userGoals: "Start building a fitness habit with basic exercises",
            startDate: startDate,
            completionDate: completionDate,
            totalDays: 14,
            completedDays: 4,
            totalExercises: 42,
            completedExercises: 9,
            dailyCompletionRecord: dailyRecords
        )
    }()
}
