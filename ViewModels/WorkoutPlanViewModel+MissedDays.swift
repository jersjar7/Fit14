//
//  WorkoutPlanViewModel+MissedDays.swift
//  Fit14
//
//  Created by Jerson on 7/11/25.
//  Extension to handle missed day logic for workout plans
//

import Foundation

// MARK: - Missed Days Extension
extension WorkoutPlanViewModel {
    
    // MARK: - Core Missed Day Properties
    
    /// Whether the current plan has any missed days that can still be caught up
    var hasMissedDays: Bool {
        guard let plan = currentPlan, plan.isActive else { return false }
        
        // If plan is finished, no more catch-ups allowed
        guard !plan.isFinished else { return false }
        
        return !missedDays.isEmpty
    }
    /// Count of missed days in the current plan
    var missedDayCount: Int {
        return missedDays.count
    }
    
    /// Array of missed days (past due and not completed)
    var missedDays: [Day] {
        guard let plan = currentPlan, plan.isActive else { return [] }
        return plan.days.filter { $0.isMissed }
    }
    
    /// Array of days available for catch-up (missed but within 14-day window)
    var catchUpAvailableDays: [Day] {
        guard let plan = currentPlan, plan.isActive else { return [] }
        
        // Can only catch up if the 14-day period hasn't ended
        guard !plan.isFinished else { return [] }
        
        return plan.days.filter { $0.isAvailableForCatchUp }
    }
    
    // MARK: - Missed Day Analytics
    
    /// Total days that are past due (missed + completed past days)
    var pastDueDayCount: Int {
        guard let plan = currentPlan, plan.isActive else { return 0 }
        return plan.days.filter { $0.isPastDue }.count
    }
    
    /// Percentage of past due days that were completed (success rate)
    var pastDaySuccessRate: Double {
        guard pastDueDayCount > 0 else { return 0.0 }
        guard let plan = currentPlan, plan.isActive else { return 0.0 }
        let completedPastDays = plan.days.filter { $0.isPastDue && $0.isCompleted }.count
        return (Double(completedPastDays) / Double(pastDueDayCount)) * 100.0
    }
    
    /// Whether user is currently on track (no missed days)
    var isOnTrack: Bool {
        return !hasMissedDays
    }
    
    // Note: currentStreak property already exists in main WorkoutPlanViewModel
    
    // MARK: - User-Friendly Messages
    
    /// Get appropriate missed days message for banner
    var missedDaysMessage: String {
        guard let plan = currentPlan else { return "" }
        
        // If plan is finished, show different message
        if plan.isFinished {
            return "Challenge period has ended"
        }
        
        let count = missedDayCount
        
        switch count {
        case 0:
            return ""
        case 1:
            return "You have 1 missed day available to complete"
        case 2...3:
            return "You have \(count) missed days available to complete"
        case 4...6:
            return "Don't give up! You have \(count) days to catch up on"
        default:
            return "Ready for a fresh start? You can still complete your challenge"
        }
    }
    
    /// Get motivational message based on missed day situation and time remaining
    var motivationalMessage: String {
        guard let plan = currentPlan else { return "" }
        
        // If plan is finished, show completion-focused message
        if plan.isFinished {
            let percentage = Int(plan.progressPercentage)
            return "You completed \(percentage)% of your challenge!"
        }
        
        let count = missedDayCount
        let successRate = pastDaySuccessRate
        
        switch count {
        case 0:
            if successRate >= 90 {
                return "Amazing consistency! Keep it up!"
            } else {
                return "You're doing great! Stay on track!"
            }
        case 1:
            return "Life happens! One makeup day and you're back on track!"
        case 2...3:
            return "You've got this! A few catch-up sessions and you'll be done!"
        case 4...6:
            return "Don't stop now! You've come too far to quit!"
        default:
            return "Every step counts! Ready to finish strong?"
        }
    }
    
    // MARK: - Catch-Up Recommendations
    
    /// Suggest how many days to catch up on today
    var suggestedCatchUpDays: Int {
        let available = catchUpAvailableDays.count
        
        switch available {
        case 0:
            return 0
        case 1...2:
            return available
        case 3...4:
            return 2 // Don't overwhelm, suggest 2 max per day
        default:
            return 2 // Cap at 2 workouts per day
        }
    }
    
    /// Whether user should be offered a restart option
    var shouldOfferRestart: Bool {
        let totalMissed = missedDayCount
        let totalDays = currentPlan?.totalDays ?? 14
        
        // Offer restart if missed more than 50% of days or more than 7 days total
        return totalMissed > (totalDays / 2) || totalMissed > 7
    }
    
    // MARK: - Time-Based Helpers
    
    /// Get the oldest missed day (most urgent to catch up)
    var oldestMissedDay: Day? {
        return missedDays.min { $0.date < $1.date }
    }
    
    /// Get the most recent missed day
    var mostRecentMissedDay: Day? {
        return missedDays.max { $0.date < $1.date }
    }
    
    /// Days since the oldest missed day
    var daysSinceOldestMissed: Int {
        guard let oldestDay = oldestMissedDay else { return 0 }
        return max(0, oldestDay.daysFromToday)
    }
    
    // MARK: - Challenge Status Assessment
    
    /// Overall challenge health status
    var challengeHealthStatus: ChallengeHealthStatus {
        let missedCount = missedDayCount
        let totalDays = currentPlan?.totalDays ?? 14
        let completedDays = currentPlan?.completedDays ?? 0
        let streak = currentStreak.days // Use existing currentStreak from main ViewModel
        
        // If more than 50% missed
        if missedCount > (totalDays / 2) {
            return .needsSupport
        }
        
        // If more than 7 days missed
        if missedCount > 7 {
            return .struggling
        }
        
        // If 3-6 days missed
        if missedCount >= 3 {
            return .behindButRecoverable
        }
        
        // If 1-2 days missed
        if missedCount > 0 {
            return .slightlyBehind
        }
        
        // No missed days
        if completedDays > (totalDays / 2) {
            return .excellent
        } else {
            return .onTrack
        }
    }
}

// MARK: - Challenge Health Status Enum
enum ChallengeHealthStatus {
    case excellent           // No missed days, good progress
    case onTrack            // No missed days, early in challenge
    case slightlyBehind     // 1-2 missed days
    case behindButRecoverable // 3-6 missed days
    case struggling         // 7+ missed days
    case needsSupport       // 50%+ missed days
    
    var emoji: String {
        switch self {
        case .excellent: return "🔥"
        case .onTrack: return "💪"
        case .slightlyBehind: return "⚡"
        case .behindButRecoverable: return "🎯"
        case .struggling: return "💙"
        case .needsSupport: return "🤝"
        }
    }
    
    var description: String {
        switch self {
        case .excellent: return "Crushing it!"
        case .onTrack: return "On track"
        case .slightlyBehind: return "Slightly behind"
        case .behindButRecoverable: return "Behind but recoverable"
        case .struggling: return "Struggling but not out"
        case .needsSupport: return "Needs support"
        }
    }
}

// MARK: - Debug Helpers
#if DEBUG
extension WorkoutPlanViewModel {
    /// Print missed days debug info
    func debugMissedDays() {
        print("=== Missed Days Debug ===")
        print("Has missed days: \(hasMissedDays)")
        print("Missed day count: \(missedDayCount)")
        print("Past due day count: \(pastDueDayCount)")
        print("Success rate: \(pastDaySuccessRate)%")
        print("Current streak: \(currentStreak.days)") // Use existing currentStreak from main ViewModel
        print("Challenge health: \(challengeHealthStatus.description)")
        print("Should offer restart: \(shouldOfferRestart)")
        
        if !missedDays.isEmpty {
            print("Missed days:")
            for day in missedDays.sorted(by: { $0.dayNumber < $1.dayNumber }) {
                print("  - Day \(day.dayNumber): \(day.daysFromToday) days ago")
            }
        }
        print("========================")
    }
}
#endif
