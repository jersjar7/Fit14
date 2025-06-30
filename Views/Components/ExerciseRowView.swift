//
//  ExerciseRowView.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//

import SwiftUI

struct ExerciseRowView: View {
    @Binding var exercise: Exercise
    
    var body: some View {
        HStack {
            Button(action: {
                exercise.isCompleted.toggle()
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
    @State var sampleExercise = SampleData.sampleExercises[0]
    return ExerciseRowView(exercise: $sampleExercise)
        .padding()
}
