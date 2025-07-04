//
//  ContentView.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WorkoutPlanViewModel()
    
    var body: some View {
        Group {
            if viewModel.hasActivePlan {
                // User has an active plan - show daily tracking interface
                ActivePlanView()
                    .environmentObject(viewModel)
            } else if viewModel.hasSuggestedPlan {
                // User has a suggested plan - show plan review interface
                SuggestedPlanView()
                    .environmentObject(viewModel)
            } else {
                // No plans - show goal input
                GoalInputView()
                    .environmentObject(viewModel)
            }
        }
        .onAppear {
            // Load any saved plan when app starts
            viewModel.loadSavedPlan()
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.hasActivePlan)
        .animation(.easeInOut(duration: 0.3), value: viewModel.hasSuggestedPlan)
    }
}

// MARK: - Navigation Wrapper Views

struct ActivePlanView: View {
    @EnvironmentObject var viewModel: WorkoutPlanViewModel
    
    var body: some View {
        PlanListView()
            .environmentObject(viewModel)
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
    }
}

struct SuggestedPlanView: View {
    @EnvironmentObject var viewModel: WorkoutPlanViewModel
    
    var body: some View {
        PlanReviewView()
            .environmentObject(viewModel)
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
    }
}

// MARK: - Legacy Wrapper Views (Keep for compatibility)

struct GoalInputViewWrapper: View {
    @ObservedObject var viewModel: WorkoutPlanViewModel
    
    var body: some View {
        GoalInputView()
            .environmentObject(viewModel)
    }
}

struct PlanListViewWrapper: View {
    @ObservedObject var viewModel: WorkoutPlanViewModel
    
    var body: some View {
        PlanListView()
            .environmentObject(viewModel)
    }
}

#Preview {
    ContentView()
}

// MARK: - Preview Helpers for Testing Different States

#Preview("Goal Input State") {
    let viewModel = WorkoutPlanViewModel()
    // No plans - should show GoalInputView
    
    return ContentView()
        .onAppear {
            // Inject the viewModel for preview (this is a bit hacky but works for preview)
            if let contentView = ContentView() as? Any {
                // The real app will use the @StateObject properly
            }
        }
}

#Preview("Suggested Plan State") {
    let viewModel = WorkoutPlanViewModel()
    viewModel.suggestedPlan = SampleData.sampleWorkoutPlan
    
    return SuggestedPlanView()
        .environmentObject(viewModel)
}

#Preview("Active Plan State") {
    let viewModel = WorkoutPlanViewModel()
    viewModel.currentPlan = SampleData.sampleWorkoutPlan.makeActive()
    
    return ActivePlanView()
        .environmentObject(viewModel)
}
