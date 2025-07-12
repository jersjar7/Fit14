//
//  BadgeCardView.swift
//  Fit14
//
//  Created by Jerson on 7/12/25.
//  Individual badge card component for grid display in BadgeCollectionView
//

import SwiftUI

struct BadgeCardView: View {
    let badge: Badge
    let isEarned: Bool
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Badge Icon Circle
            badgeIconSection
            
            // Badge Info
            badgeInfoSection
            
            // Unlock Requirement (for unearned badges)
            if !isEarned {
                unlockRequirementSection
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .frame(height: 180) // Fixed height for consistent grid
        .background(cardBackground)
        .overlay(cardBorder)
        .cornerRadius(16)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onTapGesture {
            // Haptic feedback for earned badges
            if isEarned {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }
        }
        .onLongPressGesture(minimumDuration: 0) {
            // Handle press state for visual feedback
        } onPressingChanged: { pressing in
            isPressed = pressing
        }
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(isEarned ? "Tap to view badge details" : "Unlock by completing more challenges")
    }
    
    // MARK: - Badge Icon Section
    
    private var badgeIconSection: some View {
        ZStack {
            // Background circle with rarity gradient or gray
            Circle()
                .fill(isEarned ? badge.rarity.gradient : LinearGradient(
                    gradient: Gradient(colors: [Color(.systemGray5)]),
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .frame(width: 70, height: 70)
                .shadow(
                    color: isEarned ? badge.rarity.primaryColor.opacity(0.3) : .clear,
                    radius: isEarned ? 8 : 0,
                    x: 0,
                    y: 2
                )
            
            // Lock overlay for unearned badges
            if !isEarned {
                Circle()
                    .fill(Color.black.opacity(0.3))
                    .frame(width: 70, height: 70)
                
                Image(systemName: "lock.fill")
                    .font(.title3)
                    .foregroundColor(.white)
            } else {
                // Badge icon
                Image(systemName: badge.icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
            }
            
            // Rarity indicator ring for earned badges
            if isEarned {
                Circle()
                    .stroke(badge.rarity.accentColor, lineWidth: 2)
                    .frame(width: 76, height: 76)
            }
        }
    }
    
    // MARK: - Badge Info Section
    
    private var badgeInfoSection: some View {
        VStack(spacing: 6) {
            // Badge Name
            Text(badge.name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isEarned ? .primary : .secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            
            // Rarity Badge
            rarityBadge
        }
    }
    
    private var rarityBadge: some View {
        Text(badge.rarity.displayName.uppercased())
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundColor(isEarned ? badge.rarity.primaryColor : .secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(
                isEarned ?
                badge.rarity.primaryColor.opacity(0.15) :
                Color(.systemGray5)
            )
            .cornerRadius(6)
    }
    
    // MARK: - Unlock Requirement Section
    
    private var unlockRequirementSection: some View {
        VStack(spacing: 4) {
            Text("\(badge.unlockCount) challenge\(badge.unlockCount == 1 ? "" : "s")")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text("to unlock")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Visual Properties
    
    private var cardBackground: some View {
        Group {
            if isEarned {
                // Subtle gradient background for earned badges
                LinearGradient(
                    colors: [
                        Color(.secondarySystemGroupedBackground),
                        badge.rarity.primaryColor.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                // Simple background for unearned badges
                Color(.secondarySystemGroupedBackground)
            }
        }
    }
    
    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(
                isEarned ? badge.rarity.primaryColor.opacity(0.2) : Color(.systemGray4),
                lineWidth: isEarned ? 1.5 : 1
            )
    }
    
    private var accessibilityLabel: String {
        if isEarned {
            return "\(badge.name), \(badge.rarity.displayName) rarity badge, earned"
        } else {
            return "\(badge.name), \(badge.rarity.displayName) rarity badge, requires \(badge.unlockCount) challenges to unlock"
        }
    }
}

// MARK: - Badge Progress Card (Alternative Version)

struct BadgeProgressCardView: View {
    let badge: Badge
    let completionCount: Int
    
    private var isEarned: Bool {
        badge.isEarned(completionCount: completionCount)
    }
    
    private var progress: Double {
        badge.progress(completionCount: completionCount)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Badge Icon with Progress Ring
            ZStack {
                // Progress ring background
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 4)
                    .frame(width: 70, height: 70)
                
                // Progress ring foreground
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        badge.rarity.primaryColor,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 70, height: 70)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: progress)
                
                // Badge content
                if isEarned {
                    ZStack {
                        Circle()
                            .fill(badge.rarity.gradient)
                            .frame(width: 62, height: 62)
                        
                        Image(systemName: badge.icon)
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                } else {
                    ZStack {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 62, height: 62)
                        
                        Text("\(completionCount)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Badge Info
            VStack(spacing: 4) {
                Text(badge.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isEarned ? .primary : .secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                if !isEarned {
                    let remaining = badge.remainingToUnlock(completionCount: completionCount)
                    Text("\(remaining) more to go")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .frame(height: 160)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

// MARK: - Preview

#Preview("Badge Cards - Various States") {
    VStack(spacing: 16) {
        HStack(spacing: 16) {
            // Earned Bronze Badge
            BadgeCardView(
                badge: Badge.allBadges[0], // First Steps
                isEarned: true
            )
            
            // Unearned Silver Badge
            BadgeCardView(
                badge: Badge.allBadges[2], // Habit Former
                isEarned: false
            )
        }
        
        HStack(spacing: 16) {
            // Earned Gold Badge
            BadgeCardView(
                badge: Badge.allBadges[4], // Consistency Crown
                isEarned: true
            )
            
            // Unearned Legendary Badge
            BadgeCardView(
                badge: Badge.allBadges[7], // Ultimate Warrior
                isEarned: false
            )
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Badge Progress Cards") {
    HStack(spacing: 16) {
        // In Progress Badge
        BadgeProgressCardView(
            badge: Badge.allBadges[2], // Habit Former (needs 3)
            completionCount: 2 // User has 2, needs 1 more
        )
        
        // Earned Badge
        BadgeProgressCardView(
            badge: Badge.allBadges[1], // Building Momentum (needs 2)
            completionCount: 5 // User has completed it
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("All Rarity Levels") {
    ScrollView {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            ForEach(Badge.allBadges.prefix(6)) { badge in
                BadgeCardView(badge: badge, isEarned: true)
            }
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
