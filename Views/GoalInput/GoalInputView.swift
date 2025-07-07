//
//  GoalInputView.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//  Enhanced with essential information chip system
//

import SwiftUI

struct GoalInputView: View {
    @EnvironmentObject var viewModel: WorkoutPlanViewModel
    
    // MARK: - Essential Chip System State
    @StateObject private var analysisService = GoalAnalysisService()
    @StateObject private var chipAssistant = EssentialChipAssistant()
    
    // MARK: - UI State
    @State private var showingHelpSheet = false
    
    // MARK: - Computed Properties
    
    private var canGeneratePlan: Bool {
        return viewModel.canGeneratePlan
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    headerSection
                    
                    // Smart Goal Input Section
                    smartGoalInputSection
                    
                    // Essential Information Section (Always Show)
                    essentialInformationSection
                    
                    // Generation Button
                    generateButtonSection
                        .padding(.top, 20)
                    
                    // Existing Plan Notice
                    if viewModel.hasActivePlan && !viewModel.isGenerating {
                        existingPlanSection
                    }
                    
                    Spacer(minLength: 60)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 20)
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
    
    // MARK: - Smart Goal Input Section
    
    private var smartGoalInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SmartGoalTextEditor(
                chipAssistant: chipAssistant,
                placeholder: "e.g., Lose 5 pounds and build strength at home...",
                minHeight: 120
            )
            .disabled(viewModel.isGenerating)
            
            // Subtle hint text
            VStack(alignment: .leading, spacing: 4) {
                // Character count and analysis status
                HStack {
                    if !chipAssistant.goalText.isEmpty {
                        Text("\(chipAssistant.goalText.count) characters")
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
                    } else if !chipAssistant.goalText.isEmpty {
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
                
                // Subtle hint text about additional information
                if chipAssistant.goalText.isEmpty {
                    Text("Feel free to mention any injuries, equipment preferences, or schedule constraints")
                        .font(.caption)
                        .foregroundColor(Color.secondary)
                        .padding(.top, 4)
                }
            }
        }
    }
    
    // MARK: - Essential Information Section
    
    private var essentialInformationSection: some View {
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
            
            // Interactive Essential Chips
            VStack(alignment: .leading, spacing: 8) {
                ForEach(chipAssistant.sortedChips, id: \.id) { chip in
                    interactiveChipRow(for: chip)
                }
            }
            
            // Completion Progress
            HStack {
                Text("Progress: \(chipAssistant.completedCount) of \(chipAssistant.totalCount) completed")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Progress bar
                ProgressView(value: chipAssistant.completionPercentage)
                    .frame(width: 60)
                    .tint(.green)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Interactive Chip Row Helper
    
    private func interactiveChipRow(for chip: EssentialChip) -> some View {
        Button(action: {
            if chip.isCompleted {
                // Reset the chip if already completed
                chipAssistant.resetChip(type: chip.type)
            } else {
                // Insert prompt for this chip
                chipAssistant.insertPromptForChip(type: chip.type)
                
                // Provide haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: chip.icon)
                    .font(.caption)
                    .foregroundColor(.blue)
                    .frame(width: 16)
                
                Text(chip.title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Show + or checkmark based on completion
                if chip.isCompleted {
                    HStack(spacing: 4) {
                        if let selectedOption = chip.selectedOption {
                            Text(selectedOption.displayText)
                                .font(.caption2)
                                .foregroundColor(.green)
                                .lineLimit(1)
                        }
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                } else {
                    Image(systemName: "plus.circle.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            .contentShape(Rectangle()) // Make entire row tappable
        }
        .buttonStyle(PlainButtonStyle())
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
        
        // Initialize chip assistant with empty text
        chipAssistant.updateGoalText("")
    }
    
    private func handleTextChange(_ newText: String) {
        // Update ViewModel's goal data
        viewModel.updateGoalText(newText)
        
        // Trigger real-time analysis
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
        
        // Ensure the ViewModel has the latest goal text from chip assistant
        viewModel.updateGoalText(chipAssistant.goalText)
        
        // Use ViewModel's generation method
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
