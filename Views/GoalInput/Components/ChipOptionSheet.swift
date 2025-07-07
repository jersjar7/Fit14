//
//  ChipOptionSheet.swift
//  Fit14
//
//  Created by Jerson on 7/6/25.
//

import SwiftUI

// MARK: - Option Selection Sheet

struct ChipOptionSheet: View {
    
    // MARK: - Properties
    
    let chipData: ChipData
    let onSelection: (ChipOption, String?) -> Void  // option, customValue
    let onCancel: () -> Void
    
    @State private var selectedOption: ChipOption?
    @State private var customText: String = ""
    @State private var showingCustomInput = false
    @State private var searchText = ""
    @State private var showingValidationError = false
    @State private var validationMessage = ""
    
    @FocusState private var isCustomInputFocused: Bool
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Computed Properties
    
    private var displayConfig: ChipDisplayConfig {
        ChipConfiguration.getDisplayConfig(for: chipData.type)
    }
    
    private var filteredOptions: [ChipOption] {
        if searchText.isEmpty {
            return chipData.options
        } else {
            return chipData.options.filter { option in
                option.displayText.localizedCaseInsensitiveContains(searchText) ||
                option.description?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
    }
    
    private var hasSearchableOptions: Bool {
        return chipData.options.count > 6
    }
    
    private var canSave: Bool {
        if let selected = selectedOption {
            if selected.isCustom {
                return !customText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            return true
        }
        return false
    }
    
    private var currentSelection: ChipOption? {
        return selectedOption ?? chipData.selection?.selectedOption
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Section
                headerSection
                
                // Search Bar (if needed)
                if hasSearchableOptions {
                    searchSection
                }
                
                // Options List
                optionsSection
                
                // Custom Input Section
                if showingCustomInput {
                    customInputSection
                }
                
                // Action Buttons
                actionButtonsSection
            }
            .navigationTitle(chipData.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        handleCancel()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        handleSave()
                    }
                    .disabled(!canSave)
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            setupInitialState()
        }
        .alert("Invalid Input", isPresented: $showingValidationError) {
            Button("OK") { }
        } message: {
            Text(validationMessage)
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            // Chip Type Icon and Title
            HStack(spacing: 12) {
                Image(systemName: chipData.icon)
                    .font(.title2)
                    .foregroundColor(chipIconColor)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(chipIconColor.opacity(0.1))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(chipData.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(chipData.type.promptContext)
                        .font(.subheadline)
                        .foregroundColor(Color.secondary)
                }
                
                Spacer()
                
                // Importance Badge
                importanceBadge
            }
            
            // Instructions
            if displayConfig.requiresAttention {
                attentionBanner
            } else {
                instructionText
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
    
    private var chipIconColor: Color {
        switch chipData.type.importance {
        case .critical:
            return Color.orange
        case .high:
            return Color.orange.opacity(0.8)
        case .medium:
            return Color.orange.opacity(0.6)
        case .low:
            return Color.gray
        }
    }
    
    private var importanceBadge: some View {
        Text(chipData.type.importance.displayName)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundColor(Color.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(importanceBadgeColor)
            )
    }
    
    private var importanceBadgeColor: Color {
        switch chipData.type.importance {
        case .critical:
            return Color.orange
        case .high:
            return Color.orange.opacity(0.8)
        case .medium:
            return Color.blue
        case .low:
            return Color.gray
        }
    }
    
    private var attentionBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(Color.orange)
            
            Text("This information is important for creating a safe workout plan")
                .font(.caption)
                .foregroundColor(Color.primary)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.orange.opacity(0.1))
        )
    }
    
    private var instructionText: some View {
        Text(displayConfig.allowMultipleSelection ?
             "Select all that apply to your situation" :
             "Choose the option that best describes you")
            .font(.caption)
            .foregroundColor(Color.secondary)
            .multilineTextAlignment(.center)
    }
    
    // MARK: - Search Section
    
    private var searchSection: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color.secondary)
                
                TextField("Search options...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            
            Divider()
        }
    }
    
    // MARK: - Options Section
    
    private var optionsSection: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(filteredOptions, id: \.id) { option in
                    OptionRowView(
                        option: option,
                        isSelected: currentSelection?.id == option.id,
                        allowsMultipleSelection: displayConfig.allowMultipleSelection,
                        onTap: {
                            handleOptionTap(option)
                        }
                    )
                    .padding(.horizontal, 16)
                    
                    if option.id != filteredOptions.last?.id {
                        Divider()
                            .padding(.leading, 16)
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - Custom Input Section
    
    private var customInputSection: some View {
        VStack(spacing: 12) {
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Custom Input")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Button("Clear") {
                        customText = ""
                    }
                    .font(.caption)
                    .foregroundColor(Color.orange)
                    .opacity(customText.isEmpty ? 0 : 1)
                }
                
                // Custom input field with context-specific placeholder
                TextField(getCustomInputPlaceholder(), text: $customText, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($isCustomInputFocused)
                    .lineLimit(3, reservesSpace: true)
                    .onChange(of: customText) { _, _ in
                        // Clear any validation errors when user starts typing
                        showingValidationError = false
                    }
                
                // Helper text for custom input
                Text(getCustomInputHelper())
                    .font(.caption)
                    .foregroundColor(Color.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .background(Color(.systemGroupedBackground))
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    // MARK: - Action Buttons Section
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            Divider()
            
            HStack(spacing: 16) {
                // Cancel Button
                Button("Cancel") {
                    handleCancel()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray5))
                .foregroundColor(Color.primary)
                .cornerRadius(12)
                
                // Save Button
                Button("Save") {
                    handleSave()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(canSave ? Color.orange : Color.gray)
                .foregroundColor(Color.white)
                .cornerRadius(12)
                .disabled(!canSave)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - Helper Methods
    
    private func setupInitialState() {
        // Pre-select current option if any
        selectedOption = chipData.selection?.selectedOption
        
        // Pre-fill custom text if any
        if let customValue = chipData.selection?.customValue {
            customText = customValue
        }
        
        // Show custom input if custom option is selected
        if selectedOption?.isCustom == true {
            showingCustomInput = true
            // Delay focus to allow sheet to settle
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isCustomInputFocused = true
            }
        }
    }
    
    private func handleOptionTap(_ option: ChipOption) {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        selectedOption = option
        
        // Handle custom input toggle
        withAnimation(.easeInOut(duration: 0.3)) {
            showingCustomInput = option.isCustom
        }
        
        if option.isCustom {
            // Focus custom input after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isCustomInputFocused = true
            }
        } else {
            // Clear custom text if non-custom option selected
            customText = ""
        }
    }
    
    private func handleSave() {
        guard let option = selectedOption else { return }
        
        // Validate input if needed
        if let validationResult = validateInput(option: option) {
            showingValidationError = true
            validationMessage = validationResult
            return
        }
        
        // Prepare custom value
        let customValue = option.isCustom ?
            customText.trimmingCharacters(in: .whitespacesAndNewlines) : nil
        
        // Call completion handler
        onSelection(option, customValue)
        
        // Dismiss sheet
        dismiss()
    }
    
    private func handleCancel() {
        onCancel()
        dismiss()
    }
    
    private func validateInput(option: ChipOption) -> String? {
        if option.isCustom {
            let trimmedText = customText.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmedText.isEmpty {
                return "Please enter a value or select a different option"
            }
            
            // Use ChipConfiguration validation
            let tempSelection = ChipSelection(chipType: chipData.type, selectedOption: option, customValue: trimmedText)
            let validationResult = ChipConfiguration.validateSelection(tempSelection)
            
            if !validationResult.isValid {
                return validationResult.errorMessage
            }
        }
        
        return nil
    }
    
    private func getCustomInputPlaceholder() -> String {
        switch chipData.type {
        case .physicalStats:
            return "e.g., 5'6\", 140 lbs"
        case .timeAvailable:
            return "e.g., 45 minutes"
        case .workoutLocation:
            return "e.g., home gym with weights"
        case .fitnessLevel:
            return "e.g., intermediate with some limitations"
        case .sex:
            return "e.g., non-binary"
        case .weeklyFrequency:
            return "e.g., 5 days per week when possible"
        default:
            return "Enter your details..."
        }
    }
    
    private func getCustomInputHelper() -> String {
        switch chipData.type {
        case .physicalStats:
            return "Include both height and weight for better workout recommendations"
        case .timeAvailable:
            return "Include time units (minutes/hours) for accurate planning"
        case .workoutLocation:
            return "Describe your space and any equipment available"
        case .fitnessLevel:
            return "Describe your experience level and any specific considerations"
        case .weeklyFrequency:
            return "Be realistic about how often you can consistently work out"
        default:
            return "Provide as much detail as helpful for your workout plan"
        }
    }
}

// MARK: - Option Row View

struct OptionRowView: View {
    let option: ChipOption
    let isSelected: Bool
    let allowsMultipleSelection: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Selection Indicator
                Group {
                    if allowsMultipleSelection {
                        Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    } else {
                        Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    }
                }
                .font(.title3)
                .foregroundColor(isSelected ? Color.orange : Color.gray)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
                
                // Option Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(option.displayText)
                            .font(.body)
                            .fontWeight(isSelected ? .medium : .regular)
                            .foregroundColor(Color.primary)
                        
                        Spacer()
                        
                        // Custom input indicator
                        if option.isCustom {
                            Image(systemName: "pencil")
                                .font(.caption)
                                .foregroundColor(Color.secondary)
                        }
                    }
                    
                    // Option Description
                    if let description = option.description {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(Color.secondary)
                            .multilineTextAlignment(.leading)
                    }
                }
                
                Spacer(minLength: 0)
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.orange.opacity(0.05) : Color.clear)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        )
        .accessibilityLabel("\(option.displayText)\(option.description != nil ? ", \(option.description!)" : "")")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Preview Provider

#Preview("Fitness Level Options") {
    ChipOptionSheet(
        chipData: ChipConfiguration.createChipData(for: .fitnessLevel),
        onSelection: { option, customValue in
            print("Selected: \(option.displayText), Custom: \(customValue ?? "none")")
        },
        onCancel: {
            print("Cancelled")
        }
    )
}

#Preview("Time Available Options") {
    ChipOptionSheet(
        chipData: ChipConfiguration.createChipData(for: .timeAvailable),
        onSelection: { option, customValue in
            print("Selected: \(option.displayText), Custom: \(customValue ?? "none")")
        },
        onCancel: {
            print("Cancelled")
        }
    )
}

#Preview("Physical Stats (Custom Input)") {
    ChipOptionSheet(
        chipData: ChipConfiguration.createChipData(for: .physicalStats),
        onSelection: { option, customValue in
            print("Selected: \(option.displayText), Custom: \(customValue ?? "none")")
        },
        onCancel: {
            print("Cancelled")
        }
    )
}

#Preview("Workout Location Options") {
    ChipOptionSheet(
        chipData: ChipConfiguration.createChipData(for: .workoutLocation),
        onSelection: { option, customValue in
            print("Selected: \(option.displayText), Custom: \(customValue ?? "none")")
        },
        onCancel: {
            print("Cancelled")
        }
    )
}
