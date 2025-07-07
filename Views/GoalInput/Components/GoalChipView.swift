//
//  GoalChipView.swift
//  Fit14
//
//  Created by Jerson on 7/6/25.
//

import SwiftUI

// MARK: - Chip Style Configuration

enum ChipStyle {
    case standard       // Default chip appearance
    case compact       // Smaller size for crowded layouts
    case prominent     // Larger, more attention-grabbing
    case minimal       // Text-only, subtle appearance
    
    var height: CGFloat {
        switch self {
        case .standard: return 44
        case .compact: return 36
        case .prominent: return 52
        case .minimal: return 32
        }
    }
    
    var padding: EdgeInsets {
        switch self {
        case .standard: return EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
        case .compact: return EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10)
        case .prominent: return EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        case .minimal: return EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
        }
    }
    
    var iconSize: CGFloat {
        switch self {
        case .standard: return 16
        case .compact: return 14
        case .prominent: return 20
        case .minimal: return 12
        }
    }
    
    var cornerRadius: CGFloat {
        return height / 2
    }
}

// MARK: - Goal Chip View

struct GoalChipView: View {
    
    // MARK: - Properties
    
    let chipData: ChipData
    let style: ChipStyle
    let onTap: () -> Void
    
    @State private var isPressed = false
    @State private var isAnimating = false
    
    // MARK: - Visual State
    
    private var isSelected: Bool { chipData.isSelected }
    private var isRequired: Bool { chipData.isRequired }
    
    // MARK: - Initialization
    
    init(chipData: ChipData, style: ChipStyle = .standard, onTap: @escaping () -> Void) {
        self.chipData = chipData
        self.style = style
        self.onTap = onTap
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(action: handleTap) {
            HStack(spacing: 8) {
                // Icon
                if style != .minimal {
                    Image(systemName: chipData.icon)
                        .font(.system(size: style.iconSize, weight: .medium))
                        .foregroundColor(iconColor)
                        .scaleEffect(isPressed ? 0.9 : 1.0)
                        .animation(.easeInOut(duration: 0.1), value: isPressed)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 2) {
                    // Title and selection indicator
                    HStack(spacing: 4) {
                        Text(displayTitle)
                            .font(titleFont)
                            .fontWeight(titleFontWeight)
                            .foregroundColor(titleColor)
                            .lineLimit(1)
                        
                        // Required indicator
                        if isRequired && !isSelected && style != .minimal {
                            Text("*")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(Color.red)
                        }
                        
                        Spacer(minLength: 0)
                        
                        // Selection checkmark
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.green)
                                .scaleEffect(isAnimating ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)
                        }
                    }
                    
                    // Selected value display
                    if isSelected, let selectedText = chipData.selectedText, style != .minimal {
                        Text(selectedText)
                            .font(.caption)
                            .foregroundColor(Color.secondary)
                            .lineLimit(1)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
            .padding(style.padding)
            .frame(minHeight: style.height)
            .background(backgroundView)
            .overlay(borderView)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.1)) {
                isAnimating = true
            }
        }
        .onChange(of: isSelected) { _, newValue in
            if newValue {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isAnimating = true
                }
                
                // Haptic feedback for selection
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }
        }
    }
    
    // MARK: - Visual Components
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: style.cornerRadius)
            .fill(backgroundColor)
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: 0,
                y: isPressed ? 1 : 2
            )
    }
    
    private var borderView: some View {
        RoundedRectangle(cornerRadius: style.cornerRadius)
            .stroke(borderColor, lineWidth: borderWidth)
    }
    
    // MARK: - Style Computations
    
    private var backgroundColor: Color {
        if isSelected {
            return Color.orange.opacity(0.1)
        } else if isPressed {
            return Color.gray.opacity(0.2)
        } else if isRequired && !isSelected {
            return Color.orange.opacity(0.05)
        } else {
            return Color(.systemBackground)
        }
    }
    
    private var borderColor: Color {
        if isSelected {
            return Color.orange
        } else if isRequired && !isSelected {
            return Color.orange.opacity(0.6)
        } else {
            return Color(.systemGray4)
        }
    }
    
    private var borderWidth: CGFloat {
        return isSelected ? 2.0 : 1.0
    }
    
    private var shadowColor: Color {
        if isSelected {
            return Color.orange.opacity(0.3)
        } else {
            return Color.black.opacity(0.1)
        }
    }
    
    private var shadowRadius: CGFloat {
        return isSelected ? 4 : 2
    }
    
    private var iconColor: Color {
        if isSelected {
            return Color.orange
        } else if isRequired && !isSelected {
            return Color.orange
        } else {
            return Color.primary
        }
    }
    
    private var titleColor: Color {
        if isSelected {
            return Color.orange
        } else if isRequired && !isSelected {
            return Color.primary
        } else {
            return Color.primary
        }
    }
    
    private var titleFont: Font {
        switch style {
        case .standard: return .subheadline
        case .compact: return .caption
        case .prominent: return .headline
        case .minimal: return .caption2
        }
    }
    
    private var titleFontWeight: Font.Weight {
        return isSelected ? .semibold : .medium
    }
    
    private var displayTitle: String {
        switch style {
        case .compact, .minimal:
            return chipData.type.shortTitle
        default:
            return chipData.title
        }
    }
    
    // MARK: - Accessibility
    
    private var accessibilityLabel: String {
        var label = chipData.title
        
        if isSelected, let selectedText = chipData.selectedText {
            label += ", selected: \(selectedText)"
        } else {
            label += ", not selected"
        }
        
        if isRequired {
            label += ", required"
        }
        
        label += ", essential information"
        
        return label
    }
    
    private var accessibilityHint: String {
        if isSelected {
            return "Tap to change selection"
        } else {
            return "Tap to select options"
        }
    }
    
    // MARK: - Interaction Handling
    
    private func handleTap() {
        // Visual feedback
        withAnimation(.easeInOut(duration: 0.1)) {
            isPressed = true
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Reset press state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = false
            }
        }
        
        // Execute tap action
        onTap()
    }
}

// MARK: - Chip Appearance Modifiers

extension GoalChipView {
    
    /// Create a compact version of the chip
    func compact() -> GoalChipView {
        return GoalChipView(chipData: chipData, style: .compact, onTap: onTap)
    }
    
    /// Create a prominent version of the chip
    func prominent() -> GoalChipView {
        return GoalChipView(chipData: chipData, style: .prominent, onTap: onTap)
    }
    
    /// Create a minimal version of the chip
    func minimal() -> GoalChipView {
        return GoalChipView(chipData: chipData, style: .minimal, onTap: onTap)
    }
}

// MARK: - Specialized Chip Views

/// A chip that shows loading state
struct LoadingChipView: View {
    let title: String
    let style: ChipStyle
    
    init(_ title: String, style: ChipStyle = .standard) {
        self.title = title
        self.style = style
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ProgressView()
                .scaleEffect(0.8)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color.secondary)
        }
        .padding(style.padding)
        .frame(minHeight: style.height)
        .background(
            RoundedRectangle(cornerRadius: style.cornerRadius)
                .fill(Color(.systemGray6))
        )
        .disabled(true)
    }
}

/// A chip that shows an error state
struct ErrorChipView: View {
    let title: String
    let error: String
    let style: ChipStyle
    let onRetry: () -> Void
    
    init(_ title: String, error: String, style: ChipStyle = .standard, onRetry: @escaping () -> Void) {
        self.title = title
        self.error = error
        self.style = style
        self.onRetry = onRetry
    }
    
    var body: some View {
        Button(action: onRetry) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: style.iconSize))
                    .foregroundColor(Color.red)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(Color.primary)
            }
            .padding(style.padding)
            .frame(minHeight: style.height)
            .background(
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .fill(Color.red.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .stroke(Color.red.opacity(0.6), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(title), error: \(error)")
        .accessibilityHint("Tap to retry")
    }
}

// MARK: - Preview Provider

#Preview("Essential Chips") {
    VStack(spacing: 16) {
        // Essential chip - unselected
        GoalChipView(
            chipData: ChipConfiguration.createChipData(for: .fitnessLevel),
            onTap: { print("Fitness Level tapped") }
        )
        
        // Essential chip - selected
        GoalChipView(
            chipData: {
                var chip = ChipConfiguration.createChipData(for: .timeAvailable)
                chip.select(option: ChipOption(value: "30-45 minutes", displayText: "30-45 minutes"))
                return chip
            }(),
            onTap: { print("Time Available tapped") }
        )
        
        // Required essential chip - unselected (fitnessLevel is critical)
        GoalChipView(
            chipData: ChipConfiguration.createChipData(for: .fitnessLevel),
            onTap: { print("Fitness Level tapped") }
        )
        
        // Essential chip with long selected text
        GoalChipView(
            chipData: {
                var chip = ChipConfiguration.createChipData(for: .physicalStats)
                chip.select(option: ChipOption(value: "custom", displayText: "5'8\", 165 lbs"))
                return chip
            }(),
            onTap: { print("Physical Stats tapped") }
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Chip Styles") {
    VStack(spacing: 16) {
        let chipData = {
            var chip = ChipConfiguration.createChipData(for: .fitnessLevel)
            chip.select(option: ChipOption(value: "intermediate", displayText: "Intermediate"))
            return chip
        }()
        
        // Different styles
        GoalChipView(chipData: chipData, style: .prominent, onTap: {})
        GoalChipView(chipData: chipData, style: .standard, onTap: {})
        GoalChipView(chipData: chipData, style: .compact, onTap: {})
        GoalChipView(chipData: chipData, style: .minimal, onTap: {})
        
        // Special states
        LoadingChipView("Loading...")
        ErrorChipView("Failed to Load", error: "Network error", onRetry: {})
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Essential Chips Layout") {
    ScrollView {
        LazyVGrid(columns: [
            GridItem(.adaptive(minimum: 120), spacing: 8)
        ], spacing: 8) {
            ForEach(ChipType.essentialTypes, id: \.self) { chipType in
                GoalChipView(
                    chipData: ChipConfiguration.createChipData(for: chipType),
                    style: .compact,
                    onTap: { print("\(chipType.displayTitle) tapped") }
                )
            }
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
