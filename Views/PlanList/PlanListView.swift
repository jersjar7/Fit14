//
//  PlanListView.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//

import SwiftUI

struct PlanListView: View {
    @StateObject private var viewModel = WorkoutPlanViewModel()
    
    var body: some View {
        NavigationView {
            if let workoutPlan = viewModel.currentPlan {
                VStack(spacing: 20) {
                    // Progress Header
                    VStack(spacing: 12) {
                        Text("Your 14-Day Plan")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ProgressView(value: workoutPlan.progressPercentage / 100)
                            .progressViewStyle(LinearProgressViewStyle())
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                        
                        Text("\(workoutPlan.completedDays) of 14 days completed")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Days List
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(workoutPlan.days) { day in
                                NavigationLink(destination: DayDetailView(dayId: day.id, viewModel: viewModel)) {
                                    DayRowView(day: day)
                                        .background(Color(.systemBackground))
                                        .cornerRadius(12)
                                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                                }
                                .buttonStyle(PlainButtonStyle()) // Keeps the row styling clean
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                .navigationTitle("Fit14")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Reset") {
                            viewModel.startFresh()
                            viewModel.loadSavedPlan()
                        }
                    }
                }
            } else {
                VStack {
                    Text("No workout plan found")
                    Button("Load Sample Plan") {
                        viewModel.loadSavedPlan()
                    }
                }
            }
        }
    }
}

#Preview {
    PlanListView()
}
