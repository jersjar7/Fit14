//
//  PlanHistoryView.swift
//  Fit14
//
//  Created by Jerson on 7/8/25.
//  UPDATED: Added Next Challenge Section for completed challenges
//

import SwiftUI

struct PlanHistoryView: View {
    @ObservedObject var viewModel: WorkoutPlanViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if viewModel.isLoadingHistory {
                    loadingView
                } else if viewModel.completedChallenges.isEmpty {
                    emptyStateView
                } else {
                    challengeGalleryView
                }
            }
            .navigationTitle("Challenge History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    historyStatsButton
                }
            }
            .refreshable {
                viewModel.loadChallengeHistory()
            }
        }
    }
    
    // MARK: - Next Challenge Section Logic
    
    private var shouldShowNextChallengeSection: Bool {
        // Show if user has completed challenges and doesn't have an active plan
        return !viewModel.hasActivePlan &&
               viewModel.hasCompletedChallenges &&
               viewModel.recentChallenges.count > 0 // Has challenges completed in last 30 days
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading your challenges...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            // Icon
            Image(systemName: "trophy.circle")
                .font(.system(size: 80))
                .foregroundColor(.orange)
            
            // Title and Message
            VStack(spacing: 12) {
                Text("No Completed Challenges Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text("Complete your first 2-week challenge to see it here with all your progress stats!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            // Action Button (if user has an active plan)
            if viewModel.hasActivePlan {
                VStack(spacing: 8) {
                    let progress = viewModel.progressInfo
                    
                    Text("Current Challenge: \(progress.completed)/\(progress.total) days")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        // This will be handled by parent tab view switching
                    }) {
                        Text("Continue Current Challenge")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 32)
                }
            } else {
                Button(action: {
                    viewModel.startGoalInput()
                }) {
                    Text("Start Your First Challenge")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 32)
            }
        }
        .padding()
    }
    
    // MARK: - Challenge Gallery View
    
    private var challengeGalleryView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Next Challenge Section (if recently completed and no active plan)
                if shouldShowNextChallengeSection {
                    nextChallengeSection
                        .padding(.horizontal)
                        .padding(.top, 8)
                }
                
                // Summary Stats Card (if there are multiple challenges)
                if viewModel.completedChallenges.count > 1 {
                    summaryStatsCard
                        .padding(.horizontal)
                        .padding(.top, shouldShowNextChallengeSection ? 0 : 8)
                }
                
                // Challenge Cards
                ForEach(viewModel.completedChallenges) { challenge in
                    NavigationLink(destination: ChallengeDetailView(challenge: challenge, viewModel: viewModel)) {
                        ChallengeCard(challenge: challenge)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)
                }
                
                // Bottom padding
                Color.clear
                    .frame(height: 20)
            }
            .padding(.top, 8)
        }
    }
    
    // MARK: - Next Challenge Section
    
    private var nextChallengeSection: some View {
        VStack(spacing: 16) {
            // Header
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "trophy.fill")
                        .font(.title2)
                        .foregroundColor(.yellow)
                    
                    Text("Ready for Your Next Challenge?")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Spacer()
                }
                
                Text("You've proven you can stick to a plan and see results. Build on your momentum with a new 2-week goal!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            // Action Button
            Button(action: {
                viewModel.startGoalInput()
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Create New Challenge")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .cornerRadius(12)
            }
            
            // Next Challenge Suggestions Preview
            VStack(alignment: .leading, spacing: 8) {
                Text("Suggested next challenges:")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                let suggestions = viewModel.getNextChallengeSuggestions()
                ForEach(suggestions.prefix(3), id: \.self) { suggestion in
                    HStack {
                        Image(systemName: "arrow.right.circle")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text(suggestion)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.green.opacity(0.05), Color.blue.opacity(0.05)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Summary Stats Card
    
    private var summaryStatsCard: some View {
        let stats = viewModel.historyStats
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.orange)
                Text("Your Progress")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            HStack(spacing: 24) {
                statItem(
                    title: "Challenges",
                    value: "\(stats.totalChallenges)",
                    color: .blue
                )
                
                statItem(
                    title: "Avg Success",
                    value: "\(Int(stats.averageSuccessRate))%",
                    color: .green
                )
                
                statItem(
                    title: "Days Done",
                    value: "\(stats.totalDaysCompleted)",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private func statItem(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - History Stats Button
    
    private var historyStatsButton: some View {
        Menu {
            Button(action: {
                // Future: Show detailed analytics
            }) {
                Label("View Analytics", systemImage: "chart.line.uptrend.xyaxis")
            }
            .disabled(true) // Future feature
            
            Button(action: {
                viewModel.loadChallengeHistory()
            }) {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            
            Divider()
            
            Button(role: .destructive, action: {
                // Future: Clear all history with confirmation
            }) {
                Label("Clear History", systemImage: "trash")
            }
            .disabled(true) // Future feature
            
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.title3)
        }
    }
}

// MARK: - Preview

struct PlanHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Empty State
            PlanHistoryView(viewModel: WorkoutPlanViewModel())
                .previewDisplayName("Empty State")
            
            // With Challenges
            PlanHistoryView(viewModel: previewViewModelWithChallenges())
                .previewDisplayName("With Challenges")
        }
    }
    
    static func previewViewModelWithChallenges() -> WorkoutPlanViewModel {
        let viewModel = WorkoutPlanViewModel()
        viewModel.completedChallenges = [
            CompletedChallenge.sampleCompletedChallenge,
            CompletedChallenge.samplePerfectChallenge
        ]
        return viewModel
    }
}

// MARK: - Helper Extensions

extension DateFormatter {
    func apply(_ configuration: (DateFormatter) -> Void) -> DateFormatter {
        configuration(self)
        return self
    }
}
