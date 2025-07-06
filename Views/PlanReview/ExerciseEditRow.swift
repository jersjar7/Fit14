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
                        .fill(exercise.unit.isTimeBased ? Color.orange.opacity(0.1) :
                              exercise.unit.isDistanceBased ? Color.green.opacity(0.1) :
                              Color.blue.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: unitIcon)
                        .font(.system(size: 18))
                        .foregroundColor(exercise.unit.isTimeBased ? .orange :
                                       exercise.unit.isDistanceBased ? .green :
                                       .blue)
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
                        
                        Label("\(exercise.quantity)", systemImage: unitSystemImage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(exercise.unit.shortDisplayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Unit Category Badge
                Text(exercise.unit.unitCategory)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(exercise.unit.isTimeBased ? Color.orange :
                               exercise.unit.isDistanceBased ? Color.green :
                               Color.blue)
                    .cornerRadius(4)
                    .opacity(0.8)
                
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
    
    // MARK: - Computed Properties
    
    private var unitIcon: String {
        switch exercise.unit {
        // Count-based units
        case .reps:
            return "figure.strengthtraining.traditional"
        case .steps:
            return "figure.walk"
        case .laps:
            return "arrow.clockwise"
            
        // Time-based units
        case .seconds:
            return "timer"
        case .minutes:
            return "clock"
        case .hours:
            return "clock.badge"
            
        // Distance-based units
        case .meters:
            return "ruler"
        case .yards:
            return "ruler"
        case .feet:
            return "ruler.fill"
        case .kilometers:
            return "location"
        case .miles:
            return "location.fill"
        }
    }
    
    private var unitSystemImage: String {
        switch exercise.unit {
        // Count-based units
        case .reps:
            return "number"
        case .steps:
            return "figure.walk"
        case .laps:
            return "arrow.clockwise"
            
        // Time-based units
        case .seconds:
            return "timer"
        case .minutes:
            return "clock"
        case .hours:
            return "clock.badge"
            
        // Distance-based units
        case .meters:
            return "ruler"
        case .yards:
            return "ruler"
        case .feet:
            return "ruler.fill"
        case .kilometers:
            return "location"
        case .miles:
            return "location.fill"
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 12) {
        // Count-based exercises
        ExerciseEditRow(
            exercise: Exercise(name: "Push-ups", sets: 3, quantity: 12, unit: .reps),
            onTap: { print("Edit push-ups") },
            onDelete: { print("Delete push-ups") }
        )
        
        ExerciseEditRow(
            exercise: Exercise(name: "Walking", sets: 1, quantity: 5000, unit: .steps),
            onTap: { print("Edit walking") },
            onDelete: { print("Delete walking") }
        )
        
        ExerciseEditRow(
            exercise: Exercise(name: "Swimming", sets: 1, quantity: 10, unit: .laps),
            onTap: { print("Edit swimming") },
            onDelete: { print("Delete swimming") }
        )
        
        // Time-based exercises
        ExerciseEditRow(
            exercise: Exercise(name: "Plank", sets: 1, quantity: 45, unit: .seconds),
            onTap: { print("Edit plank") },
            onDelete: { print("Delete plank") }
        )
        
        ExerciseEditRow(
            exercise: Exercise(name: "Cardio", sets: 1, quantity: 20, unit: .minutes),
            onTap: { print("Edit cardio") },
            onDelete: { print("Delete cardio") }
        )
        
        ExerciseEditRow(
            exercise: Exercise(name: "Hiking", sets: 1, quantity: 2, unit: .hours),
            onTap: { print("Edit hiking") },
            onDelete: { print("Delete hiking") }
        )
        
        // Distance-based exercises
        ExerciseEditRow(
            exercise: Exercise(name: "Sprint", sets: 3, quantity: 100, unit: .meters),
            onTap: { print("Edit sprint") },
            onDelete: { print("Delete sprint") }
        )
        
        ExerciseEditRow(
            exercise: Exercise(name: "Running", sets: 1, quantity: 5, unit: .kilometers),
            onTap: { print("Edit running") },
            onDelete: { print("Delete running") }
        )
        
        ExerciseEditRow(
            exercise: Exercise(name: "Long Run", sets: 1, quantity: 3, unit: .miles),
            onTap: { print("Edit long run") },
            onDelete: { print("Delete long run") }
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
