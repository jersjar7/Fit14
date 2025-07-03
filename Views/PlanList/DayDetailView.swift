//
//  DayDetailView.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//

import SwiftUI

struct DayDetailView: View {
    let day: Day
    @ObservedObject var viewModel: WorkoutPlanViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("Day \(day.dayNumber)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
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
        }
    }
}

#Preview {
    DayDetailView(
        day: SampleData.sampleWorkoutPlan.days[0],
        viewModel: WorkoutPlanViewModel()
    )
}
