//
//  Fit14App.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//  Updated to include onboarding flow
//

import SwiftUI
import SwiftData

@main
struct Fit14App: App {
    // MARK: - Onboarding State
    @State private var showSplash = true
    @State private var showOnboarding = false
    @State private var isOnboardingComplete = false
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashScreen {
                        handleSplashCompletion()
                    }
                } else if showOnboarding {
                    OnboardingCoordinator(isOnboardingComplete: $isOnboardingComplete)
                        .onChange(of: isOnboardingComplete) { _, completed in
                            if completed {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    showOnboarding = false
                                }
                            }
                        }
                } else {
                    // Your existing main app content
                    MainTabView()
                        .modelContainer(sharedModelContainer)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: showSplash)
            .animation(.easeInOut(duration: 0.5), value: showOnboarding)
        }
    }
    
    // MARK: - Splash Completion Handler
    
    private func handleSplashCompletion() {
        showSplash = false
        
        // Check if user has completed onboarding before
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        
        if hasCompletedOnboarding {
            // User has seen onboarding before, go directly to main app
            isOnboardingComplete = true
        } else {
            // New user, show onboarding
            showOnboarding = true
        }
    }
}

// MARK: - UserDefaults Extension for Onboarding
extension UserDefaults {
    /// Check if user has completed onboarding
    var hasCompletedOnboarding: Bool {
        get { bool(forKey: "hasCompletedOnboarding") }
        set { set(newValue, forKey: "hasCompletedOnboarding") }
    }
    
    /// Reset onboarding for testing purposes
    func resetOnboarding() {
        hasCompletedOnboarding = false
    }
}
