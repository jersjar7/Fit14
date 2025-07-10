//
//  ContentView.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//  Updated for tab navigation integration
//  UPDATED: Aligned with user-controlled completion flow, removed auto-handling
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: WorkoutPlanViewModel
    @State private var hasAppeared = false
    
    var body: some View {
        Group {
            if viewModel.hasActivePlan {
                ActivePlanView()
                    .environmentObject(viewModel)
            } else if viewModel.hasSuggestedPlan {
                SuggestedPlanView()
                    .environmentObject(viewModel)
            } else {
                GoalInputView()
                    .environmentObject(viewModel)
            }
        }
        .onAppear {
            if !hasAppeared {
                viewModel.loadSavedPlan()
                hasAppeared = true
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.hasActivePlan)
        .animation(.easeInOut(duration: 0.3), value: viewModel.hasSuggestedPlan)
        .alert("Critical Error", isPresented: .constant(viewModel.showError && shouldShowGlobalError)) {
            Button("Restart") {
                restartApp()
            }
            Button("Cancel") {
                viewModel.clearError()
            }
        } message: {
            Text("A critical error occurred. Restarting will clear your data and return you to the beginning.")
        }
    }
    
    // MARK: - Error Handling
    
    private var shouldShowGlobalError: Bool {
        guard let errorMessage = viewModel.errorMessage else { return false }
        return errorMessage.contains("critical") ||
               errorMessage.contains("corrupt") ||
               errorMessage.contains("invalid state")
    }
    
    private func restartApp() {
        viewModel.startOver()
        viewModel.clearError()
        hasAppeared = false
        viewModel.loadSavedPlan()
    }
}

// MARK: - Navigation Views

struct ActivePlanView: View {
    @EnvironmentObject var viewModel: WorkoutPlanViewModel
    
    var body: some View {
        Group {
            if let currentPlan = viewModel.currentPlan, currentPlan.isValid {
                PlanListView()
                    .environmentObject(viewModel)
                    .overlay(alignment: .bottom) {
                        // Show completion prompt if challenge is finished (user-controlled)
                        if viewModel.shouldShowCompletionPrompt {
                            completionPromptOverlay
                        }
                    }
            } else {
                ErrorRecoveryView(
                    title: "Plan Data Corrupted",
                    message: "Your workout plan data is corrupted. We'll need to start fresh.",
                    actionTitle: "Create New Plan",
                    action: { viewModel.startOver() }
                )
                .environmentObject(viewModel)
            }
        }
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
    }
    
    // MARK: - User-Controlled Completion Prompt Overlay
    
    private var completionPromptOverlay: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("🎉 Challenge Complete!")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("Great job! Ready to explore your achievement?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button("View Achievement") {
                        // User-controlled switch to history tab
                        NotificationCenter.default.post(name: .switchToHistoryTab, object: nil)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    
                    Button("New Challenge") {
                        // Note: PlanListView will handle archiving before starting new challenge
                        viewModel.startNewChallenge()
                    }
                    .buttonStyle(.bordered)
                    .tint(.green)
                }
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .padding()
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.shouldShowCompletionPrompt)
    }
}

struct SuggestedPlanView: View {
    @EnvironmentObject var viewModel: WorkoutPlanViewModel
    
    var body: some View {
        Group {
            if let suggestedPlan = viewModel.suggestedPlan, suggestedPlan.isValid {
                PlanReviewView()
                    .environmentObject(viewModel)
            } else {
                ErrorRecoveryView(
                    title: "Plan Generation Error",
                    message: "There was an issue with your generated plan. Let's try again.",
                    actionTitle: "Start Over",
                    action: { viewModel.startOver() }
                )
                .environmentObject(viewModel)
            }
        }
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
    }
}

// MARK: - Error Recovery

struct ErrorRecoveryView: View {
    let title: String
    let message: String
    let actionTitle: String
    let action: () -> Void
    
    @EnvironmentObject var viewModel: WorkoutPlanViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Spacer()
                
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.orange)
                    
                    VStack(spacing: 12) {
                        Text(title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text(message)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                    }
                }
                
                VStack(spacing: 16) {
                    Button(action: action) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text(actionTitle)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    Button("Contact Support") {
                        if let url = URL(string: "mailto:support@fit14app.com?subject=App%20Error&body=Describe%20the%20issue%20you%20encountered") {
                            UIApplication.shared.open(url)
                        }
                    }
                    .foregroundColor(.blue)
                }
                
                Spacer()
            }
            .padding(24)
            .navigationTitle("Current Challenge")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Previews

#Preview("Default State") {
    ContentView()
        .environmentObject(WorkoutPlanViewModel())
}

#Preview("Generating State") {
    let viewModel = WorkoutPlanViewModel()
    viewModel.isGenerating = true
    
    return GoalInputView()
        .environmentObject(viewModel)
}

#Preview("Active Plan with Completion") {
    let viewModel = WorkoutPlanViewModel()
    // Simulate completed challenge
    // viewModel.currentPlan = someCompletedPlan
    
    return ActivePlanView()
        .environmentObject(viewModel)
}

#Preview("Error Recovery") {
    ErrorRecoveryView(
        title: "Connection Failed",
        message: "Unable to connect to our servers. Please check your internet connection and try again.",
        actionTitle: "Retry",
        action: { print("Retry tapped") }
    )
    .environmentObject(WorkoutPlanViewModel())
}
