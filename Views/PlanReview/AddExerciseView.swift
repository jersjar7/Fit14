//
//  AddExerciseView.swift
//  Fit14
//
//  Created by Jerson on 7/4/25.
//

import SwiftUI

struct AddExerciseView: View {
    @EnvironmentObject var viewModel: WorkoutPlanViewModel
    @Environment(\.dismiss) private var dismiss
    
    let dayId: UUID
    
    @State private var exerciseName = ""
    @State private var sets = ""
    @State private var quantity = ""
    @State private var selectedUnit: ExerciseUnit = .reps
    @State private var showValidationError = false
    @State private var errorMessage = ""
    
    @FocusState private var isNameFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                    
                    Text("Add Exercise")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Create a custom exercise for this day")
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
                        
                        TextField("e.g., Push-ups, Squats, Plank", text: $exerciseName)
                            .textFieldStyle(.roundedBorder)
                            .focused($isNameFieldFocused)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.words)
                    }
                    
                    // Sets
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sets")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("3", text: $sets)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Unit Selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Measurement Type")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Picker("Unit", selection: $selectedUnit) {
                            ForEach(ExerciseUnit.allCases, id: \.self) { unit in
                                Text(unit.displayName.capitalized)
                                    .tag(unit)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // Quantity (context-aware label)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(quantityLabel)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField(quantityPlaceholder, text: $quantity)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Helpful Tips
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tips:")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            switch selectedUnit {
                            case .reps:
                                Text("• Common rep ranges: 8-12 for strength, 12-20 for endurance")
                                Text("• Start with 2-3 sets if you're unsure")
                            case .seconds:
                                Text("• Good for holds like planks, wall sits")
                                Text("• 30-60 seconds is typical for most holds")
                            case .minutes:
                                Text("• Best for longer cardio activities")
                                Text("• 5-20 minutes depending on intensity")
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .animation(.easeInOut(duration: 0.2), value: selectedUnit)
                }
                .padding(.horizontal, 4)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: saveExercise) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Add Exercise")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(!isFormValid)
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        saveExercise()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isFormValid)
                }
            }
            .alert("Invalid Input", isPresented: $showValidationError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                // Auto-focus the name field
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isNameFieldFocused = true
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var quantityLabel: String {
        switch selectedUnit {
        case .reps:
            return "Reps"
        case .seconds:
            return "Seconds"
        case .minutes:
            return "Minutes"
        }
    }
    
    private var quantityPlaceholder: String {
        switch selectedUnit {
        case .reps:
            return "10"
        case .seconds:
            return "30"
        case .minutes:
            return "5"
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
    
    // MARK: - Actions
    
    private func saveExercise() {
        guard validateInput() else { return }
        
        let newExercise = Exercise(
            name: exerciseName.trimmingCharacters(in: .whitespacesAndNewlines),
            sets: Int(sets)!,
            quantity: Int(quantity)!,
            unit: selectedUnit
        )
        
        // Add exercise to the suggested plan
        viewModel.addExerciseToSuggestedDay(dayId: dayId, exercise: newExercise)
        
        print("✅ Added exercise: \(newExercise.name) - \(newExercise.formattedDescription)")
        
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
        
        // Validate quantity (context-aware validation)
        guard let quantityValue = Int(quantity), quantityValue > 0 else {
            showError("Please enter a valid \(selectedUnit.displayName) value (1 or more)")
            return false
        }
        
        // Unit-specific validation
        switch selectedUnit {
        case .reps:
            if quantityValue > 1000 {
                showError("Number of reps seems too high (max 1000)")
                return false
            }
        case .seconds:
            if quantityValue > 3600 { // 1 hour
                showError("Duration in seconds seems too long (max 3600)")
                return false
            }
        case .minutes:
            if quantityValue > 180 { // 3 hours
                showError("Duration in minutes seems too long (max 180)")
                return false
            }
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
    AddExerciseView(dayId: UUID())
        .environmentObject(WorkoutPlanViewModel())
}
