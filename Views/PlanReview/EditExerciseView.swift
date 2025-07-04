//
//  EditExerciseView.swift
//  Fit14
//
//  Created by Jerson on 7/4/25.
//

import SwiftUI

struct EditExerciseView: View {
    @EnvironmentObject var viewModel: WorkoutPlanViewModel
    @Environment(\.dismiss) private var dismiss
    
    let exercise: Exercise
    let dayId: UUID
    
    @State private var exerciseName = ""
    @State private var sets = ""
    @State private var reps = ""
    @State private var showValidationError = false
    @State private var errorMessage = ""
    
    @FocusState private var isNameFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                    
                    Text("Edit Exercise")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Modify the exercise details")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Form Fields
                VStack(spacing: 20) {
                    // Exercise Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Exercise Name")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Exercise name", text: $exerciseName)
                            .textFieldStyle(.roundedBorder)
                            .focused($isNameFieldFocused)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.words)
                    }
                    
                    // Sets and Reps
                    HStack(spacing: 16) {
                        // Sets
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Sets")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Sets", text: $sets)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Reps
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Reps")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Reps", text: $reps)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    // Current vs New Preview
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Preview:")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            // Original
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Original")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                
                                Text("\(exercise.name)")
                                    .font(.caption)
                                    .strikethrough()
                                    .foregroundColor(.secondary)
                                
                                Text("\(exercise.sets) sets × \(exercise.reps) reps")
                                    .font(.caption)
                                    .strikethrough()
                                    .foregroundColor(.secondary)
                            }
                            
                            Image(systemName: "arrow.right")
                                .font(.caption)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 8)
                            
                            // New
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Updated")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)
                                
                                Text(exerciseName.isEmpty ? "Exercise name" : exerciseName)
                                    .font(.caption)
                                    .foregroundColor(exerciseName.isEmpty ? .secondary : .primary)
                                
                                Text("\(sets.isEmpty ? "0" : sets) sets × \(reps.isEmpty ? "0" : reps) reps")
                                    .font(.caption)
                                    .foregroundColor(sets.isEmpty || reps.isEmpty ? .secondary : .primary)
                            }
                            
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                .padding(.horizontal, 4)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: saveChanges) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Save Changes")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid && hasChanges ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(!isFormValid || !hasChanges)
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .navigationTitle("Edit Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isFormValid || !hasChanges)
                }
            }
            .alert("Invalid Input", isPresented: $showValidationError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                // Pre-fill with existing exercise data
                exerciseName = exercise.name
                sets = String(exercise.sets)
                reps = String(exercise.reps)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        !exerciseName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !sets.isEmpty &&
        !reps.isEmpty &&
        Int(sets) != nil &&
        Int(reps) != nil &&
        Int(sets)! > 0 &&
        Int(reps)! > 0
    }
    
    private var hasChanges: Bool {
        let trimmedName = exerciseName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedName != exercise.name ||
               sets != String(exercise.sets) ||
               reps != String(exercise.reps)
    }
    
    // MARK: - Actions
    
    private func saveChanges() {
        guard validateInput() else { return }
        
        let updatedExercise = Exercise(
            name: exerciseName.trimmingCharacters(in: .whitespacesAndNewlines),
            sets: Int(sets)!,
            reps: Int(reps)!
        )
        
        // Update exercise in the suggested plan
        viewModel.updateExerciseInSuggestedDay(dayId: dayId, oldExerciseId: exercise.id, newExercise: updatedExercise)
        
        print("✅ Updated exercise: \(updatedExercise.name) - \(updatedExercise.sets) sets × \(updatedExercise.reps) reps")
        
        dismiss()
    }
    
    private func validateInput() -> Bool {
        // Validate exercise name
        let trimmedName = exerciseName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            showError("Please enter an exercise name")
            return false
        }
        
        if trimmedName.count > 50 {
            showError("Exercise name is too long (max 50 characters)")
            return false
        }
        
        // Validate sets
        guard let setsValue = Int(sets), setsValue > 0 else {
            showError("Please enter a valid number of sets (1 or more)")
            return false
        }
        
        if setsValue > 20 {
            showError("Number of sets seems too high (max 20)")
            return false
        }
        
        // Validate reps
        guard let repsValue = Int(reps), repsValue > 0 else {
            showError("Please enter a valid number of reps (1 or more)")
            return false
        }
        
        if repsValue > 1000 {
            showError("Number of reps seems too high (max 1000)")
            return false
        }
        
        return true
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showValidationError = true
    }
}

// MARK: - Preview
#Preview {
    let sampleExercise = Exercise(name: "Push-ups", sets: 3, reps: 12)
    
    return EditExerciseView(exercise: sampleExercise, dayId: UUID())
        .environmentObject(WorkoutPlanViewModel())
}
