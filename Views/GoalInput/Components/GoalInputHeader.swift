//
//  GoalInputHeader.swift
//  Fit14
//
//  Created by Jerson on 7/316/25.
//  Header components for GoalInputView
//

import SwiftUI

// MARK: - GoalInputView Header Components Extension

extension GoalInputView {
    
    // MARK: - App Name Header
    
    var appNameHeader: some View {
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
    
    var mainQuestionSection: some View {
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
}
