//
//  ChipOptionSheet.swift
//  Fit14
//
//  Created by Jerson on 7/6/25.
//  Updated with new overlay styling and interaction patterns
//

import SwiftUI

// MARK: - Chip Options Overlay (New Style)

struct ChipOptionsOverlay: View {
    let chip: EssentialChip
    let onSelection: (ChipOption, EssentialChip) -> Void
    let onDismiss: () -> Void
    
    @State private var showingChipOptions = false
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            // Options container
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: chip.icon)
                                .foregroundColor(.blue)
                                .font(.title2)
                            
                            Text(chip.title)
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Button("✕") {
                                onDismiss()
                            }
                            .foregroundColor(.secondary)
                            .font(.title3)
                        }
                        
                        Text("Choose your \(chip.title.lowercased())")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Options grid
                    let chipData = ChipConfiguration.createChipData(for: chip.type)
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(chipData.options.prefix(6), id: \.id) { option in
                            ChipOptionButton(
                                option: option,
                                chip: chip,
                                onSelection: onSelection
                            )
                        }
                    }
                    
                    // Show more options if there are many
                    if chipData.options.count > 6 {
                        Button("See all \(chipData.options.count) options") {
                            // You can implement a full sheet here if needed
                            onDismiss()
                            // chipAssistant.insertPromptForChip(type: chip.type) // This would need to be handled by parent
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(.top, 8)
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.2), radius: 25, x: 0, y: 15)
                )
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
        .transition(.asymmetric(
            insertion: .scale(scale: 0.9).combined(with: .opacity),
            removal: .scale(scale: 0.95).combined(with: .opacity)
        ))
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showingChipOptions)
        .zIndex(10)
    }
}

// MARK: - Enhanced Chip Option Button

struct ChipOptionButton: View {
    let option: ChipOption
    let chip: EssentialChip
    let onSelection: (ChipOption, EssentialChip) -> Void
    
    var body: some View {
        Button(action: {
            onSelection(option, chip)
        }) {
            VStack(spacing: 8) {
                Text(option.displayText)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                if let description = option.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 70)
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Legacy Option Selection Sheet (Backwards Compatibility)

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
                // Search Section (if needed)
                if hasSearchableOptions {
                    searchSection
                }
                
                // Options List
                optionsListSection
                
                // Custom Input Section (if showing)
                if showingCustomInput {
                    customInputSection
                }
                
                // Action Buttons
                actionButtonsSection
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(chipData.type.displayTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        handleCancel()
                    }
                }
            }
        }
        .onAppear {
            selectedOption = chipData.selection?.selectedOption
            if let selected = chipData.selection?.selectedOption, selected.isCustom {
                customText = chipData.selection?.customValue ?? ""
                showingCustomInput = true
            }
        }
        .alert("Validation Error", isPresented: $showingValidationError) {
            Button("OK") { }
        } message: {
            Text(validationMessage)
        }
    }
    
    // MARK: - Search Section
    
    private var searchSection: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search options...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button("Clear") {
                        searchText = ""
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            Divider()
                .padding(.top, 8)
        }
    }
    
    // MARK: - Options List Section
    
    private var optionsListSection: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(filteredOptions, id: \.id) { option in
                    optionRow(for: option)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
    
    private func optionRow(for option: ChipOption) -> some View {
        Button(action: {
            handleOptionSelection(option)
        }) {
            HStack(spacing: 12) {
                // Selection indicator
                Image(systemName: currentSelection?.id == option.id ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(currentSelection?.id == option.id ? .blue : .secondary)
                    .font(.title3)
                
                // Option content
                VStack(alignment: .leading, spacing: 4) {
                    Text(option.displayText)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    if let description = option.description {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                }
                
                Spacer()
                
                // Custom indicator
                if option.isCustom {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(currentSelection?.id == option.id ? Color.blue.opacity(0.1) : Color(.systemBackground))
                    .stroke(currentSelection?.id == option.id ? Color.blue : Color(.systemGray4), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Custom Input Section
    
    private var customInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                    
                    Text("Custom Input")
                        .font(.headline)
                        .fontWeight(.medium)
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
                .background(canSave ? Color.blue : Color(.systemGray4))
                .foregroundColor(canSave ? Color.white : Color(.systemGray2))
                .cornerRadius(12)
                .disabled(!canSave)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - Helper Methods
    
    private func handleOptionSelection(_ option: ChipOption) {
        selectedOption = option
        
        if option.isCustom {
            showingCustomInput = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isCustomInputFocused = true
            }
        } else {
            showingCustomInput = false
            customText = ""
        }
    }
    
    private func handleSave() {
        guard let selected = selectedOption else { return }
        
        if selected.isCustom {
            let trimmed = customText.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty {
                showValidationError("Please enter a custom value")
                return
            }
            onSelection(selected, trimmed)
        } else {
            onSelection(selected, nil)
        }
        
        dismiss()
    }
    
    private func handleCancel() {
        onCancel()
        dismiss()
    }
    
    private func showValidationError(_ message: String) {
        validationMessage = message
        showingValidationError = true
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

// MARK: - Preview

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

#Preview("Chip Options Overlay") {
    ChipOptionsOverlay(
        chip: EssentialChip(
            id: UUID(),
            type: .fitnessLevel,
            title: "Fitness Level",
            icon: "figure.run",
            isCompleted: false,
            selectedOption: nil
        ),
        onSelection: { option, chip in
            print("Selected: \(option.displayText) for \(chip.title)")
        },
        onDismiss: {
            print("Dismissed")
        }
    )
    .background(Color(.systemGroupedBackground))
}
