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
    @State private var swipeIndicatorAnimation = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Consistent top spacing with other pages
                Spacer()
                    .frame(minHeight: 20)
                
                // Header section - positioned consistently with other pages
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
                        .frame(width: 100, height: 100)
                        .scaleEffect(isAnimating ? 1.0 : 0.8)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isAnimating)
                    
                    // Main title - consistent positioning
                    Text("Welcome to Fit14")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .multilineTextAlignment(.center)
                    
                    // Value proposition
                    Text("Get a personalized 14-day workout plan in under 2 minutes")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
                
                // Key benefits section
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
                .padding(.horizontal, 24)
                
                // Bottom spacing for swipe indicator
                Spacer()
                    .frame(minHeight: 60)
            }
        }
        .overlay(
            // Swipe indicator in bottom right
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Text("Swipe")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Image(systemName: "arrow.right")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .offset(x: swipeIndicatorAnimation ? 4 : 0)
                            .animation(
                                Animation.easeInOut(duration: 1.2)
                                    .repeatForever(autoreverses: true),
                                value: swipeIndicatorAnimation
                            )
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
                    .opacity(isAnimating ? 0.8 : 0)
                    .animation(.easeInOut(duration: 0.8).delay(2.0), value: isAnimating)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 40)
            }
        )
        .onAppear {
            isAnimating = true
            
            // Start swipe indicator animation after initial animations
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                swipeIndicatorAnimation = true
            }
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
