//
//  GoalInputComponents.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//  UI Components for GoalInputView (ONLY components without individual files)
//

import SwiftUI

// MARK: - GoalInputView UI Components Extension

extension GoalInputView {
    
    // MARK: - Simple Text Field Section
    
    var simpleTextFieldSection: some View {
        VStack(spacing: 8) {
            // This is now a button that triggers focus mode
            Button(action: {
                enterFocusMode()
            }) {
                HStack {
                    Text(chipAssistant.goalText.isEmpty ? "Tap to describe your fitness goals..." : chipAssistant.goalText)
                        .font(.body)
                        .foregroundColor(chipAssistant.goalText.isEmpty ? .secondary : .primary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                    
                    Spacer()
                    
                    if !chipAssistant.goalText.isEmpty {
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
            .disabled(viewModel.isGenerating)
            
            // Character count (only when there's text)
            if !chipAssistant.goalText.isEmpty {
                HStack {
                    Text("\(chipAssistant.goalText.count) characters")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Analysis status
                    analysisStatusView
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
    
    // MARK: - Focused Text Editor Section
    
    var focusedTextEditorSection: some View {
        VStack(spacing: 12) {
            TextField("Describe your fitness goals in detail...", text: $chipAssistant.goalText, axis: .vertical)
                .focused($isTextFieldFocused)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                .font(.body)
                .lineLimit(4...8)
                .disabled(viewModel.isGenerating)
            
            // Analysis status in focus mode
            if !chipAssistant.goalText.isEmpty {
                HStack {
                    Text("\(chipAssistant.goalText.count) characters")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    analysisStatusView
                }
            }
        }
    }
    
    // MARK: - Enhanced Essential Information Section
    
    var enhancedEssentialInformationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.orange)
                    .font(.title3)
                
                Text("Essential Information")
                    .font(.headline)
                    .fontWeight(.medium)
                
                Spacer()
            }
            
            // Enhanced chip grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(chipAssistant.sortedChips, id: \.id) { chip in
                    enhancedChipButton(for: chip)
                }
            }
            
            // Progress indicator
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progress: \(chipAssistant.completedCount) of \(chipAssistant.totalCount) completed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                ProgressView(value: chipAssistant.completionPercentage)
                    .tint(.blue)
                    .scaleEffect(y: 0.8)
            }
        }
    }
    
    // MARK: - Enhanced Chip Button
    
    func enhancedChipButton(for chip: EssentialChip) -> some View {
        Button(action: {
            if chip.isCompleted {
                chipAssistant.resetChip(type: chip.type)
            } else {
                showChipOptions(for: chip)
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
    
    // MARK: - Chip Options Overlay
    
    func chipOptionsOverlay(for chip: EssentialChip) -> some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissChipOptions()
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
                                dismissChipOptions()
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
                            chipOptionButton(option: option, chip: chip)
                        }
                    }
                    
                    // Show more options if there are many
                    if chipData.options.count > 6 {
                        Button("See all \(chipData.options.count) options") {
                            // You can implement a full sheet here if needed
                            dismissChipOptions()
                            chipAssistant.insertPromptForChip(type: chip.type)
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
    
    func chipOptionButton(option: ChipOption, chip: EssentialChip) -> some View {
        Button(action: {
            selectChipOption(option: option, for: chip)
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
