//
//  GenerateButton.swift
//  Fit14
//
//  Created by Jerson on 7/16/25.
//  Generate button component for GoalInputView
//

import SwiftUI

// MARK: - GoalInputView Generate Button Extension

extension GoalInputView {
    
    // MARK: - Generate Button Section
    
    var generateButtonSection: some View {
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
}
