//
//  SmartGoalTextEditor.swift
//  Fit14
//
//  Created by Jerson on 7/6/25.
//  Updated with focus mode and enhanced text input functionality
//

import SwiftUI

// MARK: - Smart Goal Text Editor

struct SmartGoalTextEditor: View {
    
    // MARK: - Bindings
    
    @Binding var text: String
    @Binding var isInFocusMode: Bool
    
    // MARK: - State
    
    @FocusState var isTextFieldFocused: Bool
    @State private var analysisService: GoalAnalysisService?
    
    // MARK: - Configuration
    
    let placeholder: String
    let analysisEnabled: Bool
    let characterLimit: Int?
    let onFocusModeToggle: () -> Void
    let onTextChange: ((String) -> Void)?
    
    // MARK: - Computed Properties
    
    private var isGenerating: Bool {
        // This would typically come from a view model
        false
    }
    
    private var showCharacterCount: Bool {
        !text.isEmpty || characterLimit != nil
    }
    
    // MARK: - Initialization
    
    init(
        text: Binding<String>,
        isInFocusMode: Binding<Bool> = .constant(false),
        placeholder: String = "Tap to describe your fitness goals...",
        analysisEnabled: Bool = true,
        characterLimit: Int? = nil,
        onFocusModeToggle: @escaping () -> Void = {},
        onTextChange: ((String) -> Void)? = nil
    ) {
        self._text = text
        self._isInFocusMode = isInFocusMode
        self.placeholder = placeholder
        self.analysisEnabled = analysisEnabled
        self.characterLimit = characterLimit
        self.onFocusModeToggle = onFocusModeToggle
        self.onTextChange = onTextChange
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 8) {
            if isInFocusMode {
                focusedTextEditorSection
            } else {
                simpleTextFieldSection
            }
            
            // Character count and analysis status
            if showCharacterCount {
                textMetadataSection
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .onAppear {
            setupAnalysisService()
        }
        .onChange(of: text) { _, newValue in
            handleTextChange(newValue)
        }
    }
    
    // MARK: - Simple Text Field Section
    
    private var simpleTextFieldSection: some View {
        Button(action: {
            onFocusModeToggle()
        }) {
            HStack {
                Text(text.isEmpty ? placeholder : text)
                    .font(.body)
                    .foregroundColor(text.isEmpty ? .secondary : .primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                
                Spacer()
                
                if !text.isEmpty {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isGenerating)
    }
    
    // MARK: - Focused Text Editor Section
    
    private var focusedTextEditorSection: some View {
        VStack(spacing: 12) {
            TextField("Describe your fitness goals in detail...", text: $text, axis: .vertical)
                .focused($isTextFieldFocused)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                .font(.body)
                .lineLimit(4...8)
                .disabled(isGenerating)
                .onAppear {
                    // Auto-focus when entering focus mode
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isTextFieldFocused = true
                    }
                }
        }
    }
    
    // MARK: - Text Metadata Section
    
    private var textMetadataSection: some View {
        HStack {
            // Character count
            if let limit = characterLimit {
                Text("\(text.count)/\(limit) characters")
                    .font(.caption)
                    .foregroundColor(text.count > limit ? .red : .secondary)
            } else {
                Text("\(text.count) characters")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Analysis status
            if analysisEnabled {
                analysisStatusView
            }
        }
    }
    
    // MARK: - Analysis Status View
    
    private var analysisStatusView: some View {
        Group {
            if let service = analysisService, service.isAnalyzing {
                HStack(spacing: 4) {
                    ProgressView()
                        .scaleEffect(0.6)
                    Text("Analyzing...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                    Text("Ready")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func setupAnalysisService() {
        if analysisEnabled && analysisService == nil {
            analysisService = GoalAnalysisService()
        }
    }
    
    private func handleTextChange(_ newValue: String) {
        // Apply character limit if specified
        if let limit = characterLimit, newValue.count > limit {
            text = String(newValue.prefix(limit))
            return
        }
        
        // Trigger analysis if enabled
        if analysisEnabled {
            analysisService?.analyzeText(newValue, with: UserGoalData())
        }
        
        // Call external change handler
        onTextChange?(newValue)
    }
}

// MARK: - Enhanced Text Editor with Suggestions

struct EnhancedGoalTextEditor: View {
    
    // MARK: - Bindings
    
    @Binding var text: String
    @Binding var isInFocusMode: Bool
    
    // MARK: - State
    
    @FocusState private var isTextFieldFocused: Bool
    @State private var showingSuggestions = false
    @State private var suggestions: [String] = []
    @State private var analysisResults: GoalAnalysisResult?
    
    // MARK: - Configuration
    
    let chipAssistant: EssentialChipAssistant
    let placeholder: String
    let onFocusModeToggle: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 12) {
            // Text input section
            textInputSection
            
            // Suggestions section
            if showingSuggestions && !suggestions.isEmpty {
                suggestionsSection
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            // Analysis insights
            if let results = analysisResults, !results.insights.isEmpty {
                analysisInsightsSection(results)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .onChange(of: text) { _, newValue in
            updateSuggestions(for: newValue)
        }
        .onChange(of: isInFocusMode) { _, inFocus in
            if inFocus {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isTextFieldFocused = true
                }
            }
        }
    }
    
    // MARK: - Text Input Section
    
    private var textInputSection: some View {
        Group {
            if isInFocusMode {
                focusedEditor
            } else {
                compactField
            }
        }
    }
    
    private var compactField: some View {
        Button(action: onFocusModeToggle) {
            HStack {
                Text(text.isEmpty ? placeholder : text)
                    .font(.body)
                    .foregroundColor(text.isEmpty ? .secondary : .primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                
                Spacer()
                
                if !text.isEmpty {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var focusedEditor: some View {
        VStack(spacing: 8) {
            TextField("Describe your fitness goals in detail...", text: $text, axis: .vertical)
                .focused($isTextFieldFocused)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                .font(.body)
                .lineLimit(4...8)
            
            // Metadata
            HStack {
                Text("\(text.count) characters")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if chipAssistant.completedCount > 0 {
                    Text("\(chipAssistant.completedCount) details added")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
    }
    
    // MARK: - Suggestions Section
    
    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb")
                    .foregroundColor(.yellow)
                    .font(.caption)
                
                Text("Suggestions")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(suggestions.prefix(3), id: \.self) { suggestion in
                        suggestionPill(suggestion)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.yellow.opacity(0.05))
                .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func suggestionPill(_ suggestion: String) -> some View {
        Button(action: {
            addSuggestionToText(suggestion)
        }) {
            Text(suggestion)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color(.systemBackground))
                        .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Analysis Insights Section
    
    private func analysisInsightsSection(_ results: GoalAnalysisResult) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "brain")
                    .foregroundColor(.blue)
                    .font(.caption)
                
                Text("AI Insights")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(results.insights.prefix(2), id: \.self) { insight in
                    HStack(alignment: .top, spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                            .font(.caption2)
                            .padding(.top, 1)
                        
                        Text(insight)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.blue.opacity(0.05))
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Helper Methods
    
    private func updateSuggestions(for text: String) {
        // Generate contextual suggestions based on current text
        var newSuggestions: [String] = []
        
        let lowercaseText = text.lowercased()
        
        // Suggest missing essential information
        if !lowercaseText.contains("beginner") && !lowercaseText.contains("intermediate") && !lowercaseText.contains("advanced") {
            newSuggestions.append("fitness level")
        }
        
        if !lowercaseText.contains("minutes") && !lowercaseText.contains("hour") {
            newSuggestions.append("workout duration")
        }
        
        if !lowercaseText.contains("home") && !lowercaseText.contains("gym") {
            newSuggestions.append("workout location")
        }
        
        if !lowercaseText.contains("equipment") && !lowercaseText.contains("weights") && !lowercaseText.contains("bodyweight") {
            newSuggestions.append("available equipment")
        }
        
        suggestions = newSuggestions
        showingSuggestions = !newSuggestions.isEmpty
    }
    
    private func addSuggestionToText(_ suggestion: String) {
        let prompt = "Please specify your \(suggestion)."
        let currentText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if currentText.isEmpty {
            text = prompt
        } else if !currentText.hasSuffix(".") && !currentText.hasSuffix("?") && !currentText.hasSuffix("!") {
            text = currentText + ". " + prompt
        } else {
            text = currentText + " " + prompt
        }
        
        // Update suggestions after adding text
        updateSuggestions(for: text)
    }
}

// MARK: - Supporting Types

struct GoalAnalysisResult {
    let insights: [String]
    let completenessScore: Double
    let suggestions: [String]
}

// MARK: - Preview

#Preview("Simple Text Editor") {
    SmartGoalTextEditor(
        text: .constant("I want to build muscle and improve my strength"),
        isInFocusMode: .constant(false),
        onFocusModeToggle: {
            print("Focus mode toggled")
        }
    )
    .padding()
}

#Preview("Focus Mode Editor") {
    SmartGoalTextEditor(
        text: .constant("I want to build muscle and improve my strength"),
        isInFocusMode: .constant(true),
        onFocusModeToggle: {
            print("Focus mode toggled")
        }
    )
    .padding()
}

#Preview("Enhanced Editor") {
    EnhancedGoalTextEditor(
        text: .constant("I want to lose weight"),
        isInFocusMode: .constant(true),
        chipAssistant: EssentialChipAssistant(),
        placeholder: "Describe your fitness goals...",
        onFocusModeToggle: {
            print("Focus mode toggled")
        }
    )
    .padding()
}
