//
//  MainTabView.swift
//  Fit14
//
//  Created by Jerson on 7/8/25.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = WorkoutPlanViewModel()
    @State private var selectedTab: TabSelection = .currentChallenge
    
    enum TabSelection: Int, CaseIterable {
        case currentChallenge = 0
        case challengeHistory = 1
        
        var title: String {
            switch self {
            case .currentChallenge:
                return "Current Challenge"
            case .challengeHistory:
                return "Challenge History"
            }
        }
        
        var icon: String {
            switch self {
            case .currentChallenge:
                return "figure.strengthtraining.traditional"
            case .challengeHistory:
                return "trophy"
            }
        }
        
        var selectedIcon: String {
            switch self {
            case .currentChallenge:
                return "figure.strengthtraining.traditional"
            case .challengeHistory:
                return "trophy.fill"
            }
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Current Challenge Tab
            currentChallengeTab
                .tabItem {
                    Image(systemName: selectedTab == .currentChallenge ? TabSelection.currentChallenge.selectedIcon : TabSelection.currentChallenge.icon)
                    Text(TabSelection.currentChallenge.title)
                }
                .tag(TabSelection.currentChallenge)
            
            // Challenge History Tab
            challengeHistoryTab
                .tabItem {
                    Image(systemName: selectedTab == .challengeHistory ? TabSelection.challengeHistory.selectedIcon : TabSelection.challengeHistory.icon)
                    Text(TabSelection.challengeHistory.title)
                }
                .tag(TabSelection.challengeHistory)
        }
        .accentColor(.orange)
        .onAppear {
            configureTabBarAppearance()
        }
        .onChange(of: viewModel.shouldShowCompletionPrompt) { shouldShow in
            // Auto-switch to history tab when challenge is completed
            if shouldShow {
                handleChallengeCompletion()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .switchToHistoryTab)) { _ in
            // Switch to history tab when requested from other views
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedTab = .challengeHistory
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .challengeCompleted)) { _ in
            // Handle challenge completion notification
            handleChallengeCompletion()
        }
    }
    
    // MARK: - Current Challenge Tab
    
    private var currentChallengeTab: some View {
        ContentView()
            .environmentObject(viewModel)
            .badge(challengeProgressBadge)
    }
    
    // MARK: - Challenge History Tab
    
    private var challengeHistoryTab: some View {
        PlanHistoryView(viewModel: viewModel)
            .badge(historyBadge)
    }
    
    // MARK: - Tab Badges
    
    private var challengeProgressBadge: String? {
        guard viewModel.hasActivePlan else { return nil }
        
        let progress = viewModel.progressInfo
        
        // Show badge if challenge is completed
        if viewModel.shouldShowCompletionPrompt {
            return "!"
        }
        
        // Show progress for active challenges
        if progress.total > 0 {
            let remaining = progress.total - progress.completed
            return remaining > 0 ? "\(remaining)" : nil
        }
        
        return nil
    }
    
    private var historyBadge: String? {
        // Show "New" badge if there are recent challenges (within last 3 days)
        let recentChallenges = viewModel.recentChallenges.filter {
            Calendar.current.dateComponents([.day], from: $0.completionDate, to: Date()).day ?? 100 <= 3
        }
        
        return recentChallenges.isEmpty ? nil : "New"
    }
    
    // MARK: - Challenge Completion Handling
    
    private func handleChallengeCompletion() {
        // Give user time to see completion celebration, then switch to history
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.5)) {
                selectedTab = .challengeHistory
            }
        }
    }
    
    // MARK: - Tab Bar Appearance
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        
        // Configure normal item appearance
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.systemGray
        ]
        
        // Configure selected item appearance
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.systemOrange
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.systemOrange
        ]
        
        // Apply appearance
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - Notification Names Extension

extension Notification.Name {
    static let challengeCompleted = Notification.Name("challengeCompleted")
    static let switchToHistoryTab = Notification.Name("switchToHistoryTab")
}

// MARK: - Preview

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
