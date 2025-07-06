//
//  ExerciseRowView.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//

import SwiftUI

struct ExerciseRowView: View {
    let exercise: Exercise
    let dayId: UUID
    let onToggle: (UUID) -> Void
    
    var body: some View {
        HStack {
            Button(action: {
                print("🔘 Exercise button tapped: \(exercise.name)")
                onToggle(exercise.id)
            }) {
                Image(systemName: exercise.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(exercise.isCompleted ? .green : .gray)
                    .font(.title2)
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.headline)
                    .strikethrough(exercise.isCompleted)
                    .foregroundColor(exercise.isCompleted ? .secondary : .primary)
                
                Text(exercise.formattedDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if exercise.isCompleted {
                Image(systemName: "checkmark")
                    .foregroundColor(.green)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle()) // Make the entire row tappable
        .onTapGesture {
            print("🔘 Row tapped: \(exercise.name)")
            onToggle(exercise.id)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        ExerciseRowView(
            exercise: Exercise(name: "Push-ups", sets: 3, quantity: 12, unit: .reps),
            dayId: UUID(),
            onToggle: { exerciseId in
                print("Preview toggle: \(exerciseId)")
            }
        )
        
        ExerciseRowView(
            exercise: Exercise(name: "Plank", sets: 1, quantity: 45, unit: .seconds),
            dayId: UUID(),
            onToggle: { exerciseId in
                print("Preview toggle: \(exerciseId)")
            }
        )
        
        ExerciseRowView(
            exercise: Exercise(name: "Cardio", sets: 1, quantity: 5, unit: .minutes),
            dayId: UUID(),
            onToggle: { exerciseId in
                print("Preview toggle: \(exerciseId)")
            }
        )
    }
    .padding()
}
