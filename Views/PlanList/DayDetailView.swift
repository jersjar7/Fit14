//
//  DayDetailView.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//

import SwiftUI

struct DayDetailView: View {
    let dayId: UUID
    @ObservedObject var viewModel: WorkoutPlanViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Computed property to get the current day from the view model
    private var currentDay: Day? {
        viewModel.currentPlan?.days.first { $0.id == dayId }
    }
    
    var body: some View {
        NavigationView {
            if let day = currentDay {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        // UPDATED: Show focus instead of day number
                        Text((day.focus ?? "Day \(day.dayNumber)").capitalized)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        // Show day number as subtitle if focus is available
                        if day.focus != nil {
                            Text("Day \(day.dayNumber)")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(day.date, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if day.isCompleted {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Completed!")
                            }
                            .foregroundColor(.green)
                            .font(.headline)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Exercises List
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Today's Exercises")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                        
                        LazyVStack(spacing: 12) {
                            ForEach(day.exercises) { exercise in
                                ExerciseRowView(
                                    exercise: exercise,
                                    dayId: day.id,
                                    onToggle: { exerciseId in
                                        viewModel.toggleExerciseCompletion(dayId: day.id, exerciseId: exerciseId)
                                    }
                                )
                                .padding(.horizontal)
                            }
                        }
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    
                    Spacer()
                    
                    // Complete Day Button
                    if !day.isCompleted && day.exercises.allSatisfy({ $0.isCompleted }) {
                        Button("Day Complete! 🎉") {
                            dismiss()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding()
                .navigationTitle("Workout")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            } else {
                // Fallback view if day is not found
                VStack {
                    Text("Day not found")
                        .font(.headline)
                    Button("Close") {
                        dismiss()
                    }
                }
                .padding()
                .navigationTitle("Error")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

#Preview("Upper Body Strength Day") {
    // Create a mock ViewModel with a sample plan that has focus
    let viewModel = WorkoutPlanViewModel()
    viewModel.currentPlan = SampleData.sampleActiveWorkoutPlan
    
    return DayDetailView(
        dayId: SampleData.sampleActiveWorkoutPlan.days[0].id,  // First day with "Upper body strength" focus
        viewModel: viewModel
    )
}

#Preview("Cardio Conditioning Day") {
    // Create a mock ViewModel with a sample plan that has focus
    let viewModel = WorkoutPlanViewModel()
    viewModel.currentPlan = SampleData.sampleActiveWorkoutPlan
    
    return DayDetailView(
        dayId: SampleData.sampleActiveWorkoutPlan.days[2].id,  // Third day with "Cardio conditioning" focus
        viewModel: viewModel
    )
}

#Preview("Completed Day") {
    // Create a mock ViewModel with a completed day
    let viewModel = WorkoutPlanViewModel()
    
    // Create a completed day with focus
    let completedExercises = [
        Exercise(name: "Push-ups", sets: 3, quantity: 12, unit: .reps).updated(isCompleted: true),
        Exercise(name: "Squats", sets: 3, quantity: 15, unit: .reps).updated(isCompleted: true),
        Exercise(name: "Plank", sets: 1, quantity: 60, unit: .seconds).updated(isCompleted: true)
    ]
    
    let completedDay = Day(
        dayNumber: 5,
        date: Date(),
        focus: "Core strengthening",
        exercises: completedExercises
    )
    
    let completedPlan = WorkoutPlan(
        userGoals: "Sample completed workout",
        summary: "Test plan with completed day",
        days: [completedDay],
        status: .active
    )
    
    viewModel.currentPlan = completedPlan
    
    return DayDetailView(
        dayId: completedDay.id,
        viewModel: viewModel
    )
}
