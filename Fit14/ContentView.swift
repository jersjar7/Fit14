//
//  ContentView.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//  Updated for tab navigation integration
//  UPDATED: Removed completion overlay - PlanListView now handles all completion UI
//  ADDED: Onboarding flow preview for development
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
                        if let url = URL(string: "mailto:support@fit14app.com?subject=App%20Error&body=Describe%20the%20issue%20you%encountered") {
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

// MARK: - Onboarding Preview Component

struct OnboardingFlowPreview: View {
    @State private var showSplash = true
    @State private var showOnboarding = false
    @State private var isOnboardingComplete = false
    @State private var canRestart = false
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashScreen {
                    showSplash = false
                    showOnboarding = true
                }
            } else if showOnboarding {
                OnboardingCoordinator(isOnboardingComplete: $isOnboardingComplete)
                    .onChange(of: isOnboardingComplete) { _, completed in
                        if completed {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showOnboarding = false
                                canRestart = true
                            }
                        }
                    }
            } else {
                // Completion screen with restart option
                VStack(spacing: 24) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                    
                    VStack(spacing: 12) {
                        Text("Onboarding Complete!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("You would now see the main Fit14 app")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Restart Onboarding Flow") {
                        restartFlow()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding()
            }
        }
        .animation(.easeInOut(duration: 0.5), value: showSplash)
        .animation(.easeInOut(duration: 0.5), value: showOnboarding)
    }
    
    private func restartFlow() {
        isOnboardingComplete = false
        canRestart = false
        showSplash = true
        showOnboarding = false
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

// 🎯 NEW: Complete Onboarding Flow Preview
#Preview("🚀 Full Onboarding Flow") {
    OnboardingFlowPreview()
}

// 🎯 NEW: Individual Onboarding Components
#Preview("💫 Splash Screen Only") {
    SplashScreen {
        print("Splash completed")
    }
}

#Preview("📝 Onboarding Pages Only") {
    OnboardingCoordinator(isOnboardingComplete: .constant(false))
}

#Preview("🎉 Welcome Page") {
    WelcomeOnboardingPage()
        .floatingNavigation(
            currentPage: 0,
            totalPages: 6,
            onNext: { print("Next tapped") },
            onSkip: { print("Skip tapped") }
        )
}

#Preview("⚙️ How It Works Page") {
    HowItWorksOnboardingPage()
        .floatingNavigation(
            currentPage: 1,
            totalPages: 6,
            onNext: { print("Next tapped") },
            onBack: { print("Back tapped") },
            onSkip: { print("Skip tapped") }
        )
}

#Preview("🎯 Goal Flexibility Page") {
    GoalFlexibilityOnboardingPage()
        .floatingNavigation(
            currentPage: 2,
            totalPages: 6,
            onNext: { print("Next tapped") },
            onBack: { print("Back tapped") },
            onSkip: { print("Skip tapped") }
        )
}

#Preview("🧠 Personalization Page") {
    PersonalizationOnboardingPage()
        .floatingNavigation(
            currentPage: 3,
            totalPages: 6,
            onNext: { print("Next tapped") },
            onBack: { print("Back tapped") },
            onSkip: { print("Skip tapped") }
        )
}

#Preview("📊 Progress Page") {
    ProgressOnboardingPage()
        .floatingNavigation(
            currentPage: 4,
            totalPages: 6,
            onNext: { print("Next tapped") },
            onBack: { print("Back tapped") },
            onSkip: { print("Skip tapped") }
        )
}

#Preview("🔔 Permissions Page") {
    PermissionsOnboardingPage()
        .floatingNavigation(
            currentPage: 5,
            totalPages: 6,
            onNext: { print("Get Started tapped") },
            onBack: { print("Back tapped") }
        )
}
