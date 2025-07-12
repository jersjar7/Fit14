//
//  EarnedBadgeView.swift
//  Fit14
//
//  Created by Jerson on 7/12/25.
//  Compact badge display component for showing newly earned badges in NextChallengeSheet
//

import SwiftUI

struct EarnedBadgeView: View {
    let badge: Badge
    let completionCount: Int
    let onTap: () -> Void
    @State private var isPressed = false
    @State private var showCelebration = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundColor(.orange)
                Text("New Badge Earned!")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            // Badge Display
            Button(action: {
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                onTap()
            }) {
                HStack(spacing: 16) {
                    // Badge Icon
                    badgeIconSection
                    
                    // Badge Info
                    badgeInfoSection
                    
                    Spacer()
                    
                    // Navigate Arrow
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .padding(16)
                .background(badgeBackground)
                .cornerRadius(16)
                .overlay(badgeBorder)
                .scaleEffect(isPressed ? 0.98 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isPressed)
            }
            .buttonStyle(PlainButtonStyle())
            .onLongPressGesture(minimumDuration: 0) {
                // Handle press state for visual feedback
            } onPressingChanged: { pressing in
                isPressed = pressing
            }
            
            // Collection Navigation Hint
            Text("Tap to view your complete badge collection")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .onAppear {
            // Celebration animation when badge appears
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                showCelebration = true
            }
        }
    }
    
    // MARK: - Badge Icon Section
    
    private var badgeIconSection: some View {
        ZStack {
            // Background circle with rarity gradient
            Circle()
                .fill(badge.rarity.gradient)
                .frame(width: 60, height: 60)
                .shadow(
                    color: badge.rarity.primaryColor.opacity(0.4),
                    radius: 8,
                    x: 0,
                    y: 2
                )
            
            // Badge icon
            Image(systemName: badge.icon)
                .font(.title2)
                .foregroundColor(.white)
                .fontWeight(.semibold)
            
            // Rarity ring
            Circle()
                .stroke(badge.rarity.accentColor, lineWidth: 2)
                .frame(width: 66, height: 66)
            
            // Celebration particles (optional enhancement)
            if showCelebration {
                celebrationOverlay
            }
        }
    }
    
    // MARK: - Badge Info Section
    
    private var badgeInfoSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Badge Name
            Text(badge.name)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .lineLimit(2)
            
            // Rarity Badge
            rarityBadge
            
            // Achievement Description
            Text("Unlocked with \(completionCount) challenge\(completionCount == 1 ? "" : "s")!")
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
    }
    
    private var rarityBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.caption2)
                .foregroundColor(badge.rarity.primaryColor)
            
            Text(badge.rarity.displayName.uppercased())
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(badge.rarity.primaryColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(badge.rarity.primaryColor.opacity(0.15))
        .cornerRadius(8)
    }
    
    // MARK: - Visual Properties
    
    private var badgeBackground: some View {
        LinearGradient(
            colors: [
                Color(.secondarySystemGroupedBackground),
                badge.rarity.primaryColor.opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var badgeBorder: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(badge.rarity.primaryColor.opacity(0.3), lineWidth: 1.5)
    }
    
    // MARK: - Celebration Overlay
    
    private var celebrationOverlay: some View {
        ZStack {
            // Pulsing ring effect
            Circle()
                .stroke(badge.rarity.primaryColor.opacity(0.3), lineWidth: 3)
                .frame(width: 80, height: 80)
                .scaleEffect(showCelebration ? 1.2 : 1.0)
                .opacity(showCelebration ? 0.0 : 1.0)
                .animation(.easeOut(duration: 1.0).repeatCount(2, autoreverses: false), value: showCelebration)
        }
    }
}

// MARK: - No Badge Earned View

struct NoBadgeEarnedView: View {
    let completionCount: Int
    let nextBadge: Badge?
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "target")
                    .foregroundColor(.blue)
                Text("Your Collection")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            // Collection Button
            Button(action: onTap) {
                HStack(spacing: 16) {
                    // Badge Count Icon
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [.blue.opacity(0.8), .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 60, height: 60)
                        
                        VStack(spacing: 2) {
                            Text("\(Badge.earned(completionCount: completionCount).count)")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("badges")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    // Collection Info
                    VStack(alignment: .leading, spacing: 6) {
                        Text("View Badge Collection")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        if let nextBadge = nextBadge {
                            let remaining = nextBadge.remainingToUnlock(completionCount: completionCount)
                            Text("Next: \(nextBadge.name) (\(remaining) more)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text("You've collected all available badges!")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - Container View for NextChallengeSheet

struct BadgeEarnedSection: View {
    @EnvironmentObject var viewModel: WorkoutPlanViewModel
    let onTapCollection: () -> Void
    
    var body: some View {
        let completionCount = viewModel.completedChallenges.count
        let latestBadge = Badge.mostRecentlyEarned(completionCount: completionCount)
        
        Group {
            if let badge = latestBadge {
                EarnedBadgeView(
                    badge: badge,
                    completionCount: completionCount,
                    onTap: onTapCollection
                )
            } else {
                NoBadgeEarnedView(
                    completionCount: completionCount,
                    nextBadge: Badge.nextToUnlock(completionCount: completionCount),
                    onTap: onTapCollection
                )
            }
        }
    }
}

// MARK: - Preview

#Preview("Earned Badge - Gold") {
    EarnedBadgeView(
        badge: Badge.allBadges[4], // Consistency Crown (Gold)
        completionCount: 7,
        onTap: { print("Tapped badge collection") }
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Earned Badge - Legendary") {
    EarnedBadgeView(
        badge: Badge.allBadges[7], // Ultimate Warrior (Legendary)
        completionCount: 20,
        onTap: { print("Tapped badge collection") }
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("No Badge Earned") {
    NoBadgeEarnedView(
        completionCount: 2,
        nextBadge: Badge.allBadges[2], // Habit Former
        onTap: { print("Tapped collection") }
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Badge Section Container") {
    let viewModel = WorkoutPlanViewModel()
    viewModel.completedChallenges = [
        CompletedChallenge.sampleCompletedChallenge,
        CompletedChallenge.samplePerfectChallenge,
        CompletedChallenge.sampleCompletedChallenge
    ]
    
    return BadgeEarnedSection(onTapCollection: { print("Navigate to collection") })
        .environmentObject(viewModel)
        .padding()
        .background(Color(.systemGroupedBackground))
}
