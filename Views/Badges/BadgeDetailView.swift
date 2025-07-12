//
//  BadgeDetailView.swift
//  Fit14
//
//  Created by Jerson on 7/12/25.
//  Detailed modal view for displaying individual badge information and achievements
//

import SwiftUI

struct BadgeDetailView: View {
    let badge: Badge
    let isEarned: Bool
    let completionCount: Int
    @Environment(\.dismiss) private var dismiss
    @State private var showCelebration = false
    @State private var currentImageIndex = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Large Badge Display
                    badgeDisplaySection
                    
                    // Badge Information
                    badgeInfoSection
                    
                    // Progress Section (for unearned badges)
                    if !isEarned {
                        progressSection
                    }
                    
                    // Achievement Details
                    achievementSection
                    
                    // Rarity Information
                    raritySection
                    
                    // Share Section (for earned badges)
                    if isEarned {
                        shareSection
                    }
                    
                    // Bottom spacing
                    Color.clear.frame(height: 20)
                }
                .padding(24)
            }
            .background(backgroundGradient)
            .navigationTitle("Badge Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.medium)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .onAppear {
            if isEarned {
                // Celebration animation for earned badges
                withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                    showCelebration = true
                }
            }
        }
    }
    
    // MARK: - Badge Display Section
    
    private var badgeDisplaySection: some View {
        VStack(spacing: 20) {
            ZStack {
                // Background glow effect for earned badges
                if isEarned {
                    Circle()
                        .fill(badge.rarity.primaryColor.opacity(0.2))
                        .frame(width: 160, height: 160)
                        .blur(radius: 20)
                        .scaleEffect(showCelebration ? 1.3 : 1.0)
                        .opacity(showCelebration ? 0.6 : 0.3)
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: showCelebration)
                }
                
                // Main badge circle
                ZStack {
                    Circle()
                        .fill(isEarned ? badge.rarity.gradient : LinearGradient(
                            gradient: Gradient(colors: [Color(.systemGray4)]),
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                        .frame(width: 140, height: 140)
                        .shadow(
                            color: isEarned ? badge.rarity.primaryColor.opacity(0.4) : .clear,
                            radius: isEarned ? 15 : 0,
                            x: 0,
                            y: 5
                        )
                    
                    // Lock overlay for unearned badges
                    if !isEarned {
                        Circle()
                            .fill(Color.black.opacity(0.4))
                            .frame(width: 140, height: 140)
                        
                        Image(systemName: "lock.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    } else {
                        // Badge icon
                        Image(systemName: badge.icon)
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                    }
                    
                    // Outer ring for earned badges
                    if isEarned {
                        Circle()
                            .stroke(badge.rarity.accentColor, lineWidth: 3)
                            .frame(width: 150, height: 150)
                    }
                }
                .scaleEffect(showCelebration ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 0.6), value: showCelebration)
            }
            
            // Badge Status
            badgeStatusView
        }
    }
    
    private var badgeStatusView: some View {
        VStack(spacing: 8) {
            if isEarned {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("EARNED")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.green.opacity(0.1))
                .cornerRadius(20)
            } else {
                HStack(spacing: 6) {
                    Image(systemName: "lock.circle.fill")
                        .foregroundColor(.orange)
                    Text("LOCKED")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(20)
            }
        }
    }
    
    // MARK: - Badge Info Section
    
    private var badgeInfoSection: some View {
        VStack(spacing: 16) {
            // Name and Rarity
            VStack(spacing: 8) {
                Text(badge.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                rarityBadge
            }
            
            // Description
            Text(badge.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .padding(.horizontal, 8)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    private var rarityBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "star.fill")
                .font(.caption)
                .foregroundColor(badge.rarity.primaryColor)
            
            Text(badge.rarity.displayName.uppercased())
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(badge.rarity.primaryColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(badge.rarity.primaryColor.opacity(0.15))
        .cornerRadius(12)
    }
    
    // MARK: - Progress Section (Unearned Badges)
    
    private var progressSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "target")
                    .foregroundColor(.blue)
                Text("Progress to Unlock")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 12) {
                // Progress bar
                VStack(spacing: 8) {
                    HStack {
                        Text("Challenges Completed")
                            .font(.subheadline)
                        Spacer()
                        Text("\(completionCount) / \(badge.unlockCount)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(badge.rarity.primaryColor)
                    }
                    
                    ProgressView(value: badge.progress(completionCount: completionCount))
                        .progressViewStyle(LinearProgressViewStyle(tint: badge.rarity.primaryColor))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                }
                
                // Remaining count
                let remaining = badge.remainingToUnlock(completionCount: completionCount)
                HStack {
                    Image(systemName: "flag.checkered")
                        .foregroundColor(.orange)
                    Text("\(remaining) more challenge\(remaining == 1 ? "" : "s") to unlock this badge!")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Achievement Section
    
    private var achievementSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "trophy")
                    .foregroundColor(.yellow)
                Text("Achievement Details")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 12) {
                achievementRow(
                    icon: "number.circle",
                    title: "Requirement",
                    value: "Complete \(badge.unlockCount) challenge\(badge.unlockCount == 1 ? "" : "s")",
                    color: .blue
                )
                
                achievementRow(
                    icon: "star.circle",
                    title: "Rarity Level",
                    value: badge.rarity.displayName,
                    color: badge.rarity.primaryColor
                )
                
                if isEarned {
                    achievementRow(
                        icon: "checkmark.circle",
                        title: "Status",
                        value: "Unlocked & Earned",
                        color: .green
                    )
                } else {
                    achievementRow(
                        icon: "clock.circle",
                        title: "Status",
                        value: "In Progress",
                        color: .orange
                    )
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    private func achievementRow(icon: String, title: String, value: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
    
    // MARK: - Rarity Section
    
    private var raritySection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "crown")
                    .foregroundColor(badge.rarity.primaryColor)
                Text("Rarity Information")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 12) {
                Text("This is a \(badge.rarity.displayName.lowercased()) rarity badge.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Rarity scale
                rarityScale
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    private var rarityScale: some View {
        HStack(spacing: 4) {
            ForEach(BadgeRarity.allOrdered, id: \.self) { rarity in
                VStack(spacing: 4) {
                    Circle()
                        .fill(rarity == badge.rarity ? rarity.primaryColor : Color(.systemGray5))
                        .frame(width: rarity == badge.rarity ? 16 : 12, height: rarity == badge.rarity ? 16 : 12)
                        .overlay(
                            Circle()
                                .stroke(rarity == badge.rarity ? rarity.primaryColor : Color.clear, lineWidth: 2)
                                .frame(width: 20, height: 20)
                        )
                    
                    Text(rarity.displayName)
                        .font(.caption2)
                        .foregroundColor(rarity == badge.rarity ? rarity.primaryColor : .secondary)
                        .fontWeight(rarity == badge.rarity ? .semibold : .regular)
                }
            }
        }
    }
    
    // MARK: - Share Section (Earned Badges)
    
    private var shareSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(.blue)
                Text("Share Achievement")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            Button(action: shareBadge) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share This Badge")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Visual Properties
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(.systemGroupedBackground),
                badge.rarity.primaryColor.opacity(isEarned ? 0.05 : 0.02)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // MARK: - Actions
    
    private func shareBadge() {
        let shareText = """
        🏆 Just earned the "\(badge.name)" badge in Fit14!
        
        \(badge.description)
        
        Rarity: \(badge.rarity.displayName)
        Requirement: \(badge.unlockCount) challenge\(badge.unlockCount == 1 ? "" : "s") completed
        
        #Fit14 #FitnessAchievement #\(badge.rarity.displayName)Badge
        """
        
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first,
           let rootVC = window.rootViewController {
            activityVC.popoverPresentationController?.sourceView = window
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Convenience Initializers

extension BadgeDetailView {
    /// Create badge detail view from user's completion count
    init(badge: Badge, completionCount: Int) {
        self.badge = badge
        self.isEarned = badge.isEarned(completionCount: completionCount)
        self.completionCount = completionCount
    }
}

// MARK: - Preview

#Preview("Earned Gold Badge") {
    BadgeDetailView(
        badge: Badge.allBadges[4], // Consistency Crown
        isEarned: true,
        completionCount: 7
    )
}

#Preview("Unearned Legendary Badge") {
    BadgeDetailView(
        badge: Badge.allBadges[7], // Ultimate Warrior
        isEarned: false,
        completionCount: 15
    )
}

#Preview("Bronze Badge In Progress") {
    BadgeDetailView(
        badge: Badge.allBadges[1], // Building Momentum
        isEarned: false,
        completionCount: 1
    )
}
