//
//  OnboardingCoordinator.swift
//  Fit14
//
//  Onboarding flow coordinator and main container
//

import SwiftUI

struct OnboardingCoordinator: View {
    @State private var currentPage = 0
    @State private var showOnboarding = true
    @Binding var isOnboardingComplete: Bool
    
    private let totalPages = 6
    
    var body: some View {
        if showOnboarding {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Progress indicator
                    OnboardingProgressBar(currentPage: currentPage, totalPages: totalPages)
                        .padding(.top)
                    
                    // Page content
                    TabView(selection: $currentPage) {
                        WelcomeOnboardingPage()
                            .floatingNavigation(
                                currentPage: 0,
                                totalPages: totalPages,
                                onNext: nextPage,
                                onSkip: completeOnboarding
                            )
                            .tag(0)
                        
                        HowItWorksOnboardingPage()
                            .floatingNavigation(
                                currentPage: 1,
                                totalPages: totalPages,
                                onNext: nextPage,
                                onBack: previousPage,
                                onSkip: completeOnboarding
                            )
                            .tag(1)
                        
                        GoalFlexibilityOnboardingPage()
                            .floatingNavigation(
                                currentPage: 2,
                                totalPages: totalPages,
                                onNext: nextPage,
                                onBack: previousPage,
                                onSkip: completeOnboarding
                            )
                            .tag(2)
                        
                        PersonalizationOnboardingPage()
                            .floatingNavigation(
                                currentPage: 3,
                                totalPages: totalPages,
                                onNext: nextPage,
                                onBack: previousPage,
                                onSkip: completeOnboarding
                            )
                            .tag(3)
                        
                        ProgressOnboardingPage()
                            .floatingNavigation(
                                currentPage: 4,
                                totalPages: totalPages,
                                onNext: nextPage,
                                onBack: previousPage,
                                onSkip: completeOnboarding
                            )
                            .tag(4)
                        
                        PermissionsOnboardingPage()
                            .floatingNavigation(
                                currentPage: 5,
                                totalPages: totalPages,
                                onNext: completeOnboarding,
                                onBack: previousPage
                            )
                            .tag(5)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut, value: currentPage)
                    
                    // Remove navigation controls - each page handles its own floating buttons
                }
            }
        }
    }
    
    private func nextPage() {
        if currentPage < totalPages - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPage += 1
            }
        } else {
            completeOnboarding()
        }
    }
    
    private func previousPage() {
        if currentPage > 0 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPage -= 1
            }
        }
    }
    
    private func completeOnboarding() {
        // Save onboarding completion status
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        withAnimation(.easeInOut(duration: 0.5)) {
            showOnboarding = false
            isOnboardingComplete = true
        }
    }
}

struct OnboardingProgressBar: View {
    let currentPage: Int
    let totalPages: Int
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                ForEach(0..<totalPages, id: \.self) { index in
                    Capsule()
                        .fill(index <= currentPage ? Color.blue : Color.gray.opacity(0.3))
                        .frame(height: 4)
                        .animation(.easeInOut(duration: 0.3), value: currentPage)
                }
            }
            .padding(.horizontal)
            
            Text("\(currentPage + 1) of \(totalPages)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
