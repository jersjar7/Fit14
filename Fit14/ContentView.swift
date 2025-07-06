//
//  ContentView.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WorkoutPlanViewModel()
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
            .navigationTitle("Fit14")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Previews

#Preview("Default State") {
    ContentView()
}

#Preview("Generating State") {
    let viewModel = WorkoutPlanViewModel()
    viewModel.isGenerating = true
    
    return GoalInputView()
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
