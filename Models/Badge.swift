//
//  Badge.swift
//  Fit14
//
//  Created by Jerson on 7/12/25.
//  Badge model and predefined achievement badges for challenge completions
//

import Foundation

struct Badge: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let description: String
    let icon: String // SF Symbol name
    let unlockCount: Int // Number of completed challenges required
    let rarity: BadgeRarity
    
    // MARK: - Computed Properties
    
    /// Whether this badge has been earned by the user
    func isEarned(completionCount: Int) -> Bool {
        return completionCount >= unlockCount
    }
    
    /// Progress towards unlocking this badge (0.0 to 1.0)
    func progress(completionCount: Int) -> Double {
        guard unlockCount > 0 else { return 1.0 }
        let progress = Double(completionCount) / Double(unlockCount)
        return min(progress, 1.0)
    }
    
    /// How many more completions needed to unlock this badge
    func remainingToUnlock(completionCount: Int) -> Int {
        return max(0, unlockCount - completionCount)
    }
}

// MARK: - Predefined Badges

extension Badge {
    /// All available badges in the system
    static let allBadges: [Badge] = [
        // BRONZE TIER - Getting Started
        Badge(
            id: "first_steps",
            name: "First Steps",
            description: "Completed your very first 2-week challenge! Every journey begins with a single step.",
            icon: "figure.walk",
            unlockCount: 1,
            rarity: .bronze
        ),
        
        Badge(
            id: "building_momentum",
            name: "Building Momentum",
            description: "Two challenges down! You're proving that consistency is your superpower.",
            icon: "arrow.up.right",
            unlockCount: 2,
            rarity: .bronze
        ),
        
        // SILVER TIER - Habit Formation
        Badge(
            id: "habit_former",
            name: "Habit Former",
            description: "Three challenges completed! You're officially building lasting fitness habits.",
            icon: "repeat.circle",
            unlockCount: 3,
            rarity: .silver
        ),
        
        Badge(
            id: "fitness_champion",
            name: "Fitness Champion",
            description: "Five challenges conquered! Your dedication is truly inspiring.",
            icon: "trophy",
            unlockCount: 5,
            rarity: .silver
        ),
        
        // GOLD TIER - Serious Commitment
        Badge(
            id: "consistency_crown",
            name: "Consistency Crown",
            description: "Seven challenges! You've shown that consistency is the crown jewel of fitness.",
            icon: "crown",
            unlockCount: 7,
            rarity: .gold
        ),
        
        Badge(
            id: "perfect_ten",
            name: "Perfect Ten",
            description: "Ten challenges completed! You've reached double digits and proven your commitment.",
            icon: "10.circle",
            unlockCount: 10,
            rarity: .gold
        ),
        
        // PLATINUM TIER - Elite Status
        Badge(
            id: "fitness_legend",
            name: "Fitness Legend",
            description: "Fifteen challenges! You're writing your own fitness legend, one challenge at a time.",
            icon: "star.circle",
            unlockCount: 15,
            rarity: .platinum
        ),
        
        Badge(
            id: "ultimate_warrior",
            name: "Ultimate Warrior",
            description: "Twenty challenges! You've achieved ultimate warrior status with unmatched dedication.",
            icon: "shield",
            unlockCount: 20,
            rarity: .legendary
        ),
        
        Badge(
            id: "unstoppable_force",
            name: "Unstoppable Force",
            description: "Twenty-five challenges! You are truly an unstoppable force of fitness excellence.",
            icon: "bolt.circle",
            unlockCount: 25,
            rarity: .legendary
        )
    ]
    
    // MARK: - Badge Filtering and Utilities
    
    /// Get all badges earned by a user with given completion count
    static func earned(completionCount: Int) -> [Badge] {
        return allBadges.filter { $0.isEarned(completionCount: completionCount) }
    }
    
    /// Get all badges not yet earned by a user
    static func unearned(completionCount: Int) -> [Badge] {
        return allBadges.filter { !$0.isEarned(completionCount: completionCount) }
    }
    
    /// Get the next badge to unlock
    static func nextToUnlock(completionCount: Int) -> Badge? {
        return unearned(completionCount: completionCount)
            .min(by: { $0.unlockCount < $1.unlockCount })
    }
    
    /// Get badges by rarity level
    static func badges(withRarity rarity: BadgeRarity) -> [Badge] {
        return allBadges.filter { $0.rarity == rarity }
    }
    
    /// Get the most recently earned badge
    static func mostRecentlyEarned(completionCount: Int) -> Badge? {
        return earned(completionCount: completionCount)
            .max(by: { $0.unlockCount < $1.unlockCount })
    }
    
    /// Get badges sorted by unlock count (ascending)
    static var sortedByUnlockCount: [Badge] {
        return allBadges.sorted { $0.unlockCount < $1.unlockCount }
    }
    
    /// Get badges sorted by rarity then unlock count
    static var sortedByRarity: [Badge] {
        return allBadges.sorted {
            if $0.rarity == $1.rarity {
                return $0.unlockCount < $1.unlockCount
            }
            return $0.rarity < $1.rarity
        }
    }
}

// MARK: - Sample Data for Previews

extension Badge {
    /// Sample earned badge for previews
    static let sampleEarned = Badge(
        id: "sample_earned",
        name: "Sample Champion",
        description: "This is a sample badge for preview purposes.",
        icon: "trophy.fill",
        unlockCount: 3,
        rarity: .gold
    )
    
    /// Sample unearned badge for previews
    static let sampleUnearned = Badge(
        id: "sample_unearned",
        name: "Future Goal",
        description: "This badge represents a future achievement to work towards.",
        icon: "target",
        unlockCount: 10,
        rarity: .platinum
    )
    
    /// Sample badges for different rarities
    static let samplesByRarity: [BadgeRarity: Badge] = [
        .bronze: allBadges.first { $0.rarity == .bronze }!,
        .silver: allBadges.first { $0.rarity == .silver }!,
        .gold: allBadges.first { $0.rarity == .gold }!,
        .platinum: allBadges.first { $0.rarity == .platinum }!,
        .legendary: allBadges.first { $0.rarity == .legendary }!
    ]
}
