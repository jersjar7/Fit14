//
//  GoalInputHelpers.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//  Helper methods and computed properties for GoalInputView
//

import SwiftUI

// MARK: - GoalInputView Helpers Extension

extension GoalInputView {
    
    // MARK: - Computed Properties
    
    var canGeneratePlan: Bool {
        return viewModel.canGeneratePlan
    }
    
    var errorAlertTitle: String {
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
    
    var errorAlertMessage: String {
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
    
    var shouldShowHelpButton: Bool {
        guard let errorMessage = viewModel.errorMessage else { return false }
        return errorMessage.contains("truncated") ||
               errorMessage.contains("invalid") ||
               errorMessage.contains("format")
    }
    
    // MARK: - Event Handlers
    
    func setupInitialState() {
        viewModel.startGoalInput()
        analysisService.analyzeText("", with: viewModel.userGoalData)
        chipAssistant.updateGoalText("")
    }
    
    func handleTextChange(_ newText: String) {
        viewModel.updateGoalText(newText)
        analysisService.analyzeText(newText, with: viewModel.userGoalData)
    }
    
    func resetForm() {
        chipAssistant.reset()
        setupInitialState()
    }
    
    // MARK: - Actions
    
    func generatePlan() async {
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
}
