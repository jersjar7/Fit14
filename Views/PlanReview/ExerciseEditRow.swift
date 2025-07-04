//
//  ExerciseEditRow.swift
//  Fit14
//
//  Created by Jerson on 7/4/25.
//

import SwiftUI

struct ExerciseEditRow: View {
    let exercise: Exercise
    let onTap: () -> Void
    let onDelete: () -> Void
    
    @State private var dragOffset = CGSize.zero
    @State private var showDeleteButton = false
    
    private let deleteThreshold: CGFloat = -80
    private let showButtonThreshold: CGFloat = -30
    
    var body: some View {
        HStack(spacing: 0) {
            // Main Exercise Content
            HStack(spacing: 12) {
                // Exercise Icon
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 18))
                        .foregroundColor(.blue)
                }
                
                // Exercise Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        Label("\(exercise.sets)", systemImage: "repeat")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Label("\(exercise.reps)", systemImage: "number")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Edit Indicator
                Image(systemName: "pencil")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .opacity(0.6)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .offset(x: dragOffset.width)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: dragOffset)
            
            // Delete Button (revealed on swipe)
            if showDeleteButton {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        dragOffset = CGSize.zero
                        showDeleteButton = false
                    }
                    
                    // Delay the delete action slightly for better UX
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        onDelete()
                    }
                }) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.red)
                        .cornerRadius(12)
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onChanged { value in
                    // Only allow left swipes (negative translation)
                    let translation = min(0, value.translation.width)
                    dragOffset = CGSize(width: translation, height: 0)
                    
                    // Show delete button when swiped far enough
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showDeleteButton = translation < showButtonThreshold
                    }
                }
                .onEnded { value in
                    let translation = value.translation.width
                    
                    if translation < deleteThreshold {
                        // Auto-delete if swiped far enough
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            dragOffset = CGSize(width: -200, height: 0)
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            onDelete()
                        }
                    } else if translation < showButtonThreshold {
                        // Keep delete button visible
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            dragOffset = CGSize(width: -60, height: 0)
                        }
                    } else {
                        // Snap back to original position
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            dragOffset = CGSize.zero
                            showDeleteButton = false
                        }
                    }
                }
        )
        .onTapGesture {
            // Reset swipe state if user taps
            if showDeleteButton {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    dragOffset = CGSize.zero
                    showDeleteButton = false
                }
            } else {
                onTap()
            }
        }
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 12) {
        ExerciseEditRow(
            exercise: Exercise(name: "Push-ups", sets: 3, reps: 12),
            onTap: { print("Edit push-ups") },
            onDelete: { print("Delete push-ups") }
        )
        
        ExerciseEditRow(
            exercise: Exercise(name: "Squats", sets: 4, reps: 15),
            onTap: { print("Edit squats") },
            onDelete: { print("Delete squats") }
        )
        
        ExerciseEditRow(
            exercise: Exercise(name: "Plank Hold", sets: 1, reps: 60),
            onTap: { print("Edit plank") },
            onDelete: { print("Delete plank") }
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
