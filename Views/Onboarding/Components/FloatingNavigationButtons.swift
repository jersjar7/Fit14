//
//  FloatingNavigationButtons.swift
//  Fit14
//
//  Created by Jerson on 7/14/25.
//  Reusable floating navigation component for onboarding
//

import SwiftUI

struct FloatingNavigationButtons: View {
    let currentPage: Int
    let totalPages: Int
    let onNext: () -> Void
    let onBack: (() -> Void)?
    let onSkip: (() -> Void)?
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                // Back button (show from page 2 onwards)
                if currentPage > 0, let backAction = onBack {
                    Button(action: backAction) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 14, weight: .medium))
                            Text("Back")
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(.systemBackground))
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                } else {
                    // Invisible spacer to maintain layout
                    Color.clear.frame(width: 80, height: 40)
                }
                
                Spacer()
                
                // Skip button (don't show on last page)
                if currentPage < totalPages - 1, let skipAction = onSkip {
                    Button(action: skipAction) {
                        Text("Skip")
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(.systemBackground))
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                    
                    Spacer().frame(width: 16)
                }
                
                // Next/Get Started button
                Button(action: onNext) {
                    HStack(spacing: 8) {
                        Text(currentPage == totalPages - 1 ? "Get Started" : "Next")
                            .fontWeight(.medium)
                        
                        if currentPage == totalPages - 1 {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .medium))
                        } else {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .medium))
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        currentPage == totalPages - 1 ?
                        LinearGradient(
                            gradient: Gradient(colors: [Color.green, Color.blue]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
                    .shadow(
                        color: (currentPage == totalPages - 1 ? Color.green : Color.blue).opacity(0.3),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }
}

// MARK: - View Extension for Floating Navigation

extension View {
    func floatingNavigation(
        currentPage: Int,
        totalPages: Int,
        onNext: @escaping () -> Void,
        onBack: (() -> Void)? = nil,
        onSkip: (() -> Void)? = nil
    ) -> some View {
        self.overlay(
            FloatingNavigationButtons(
                currentPage: currentPage,
                totalPages: totalPages,
                onNext: onNext,
                onBack: onBack,
                onSkip: onSkip
            )
        )
    }
}
