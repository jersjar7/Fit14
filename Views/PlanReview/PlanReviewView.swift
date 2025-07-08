//
//  PlanReviewView.swift
//  Fit14
//
//  Created by Jerson on 7/3/25.
//  Enhanced with 2-week focus messaging and AI-determined start date support
//

import SwiftUI

struct PlanReviewView: View {
    @EnvironmentObject var viewModel: WorkoutPlanViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDay: Day?
    @State private var showRegenerateConfirmation = false
    @State private var showTwoWeekInfo = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Section
                VStack(spacing: 16) {
                    
                    // Plan Info with 2-Week Focus
                    VStack(spacing: 12) {
                        Text("Personalized 2-Week Challenge")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if let suggestedPlan = viewModel.suggestedPlan {
                            Text(suggestedPlan.userGoals)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(3)
                        }
                        
                        // Start Date Info Section
                        startDateInfoSection
                        
                        Divider()
                            .padding(.bottom, 5.0)
                        
                        VStack(spacing: 8) {
                            Text("Review and customize your plan below")
                                .font(.caption)
                                .foregroundColor(.primary)
                            
                            Button(action: {
                                showTwoWeekInfo = true
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "info.circle")
                                    Text("Why 2 weeks?")
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
                
                Divider()
                
                // Days List
                if let suggestedPlan = viewModel.suggestedPlan {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(suggestedPlan.days) { day in
                                DayPreviewRow(day: day) {
                                    selectedDay = day
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.vertical, 16)
                    }
                    .background(Color(.systemGroupedBackground))
                } else {
                    // No suggested plan available
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(.orange)
                        
                        Text("No Plan Available")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("There was an issue loading your 2-week challenge")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
                }
                
                // Bottom CTA Section - Enhanced
                VStack(spacing: 5) {
                    // Primary CTA - Accept Plan
                    Button(action: acceptPlan) {
                        HStack {
                            Image(systemName: "flag.checkered")
                            Text("Start My 2-Week Challenge")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
                .background(Color(.systemBackground))
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.blue)
                        Text("AI Generated Plan")
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            showRegenerateConfirmation = true
                        }) {
                            Label("Create New Plan", systemImage: "arrow.clockwise")
                        }
                        
                        Button(action: startOver) {
                            Label("Start Over", systemImage: "arrow.uturn.left")
                        }
                        .foregroundColor(.red)
                        
                        Divider()
                        
                        Button(action: {
                            showTwoWeekInfo = true
                        }) {
                            Label("About 2-Week Goals", systemImage: "info.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(item: $selectedDay) { day in
                DayEditView(day: day, dayId: day.id)
                    .environmentObject(viewModel)
            }
            .sheet(isPresented: $showTwoWeekInfo) {
                TwoWeekInfoSheet()
            }
            .alert("Create New Plan", isPresented: $showRegenerateConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Create New Plan", role: .destructive) {
                    Task {
                        await regeneratePlan()
                    }
                }
            } message: {
                Text("This will generate a completely new 2-week plan and remove your current customizations. Are you sure?")
            }
        }
    }
    
    // MARK: - Start Date Info Section
    
    private var startDateInfoSection: some View {
        Group {
            if let suggestedPlan = viewModel.suggestedPlan,
               let firstDay = suggestedPlan.days.first {
                
                let startDate = firstDay.date
                let isStartingToday = Calendar.current.isDate(startDate, inSameDayAs: Date())
                let isStartingTomorrow = Calendar.current.isDate(startDate, inSameDayAs: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date())
                
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                        .font(.caption)
                    
                    if isStartingToday {
                        Text("Starting today")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                        
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(startDate, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else if isStartingTomorrow {
                        Text("Starting tomorrow")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                        
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(startDate, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Starting")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(formatStartDate(startDate))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatStartDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        // Check if it's this week
        if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE" // Full day name
            return "this \(formatter.string(from: date))"
        }
        
        // Check if it's next week
        if let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: now),
           calendar.isDate(date, equalTo: nextWeek, toGranularity: .weekOfYear) {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE" // Full day name
            return "next \(formatter.string(from: date))"
        }
        
        // For dates further out, show full date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "on \(formatter.string(from: date))"
    }
    
    // MARK: - Actions
    
    private func acceptPlan() {
        viewModel.acceptSuggestedPlan()
        dismiss()
    }
    
    private func regeneratePlan() async {
        await viewModel.regeneratePlan()
    }
    
    private func startOver() {
        viewModel.startOver()
        dismiss()
    }
}

// MARK: - 2-Week Info Sheet

struct TwoWeekInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "target")
                            .font(.system(size: 48))
                            .foregroundColor(.blue)
                        
                        Text("Why 2-Week Goals Work")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Science-backed approach to sustainable fitness habits")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Benefits
                    VStack(spacing: 20) {
                        benefitRow(
                            icon: "brain.head.profile",
                            title: "Perfect for Your Brain",
                            description: "2 weeks is long enough to see real progress but short enough to maintain motivation and focus.",
                            color: .blue
                        )
                        
                        benefitRow(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Visible Results",
                            description: "You'll notice improvements in strength, energy, and confidence within the first week.",
                            color: .green
                        )
                        
                        benefitRow(
                            icon: "arrow.triangle.2.circlepath",
                            title: "Habit Formation",
                            description: "Research shows it takes 14-21 days to start forming new habits. You're right in the sweet spot!",
                            color: .orange
                        )
                        
                        benefitRow(
                            icon: "trophy.fill",
                            title: "Achievement Mindset",
                            description: "Completing a 2-week challenge builds confidence for longer-term fitness goals.",
                            color: .purple
                        )
                    }
                    
                    // Success Quote - Updated to be generic about start date
                    VStack(spacing: 12) {
                        Text("\"The best time to plant a tree was 20 years ago. The second best time is now.\"")
                            .font(.body)
                            .italic()
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        Text("Your 2-week journey is about to begin!")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // What Happens Next
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What happens after 2 weeks?")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Celebrate your success and track your progress")
                                    .font(.subheadline)
                                Spacer()
                            }
                            
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "arrow.up.right.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Level up with a new 2-week challenge")
                                    .font(.subheadline)
                                Spacer()
                            }
                            
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "repeat.circle.fill")
                                    .foregroundColor(.orange)
                                Text("Build on your momentum with progressive goals")
                                    .font(.subheadline)
                                Spacer()
                            }
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(24)
            }
            .navigationTitle("2-Week Success")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private func benefitRow(icon: String, title: String, description: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
    }
}

#Preview("Plan Review") {
    // Create a sample suggested plan for preview
    let viewModel = WorkoutPlanViewModel()
    viewModel.suggestedPlan = SampleData.sampleSuggestedPlan
    
    return PlanReviewView()
        .environmentObject(viewModel)
}

#Preview("2-Week Info Sheet") {
    TwoWeekInfoSheet()
}
