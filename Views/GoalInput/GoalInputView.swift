//
//  GoalInputView.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//  Enhanced with smart chip system and real-time analysis
//

import SwiftUI

struct GoalInputView: View {
    @EnvironmentObject var viewModel: WorkoutPlanViewModel
    
    // MARK: - Smart Chip System State
    @StateObject private var analysisService = GoalAnalysisService()
    
    // MARK: - UI State
    @State private var goalsText = ""
    @State private var showingHelpSheet = false
    @State private var hasUserInteracted = false
    @State private var showQualityIndicator = false
    
    @FocusState private var isTextFieldFocused: Bool
    
    // MARK: - Computed Properties
    
    private var canGeneratePlan: Bool {
        return viewModel.canGeneratePlan
    }
    
    private var qualityAssessment: GoalQualityAssessment {
        return analysisService.getQualityAssessment(for: viewModel.userGoalData)
    }
    
    private var shouldShowChips: Bool {
        return hasUserInteracted || !goalsText.isEmpty
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) { // Increased from 20 to 24
                    // Header Section
                    headerSection
                    
                    // Goal Input Section
                    goalInputSection
                    
                    // Smart Chips Section
                    if shouldShowChips {
                        smartChipsSection
                    }
                    
                    // Quality Guidance Section
                    if showQualityIndicator && qualityAssessment.overallScore < 0.8 {
                        qualityGuidanceSection
                    }
                    
                    // Generation Button
                    generateButtonSection
                        .padding(.top, 20) // Add explicit top padding to button section
                    
                    // Existing Plan Notice
                    if viewModel.hasActivePlan && !viewModel.isGenerating {
                        existingPlanSection
                    }
                    
                    Spacer(minLength: 60) // Increased from 40 to 60
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 20) // Add bottom padding to entire content
            }
            .background(Color(.systemGroupedBackground))
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
        .onChange(of: goalsText) { _, newText in
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
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // App Title
            HStack {
                Text("Fit14")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.primary)
                Spacer()
            }
            
            // Main Question
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(Color.blue)
                        .font(.title2)
                    Text("What do you want to achieve in 2 weeks?")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                
                HStack {
                    Text("Our AI will create a personalized 14-day workout plan just for you")
                        .font(.subheadline)
                        .foregroundColor(Color.secondary)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 4)
    }
    
    // MARK: - Goal Input Section
    
    private var goalInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Input Field
            VStack(alignment: .leading, spacing: 8) {
                TextField(
                    "e.g., Lose 5 pounds and build strength at home...",
                    text: $goalsText,
                    axis: .vertical
                )
                .textFieldStyle(PlainTextFieldStyle())
                .font(.body)
                .foregroundColor(Color.primary)
                .lineLimit(4, reservesSpace: true)
                .focused($isTextFieldFocused)
                .disabled(viewModel.isGenerating)
                .onChange(of: isTextFieldFocused) { _, focused in
                    if focused && !hasUserInteracted {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            hasUserInteracted = true
                        }
                    }
                }
                
                // Character count and analysis status
                HStack {
                    if !goalsText.isEmpty {
                        Text("\(goalsText.count) characters")
                            .font(.caption2)
                            .foregroundColor(Color.secondary)
                    }
                    
                    Spacer()
                    
                    // Real-time analysis indicator
                    if analysisService.isAnalyzing {
                        HStack(spacing: 4) {
                            ProgressView()
                                .scaleEffect(0.6)
                            Text("Analyzing...")
                                .font(.caption2)
                                .foregroundColor(Color.secondary)
                        }
                    } else if !goalsText.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color.green)
                                .font(.caption)
                            Text("Ready")
                                .font(.caption2)
                                .foregroundColor(Color.green)
                        }
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .stroke(
                        isTextFieldFocused ? Color.blue : Color(.systemGray4),
                        lineWidth: isTextFieldFocused ? 2 : 1
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: isTextFieldFocused)
        }
    }
    
    // MARK: - Smart Chips Section (Updated with Progressive Disclosure)
    
    private var smartChipsSection: some View {
        VStack(spacing: 20) { // Increased spacing from 16 to 20
            // Always show what we need, regardless of current state
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    Text("Essential Information")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                }
                
                // Show preview of what we need even before user types
                VStack(alignment: .leading, spacing: 8) {
                    quickInfoRow(
                        icon: "figure.strengthtraining.traditional",
                        title: "Fitness Level",
                        isCompleted: viewModel.userGoalData.isChipSelected(.fitnessLevel)
                    )
                    
                    quickInfoRow(
                        icon: "person.2",
                        title: "Sex",
                        isCompleted: viewModel.userGoalData.isChipSelected(.sex)
                    )
                    
                    quickInfoRow(
                        icon: "ruler.fill",
                        title: "Height & Weight",
                        isCompleted: viewModel.userGoalData.isChipSelected(.physicalStats)
                    )
                    
                    quickInfoRow(
                        icon: "clock",
                        title: "Time Per Workout",
                        isCompleted: viewModel.userGoalData.isChipSelected(.timeAvailable)
                    )
                    
                    quickInfoRow(
                        icon: "location",
                        title: "Workout Location",
                        isCompleted: viewModel.userGoalData.isChipSelected(.workoutLocation)
                    )
                    
                    quickInfoRow(
                        icon: "calendar",
                        title: "Days Per Week",
                        isCompleted: viewModel.userGoalData.isChipSelected(.weeklyFrequency)
                    )
                }
                
                if !hasUserInteracted {
                    Text("Start typing your goal above and selection options will appear")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Show actual chips once user starts interacting
            if hasUserInteracted {
                ChipSelectorView(
                    userGoalData: .constant(viewModel.userGoalData),
                    layout: .adaptive,
                    style: .standard,
                    showSectionHeaders: false, // Hide section headers to avoid duplication
                    onSelectionChanged: { chipData in
                        handleChipSelection(chipData)
                    }
                )
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: hasUserInteracted)
    }
    
    // MARK: - Quick Info Row Helper
    
    private func quickInfoRow(icon: String, title: String, isCompleted: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.blue)
                .frame(width: 16)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.caption)
                .foregroundColor(isCompleted ? .green : .gray)
        }
    }
    
    // MARK: - Quality Guidance Section
    
    private var qualityGuidanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(Color.orange)
                Text("Improve Your Plan Quality")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            // Quality Score
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(qualityAssessment.scoreCategory)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(qualityScoreColor)
                    
                    Text("\(Int(qualityAssessment.overallScore * 100))% Complete")
                        .font(.caption2)
                        .foregroundColor(Color.secondary)
                }
                
                Spacer()
                
                // Progress Ring
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 3)
                        .frame(width: 32, height: 32)
                    
                    Circle()
                        .trim(from: 0, to: qualityAssessment.overallScore)
                        .stroke(qualityScoreColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 32, height: 32)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: qualityAssessment.overallScore)
                }
            }
            
            // Suggestions
            if !qualityAssessment.suggestions.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(qualityAssessment.suggestions.prefix(3), id: \.self) { suggestion in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(Color.blue)
                                .font(.caption)
                            
                            Text(suggestion)
                                .font(.caption)
                                .foregroundColor(Color.secondary)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.05))
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showQualityIndicator)
    }
    
    private var qualityScoreColor: Color {
        switch qualityAssessment.overallScore {
        case 0.8...1.0: return Color.green
        case 0.6..<0.8: return Color.blue
        case 0.4..<0.6: return Color.orange
        default: return Color.red
        }
    }
    
    // MARK: - Generate Button Section
    
    private var generateButtonSection: some View {
        VStack(spacing: 12) {
            // Add a visual separator to ensure proper spacing
            Rectangle()
                .fill(Color.clear)
                .frame(height: 1)
            
            Button(action: {
                Task {
                    await generatePlan()
                }
            }) {
                HStack {
                    if viewModel.isGenerating {
                        ProgressView()
                            .scaleEffect(0.8)
                            .foregroundColor(Color.white)
                    } else {
                        Image(systemName: "sparkles")
                    }
                    Text(viewModel.isGenerating ? "Creating Your Plan..." : "Generate AI Workout Plan")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(canGeneratePlan ? Color.blue : Color.gray)
                .foregroundColor(Color.white)
                .cornerRadius(12)
            }
            .disabled(!canGeneratePlan)
            .animation(.easeInOut(duration: 0.2), value: canGeneratePlan)
            
            // Generation Requirements
            if !canGeneratePlan && hasUserInteracted {
                VStack(spacing: 4) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(Color.secondary)
                        Text("To generate a great plan:")
                            .font(.caption)
                            .foregroundColor(Color.secondary)
                        Spacer()
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        if goalsText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            requirementRow("Describe your fitness goal", completed: false)
                        } else {
                            requirementRow("Describe your fitness goal", completed: true)
                        }
                        
                        requirementRow(
                            "Add your fitness level and available time",
                            completed: viewModel.userGoalData.completenessScore >= 0.3
                        )
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
    
    private func requirementRow(_ text: String, completed: Bool) -> some View {
        HStack(spacing: 6) {
            Image(systemName: completed ? "checkmark.circle.fill" : "circle")
                .foregroundColor(completed ? Color.green : Color.secondary)
                .font(.caption)
            
            Text(text)
                .font(.caption)
                .foregroundColor(completed ? Color.secondary : Color.primary)
                .strikethrough(completed)
            
            Spacer()
        }
    }
    
    // MARK: - Existing Plan Section
    
    private var existingPlanSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(Color.orange)
                Text("You already have an active workout plan")
                    .font(.subheadline)
                    .foregroundColor(Color.secondary)
                Spacer()
            }
            
            HStack(spacing: 16) {
                NavigationLink(destination: PlanListView().environmentObject(viewModel)) {
                    HStack {
                        Image(systemName: "list.bullet")
                        Text("View Current Plan")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .foregroundColor(Color.white)
                    .cornerRadius(8)
                }
                
                Button(action: {
                    viewModel.startOver()
                    resetForm()
                }) {
                    HStack {
                        Image(systemName: "arrow.uturn.left")
                        Text("Start Fresh")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.orange)
                    .foregroundColor(Color.white)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Event Handlers
    
    private func setupInitialState() {
        // Initialize goal input process in ViewModel
        viewModel.startGoalInput()
        
        // Set up analysis service
        analysisService.analyzeText("", with: viewModel.userGoalData)
    }
    
    private func handleTextChange(_ newText: String) {
        // Update ViewModel's goal data
        viewModel.updateGoalText(newText)
        
        // Trigger real-time analysis
        analysisService.analyzeText(newText, with: viewModel.userGoalData)
        
        // Show quality indicator after user has typed something substantial
        if newText.count > 20 && !showQualityIndicator {
            withAnimation(.easeInOut(duration: 0.5).delay(1.0)) {
                showQualityIndicator = true
            }
        }
        
        // Update chip visibility based on analysis
        updateChipVisibility()
    }
    
    private func handleChipSelection(_ chipData: ChipData) {
        // Update ViewModel's goal data
        viewModel.updateChipSelection(chipData)
        
        // Re-trigger analysis with updated data
        Task {
            await analysisService.forceAnalysis(for: goalsText, with: viewModel.userGoalData)
        }
        
        // Haptic feedback for successful selection
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
    
    private func updateChipVisibility() {
        // Get suggested chip types from analysis
        let suggestedTypes = viewModel.userGoalData.suggestedChipTypesByRelevance
        
        // Update contextual chip visibility
        for chipType in ChipType.contextualTypes {
            var chip = viewModel.userGoalData.getChip(chipType) ?? ChipConfiguration.createChipData(for: chipType)
            
            if suggestedTypes.contains(chipType) {
                chip.isVisible = true
            } else if !chip.isSelected {
                chip.isVisible = false
            }
            
            viewModel.updateChipSelection(chip)
        }
    }
    
    private func resetForm() {
        goalsText = ""
        hasUserInteracted = false
        showQualityIndicator = false
        setupInitialState()
    }
    
    // MARK: - Actions
    
    private func generatePlan() async {
        print("🎯 Generate Plan button tapped")
        print("📝 Complete goal text: \(viewModel.userGoalData.completeGoalText)")
        print("📊 Quality score: \(qualityAssessment.overallScore)")
        
        // Use ViewModel's new parameterless method
        await viewModel.generatePlanFromGoals()
        
        // Clear the form after successful generation
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
