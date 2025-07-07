//
//  PlanListView.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//  Enhanced with 2-week completion and next challenge features
//

import SwiftUI

struct PlanListView: View {
    @EnvironmentObject var viewModel: WorkoutPlanViewModel
    @State private var showingNextChallengeSheet = false
    @State private var showingCompletionCelebration = false
    
    var body: some View {
        NavigationView {
            if let workoutPlan = viewModel.currentPlan, workoutPlan.isActive {
                VStack(spacing: 20) {
                    // Completion Celebration (if plan is completed)
                    if workoutPlan.isCompleted && !showingCompletionCelebration {
                        completionCelebrationBanner
                    }
                    
                    // Progress Header
                    progressHeaderSection(for: workoutPlan)
                    
                    // Days List
                    daysListSection(for: workoutPlan)
                    
                    // Next Challenge Section (if plan is completed)
                    if workoutPlan.isCompleted {
                        nextChallengeSection
                    }
                }
                .padding()
                .navigationTitle("Fit14")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            if workoutPlan.isCompleted {
                                Button(action: {
                                    showingNextChallengeSheet = true
                                }) {
                                    Label("Start New Challenge", systemImage: "plus.circle")
                                }
                                
                                Divider()
                            }
                            
                            Button(action: {
                                viewModel.startFresh()
                            }) {
                                Label("Start Fresh", systemImage: "arrow.uturn.left")
                            }
                            .accessibilityLabel("Start fresh - create a new workout plan")
                            
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
                .sheet(isPresented: $showingNextChallengeSheet) {
                    NextChallengeSheet()
                        .environmentObject(viewModel)
                }
                .alert("Error", isPresented: $viewModel.showError) {
                    Button("OK") {
                        viewModel.clearError()
                    }
                } message: {
                    Text(viewModel.errorMessage ?? "An unexpected error occurred")
                }
                .onAppear {
                    // Show completion celebration if plan just completed
                    if workoutPlan.isCompleted && !showingCompletionCelebration {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showingCompletionCelebration = true
                        }
                    }
                }
            } else {
                // No active plan found - show empty state
                emptyStateSection
            }
        }
    }
    
    // MARK: - Completion Celebration Banner
    
    private var completionCelebrationBanner: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "party.popper.fill")
                    .font(.title)
                    .foregroundColor(.yellow)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Challenge Complete! 🎉")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("You finished your 2-week fitness challenge!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingCompletionCelebration = true
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.green.opacity(0.1), Color.blue.opacity(0.1)]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
        .transition(.asymmetric(
            insertion: .scale.combined(with: .opacity),
            removal: .opacity
        ))
    }
    
    // MARK: - Progress Header Section
    
    private func progressHeaderSection(for workoutPlan: WorkoutPlan) -> some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workoutPlan.isCompleted ? "Completed Challenge" : "Your 2-Week Challenge")
                        .font(.title2)
                        .fontWeight(.bold)
                        .accessibilityLabel("Your 14-Day Active Workout Plan")
                    
                    // Status Badge
                    HStack(spacing: 4) {
                        Image(systemName: workoutPlan.isCompleted ? "checkmark.seal.fill" : "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(workoutPlan.isCompleted ? .green : .blue)
                        Text(workoutPlan.isCompleted ? "Completed!" : "In Progress")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(workoutPlan.isCompleted ? .green : .blue)
                    }
                    .accessibilityLabel(workoutPlan.isCompleted ? "Challenge completed" : "Challenge in progress")
                }
                
                Spacer()
                
                // Days Completed Badge
                VStack {
                    Text("\(workoutPlan.completedDays)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(workoutPlan.isCompleted ? .green : .blue)
                    
                    Text("of 14")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .accessibilityLabel("\(workoutPlan.completedDays) of 14 days completed")
            }
            
            // Progress Bar
            VStack(spacing: 8) {
                ProgressView(value: workoutPlan.progressPercentage / 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: workoutPlan.isCompleted ? .green : .blue))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .accessibilityLabel("Progress: \(Int(workoutPlan.progressPercentage))% complete")
                
                HStack {
                    Text("\(Int(workoutPlan.progressPercentage))% Complete")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(workoutPlan.isCompleted ? .green : .blue)
                    
                    Spacer()
                    
                    if workoutPlan.isCompleted {
                        Text("Congratulations! 🏆")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    } else {
                        Text("\(workoutPlan.remainingDays) days remaining")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
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
    }
    
    // MARK: - Days List Section
    
    private func daysListSection(for workoutPlan: WorkoutPlan) -> some View {
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
    
    // MARK: - Next Challenge Section
    
    private var nextChallengeSection: some View {
        VStack(spacing: 16) {
            // Success Message
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "trophy.fill")
                        .font(.title2)
                        .foregroundColor(.yellow)
                    
                    Text("Ready for Your Next Challenge?")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Spacer()
                }
                
                Text("You've proven you can stick to a plan and see results. Build on your momentum with a new 2-week goal!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            // Next Challenge Suggestions Preview
            VStack(alignment: .leading, spacing: 8) {
                Text("Suggested next challenges:")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                let suggestions = viewModel.getNextChallengeSuggestions()
                ForEach(suggestions.prefix(3), id: \.self) { suggestion in
                    HStack {
                        Image(systemName: "arrow.right.circle")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text(suggestion)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
            
            // CTA Button
            Button(action: {
                showingNextChallengeSheet = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Start New 2-Week Challenge")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.green.opacity(0.05), Color.blue.opacity(0.05)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Empty State Section
    
    private var emptyStateSection: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: "sparkles")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .accessibilityHidden(true)
                
                VStack(spacing: 8) {
                    Text("Ready to Start Your 2-Week Fitness Journey?")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    Text("Get a personalized 14-day workout plan created by AI based on your specific goals and preferences")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            // Main CTA Button
            Button(action: {
                viewModel.startFresh() // This will trigger navigation to GoalInputView
            }) {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Create Your 2-Week Challenge")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .accessibilityLabel("Create AI-powered workout plan")
            .accessibilityHint("Tap to start creating your personalized 2-week fitness challenge using AI")
            
            // How it works section
            VStack(spacing: 12) {
                Text("How it works:")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "1.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title3)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Set Your 2-Week Goal")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("Tell us what you want to achieve in the next 14 days")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "2.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title3)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("AI Creates Your Challenge")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("Our AI generates a personalized 14-day plan optimized for your goals")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "3.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title3)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Track Your Progress")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("Complete daily workouts and watch your progress grow over 2 weeks")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "4.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title3)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Celebrate & Level Up")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("Complete your challenge and start your next 2-week goal!")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding()
        .navigationTitle("Fit14")
        .accessibilityElement(children: .combine)
        .accessibilityLabel("No active workout plan. Create an AI-powered 2-week challenge to get started.")
    }
}

// MARK: - Next Challenge Sheet

struct NextChallengeSheet: View {
    @EnvironmentObject var viewModel: WorkoutPlanViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Completion Message
                    VStack(spacing: 16) {
                        Text(viewModel.planCompletionMessage ?? AIPrompts.getTwoWeekCompletionMessage())
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.primary)
                        
                        Image(systemName: "trophy.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Next Challenge Suggestions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Next Challenge Options:")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        let suggestions = viewModel.getNextChallengeSuggestions()
                        ForEach(suggestions, id: \.self) { suggestion in
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "target")
                                    .foregroundColor(.blue)
                                    .font(.title3)
                                
                                Text(suggestion)
                                    .font(.subheadline)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                        }
                    }
                    
                    // CTA Button
                    Button(action: {
                        dismiss()
                        viewModel.startNewChallenge()
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Create My Next Challenge")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    // Later option
                    Button("I'll decide later") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                    
                    Spacer(minLength: 20)
                }
                .padding(24)
            }
            .navigationTitle("Next Challenge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

#Preview("Active Plan") {
    let viewModel = WorkoutPlanViewModel()
    viewModel.currentPlan = SampleData.sampleActiveWorkoutPlan
    
    return PlanListView()
        .environmentObject(viewModel)
}

#Preview("Completed Plan") {
    let viewModel = WorkoutPlanViewModel()
    viewModel.currentPlan = SampleData.sampleCompletedWorkoutPlan
    
    return PlanListView()
        .environmentObject(viewModel)
}

#Preview("No Plan") {
    let viewModel = WorkoutPlanViewModel()
    // No current plan
    
    return PlanListView()
        .environmentObject(viewModel)
}

#Preview("Next Challenge Sheet") {
    let viewModel = WorkoutPlanViewModel()
    viewModel.currentPlan = SampleData.sampleCompletedWorkoutPlan
    
    return NextChallengeSheet()
        .environmentObject(viewModel)
}
