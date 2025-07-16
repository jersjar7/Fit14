//
//  GoalInputView.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//  Enhanced with essential information chip system and start date support
//  UPDATED: Added animated focus mode with progressive disclosure
//

import SwiftUI

struct GoalInputView: View {
    @EnvironmentObject var viewModel: WorkoutPlanViewModel
    
    // MARK: - Essential Chip System State
    @StateObject var analysisService = GoalAnalysisService()
    @StateObject var chipAssistant = EssentialChipAssistant()
    
    // MARK: - UI State
    @State var showingHelpSheet = false
    @State var showingStartDateHelp = false
    @State var showingDatePicker = false
    
    // MARK: - Focus Mode State
    @State var isInFocusMode = false
    @FocusState var isTextFieldFocused: Bool
    
    // MARK: - Chip Selection State
    @State var selectedChipForOptions: EssentialChip?
    @State var showingChipOptions = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                // Main Content
                if isInFocusMode {
                    focusModeView
                } else {
                    cleanInitialView
                }
                
                // Chip Options Overlay
                if showingChipOptions, let chip = selectedChipForOptions {
                    chipOptionsOverlay(for: chip)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingHelpSheet = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "questionmark.circle")
                            Text("Tips")
                                .font(.caption)
                        }
                        .foregroundColor(Color.blue)
                    }
                }
            }
        }
        .onAppear {
            setupInitialState()
        }
        .onChange(of: chipAssistant.goalText) { _, newText in
            handleTextChange(newText)
        }
        .sheet(isPresented: $showingHelpSheet) {
            GoalHelpSheet(
                userGoalData: viewModel.userGoalData,
                onDismiss: {
                    // Help sheet dismissed
                }
            )
        }
        .sheet(isPresented: $showingStartDateHelp) {
            StartDateHelpSheet()
        }
        .sheet(isPresented: $showingDatePicker) {
            startDatePickerSheet
        }
        .alert(errorAlertTitle, isPresented: $viewModel.showError) {
            Button("Try Again") {
                viewModel.clearError()
            }
            
            if shouldShowHelpButton {
                Button("Get Help") {
                    viewModel.clearError()
                    showingHelpSheet = true
                }
            }
        } message: {
            Text(errorAlertMessage)
        }
    }
    
    // MARK: - Main Views
    
    var cleanInitialView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // App Name Header
                appNameHeader
                
                // Main Question Section
                mainQuestionSection
                
                // Completed Chips Summary (when there are completed chips)
                if chipAssistant.completedCount > 0 {
                    completedChipsSummary
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
                
                // Simple Text Field
                simpleTextFieldSection
                
                // Hint Text
                enhancedHintText
                
                // Generate Button
                generateButtonSection
                    .padding(.top, 20)
                
                Spacer(minLength: 50)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
    
    var focusModeView: some View {
        ZStack {
            // Dark overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.3), value: isInFocusMode)
            
            // Centered Modal
            VStack {
                Spacer()
                
                // Focused Modal Container
                VStack(spacing: 24) {
                    // Header in focus mode
                    focusModeHeader
                    
                    // Text Editor Section
                    focusedTextEditorSection
                    
                    // Start Date Section
                    enhancedStartDateSection
                    
                    // Essential Information Section
                    enhancedEssentialInformationSection
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.2), radius: 30, x: 0, y: 20)
                )
                .padding(.horizontal, 20)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.85).combined(with: .opacity),
                    removal: .scale(scale: 0.9).combined(with: .opacity)
                ))
                
                Spacer()
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isInFocusMode)
    }
    
    // MARK: - Focus Mode Actions
    
    func enterFocusMode() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            isInFocusMode = true
        }
        
        // Delay focus to allow animation to start
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isTextFieldFocused = true
        }
    }
    
    func exitFocusMode() {
        isTextFieldFocused = false
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isInFocusMode = false
        }
    }
    
    // MARK: - Chip Options Management
    
    func showChipOptions(for chip: EssentialChip) {
        selectedChipForOptions = chip
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showingChipOptions = true
        }
    }
    
    func dismissChipOptions() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showingChipOptions = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            selectedChipForOptions = nil
        }
    }
    
    func selectChipOption(option: ChipOption, for chip: EssentialChip) {
        // Insert the selected option text into the goal
        let optionText = "\(chip.title): \(option.displayText)"
        let currentText = chipAssistant.goalText
        let newText = currentText.isEmpty ? optionText : "\(currentText), \(optionText)"
        chipAssistant.updateGoalText(newText)
        
        // Mark this chip as completed by inserting its prompt
        chipAssistant.insertPromptForChip(type: chip.type)
        
        // Provide haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Dismiss the overlay
        dismissChipOptions()
    }
}

// MARK: - Preview Provider

#Preview("Default State") {
    GoalInputView()
        .environmentObject(WorkoutPlanViewModel())
}

#Preview("With Active Plan") {
    let viewModel = WorkoutPlanViewModel()
    viewModel.currentPlan = SampleData.sampleActiveWorkoutPlan
    
    return GoalInputView()
        .environmentObject(viewModel)
}

#Preview("Generating State") {
    let viewModel = WorkoutPlanViewModel()
    viewModel.isGenerating = true
    
    return GoalInputView()
        .environmentObject(viewModel)
}
