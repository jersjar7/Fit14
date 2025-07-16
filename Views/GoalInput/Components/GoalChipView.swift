//
//  GoalChipView.swift
//  Fit14
//
//  Created by Jerson on 7/6/25.
//  Updated with enhanced chip button component and better animations
//

import SwiftUI

// MARK: - Enhanced Goal Chip View

struct EnhancedGoalChipView: View {
    let chip: EssentialChip
    let onTap: () -> Void
    let onReset: () -> Void
    
    var body: some View {
        Button(action: {
            if chip.isCompleted {
                onReset()
            } else {
                onTap()
            }
        }) {
            VStack(spacing: 6) {
                Image(systemName: chip.icon)
                    .font(.title2)
                    .foregroundColor(chip.isCompleted ? .white : .blue)
                
                Text(chip.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(chip.isCompleted ? .white : .primary)
                    .multilineTextAlignment(.center)
                
                // Completion status with subtle text
                if chip.isCompleted {
                    if let selectedOption = chip.selectedOption,
                       !selectedOption.displayText.isEmpty {
                        Text(selectedOption.displayText)
                            .font(.caption2)
                            .fontWeight(.regular)
                            .foregroundColor(.white.opacity(0.85))
                            .lineLimit(1)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.15))
                            )
                    } else {
                        Text("✓ Added")
                            .font(.caption2)
                            .fontWeight(.regular)
                            .foregroundColor(.white.opacity(0.85))
                    }
                } else {
                    Text("Tap to select")
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.8))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        chip.isCompleted ?
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color(.systemGray6), Color(.systemGray6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .stroke(
                        chip.isCompleted ? Color.clear : Color(.systemGray4),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(chip.isCompleted ? 1.0 : 0.98)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: chip.isCompleted)
    }
}

// MARK: - Legacy Goal Chip View (Backwards Compatibility)

struct GoalChipView: View {
    let chipData: ChipData
    let style: ChipStyle
    let isSelected: Bool
    let onTap: () -> Void
    
    @State private var isPressed = false
    @State private var hasAppeared = false
    
    init(
        chipData: ChipData,
        style: ChipStyle = .standard,
        isSelected: Bool = false,
        onTap: @escaping () -> Void
    ) {
        self.chipData = chipData
        self.style = style
        self.isSelected = isSelected || chipData.isSelected
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: handleTap) {
            chipContent
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : (hasAppeared ? 1.0 : 0.8))
        .opacity(hasAppeared ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double.random(in: 0.0...0.3))) {
                hasAppeared = true
            }
        }
        .onLongPressGesture(minimumDuration: 0.0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
    
    @ViewBuilder
    private var chipContent: some View {
        switch style {
        case .standard:
            standardChipContent
        case .compact:
            compactChipContent
        case .detailed:
            detailedChipContent
        }
    }
    
    // MARK: - Standard Style
    
    private var standardChipContent: some View {
        VStack(spacing: 8) {
            // Icon
            Image(systemName: chipData.icon)
                .font(.title2)
                .foregroundColor(isSelected ? .white : accentColor)
                .fontWeight(.medium)
            
            // Title
            Text(chipData.title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : .primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            // Selection indicator or prompt
            if isSelected {
                selectionIndicator
            } else {
                Text("Tap to select")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .opacity(0.8)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 90)
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(backgroundView)
    }
    
    // MARK: - Compact Style
    
    private var compactChipContent: some View {
        HStack(spacing: 8) {
            Image(systemName: chipData.icon)
                .font(.title3)
                .foregroundColor(isSelected ? .white : accentColor)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(chipData.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                
                if isSelected, let selectedOption = chipData.selection?.selectedOption {
                    Text(selectedOption.displayText)
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.white)
                    .font(.caption)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(backgroundView)
    }
    
    // MARK: - Detailed Style
    
    private var detailedChipContent: some View {
        VStack(spacing: 10) {
            // Header
            HStack {
                Image(systemName: chipData.icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .white : accentColor)
                
                Text(chipData.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.caption)
                }
            }
            
            // Content
            if isSelected, let selectedOption = chipData.selection?.selectedOption {
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedOption.displayText)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    if let description = selectedOption.description {
                        Text(description)
                            .font(.caption2)
                            .foregroundColor(isSelected ? .white.opacity(0.7) : .secondary)
                            .lineLimit(2)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text("Tap to select your \(chipData.title.lowercased())")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(backgroundView)
    }
    
    // MARK: - Supporting Views
    
    private var selectionIndicator: some View {
        Group {
            if let selectedOption = chipData.selection?.selectedOption {
                Text(selectedOption.displayText)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                    )
                    .lineLimit(1)
            } else {
                HStack(spacing: 2) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption2)
                        .foregroundColor(.white)
                    Text("Selected")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.9))
                }
            }
        }
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                isSelected ?
                LinearGradient(
                    colors: [accentColor, accentColor.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ) :
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.systemGray6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .stroke(
                isSelected ? Color.clear : Color(.systemGray4),
                lineWidth: 1
            )
            .shadow(
                color: isSelected ? accentColor.opacity(0.3) : Color.clear,
                radius: isSelected ? 8 : 0,
                x: 0,
                y: isSelected ? 2 : 0
            )
    }
    
    private var accentColor: Color {
        switch chipData.category {
        case .universal:
            return .blue
        }
    }
    
    // MARK: - Actions
    
    private func handleTap() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        onTap()
    }
}

// MARK: - Chip Styles

enum ChipStyle {
    case standard
    case compact
    case detailed
}

// MARK: - Preview

#Preview("Enhanced Chip - Incomplete") {
    EnhancedGoalChipView(
        chip: EssentialChip(
            type: .fitnessLevel,
            title: "Fitness Level",
            icon: "figure.run",
            isCompleted: false
        ),
        onTap: { print("Chip tapped") },
        onReset: { print("Chip reset") }
    )
    .padding()
    .frame(width: 150)
}

#Preview("Enhanced Chip - Complete") {
    EnhancedGoalChipView(
        chip: EssentialChip(
            type: .fitnessLevel,
            title: "Fitness Level",
            icon: "figure.run",
            isCompleted: true,
            selectedOption: ChipOption(value: "intermediate", displayText: "Intermediate")
        ),
        onTap: { print("Chip tapped") },
        onReset: { print("Chip reset") }
    )
    .padding()
    .frame(width: 150)
}

#Preview("Legacy Chip Styles") {
    VStack(spacing: 20) {
        // Standard style
        GoalChipView(
            chipData: ChipConfiguration.createChipData(for: .fitnessLevel),
            style: .standard,
            isSelected: false,
            onTap: { print("Standard tapped") }
        )
        .frame(width: 120, height: 90)
        
        // Compact style
        GoalChipView(
            chipData: ChipConfiguration.createChipData(for: .timeAvailable),
            style: .compact,
            isSelected: true,
            onTap: { print("Compact tapped") }
        )
        .frame(width: 200, height: 50)
        
        // Detailed style
        GoalChipView(
            chipData: ChipConfiguration.createChipData(for: .workoutLocation),
            style: .detailed,
            isSelected: true,
            onTap: { print("Detailed tapped") }
        )
        .frame(width: 250, height: 80)
    }
    .padding()
}
