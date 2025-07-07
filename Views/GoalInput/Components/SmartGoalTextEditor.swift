//
//  SmartGoalTextEditor.swift
//  Fit14
//
//  Created by Jerson on 7/7/25.
//  Advanced text editor with inline chip selection for goal input assistance
//

import SwiftUI

// MARK: - Smart Goal Text Editor

/// An intelligent text editor that provides inline chip selection for essential information
struct SmartGoalTextEditor: View {
    
    // MARK: - Properties
    
    @ObservedObject var chipAssistant: EssentialChipAssistant
    @State private var textFieldText: String = ""
    @State private var isEditing: Bool = false
    @State private var currentPromptType: ChipType? = nil
    @State private var showingInlineOptions: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    
    // Text field configuration
    let placeholder: String
    let minHeight: CGFloat
    
    // MARK: - Computed Properties
    
    /// Convert placeholder tokens to user-friendly display text
    private var displayText: String {
        var text = textFieldText
        
        // Replace placeholder tokens with user-friendly prompts
        let tokenReplacements: [String: String] = [
            "{{FITNESS_LEVEL_PLACEHOLDER}}": "My fitness level is ",
            "{{SEX_PLACEHOLDER}}": "I am a ",
            "{{PHYSICAL_STATS_PLACEHOLDER}}": "My height and weight are ",
            "{{TIME_AVAILABLE_PLACEHOLDER}}": "I can work out for ",
            "{{WORKOUT_LOCATION_PLACEHOLDER}}": "I will be working out ",
            "{{WEEKLY_FREQUENCY_PLACEHOLDER}}": "I can exercise "  // Changed from "I can work out "
        ]
        
        for (token, replacement) in tokenReplacements {
            text = text.replacingOccurrences(of: token, with: replacement)
        }
        
        return text
    }
    
    /// Detect if the current text ends with a user-friendly prompt
    private var activePromptInfo: (type: ChipType, template: String)? {
        // Check if displayText ends with any user-friendly prompts (order matters - longer prompts first)
        let promptMappings: [(String, ChipType)] = [
            ("My fitness level is ", .fitnessLevel),
            ("My height and weight are ", .physicalStats),
            ("I can work out for ", .timeAvailable),  // Check this before the shorter "I can exercise "
            ("I will be working out ", .workoutLocation),
            ("I can exercise ", .weeklyFrequency),  // Changed from "I can work out "
            ("I am a ", .sex)
        ]
        
        for (prompt, chipType) in promptMappings {
            if displayText.hasSuffix(prompt) {
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
        .onChange(of: textFieldText) { _, newValue in
            // Sync with chip assistant
            chipAssistant.updateGoalText(newValue)
        }
        .onChange(of: chipAssistant.goalText) { _, newValue in
            // Sync from chip assistant (when external updates happen)
            if newValue != textFieldText {
                textFieldText = newValue
            }
        }
        .onAppear {
            // Initialize with existing goal text
            textFieldText = chipAssistant.goalText
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
            
            // Text editor
            TextEditor(text: Binding(
                get: { displayText },
                set: { newValue in
                    // Convert user-friendly text back to tokens if needed
                    textFieldText = convertDisplayTextToTokens(newValue)
                }
            ))
            .focused($isTextFieldFocused)
            .font(.system(size: 15, weight: .regular, design: .rounded)) // Custom size with rounded design
            .padding(12)
            .padding(.bottom, isTextFieldFocused ? 40 : 12) // Extra bottom padding when focused to make room for Done button
            .background(Color.clear)
            .scrollContentBackground(.hidden)
            .frame(minHeight: minHeight)
            .onChange(of: isTextFieldFocused) { _, focused in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isEditing = focused
                }
            }
            
            // Placeholder text
            if displayText.isEmpty && !isEditing {
                Text(placeholder)
                    .font(.system(size: 15, weight: .regular, design: .rounded)) // Match the TextEditor font
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
            
            // Done button in bottom right corner (only when focused)
            if isTextFieldFocused {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            isTextFieldFocused = false
                        }) {
                            Text("Done")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue)
                                .cornerRadius(6)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(8)
                .transition(.opacity.combined(with: .scale))
                .animation(.easeInOut(duration: 0.2), value: isTextFieldFocused)
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
    
    /// Convert user-friendly display text back to internal tokens
    private func convertDisplayTextToTokens(_ displayText: String) -> String {
        var text = displayText
        
        // Convert user-friendly prompts back to tokens (reverse of displayText conversion)
        let tokenReplacements: [String: String] = [
            "My fitness level is ": "{{FITNESS_LEVEL_PLACEHOLDER}}",
            "I am a ": "{{SEX_PLACEHOLDER}}",
            "My height and weight are ": "{{PHYSICAL_STATS_PLACEHOLDER}}",
            "I can work out for ": "{{TIME_AVAILABLE_PLACEHOLDER}}",
            "I will be working out ": "{{WORKOUT_LOCATION_PLACEHOLDER}}",
            "I can work out ": "{{WEEKLY_FREQUENCY_PLACEHOLDER}}"
        ]
        
        for (prompt, token) in tokenReplacements {
            text = text.replacingOccurrences(of: prompt, with: token)
        }
        
        return text
    }
    
    /// Handle selection of an inline option
    private func selectOption(_ option: ChipSelectionOption) {
        guard let promptInfo = activePromptInfo else { return }
        
        // Complete the chip in the assistant
        chipAssistant.completeChip(type: promptInfo.type, selectedOption: option)
        
        // Update local text (will be synced from chipAssistant)
        withAnimation(.easeInOut(duration: 0.3)) {
            // The chipAssistant will update the goalText, which will sync back to textFieldText
        }
        
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
        textFieldText = ""
        isTextFieldFocused = false
    }
    
    /// Get the current text content
    func getText() -> String {
        return textFieldText
    }
    
    /// Set text content programmatically
    func setText(_ text: String) {
        chipAssistant.updateGoalText(text)
        textFieldText = text
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
