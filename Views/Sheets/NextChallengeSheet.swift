//
//  NextChallengeSheet.swift
//  Fit14
//
//  Created by Jerson on 7/12/25.
//  Extracted from PlanListView for better code organization
//  UPDATED: Added contextual completion messaging based on user's challenge history

import SwiftUI

struct NextChallengeSheet: View {
    @EnvironmentObject var viewModel: WorkoutPlanViewModel
    @Environment(\.dismiss) private var dismiss
    
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
                    
                    // View Achievement Section
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "trophy.fill")
                                .foregroundColor(.orange)
                            Text("Your Achievement")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        
                        Button(action: {
                            dismiss()
                            // Switch to history tab to view achievement
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                NotificationCenter.default.post(name: .switchToHistoryTab, object: nil)
                            }
                        }) {
                            HStack {
//                                Image(systemName: "trophy.circle.fill")
                                Text("View Your Completed Challenge")
                            }
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    
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
                        dismiss()
                        // Note: UI will handle archiving before this is called
                        viewModel.startNewChallenge()
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
    // Simulate multiple completed challenges for testing different messages
    viewModel.completedChallenges = [
        CompletedChallenge.sampleCompletedChallenge,
        CompletedChallenge.samplePerfectChallenge,
        CompletedChallenge.sampleCompletedChallenge
    ]
    
    return NextChallengeSheet()
        .environmentObject(viewModel)
}
