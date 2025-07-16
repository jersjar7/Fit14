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
    @StateObject private var analysisService = GoalAnalysisService()
    @StateObject private var chipAssistant = EssentialChipAssistant()
    
    // MARK: - UI State
    @State private var showingHelpSheet = false
    @State private var showingStartDateHelp = false
    @State private var showingDatePicker = false
    
    // MARK: - Focus Mode State
    @State private var isInFocusMode = false
    @FocusState private var isTextFieldFocused: Bool
    
    // MARK: - Chip Selection State
    @State private var selectedChipForOptions: EssentialChip?
    @State private var showingChipOptions = false
    
    // MARK: - Computed Properties
    
    private var canGeneratePlan: Bool {
        return viewModel.canGeneratePlan
    }
    
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
    
    // MARK: - Clean Initial View
    
    private var cleanInitialView: some View {
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
    
    // MARK: - Focus Mode View
    
    private var focusModeView: some View {
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
    
    // MARK: - App Name Header
    
    private var appNameHeader: some View {
        HStack {
            Text("Fit14")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            Spacer()
        }
    }
    
    // MARK: - Main Question Section
    
    private var mainQuestionSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .font(.title)
                
                Text("What do you want to achieve in 2 weeks?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            HStack {
                Text("Our AI will create a personalized 14-day workout plan just for you")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
        }
    }
    
    // MARK: - Simple Text Field Section
    
    private var simpleTextFieldSection: some View {
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
    
    // MARK: - Chip Options Overlay
    
    private func chipOptionsOverlay(for chip: EssentialChip) -> some View {
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
    
    private func chipOptionButton(option: ChipOption, chip: EssentialChip) -> some View {
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
    
    // MARK: - Completed Chips Summary
    
    private var completedChipsSummary: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.caption)
                
                Text("Added Information")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(chipAssistant.completedCount) of \(chipAssistant.totalCount)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            // Completed chips in a horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(chipAssistant.sortedChips.filter { $0.isCompleted }, id: \.id) { chip in
                        completedChipPill(for: chip)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.green.opacity(0.05))
                .stroke(Color.green.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func completedChipPill(for chip: EssentialChip) -> some View {
        Button(action: {
            showChipOptions(for: chip)
        }) {
            HStack(spacing: 6) {
                Image(systemName: chip.icon)
                    .foregroundColor(.green)
                    .font(.caption2)
                
                Text(chip.title)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                if let selectedOption = chip.selectedOption,
                   !selectedOption.displayText.isEmpty {
                    Text("•")
                        .foregroundColor(.secondary)
                        .font(.caption2)
                    
                    Text(selectedOption.displayText)
                        .font(.caption2)
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                }
                
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
                    .font(.caption2)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color(.systemBackground))
                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Enhanced Hint Text
    
    private var enhancedHintText: some View {
        Text("💡 Feel free to mention any injuries, equipment preferences, or schedule constraints")
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 8)
    }
    
    // MARK: - Focus Mode Components
    
    private var focusModeHeader: some View {
        HStack {
            Text("Tell us about your goals")
                .font(.title3)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button("Done") {
                exitFocusMode()
            }
            .font(.body)
            .fontWeight(.medium)
            .foregroundColor(.blue)
        }
    }
    
    private var focusedTextEditorSection: some View {
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
    
    private var enhancedStartDateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                    .font(.title3)
                
                Text("Plan's Start Date")
                    .font(.headline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Button(action: {
                    showingStartDateHelp = true
                }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                }
            }
            
            Button(action: {
                showingDatePicker = true
            }) {
                HStack {
                    Text(viewModel.startDateDisplayText)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(viewModel.hasExplicitStartDate ? .blue : .primary)
                    
                    Spacer()
                    
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.1))
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private var enhancedEssentialInformationSection: some View {
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
    
    private var focusModeActions: some View {
        HStack(spacing: 16) {
            Button("Cancel") {
                exitFocusMode()
            }
            .font(.body)
            .foregroundColor(.secondary)
            
            Spacer()
            
            Button("Done") {
                exitFocusMode()
            }
            .font(.body)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(8)
        }
    }
    
    // MARK: - Enhanced Chip Button
    
    private func enhancedChipButton(for chip: EssentialChip) -> some View {
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
    
    // MARK: - Analysis Status View
    
    private var analysisStatusView: some View {
        Group {
            if analysisService.isAnalyzing {
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
    
    // MARK: - Generate Button Section
    
    private var generateButtonSection: some View {
        VStack(spacing: 20) {
            UltraInstinctButton.generatePlan(
                action: {
                    Task {
                        await generatePlan()
                    }
                },
                isGenerating: viewModel.isGenerating,
                canGenerate: canGeneratePlan
            )
        }
    }
    
    // MARK: - Chip Options Management
    
    private func showChipOptions(for chip: EssentialChip) {
        selectedChipForOptions = chip
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showingChipOptions = true
        }
    }
    
    private func dismissChipOptions() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showingChipOptions = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            selectedChipForOptions = nil
        }
    }
    
    private func selectChipOption(option: ChipOption, for chip: EssentialChip) {
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
    
    // MARK: - Focus Mode Actions
    
    private func enterFocusMode() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            isInFocusMode = true
        }
        
        // Delay focus to allow animation to start
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isTextFieldFocused = true
        }
    }
    
    private func exitFocusMode() {
        isTextFieldFocused = false
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isInFocusMode = false
        }
    }
    
    // MARK: - Start Date Picker Sheet
    
    private var startDatePickerSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                DatePicker(
                    "",
                    selection: Binding(
                        get: { viewModel.selectedStartDate },
                        set: { newDate in
                            viewModel.updateStartDate(newDate)
                        }
                    ),
                    in: Date()...,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding(.horizontal, 60)
                
                if viewModel.hasExplicitStartDate {
                    Button(action: {
                        viewModel.clearStartDate()
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset to Today")
                        }
                        .font(.subheadline)
                        .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
            }
            .navigationTitle("Select Start Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingDatePicker = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingDatePicker = false
                    }
                    .fontWeight(.medium)
                }
            }
        }
        .presentationDetents([.height(400)])
    }
    
    // MARK: - Event Handlers
    
    private func setupInitialState() {
        viewModel.startGoalInput()
        analysisService.analyzeText("", with: viewModel.userGoalData)
        chipAssistant.updateGoalText("")
    }
    
    private func handleTextChange(_ newText: String) {
        viewModel.updateGoalText(newText)
        analysisService.analyzeText(newText, with: viewModel.userGoalData)
    }
    
    private func resetForm() {
        chipAssistant.reset()
        setupInitialState()
    }
    
    // MARK: - Actions
    
    private func generatePlan() async {
        print("🎯 Generate Plan button tapped")
        print("📝 Complete goal text: \(chipAssistant.goalText)")
        print("✅ Essential chips completed: \(chipAssistant.completedCount)/\(chipAssistant.totalCount)")
        print("📅 Start date: \(viewModel.startDateDisplayText) (explicit: \(viewModel.hasExplicitStartDate))")
        
        viewModel.updateGoalText(chipAssistant.goalText)
        await viewModel.generatePlanFromGoals()
        
        if viewModel.suggestedPlan != nil {
            resetForm()
        }
    }
    
    // MARK: - Error Handling
    
    private var errorAlertTitle: String {
        guard let errorMessage = viewModel.errorMessage else { return "Error" }
        
        if errorMessage.contains("network") || errorMessage.contains("connection") {
            return "Connection Problem"
        } else if errorMessage.contains("quota") || errorMessage.contains("limit") {
            return "Daily Limit Reached"
        } else if errorMessage.contains("API") || errorMessage.contains("service") {
            return "Service Temporarily Unavailable"
        } else {
            return "Plan Generation Failed"
        }
    }
    
    private var errorAlertMessage: String {
        guard let errorMessage = viewModel.errorMessage else {
            return "An unexpected error occurred. Please try again."
        }
        
        if errorMessage.contains("network") || errorMessage.contains("connection") {
            return "\(errorMessage)\n\nTip: Make sure you have a stable internet connection and try again."
        } else if errorMessage.contains("quota") || errorMessage.contains("limit") {
            return "\(errorMessage)\n\nDon't worry - your limit will reset tomorrow, or you can try simplifying your goals description."
        } else if errorMessage.contains("truncated") || errorMessage.contains("cut off") {
            return "\(errorMessage)\n\nTip: Try using simpler language or fewer details in your goals description."
        } else {
            return "\(errorMessage)\n\nTip: Try rewording your goals or check your internet connection."
        }
    }
    
    private var shouldShowHelpButton: Bool {
        guard let errorMessage = viewModel.errorMessage else { return false }
        return errorMessage.contains("truncated") ||
               errorMessage.contains("invalid") ||
               errorMessage.contains("format")
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
