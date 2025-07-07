//
//  SmartGoalTextEditor.swift
//  Fit14
//
//  Created by Jerson on 7/7/25.
//  Advanced text editor with inline chip selection for goal input assistance
//  FIXED: Removed token conversion that was interfering with chip completion
//

import SwiftUI

// MARK: - Smart Goal Text Editor

/// An intelligent text editor that provides inline chip selection for essential information
struct SmartGoalTextEditor: View {
    
    // MARK: - Properties
    
    @ObservedObject var chipAssistant: EssentialChipAssistant
    @State private var isEditing: Bool = false
    @State private var currentPromptType: ChipType? = nil
    @State private var showingInlineOptions: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    
    // Text field configuration
    let placeholder: String
    let minHeight: CGFloat
    
    // MARK: - Computed Properties
    
    /// Detect if the current text ends with a user-friendly prompt that needs completion
    private var activePromptInfo: (type: ChipType, template: String)? {
        let text = chipAssistant.goalText
        
        // Check if text ends with any user-friendly prompts (order matters - longer prompts first)
        let promptMappings: [(String, ChipType)] = [
            ("My fitness level is ", .fitnessLevel),
            ("My height and weight are ", .physicalStats),
            ("I can work out for ", .timeAvailable),
            ("I will be working out ", .workoutLocation),
            ("I can exercise ", .weeklyFrequency),
            ("I am a ", .sex)
        ]
        
        for (prompt, chipType) in promptMappings {
            if text.hasSuffix(prompt) {
                if let chip = chipAssistant.getChip(for: chipType), !chip.isCompleted {
                    return (chipType, chip.promptTemplate)
                }
            }
        }
        
        return nil
    }
    
    /// Get the inline options for the current active prompt
    private var inlineOptions: [ChipSelectionOption] {
        guard let promptInfo = activePromptInfo else { return [] }
        return chipAssistant.getInlineOptions(for: promptInfo.type)
    }
    
    /// Whether to show inline selection chips
    private var shouldShowInlineSelection: Bool {
        return isEditing && activePromptInfo != nil && !inlineOptions.isEmpty
    }
    
    // MARK: - Initialization
    
    init(
        chipAssistant: EssentialChipAssistant,
        placeholder: String = "Describe your fitness goals...",
        minHeight: CGFloat = 120
    ) {
        self.chipAssistant = chipAssistant
        self.placeholder = placeholder
        self.minHeight = minHeight
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main text editor
            textEditorSection
            
            // Inline selection chips (appears below text field when needed)
            if shouldShowInlineSelection {
                inlineSelectionSection
                    .padding(.top, 8)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .onTapGesture {
            // Dismiss keyboard when tapping outside the text area
            if isTextFieldFocused {
                isTextFieldFocused = false
            }
        }
        .onChange(of: isTextFieldFocused) { _, focused in
            withAnimation(.easeInOut(duration: 0.2)) {
                isEditing = focused
            }
        }
    }
    
    // MARK: - Text Editor Section
        
    private var textEditorSection: some View {
        ZStack(alignment: .topLeading) {
            // Background
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground)) // White background
                .stroke(isTextFieldFocused ? Color.blue : Color(.systemGray4), lineWidth: isTextFieldFocused ? 2 : 1)
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2) // More prominent shadow
            
            // Text editor - FIXED: Now works directly with chipAssistant.goalText
            TextEditor(text: $chipAssistant.goalText)
                .focused($isTextFieldFocused)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .padding(12)
                .background(Color.clear)
                .scrollContentBackground(.hidden)
                .frame(minHeight: minHeight)
            
            // Placeholder text
            if chipAssistant.goalText.isEmpty && !isEditing {
                Text(placeholder)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                    .allowsHitTesting(false)
            }
            
            // Invisible overlay to handle taps on the text editor specifically
            if !isTextFieldFocused {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isTextFieldFocused = true
                    }
            }
        }
    }
    
    // MARK: - Inline Selection Section
    
    private var inlineSelectionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Section header
            HStack {
                Image(systemName: "hand.tap")
                    .foregroundColor(.blue)
                    .font(.caption)
                
                Text("Select an option:")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            // Selection chips
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 120), spacing: 8)
            ], spacing: 8) {
                ForEach(inlineOptions) { option in
                    selectionChipView(for: option)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.blue.opacity(0.05))
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Selection Chip View
    
    private func selectionChipView(for option: ChipSelectionOption) -> some View {
        Button(action: {
            selectOption(option)
        }) {
            HStack(spacing: 4) {
                Text(option.displayText)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                
                // Show info icon if there's a description
                if option.description != nil {
                    Image(systemName: "info.circle")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white)
                    .stroke(Color.blue, lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .help(option.description ?? "")
    }
    
    // MARK: - Actions
    
    /// Handle selection of an inline option
    private func selectOption(_ option: ChipSelectionOption) {
        guard let promptInfo = activePromptInfo else { return }
        
        // Complete the chip in the assistant
        chipAssistant.completeChip(type: promptInfo.type, selectedOption: option)
        
        // Provide haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Keep focus on text field for continued editing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isTextFieldFocused = true
        }
        
        print("✅ Selected option: \(option.displayText) for \(promptInfo.type.displayTitle)")
    }
    
    /// Insert a prompt template at the current cursor position
    func insertPrompt(for chipType: ChipType) {
        chipAssistant.insertPromptForChip(type: chipType)
        
        // Focus the text field after insertion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isTextFieldFocused = true
        }
    }
    
    /// Clear all text and reset chips
    func clearText() {
        chipAssistant.reset()
        isTextFieldFocused = false
    }
    
    /// Get the current text content
    func getText() -> String {
        return chipAssistant.goalText
    }
    
    /// Set text content programmatically
    func setText(_ text: String) {
        chipAssistant.updateGoalText(text)
    }
}

// MARK: - Scale Button Style

/// Custom button style that provides subtle scale animation
private struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    VStack {
        SmartGoalTextEditor(
            chipAssistant: EssentialChipAssistant(),
            placeholder: "Describe your fitness goals..."
        )
        .padding()
        
        Spacer()
    }
    .background(Color(.systemBackground))
}
