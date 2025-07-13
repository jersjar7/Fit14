//
//  NextChallengeSheet.swift
//  Fit14
//
//  Created by Jerson on 7/12/25.
//  Extracted from PlanListView for better code organization
//  UPDATED: Added contextual completion messaging based on user's challenge history
//  UPDATED: Replaced achievement section with badge system integration

import SwiftUI

struct NextChallengeSheet: View {
    @EnvironmentObject var viewModel: WorkoutPlanViewModel
    @StateObject private var badgeService = BadgeService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showBadgeCollection = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Completion Message - UPDATED with contextual messaging
                    VStack(spacing: 16) {
                        Text(viewModel.contextualCompletionMessage)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.primary)
                        
                        Image(systemName: "trophy.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                    }
                    .padding()
                    .padding(.top)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Badge Achievement Section - UPDATED to replace View Achievement Section
                    badgeAchievementSection
                    
                    // Next Challenge Suggestions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Next Challenge Options:")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        let suggestions = viewModel.getNextChallengeSuggestions()
                        ForEach(suggestions, id: \.self) { suggestion in
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "target")
                                    .foregroundColor(.blue)
                                    .font(.title3)
                                
                                Text(suggestion)
                                    .font(.subheadline)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                        }
                    }
                    
                    // CTA Button
                    Button(action: {
                        // Dismiss sheet first, then start new challenge after a brief delay
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            viewModel.startNewChallenge()
                        }
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Create My Next Challenge")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    // Later option
                    Button("I'll decide later") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                    
                    Spacer(minLength: 20)
                }
                .padding(24)
            }
            .navigationTitle("Next Challenge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $showBadgeCollection) {
            BadgeCollectionView()
                .environmentObject(viewModel)
        }
        .onAppear {
            // Check for newly earned badges when sheet appears
            badgeService.checkForNewBadges(completionCount: viewModel.completedChallenges.count)
        }
    }
    
    // MARK: - Badge Achievement Section
    
    private var badgeAchievementSection: some View {
        VStack(spacing: 16) {
            // Check if any badges were just earned
            if !badgeService.lastEarnedBadges.isEmpty {
                // Show the most recent badge earned
                if let latestBadge = badgeService.lastEarnedBadges.last {
                    EarnedBadgeView(
                        badge: latestBadge,
                        completionCount: viewModel.completedChallenges.count,
                        onTap: {
                            showBadgeCollection = true
                        }
                    )
                }
            } else {
                // No new badges earned, show general collection view
                let nextBadge = Badge.nextToUnlock(completionCount: viewModel.completedChallenges.count)
                
                NoBadgeEarnedView(
                    completionCount: viewModel.completedChallenges.count,
                    nextBadge: nextBadge,
                    onTap: {
                        showBadgeCollection = true
                    }
                )
            }
            

        }
    }

}

// MARK: - Preview

#Preview("Next Challenge Sheet - First Completion") {
    let viewModel = WorkoutPlanViewModel()
    viewModel.currentPlan = SampleData.sampleCompletedWorkoutPlan
    // Note: Preview will show first completion message since sample data starts with empty challenge history
    
    return NextChallengeSheet()
        .environmentObject(viewModel)
}

#Preview("Next Challenge Sheet - Multiple Completions") {
    let viewModel = WorkoutPlanViewModel()
    viewModel.currentPlan = SampleData.sampleCompletedWorkoutPlan
    // Simulate multiple FULLY completed challenges for testing different messages
    viewModel.completedChallenges = [
        CompletedChallenge.samplePerfectChallenge, // This one is already perfect
        CompletedChallenge.samplePerfectChallenge, // Use perfect challenge
        CompletedChallenge.samplePerfectChallenge  // All 100% completed
    ]
    
    return NextChallengeSheet()
        .environmentObject(viewModel)
}

#Preview("Next Challenge Sheet - Badge Earned") {
    let viewModel = WorkoutPlanViewModel()
    viewModel.currentPlan = SampleData.sampleCompletedWorkoutPlan
    
    // Simulate exactly 3 PERFECT challenges to trigger "Habit Former" badge
    viewModel.completedChallenges = Array(repeating: CompletedChallenge.samplePerfectChallenge, count: 3)
    
    return NextChallengeSheet()
        .environmentObject(viewModel)
}

#Preview("Next Challenge Sheet - Many Perfect Challenges") {
    let viewModel = WorkoutPlanViewModel()
    viewModel.currentPlan = SampleData.sampleCompletedWorkoutPlan
    
    // Simulate 6 perfect challenges for champion-level messaging
    viewModel.completedChallenges = Array(repeating: CompletedChallenge.samplePerfectChallenge, count: 6)
    
    return NextChallengeSheet()
        .environmentObject(viewModel)
}

#Preview("Next Challenge Sheet - No Badges Yet") {
    let viewModel = WorkoutPlanViewModel()
    viewModel.currentPlan = SampleData.sampleCompletedWorkoutPlan
    // Empty challenges array for no badges scenario
    viewModel.completedChallenges = []
    
    return NextChallengeSheet()
        .environmentObject(viewModel)
}
