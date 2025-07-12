//
//  BadgeService.swift
//  Fit14
//
//  Created by Jerson on 7/12/25.
//  Service for managing badge logic, progress tracking, and achievement detection
//

import Foundation
import SwiftUI

/// Service responsible for all badge-related business logic
class BadgeService: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var lastEarnedBadges: [Badge] = []
    @Published var shouldShowCelebration = false
    
    // MARK: - Private Properties
    
    private var previousCompletionCount: Int = 0
    private let notificationCenter = NotificationCenter.default
    
    // MARK: - Singleton
    
    static let shared = BadgeService()
    
    private init() {
        setupNotifications()
    }
    
    // MARK: - Core Badge Logic
    
    /// Check for newly earned badges and trigger celebrations
    /// Call this whenever the completion count changes
    func checkForNewBadges(completionCount: Int) {
        let newlyEarned = getNewlyEarnedBadges(
            previousCount: previousCompletionCount,
            currentCount: completionCount
        )
        
        if !newlyEarned.isEmpty {
            handleNewBadgesEarned(newlyEarned)
        }
        
        previousCompletionCount = completionCount
    }
    
    /// Get badges that were just earned with this completion
    func getNewlyEarnedBadges(previousCount: Int, currentCount: Int) -> [Badge] {
        let previouslyEarned = Badge.earned(completionCount: previousCount)
        let currentlyEarned = Badge.earned(completionCount: currentCount)
        
        // Find badges that are in currentlyEarned but not in previouslyEarned
        return currentlyEarned.filter { currentBadge in
            !previouslyEarned.contains { previousBadge in
                previousBadge.id == currentBadge.id
            }
        }
    }
    
    /// Get comprehensive badge statistics for a given completion count
    func getBadgeStats(completionCount: Int) -> BadgeStats {
        let earnedBadges = Badge.earned(completionCount: completionCount)
        let unearnedBadges = Badge.unearned(completionCount: completionCount)
        let nextBadge = Badge.nextToUnlock(completionCount: completionCount)
        
        let rarityBreakdown = Dictionary(grouping: earnedBadges, by: \.rarity)
            .mapValues { $0.count }
        
        let highestRarity = earnedBadges
            .map(\.rarity)
            .max { $0.sortOrder < $1.sortOrder }
        
        let totalProgress = Badge.allBadges.reduce(0.0) { total, badge in
            total + badge.progress(completionCount: completionCount)
        } / Double(Badge.allBadges.count)
        
        return BadgeStats(
            totalBadges: Badge.allBadges.count,
            earnedCount: earnedBadges.count,
            unearnedCount: unearnedBadges.count,
            completionPercentage: Double(earnedBadges.count) / Double(Badge.allBadges.count),
            highestRarity: highestRarity,
            nextBadge: nextBadge,
            rarityBreakdown: rarityBreakdown,
            overallProgress: totalProgress
        )
    }
    
    /// Get badges filtered and sorted by various criteria
    func getFilteredBadges(
        completionCount: Int,
        filter: BadgeFilter = .all,
        sortBy: BadgeSortOption = .unlockOrder
    ) -> [Badge] {
        var badges = Badge.allBadges
        
        // Apply filter
        switch filter {
        case .all:
            break
        case .earned:
            badges = badges.filter { $0.isEarned(completionCount: completionCount) }
        case .unearned:
            badges = badges.filter { !$0.isEarned(completionCount: completionCount) }
        case .rarity(let rarity):
            badges = badges.filter { $0.rarity == rarity }
        case .nearCompletion(let threshold):
            badges = badges.filter { badge in
                let progress = badge.progress(completionCount: completionCount)
                return progress >= threshold && progress < 1.0
            }
        }
        
        // Apply sorting
        switch sortBy {
        case .unlockOrder:
            badges.sort { $0.unlockCount < $1.unlockCount }
        case .rarity:
            badges.sort { badge1, badge2 in
                if badge1.rarity == badge2.rarity {
                    return badge1.unlockCount < badge2.unlockCount
                }
                return badge1.rarity < badge2.rarity
            }
        case .alphabetical:
            badges.sort { $0.name < $1.name }
        case .progress(let completionCount):
            badges.sort { badge1, badge2 in
                let progress1 = badge1.progress(completionCount: completionCount)
                let progress2 = badge2.progress(completionCount: completionCount)
                return progress1 > progress2 // Higher progress first
            }
        }
        
        return badges
    }
    
    /// Get badges that are close to being unlocked (within a certain threshold)
    func getUpcomingBadges(completionCount: Int, threshold: Int = 3) -> [Badge] {
        return Badge.unearned(completionCount: completionCount)
            .filter { $0.remainingToUnlock(completionCount: completionCount) <= threshold }
            .sorted { $0.unlockCount < $1.unlockCount }
    }
    
    /// Get progress summary for the next few badges
    func getProgressSummary(completionCount: Int, limit: Int = 3) -> [BadgeProgress] {
        let upcomingBadges = getUpcomingBadges(completionCount: completionCount, threshold: 10)
            .prefix(limit)
        
        return upcomingBadges.map { badge in
            BadgeProgress(
                badge: badge,
                progress: badge.progress(completionCount: completionCount),
                remaining: badge.remainingToUnlock(completionCount: completionCount),
                isEarned: badge.isEarned(completionCount: completionCount)
            )
        }
    }
    
    // MARK: - Badge Achievements & Celebrations
    
    /// Handle newly earned badges with celebrations and notifications
    private func handleNewBadgesEarned(_ badges: [Badge]) {
        lastEarnedBadges = badges
        shouldShowCelebration = true
        
        // Trigger haptic feedback
        triggerHapticFeedback(for: badges)
        
        // Post notification for other parts of the app
        badges.forEach { badge in
            notificationCenter.post(
                name: .badgeEarned,
                object: nil,
                userInfo: ["badge": badge]
            )
        }
        
        // Log achievement for analytics
        logBadgeAchievements(badges)
        
        // Auto-hide celebration after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.shouldShowCelebration = false
        }
    }
    
    /// Trigger appropriate haptic feedback based on badge rarity
    private func triggerHapticFeedback(for badges: [Badge]) {
        let highestRarity = badges.map(\.rarity).max { $0.sortOrder < $1.sortOrder }
        
        let feedbackGenerator: UIImpactFeedbackGenerator
        
        switch highestRarity {
        case .bronze, .silver:
            feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        case .gold:
            feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        case .platinum, .legendary:
            feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
        case .none:
            feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        }
        
        feedbackGenerator.impactOccurred()
        
        // Additional feedback for legendary badges
        if highestRarity == .legendary {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                feedbackGenerator.impactOccurred()
            }
        }
    }
    
    /// Log badge achievements for analytics
    private func logBadgeAchievements(_ badges: [Badge]) {
        badges.forEach { badge in
            print("🏆 Badge Earned: \(badge.name) (\(badge.rarity.displayName))")
            
            // Here you could integrate with analytics services like:
            // Analytics.logEvent("badge_earned", parameters: [
            //     "badge_id": badge.id,
            //     "badge_name": badge.name,
            //     "rarity": badge.rarity.rawValue,
            //     "unlock_count": badge.unlockCount
            // ])
        }
    }
    
    // MARK: - Integration Helpers
    
    /// Initialize the service with current completion count
    func initialize(with completionCount: Int) {
        previousCompletionCount = completionCount
    }
    
    /// Reset badge state (useful for testing or user data reset)
    func reset() {
        previousCompletionCount = 0
        lastEarnedBadges.removeAll()
        shouldShowCelebration = false
    }
    
    /// Get share text for a specific badge
    func getShareText(for badge: Badge, completionCount: Int) -> String {
        return """
        🏆 Just earned the "\(badge.name)" badge in Fit14!
        
        \(badge.description)
        
        Rarity: \(badge.rarity.displayName)
        Requirement: \(badge.unlockCount) challenge\(badge.unlockCount == 1 ? "" : "s") completed
        Total completed: \(completionCount)
        
        #Fit14 #FitnessAchievement #\(badge.rarity.displayName)Badge
        """
    }
    
    /// Get motivational message based on current progress
    func getMotivationalMessage(completionCount: Int) -> String {
        let stats = getBadgeStats(completionCount: completionCount)
        
        if let nextBadge = stats.nextBadge {
            let remaining = nextBadge.remainingToUnlock(completionCount: completionCount)
            return "Just \(remaining) more challenge\(remaining == 1 ? "" : "s") to unlock \(nextBadge.name)!"
        } else {
            return "Incredible! You've earned all available badges! 🎉"
        }
    }
    
    // MARK: - Notification Setup
    
    private func setupNotifications() {
        // Listen for app state changes to handle badge checks
        notificationCenter.addObserver(
            self,
            selector: #selector(handleAppDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc private func handleAppDidBecomeActive() {
        // Could check for time-based badges here if needed
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
}

// MARK: - Supporting Data Structures

/// Comprehensive badge statistics
struct BadgeStats {
    let totalBadges: Int
    let earnedCount: Int
    let unearnedCount: Int
    let completionPercentage: Double
    let highestRarity: BadgeRarity?
    let nextBadge: Badge?
    let rarityBreakdown: [BadgeRarity: Int]
    let overallProgress: Double
}

/// Badge progress information
struct BadgeProgress {
    let badge: Badge
    let progress: Double
    let remaining: Int
    let isEarned: Bool
}

/// Filter options for badges
enum BadgeFilter {
    case all
    case earned
    case unearned
    case rarity(BadgeRarity)
    case nearCompletion(Double) // Progress threshold (0.0 to 1.0)
}

/// Sorting options for badges
enum BadgeSortOption {
    case unlockOrder
    case rarity
    case alphabetical
    case progress(Int) // Completion count for progress-based sorting
}

// MARK: - Notification Names

extension Notification.Name {
    static let badgeEarned = Notification.Name("badgeEarned")
    static let badgeProgress = Notification.Name("badgeProgress")
}

// MARK: - Preview Helpers

extension BadgeService {
    /// Create a preview instance with mock data
    static func preview(with completionCount: Int = 5) -> BadgeService {
        let service = BadgeService()
        service.initialize(with: completionCount)
        return service
    }
}
