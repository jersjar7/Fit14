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
                
                Text("\(exercise.sets) sets × \(exercise.reps) reps")
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
    }
}

#Preview {
    ExerciseRowView(
        exercise: SampleData.sampleExercises[0],
        dayId: UUID(),
        onToggle: { _ in }
    )
    .padding()
}
