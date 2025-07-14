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
        VStack(spacing: 32) {
            Spacer()
            
            // Hero Section
            VStack(spacing: 24) {
                // Animated logo/icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                    
                    VStack {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 40, weight: .light))
                            .foregroundColor(.white)
                        
                        Text("14")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                
                // Main headline
                VStack(spacing: 12) {
                    Text("Your Personal AI")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                    
                    Text("Fitness Trainer")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
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
            
            // Bottom spacer to ensure floating buttons don't cover content
            Spacer()
                .frame(minHeight: 120)
        }
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
