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
    @State private var quantity = ""
    @State private var selectedUnit: ExerciseUnit = .reps
    @State private var showValidationError = false
    @State private var errorMessage = ""
    @State private var hasUserChangedUnit = false
    
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
                            .onChange(of: exerciseName) { _, newValue in
                                // Only suggest unit changes if user hasn't manually changed the unit
                                if !hasUserChangedUnit && !newValue.isEmpty {
                                    let smartUnit = CategoryUnitPicker.smartDefaultUnit(for: newValue)
                                    if smartUnit != selectedUnit {
                                        selectedUnit = smartUnit
                                    }
                                }
                            }
                    }
                    
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
                    
                    // Unit Selection with CategoryUnitPicker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Measurement Type")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        CategoryUnitPicker(selectedUnit: $selectedUnit)
                            .onChange(of: selectedUnit) { _, newUnit in
                                hasUserChangedUnit = true
                                // Adjust quantity if it's outside the new unit's valid range
                                if let currentQuantity = Int(quantity),
                                   !newUnit.isValidQuantity(currentQuantity) {
                                    let range = newUnit.suggestedRange
                                    quantity = String((range.lowerBound + range.upperBound) / 2)
                                }
                            }
                    }
                    
                    // Quantity (context-aware label)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(quantityLabel)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField(quantityLabel, text: $quantity)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
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
                                
                                Text(exercise.name)
                                    .font(.caption)
                                    .strikethrough()
                                    .foregroundColor(.secondary)
                                
                                Text(exercise.formattedDescription)
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
                                
                                Text(updatedDescription)
                                    .font(.caption)
                                    .foregroundColor(sets.isEmpty || quantity.isEmpty ? .secondary : .primary)
                            }
                            
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                    // Smart Tips based on selected unit
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: selectedUnit.systemIcon)
                                .foregroundColor(.blue)
                                .font(.caption)
                            
                            Text("Tips for \(selectedUnit.displayName):")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(tipsForSelectedUnit, id: \.self) { tip in
                                Text("• \(tip)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .animation(.easeInOut(duration: 0.2), value: selectedUnit)
                }
                .padding(.horizontal, 4)
                
                Spacer()
            }
            .padding(.horizontal, 20)
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
                quantity = String(exercise.quantity)
                selectedUnit = exercise.unit
                
                // Don't auto-suggest units since we're editing existing exercise
                hasUserChangedUnit = true
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var quantityLabel: String {
        switch selectedUnit {
        // Count-based
        case .reps:
            return "Repetitions"
        case .steps:
            return "Steps"
        case .laps:
            return "Laps"
            
        // Time-based
        case .seconds:
            return "Seconds"
        case .minutes:
            return "Minutes"
        case .hours:
            return "Hours"
            
        // Distance-based
        case .meters:
            return "Meters"
        case .yards:
            return "Yards"
        case .feet:
            return "Feet"
        case .kilometers:
            return "Kilometers"
        case .miles:
            return "Miles"
        }
    }
    
    private var updatedDescription: String {
        let setsText = sets.isEmpty ? "0" : sets
        let quantityText = quantity.isEmpty ? "0" : quantity
        return "\(setsText) sets × \(quantityText) \(selectedUnit.shortDisplayName)"
    }
    
    private var tipsForSelectedUnit: [String] {
        switch selectedUnit {
        // Count-based tips
        case .reps:
            return [
                "8-12 reps for strength building",
                "12-20 reps for endurance",
                "Adjust based on your fitness level"
            ]
        case .steps:
            return [
                "10,000 steps = roughly 5 miles",
                "2,000 steps = about 1 mile",
                "Great for active recovery days"
            ]
        case .laps:
            return [
                "Pool lap = down and back (50m)",
                "Track lap = 400m around",
                "Build up gradually for endurance"
            ]
            
        // Time-based tips
        case .seconds:
            return [
                "Perfect for holds and isometric exercises",
                "30-60 seconds is typical for planks",
                "Focus on maintaining proper form"
            ]
        case .minutes:
            return [
                "Great for cardio and longer activities",
                "5-20 minutes depending on intensity",
                "Good for stretching and mobility work"
            ]
        case .hours:
            return [
                "Best for long activities like hiking",
                "1-4 hours for endurance activities",
                "Remember to take breaks and stay hydrated"
            ]
            
        // Distance-based tips
        case .meters:
            return [
                "Good for short runs and sprints",
                "100m sprint = about 10-15 seconds",
                "Track your progress over time"
            ]
        case .yards:
            return [
                "Common in American sports training",
                "100 yards ≈ 91 meters",
                "Great for agility and speed work"
            ]
        case .feet:
            return [
                "Perfect for jump distances",
                "Good for short movement drills",
                "Focus on consistent technique"
            ]
        case .kilometers:
            return [
                "Ideal for medium to long runs",
                "5K = beginner race distance",
                "10K = intermediate challenge"
            ]
        case .miles:
            return [
                "Popular for running goals",
                "1 mile ≈ 1.6 kilometers",
                "Half marathon = 13.1 miles"
            ]
        }
    }
    
    private var isFormValid: Bool {
        !exerciseName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !sets.isEmpty &&
        !quantity.isEmpty &&
        Int(sets) != nil &&
        Int(quantity) != nil &&
        Int(sets)! > 0 &&
        Int(quantity)! > 0
    }
    
    private var hasChanges: Bool {
        let trimmedName = exerciseName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedName != exercise.name ||
               sets != String(exercise.sets) ||
               quantity != String(exercise.quantity) ||
               selectedUnit != exercise.unit
    }
    
    // MARK: - Actions
    
    private func saveChanges() {
        guard validateInput() else { return }
        
        let updatedExercise = Exercise(
            name: exerciseName.trimmingCharacters(in: .whitespacesAndNewlines),
            sets: Int(sets)!,
            quantity: Int(quantity)!,
            unit: selectedUnit
        )
        
        // Update exercise in the suggested plan
        viewModel.updateExerciseInSuggestedDay(dayId: dayId, oldExerciseId: exercise.id, newExercise: updatedExercise)
        
        print("✅ Updated exercise: \(updatedExercise.name) - \(updatedExercise.formattedDescription)")
        
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
        
        // Validate quantity using the ExerciseUnit's validation
        guard let quantityValue = Int(quantity), quantityValue > 0 else {
            showError("Please enter a valid \(selectedUnit.displayName) value (1 or more)")
            return false
        }
        
        // Use the unit's built-in validation
        guard selectedUnit.isValidQuantity(quantityValue) else {
            let range = selectedUnit.suggestedRange
            showError("Value for \(selectedUnit.displayName) should be between \(range.lowerBound) and \(range.upperBound)")
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
    let sampleExercise = Exercise(name: "Push-ups", sets: 3, quantity: 12, unit: .reps)
    
    return EditExerciseView(exercise: sampleExercise, dayId: UUID())
        .environmentObject(WorkoutPlanViewModel())
}

#Preview("Running Exercise") {
    let runningExercise = Exercise(name: "Morning Run", sets: 1, quantity: 5, unit: .kilometers)
    
    return EditExerciseView(exercise: runningExercise, dayId: UUID())
        .environmentObject(WorkoutPlanViewModel())
}

#Preview("Time-based Exercise") {
    let plankExercise = Exercise(name: "Plank Hold", sets: 3, quantity: 45, unit: .seconds)
    
    return EditExerciseView(exercise: plankExercise, dayId: UUID())
        .environmentObject(WorkoutPlanViewModel())
}
