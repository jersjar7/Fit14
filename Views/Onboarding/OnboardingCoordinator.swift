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
                    
                    // Page content with swipe navigation
                    TabView(selection: $currentPage) {
                        WelcomeOnboardingPage()
                            .tag(0)
                        
                        HowItWorksOnboardingPage()
                            .tag(1)
                        
                        GoalFlexibilityOnboardingPage()
                            .tag(2)
                        
                        PersonalizationOnboardingPage()
                            .tag(3)
                        
                        ProgressOnboardingPage()
                            .tag(4)
                        
                        PermissionsOnboardingPage(onComplete: completeOnboarding)
                            .tag(5)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut, value: currentPage)
                }
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
