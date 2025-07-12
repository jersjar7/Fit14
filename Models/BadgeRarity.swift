//
//  BadgeRarity.swift
//  Fit14
//
//  Created by Jerson on 7/12/25.
//  Badge rarity system for challenge completion achievements
//

import SwiftUI

enum BadgeRarity: String, CaseIterable, Codable {
    case bronze = "bronze"
    case silver = "silver"
    case gold = "gold"
    case platinum = "platinum"
    case legendary = "legendary"
    
    // MARK: - Display Properties
    
    /// Human-readable name for the rarity
    var displayName: String {
        switch self {
        case .bronze:
            return "Bronze"
        case .silver:
            return "Silver"
        case .gold:
            return "Gold"
        case .platinum:
            return "Platinum"
        case .legendary:
            return "Legendary"
        }
    }
    
    /// Primary color associated with this rarity
    var primaryColor: Color {
        switch self {
        case .bronze:
            return Color.orange
        case .silver:
            return Color.gray
        case .gold:
            return Color.yellow
        case .platinum:
            return Color.blue
        case .legendary:
            return Color.purple
        }
    }
    
    /// Secondary/accent color for gradients and highlights
    var accentColor: Color {
        switch self {
        case .bronze:
            return Color.orange.opacity(0.7)
        case .silver:
            return Color.gray.opacity(0.8)
        case .gold:
            return Color.yellow.opacity(0.8)
        case .platinum:
            return Color.cyan
        case .legendary:
            return Color.pink
        }
    }
    
    /// Gradient colors for premium visual effects
    var gradient: LinearGradient {
        switch self {
        case .bronze:
            return LinearGradient(
                colors: [Color.orange, Color.orange.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .silver:
            return LinearGradient(
                colors: [Color.gray, Color.gray.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .gold:
            return LinearGradient(
                colors: [Color.yellow, Color.orange],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .platinum:
            return LinearGradient(
                colors: [Color.blue, Color.cyan],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .legendary:
            return LinearGradient(
                colors: [Color.purple, Color.pink, Color.purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    // MARK: - Ordering and Comparison
    
    /// Numeric value for sorting (higher = more rare)
    var sortOrder: Int {
        switch self {
        case .bronze:
            return 1
        case .silver:
            return 2
        case .gold:
            return 3
        case .platinum:
            return 4
        case .legendary:
            return 5
        }
    }
    
    /// Get the rarity level from a completion count
    static func from(completionCount: Int) -> BadgeRarity {
        switch completionCount {
        case 1...2:
            return .bronze
        case 3...6:
            return .silver
        case 7...14:
            return .gold
        case 15...29:
            return .platinum
        default: // 30+
            return .legendary
        }
    }
}

// MARK: - Comparable Conformance

extension BadgeRarity: Comparable {
    static func < (lhs: BadgeRarity, rhs: BadgeRarity) -> Bool {
        return lhs.sortOrder < rhs.sortOrder
    }
}

// MARK: - Preview Helpers

extension BadgeRarity {
    /// All rarities in ascending order for previews
    static var allOrdered: [BadgeRarity] {
        return BadgeRarity.allCases.sorted()
    }
    
    /// Get a sample rarity for previews
    static var sample: BadgeRarity {
        return .gold
    }
}
