//
//  PlanListView.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//

import SwiftUI

struct PlanListView: View {
    @EnvironmentObject var viewModel: WorkoutPlanViewModel
    
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
                        
                        // Show user goals
                        if !workoutPlan.userGoals.isEmpty {
                            Text("Goal: \(workoutPlan.userGoals)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
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
                        Menu {
                            Button("Start Fresh") {
                                viewModel.startFresh()
                            }
                            
                            Button("Load Sample Data") {
                                viewModel.loadSampleData()
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            } else {
                // No plan found - show option to create one
                VStack(spacing: 20) {
                    Image(systemName: "target")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("No workout plan found")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Create your personalized 14-day fitness plan")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Create Plan") {
                        viewModel.startFresh() // This will trigger navigation to GoalInputView
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("Load Sample Plan") {
                        viewModel.loadSampleData()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                .padding()
            }
        }
    }
}

#Preview {
    PlanListView()
        .environmentObject(WorkoutPlanViewModel())
}
