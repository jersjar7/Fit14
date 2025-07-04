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
                // Show plan list if user has an active plan
                PlanListViewWrapper(viewModel: viewModel)
            } else {
                // Show goal input if no active plan
                GoalInputViewWrapper(viewModel: viewModel)
            }
        }
        .onAppear {
            // Load any saved plan when app starts
            viewModel.loadSavedPlan()
        }
    }
}

// MARK: - Wrapper Views

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
