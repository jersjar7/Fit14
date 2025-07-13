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
    @State private var showBadgeCollection = false  // ← Add this line
    
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
            .navigationTitle("Plan History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {  // ← Replace historyStatsButton with Menu
                        Button(action: {
                            showBadgeCollection = true
                        }) {
                            Label("View Badge Collection", systemImage: "rosette")
                        }
                        // Could add more options here later like:
                        // - Export History
                        // - Share Achievements
                        // - Statistics

                        // Keep your existing stats functionality
                        Button(action: {
                            // Add your existing historyStatsButton action here
                            // (whatever the historyStatsButton currently does)
                        }) {
                            Label("View Statistics", systemImage: "chart.bar")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .accessibilityLabel("More options")
                    }
                }
            }
            .sheet(isPresented: $showBadgeCollection) {  // ← Add this sheet
                BadgeCollectionView()
                    .environmentObject(viewModel)
            }
            .refreshable {
                viewModel.loadChallengeHistory()
            }
        }
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
                        // Switch to current challenge tab to continue active challenge
                        NotificationCenter.default.post(name: .switchToCurrentChallengeTab, object: nil)
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
                    // Switch to current challenge tab to start goal input
                    NotificationCenter.default.post(name: .switchToCurrentChallengeTab, object: nil)
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
        
                // Summary Stats Card (if there are multiple challenges)
                if viewModel.completedChallenges.count > 1 {
                    summaryStatsCard
                        .padding(.horizontal)
                        .padding(.top, 8)
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
            PlanHistoryView(viewModel: emptyStateViewModel())
                .previewDisplayName("Empty State")
            
            // With Challenges
            PlanHistoryView(viewModel: previewViewModelWithChallenges())
                .previewDisplayName("With Challenges")
        }
    }
    
    static func emptyStateViewModel() -> WorkoutPlanViewModel {
        let viewModel = WorkoutPlanViewModel()
        // Force empty state by clearing any loaded challenges
        viewModel.completedChallenges = []
        viewModel.isLoadingHistory = false
        return viewModel
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
