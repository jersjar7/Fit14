//
//  FocusModeComponents.swift
//  Fit14
//
//  Created by Jerson on 7/16/25.
//  Focus mode components for GoalInputView
//

import SwiftUI

// MARK: - GoalInputView Focus Mode Components Extension

extension GoalInputView {
    
    // MARK: - Focus Mode Header
    
    var focusModeHeader: some View {
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
    
    // MARK: - Focus Mode Actions
    
    var focusModeActions: some View {
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
}
