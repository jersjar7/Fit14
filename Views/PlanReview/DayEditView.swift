//
//  DayEditView.swift
//  Fit14
//
//  Created by Jerson on 7/3/25.
//

import SwiftUI

struct DayEditView: View {
    @EnvironmentObject var viewModel: WorkoutPlanViewModel
    @Environment(\.dismiss) private var dismiss
    
    let day: Day
    let dayId: UUID
    
    @State private var showAddExercise = false
    @State private var editingExercise: Exercise?
    
    // Get the current state of the day from the viewModel
    private var currentDay: Day {
        viewModel.getSuggestedDay(by: dayId) ?? day
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Section
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Day \(currentDay.dayNumber)")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(currentDay.date, style: .date)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(currentDay.exercises.count)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            
                            Text("exercise\(currentDay.exercises.count == 1 ? "" : "s")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Text("Tap an exercise to edit, swipe left to delete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
                
                Divider()
                
                // Exercises List
                if currentDay.exercises.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "figure.run")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        
                        Text("No exercises yet")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Add some exercises to get started")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Button("Add Exercise") {
                            showAddExercise = true
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(currentDay.exercises) { exercise in
                                ExerciseEditRow(
                                    exercise: exercise,
                                    onTap: {
                                        editingExercise = exercise
                                    },
                                    onDelete: {
                                        deleteExercise(exercise.id)
                                    }
                                )
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.vertical, 16)
                    }
                    .background(Color(.systemGroupedBackground))
                }
                
                // Bottom Actions
                VStack(spacing: 12) {
                    Divider()
                    
                    Button(action: {
                        showAddExercise = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Exercise")
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
            }
            .navigationTitle("Edit Day")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Cancel") {
//                        dismiss()
//                    }
//                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Reset to Original") {
                            resetDayToOriginal()
                        }
                        
                        Button("Done") {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showAddExercise) {
            AddExerciseView(dayId: dayId)
                .environmentObject(viewModel)
        }
        .sheet(item: $editingExercise) { exercise in
            EditExerciseView(exercise: exercise, dayId: dayId)
                .environmentObject(viewModel)
        }
    }
    
    // MARK: - Actions
    
    private func deleteExercise(_ exerciseId: UUID) {
        // Prevent deleting the last exercise
        if currentDay.exercises.count <= 1 {
            viewModel.showErrorMessage("Each day must have at least one exercise")
            return
        }
        
        viewModel.deleteExerciseFromSuggestedDay(dayId: dayId, exerciseId: exerciseId)
    }
    
    private func resetDayToOriginal() {
        viewModel.resetSuggestedDayToOriginal(dayId: dayId)
    }
}

// MARK: - Preview
#Preview {
    let viewModel = WorkoutPlanViewModel()
    let sampleDay = SampleData.sampleDay
    viewModel.suggestedPlan = SampleData.sampleSuggestedPlan
    
    return DayEditView(day: sampleDay, dayId: sampleDay.id)
        .environmentObject(viewModel)
}
