//
//  PlanListView.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//  Enhanced with 2-week completion and next challenge features
//  Updated with challenge history integration
//  UPDATED: Cleaned up completion flow - single trigger, user-controlled timing, bottom popup, inline see more
//  UPDATED: Added missed days banner integration
//

import SwiftUI
import UIKit // For UIApplication.willEnterForegroundNotification

struct PlanListView: View {
    @EnvironmentObject var viewModel: WorkoutPlanViewModel
    @State private var showingNextChallengeSheet = false
    @State private var showingCompletionCelebration = false
    @State private var hasArchivedCurrentPlan = false // Track if we've archived this completion
    @State private var showingFullDescription = false
    @State private var showingStartFreshAlert = false
    
    var body: some View {
        NavigationView {
            if let workoutPlan = viewModel.currentPlan, workoutPlan.isActive {
                VStack(spacing: 20) {
                    // Progress Header
                    progressHeaderSection(for: workoutPlan)
                    
                    // Days List (now includes missed days banner)
                    daysListSection(for: workoutPlan)
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
                                
                                Button(action: {
                                    // Switch to history tab to show this achievement
                                    NotificationCenter.default.post(name: .switchToHistoryTab, object: nil)
                                }) {
                                    Label("View Challenge History", systemImage: "trophy")
                                }
                                
                                Divider()
                            }
                            
                            Button(action: {
                                showingStartFreshAlert = true
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
                .sheet(isPresented: $showingFullDescription) {
                    FullDescriptionSheet(description: workoutPlan.displayDescription)
                }
                .alert("Error", isPresented: $viewModel.showError) {
                    Button("OK") {
                        viewModel.clearError()
                    }
                } message: {
                    Text(viewModel.errorMessage ?? "An unexpected error occurred")
                }
                .alert("Start Fresh?", isPresented: $showingStartFreshAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Start Fresh", role: .destructive) {
                        viewModel.startFresh()
                    }
                } message: {
                    Text("Are you sure you want to start fresh? Your current challenge and all progress will be permanently lost.")
                }
                .onChange(of: workoutPlan.isCompleted) { isCompleted in
                    // Handle 100% completion celebration
                    if isCompleted && !hasArchivedCurrentPlan {
                        handlePlanCompletion()
                    }
                }
                .overlay(alignment: .bottom) {
                    if workoutPlan.isCompleted && !showingCompletionCelebration {
                        completionPopupBanner
                            .padding()
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showingCompletionCelebration)
                    }
                }
                .onAppear {
                    // Check if plan should be auto-archived when view appears
                    viewModel.checkForFinishedPlan()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    // Check when app comes back to foreground (in case midnight passed while app was closed)
                    viewModel.checkForFinishedPlan()
                }
                .onChange(of: workoutPlan.isFinished) { isFinished in
                    // Handle auto-archiving when 14-day period ends
                    if isFinished && !hasArchivedCurrentPlan && !workoutPlan.isCompleted {
                        // Plan finished but not 100% completed - auto-archive without celebration
                        handlePlanFinished()
                    }
                }
            } else {
                // No active plan found - show empty state
                emptyStateSection
            }
        }
    }
    
    // MARK: - Method to handle non-100% completion scenarios
    private func handlePlanFinished() {
        // Mark as archived to prevent duplicates
        hasArchivedCurrentPlan = true
        
        // Archive after brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            viewModel.archiveCompletedPlan()
            let percentage = Int(viewModel.currentPlan?.progressPercentage ?? 0)
            print("📊 Challenge finished with \(percentage)% completion")
        }
    }
    
    // MARK: - Single Completion Flow Handler
    
    private func handlePlanCompletion() {
        // Step 1: Immediate - Mark as archived to prevent duplicates
        hasArchivedCurrentPlan = true
        
        // Step 2: Show banner + Archive after 0.5s (only timing we use)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showingCompletionCelebration = false // Ensure banner shows
            viewModel.archiveCompletedPlan() // Archive once
            print("🏆 Challenge completed and archived!")
        }
    }
    
    // MARK: - Completion Popup Banner
    
    private var completionPopupBanner: some View {
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
                        showingCompletionCelebration = true // Hide banner when dismissed
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
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
                        Button(action: {
                            NotificationCenter.default.post(name: .switchToHistoryTab, object: nil)
                        }) {
                            HStack(spacing: 4) {
                                Text("View Achievement")
                                Image(systemName: "trophy.fill")
                            }
                            .font(.caption)
                            .foregroundColor(.orange)
                        }
                    } else {
                        Text("\(workoutPlan.remainingDays) days remaining")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // User Goals with inline "see more"
            if !workoutPlan.userGoals.isEmpty {
                HStack(alignment: .top) {
                    Image(systemName: "target")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Smart truncation with inline "see more"
                    if workoutPlan.displayDescription.count > 120 {
                        // Long description - truncate and add inline "see more"
                        Text(truncatedDescriptionWithSeeMore(workoutPlan.displayDescription))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .onTapGesture {
                                showingFullDescription = true
                            }
                    } else {
                        // Short description - show normally
                        Text(workoutPlan.displayDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                    }
                    
                    Spacer()
                }
                .accessibilityLabel("Your goal: \(workoutPlan.displayDescription)")
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
    }
    
    // MARK: - Helper Functions
    
    private func truncatedDescriptionWithSeeMore(_ text: String) -> AttributedString {
        let maxLength = 120 // Adjust based on desired truncation
        
        if text.count <= maxLength {
            return AttributedString(text)
        }
        
        // Find a good place to truncate (preferably at a word boundary)
        let truncatedText = String(text.prefix(maxLength))
        let lastSpaceIndex = truncatedText.lastIndex(of: " ") ?? truncatedText.endIndex
        let finalText = String(truncatedText[..<lastSpaceIndex])
        
        // Create attributed string with colored "see more >"
        var attributedString = AttributedString(finalText + "... ")
        
        var seeMore = AttributedString("see more >")
        seeMore.foregroundColor = .blue
        seeMore.font = .caption
        
        attributedString.append(seeMore)
        
        return attributedString
    }
    
    // MARK: - Full Description Sheet

    struct FullDescriptionSheet: View {
        let description: String
        @Environment(\.dismiss) private var dismiss
        
        var body: some View {
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "target")
                                .font(.title2)
                                .foregroundColor(.blue)
                            
                            Text("Your Challenge Goal")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Spacer()
                        }
                        
                        Text(description)
                            .font(.body)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(2)
                        
                        Spacer()
                    }
                    .padding(24)
                }
                .navigationTitle("Challenge Description")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                        .fontWeight(.medium)
                    }
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Days List Section (UPDATED with Missed Days Banner)
    
    private func daysListSection(for workoutPlan: WorkoutPlan) -> some View {
        ScrollView {
            VStack(spacing: 12) {
                // MISSED DAYS BANNER (NEW)
                if viewModel.hasMissedDays {
                    MissedDaysBanner()
                        .padding(.horizontal)
                        .transition(.slide.combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.3), value: viewModel.hasMissedDays)
                }
                
                // DAYS LIST
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
        }
        .accessibilityLabel("Workout days list")
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
            
            // Show history hint if user has completed challenges
            if viewModel.hasCompletedChallenges {
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.orange)
                        Text("You've completed challenges before!")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    
                    Button(action: {
                        NotificationCenter.default.post(name: .switchToHistoryTab, object: nil)
                    }) {
                        HStack {
                            Image(systemName: "trophy.circle")
                            Text("View Your Challenge History")
                        }
                        .font(.subheadline)
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
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
                            Text("Complete your challenge and check your history!")
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
                    
                    // View Achievement Section
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "trophy.fill")
                                .foregroundColor(.orange)
                            Text("Your Achievement")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        
                        Button(action: {
                            dismiss()
                            // Switch to history tab to view achievement
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                NotificationCenter.default.post(name: .switchToHistoryTab, object: nil)
                            }
                        }) {
                            HStack {
                                Image(systemName: "trophy.circle.fill")
                                Text("View Your Completed Challenge")
                            }
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
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
                        // Note: UI will handle archiving before this is called
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

// MARK: - Preview with Missed Days (NEW)
#Preview("Plan with Missed Days") {
    let viewModel = WorkoutPlanViewModel()
    
    // Create a sample plan with missed days for testing
    var plan = SampleData.sampleActiveWorkoutPlan
    
    // Modify some days to be in the past and incomplete (missed)
    let calendar = Calendar.current
    plan.days = plan.days.enumerated().map { index, day in
        if index < 8 {
            // Make first 8 days past dates and incomplete (missed)
            let pastDate = calendar.date(byAdding: .day, value: -(8-index), to: Date()) ?? Date()
            return day.updated(date: pastDate)
        } else if index == 8 {
            // Make today
            return day.updated(date: Date())
        } else {
            // Keep future days as future
            let futureDate = calendar.date(byAdding: .day, value: index-8, to: Date()) ?? Date()
            return day.updated(date: futureDate)
        }
    }
    
    viewModel.currentPlan = plan
    
    return PlanListView()
        .environmentObject(viewModel)
}
