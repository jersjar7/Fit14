//
//  WelcomeOnboardingPage.swift
//  Fit14
//
//  Created by Jerson on 7/13/25.
//  Welcome and value proposition onboarding page
//

import SwiftUI

struct WelcomeOnboardingPage: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(minHeight: 50)
            
            // Hero section
            VStack(spacing: 24) {
                // App icon placeholder
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isAnimating)
                
                // Main title with gradient
                VStack(spacing: 12) {
                    Text("Welcome to Fit14")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .multilineTextAlignment(.center)
                }
                
                // Value proposition
                Text("Get a personalized 14-day workout plan in under 2 minutes")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            HStack(alignment: .center){
                Spacer()
                // Key benefits
                VStack(spacing: 20) {
                    benefitRow(
                        icon: "sparkles",
                        title: "AI-Powered Personalization",
                        description: "Every plan is uniquely yours"
                    )
                    
                    benefitRow(
                        icon: "clock.badge.checkmark",
                        title: "Just 14 Days",
                        description: "Perfect time to build lasting habits"
                    )
                    
                    benefitRow(
                        icon: "target",
                        title: "Any Fitness Goal",
                        description: "From PRs to first pull-ups"
                    )
                }
                .padding(.horizontal)
            }
            
            // FIXED: Proper bottom spacing for floating buttons
            Spacer().frame(minHeight: 100)
        }
        .padding(.bottom, 30) // Safety padding for different screen sizes
        .onAppear {
            isAnimating = true
        }
    }
    
    private func benefitRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}
