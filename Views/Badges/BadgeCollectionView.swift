//
//  BadgeCollectionView.swift
//  Fit14
//
//  Created by Jerson on 7/12/25.
//  Gallery view displaying all earned and unearned badges in a grid layout
//

import SwiftUI

struct BadgeCollectionView: View {
    @EnvironmentObject var viewModel: WorkoutPlanViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedBadge: Badge?
    @State private var showOnlyEarned = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Stats Header
                    statsHeaderSection
                    
                    // Filter Toggle
                    filterSection
                    
                    // Next Badge Progress (if any unearned badges exist)
                    if let nextBadge = Badge.nextToUnlock(completionCount: viewModel.completedChallenges.count) {
                        nextBadgeSection(nextBadge)
                    }
                    
                    // Badges Grid
                    badgesGridSection
                    
                    // Bottom padding for better scrolling
                    Color.clear.frame(height: 20)
                }
                .padding(.horizontal)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Badge Collection")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.medium)
                }
            }
        }
        .sheet(item: $selectedBadge) { badge in
            BadgeDetailView(badge: badge, completionCount: viewModel.completedChallenges.count)
        }
    }
    
    // MARK: - Stats Header Section
    
    private var statsHeaderSection: some View {
        VStack(spacing: 16) {
            // Main Stats
            HStack(spacing: 24) {
                statCard(
                    title: "Challenges",
                    value: "\(viewModel.completedChallenges.count)",
                    subtitle: "Completed",
                    color: .blue,
                    icon: "checkmark.circle.fill"
                )
                
                statCard(
                    title: "Badges",
                    value: "\(earnedBadges.count)",
                    subtitle: "of \(Badge.allBadges.count)",
                    color: .orange,
                    icon: "trophy.fill"
                )
                
                statCard(
                    title: "Rarity",
                    value: highestRarity?.displayName ?? "None",
                    subtitle: "Highest",
                    color: highestRarity?.primaryColor ?? .gray,
                    icon: "star.fill"
                )
            }
            
            // Progress Bar for Badge Collection
            VStack(spacing: 8) {
                HStack {
                    Text("Collection Progress")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("\(Int(collectionProgress * 100))%")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(collectionProgress == 1.0 ? .green : .blue)
                }
                
                ProgressView(value: collectionProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: collectionProgress == 1.0 ? .green : .blue))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private func statCard(title: String, value: String, subtitle: String, color: Color, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(8)
    }
    
    // MARK: - Filter Section
    
    private var filterSection: some View {
        HStack {
            Button(action: {
                showOnlyEarned = false
            }) {
                Text("All Badges")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(showOnlyEarned ? .secondary : .white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(showOnlyEarned ? Color.clear : Color.blue)
                    .cornerRadius(20)
            }
            
            Button(action: {
                showOnlyEarned = true
            }) {
                Text("Earned Only")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(showOnlyEarned ? .white : .secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(showOnlyEarned ? Color.blue : Color.clear)
                    .cornerRadius(20)
            }
            
            Spacer()
            
            Text("\(filteredBadges.count) badges")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Next Badge Section
    
    private func nextBadgeSection(_ nextBadge: Badge) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "target")
                    .foregroundColor(.blue)
                Text("Next Badge Goal")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            HStack(spacing: 12) {
                // Badge Icon
                ZStack {
                    Circle()
                        .fill(nextBadge.rarity.gradient)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: nextBadge.icon)
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(nextBadge.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    let remaining = nextBadge.remainingToUnlock(completionCount: viewModel.completedChallenges.count)
                    Text("\(remaining) more challenge\(remaining == 1 ? "" : "s") to unlock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Progress bar for next badge
                    ProgressView(value: nextBadge.progress(completionCount: viewModel.completedChallenges.count))
                        .progressViewStyle(LinearProgressViewStyle(tint: nextBadge.rarity.primaryColor))
                        .frame(height: 4)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Badges Grid Section
    
    private var badgesGridSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(showOnlyEarned ? "Earned Badges" : "All Badges")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            LazyVGrid(columns: gridColumns, spacing: 16) {
                ForEach(filteredBadges) { badge in
                    BadgeCardView(
                        badge: badge,
                        isEarned: badge.isEarned(completionCount: viewModel.completedChallenges.count)
                    )
                    .onTapGesture {
                        selectedBadge = badge
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var earnedBadges: [Badge] {
        Badge.earned(completionCount: viewModel.completedChallenges.count)
    }
    
    private var filteredBadges: [Badge] {
        let badges = showOnlyEarned ? earnedBadges : Badge.sortedByUnlockCount
        return badges
    }
    
    private var collectionProgress: Double {
        guard !Badge.allBadges.isEmpty else { return 0.0 }
        return Double(earnedBadges.count) / Double(Badge.allBadges.count)
    }
    
    private var highestRarity: BadgeRarity? {
        earnedBadges.max(by: { $0.rarity < $1.rarity })?.rarity
    }
    
    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)
    }
}

// MARK: - Preview

#Preview("Badge Collection - Beginner") {
    let viewModel = WorkoutPlanViewModel()
    // Simulate 2 completed challenges (bronze level)
    viewModel.completedChallenges = [
        CompletedChallenge.sampleCompletedChallenge,
        CompletedChallenge.samplePerfectChallenge
    ]
    
    return BadgeCollectionView()
        .environmentObject(viewModel)
}

#Preview("Badge Collection - Advanced") {
    let viewModel = WorkoutPlanViewModel()
    // Simulate 12 completed challenges (gold level)
    let mockChallenges = Array(repeating: CompletedChallenge.sampleCompletedChallenge, count: 12)
    viewModel.completedChallenges = mockChallenges
    
    return BadgeCollectionView()
        .environmentObject(viewModel)
}
