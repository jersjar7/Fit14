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
            if let workoutPlan = viewModel.currentPlan, workoutPlan.isActive {
                VStack(spacing: 20) {
                    // Progress Header
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Your 14-Day Plan")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .accessibilityLabel("Your 14-Day Active Workout Plan")
                                
                                // Active Plan Badge
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                    Text("Active Plan")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.green)
                                }
                                .accessibilityLabel("This is your active workout plan")
                            }
                            
                            Spacer()
                            
                            // Days Completed Badge
                            VStack {
                                Text("\(workoutPlan.completedDays)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                
                                Text("of 14")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .accessibilityLabel("\(workoutPlan.completedDays) of 14 days completed")
                        }
                        
                        // Progress Bar
                        VStack(spacing: 8) {
                            ProgressView(value: workoutPlan.progressPercentage / 100)
                                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                                .scaleEffect(x: 1, y: 2, anchor: .center)
                                .accessibilityLabel("Progress: \(Int(workoutPlan.progressPercentage))% complete")
                            
                            HStack {
                                Text("\(Int(workoutPlan.progressPercentage))% Complete")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)
                                
                                Spacer()
                                
                                Text("\(14 - workoutPlan.completedDays) days remaining")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // User Goals
                        if !workoutPlan.userGoals.isEmpty {
                            HStack {
                                Image(systemName: "target")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(workoutPlan.userGoals)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(3)
                                
                                Spacer()
                            }
                            .accessibilityLabel("Your goal: \(workoutPlan.userGoals)")
                        }
                    }
                    .padding(16)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .accessibilityElement(children: .combine)
                    
                    // Days List
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(workoutPlan.days) { day in
                                NavigationLink(destination: DayDetailView(dayId: day.id, viewModel: viewModel)) {
                                    DayRowView(day: day)
                                        .background(Color(.systemBackground))
                                        .cornerRadius(12)
                                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                                        .accessibilityLabel("Day \(day.dayNumber), \(day.exercises.count) exercises, \(day.isCompleted ? "completed" : "not completed")")
                                        .accessibilityHint("Tap to view and track today's exercises")
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                    .accessibilityLabel("Workout days list")
                }
                .padding()
                .navigationTitle("Fit14")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button(action: {
                                viewModel.startFresh()
                            }) {
                                Label("Start Fresh", systemImage: "arrow.uturn.left")
                            }
                            .accessibilityLabel("Start fresh - create a new workout plan")
                            
                            Button(action: {
                                viewModel.loadSampleData()
                            }) {
                                Label("Load Sample Data", systemImage: "doc.text")
                            }
                            .accessibilityLabel("Load sample workout data for testing")
                            
                            if workoutPlan.completedDays > 0 {
                                Divider()
                                
                                Button(action: {
                                    // Future feature: Export progress
                                }) {
                                    Label("Export Progress", systemImage: "square.and.arrow.up")
                                }
                                .disabled(true)
                                .accessibilityLabel("Export progress - coming soon")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .accessibilityLabel("More options")
                        }
                    }
                }
                .alert("Error", isPresented: $viewModel.showError) {
                    Button("OK") {
                        viewModel.clearError()
                    }
                } message: {
                    Text(viewModel.errorMessage ?? "An unexpected error occurred")
                }
            } else {
                // No active plan found - show empty state
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        Image(systemName: "target")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                            .accessibilityHidden(true)
                        
                        VStack(spacing: 8) {
                            Text("No Active Plan")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Create your personalized 14-day fitness plan to start tracking your workouts")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    VStack(spacing: 12) {
                        Button(action: {
                            viewModel.startFresh() // This will trigger navigation to GoalInputView
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Create New Plan")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .accessibilityLabel("Create new workout plan")
                        .accessibilityHint("Tap to start creating your personalized fitness plan")
                        
                        Button(action: {
                            viewModel.loadSampleData()
                        }) {
                            HStack {
                                Image(systemName: "doc.text")
                                Text("Try Sample Plan")
                            }
                            .foregroundColor(.blue)
                        }
                        .accessibilityLabel("Load sample workout plan")
                        .accessibilityHint("Load a pre-made plan to explore the app features")
                    }
                    
                    // Help Text
                    VStack(spacing: 8) {
                        Text("How it works:")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Label("Tell us your fitness goals", systemImage: "1.circle")
                            Label("AI creates your personalized plan", systemImage: "2.circle")
                            Label("Review and customize exercises", systemImage: "3.circle")
                            Label("Track your daily progress", systemImage: "4.circle")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                .padding()
                .navigationTitle("Fit14")
                .accessibilityElement(children: .combine)
                .accessibilityLabel("No active workout plan. Create a new plan to get started.")
            }
        }
    }
}

#Preview("Active Plan") {
    let viewModel = WorkoutPlanViewModel()
    viewModel.currentPlan = SampleData.sampleActiveWorkoutPlan
    
    return PlanListView()
        .environmentObject(viewModel)
}

#Preview("No Plan") {
    let viewModel = WorkoutPlanViewModel()
    // No current plan
    
    return PlanListView()
        .environmentObject(viewModel)
}

#Preview("Completed Plan") {
    let viewModel = WorkoutPlanViewModel()
    viewModel.currentPlan = SampleData.sampleCompletedWorkoutPlan
    
    return PlanListView()
        .environmentObject(viewModel)
}
