//
//  HowItWorksOnboardingPage.swift
//  Fit14
//
//  Created by Jerson on 7/13/25.
//  Enhanced with better animations and visual flow
//

import SwiftUI

struct HowItWorksOnboardingPage: View {
    @State private var currentStep = 0
    @State private var flowAnimation = 0.0
    @State private var isAnimatingFlow = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Consistent top spacing
                Spacer()
                    .frame(minHeight: 20)
                
                // Header with subtle animation
                VStack(spacing: 16) {
                    Text("How It Works")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .opacity(currentStep >= 0 ? 1.0 : 0.5)
                        .animation(Animation.easeInOut(duration: 0.8), value: currentStep)
                    
                    Text("Get your personalized plan in 3 simple steps")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .opacity(currentStep >= 0 ? 1.0 : 0.5)
                        .animation(Animation.easeInOut(duration: 0.8).delay(0.2), value: currentStep)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
                
                // Compact steps with coordinated timing
                VStack(spacing: 0) {
                    // Step 1 - Activates immediately
                    enhancedStepView(
                        number: 1,
                        icon: "message.badge.filled.fill",
                        title: "Tell Us Your Goal",
                        description: "\"Beat my 5K PR of 25 minutes\"\n\"Do my first pull-up\"",
                        isActive: currentStep >= 0,
                        color: .blue,
                        delay: 0.0  // Step 1 starts immediately
                    )
                    
                    // Flow 1 - Starts after Step 1 is established
                    compactConnectionFlow(
                        isActive: currentStep >= 1,
                        delay: 0.6  // Flow starts after step 1 is established
                    )
                    
                    // Step 2 - Activates when flow 1 reaches it
                    enhancedStepView(
                        number: 2,
                        icon: "brain.head.profile",
                        title: "AI Creates Your Plan",
                        description: "Our AI considers your fitness level, time, location, and equipment",
                        isActive: currentStep >= 1,
                        color: .purple,
                        delay: 1.2  // Activates when flow 1 reaches it
                    )
                    
                    // Flow 2 - Starts after Step 2 is established
                    compactConnectionFlow(
                        isActive: currentStep >= 2,
                        delay: 1.8  // Flow starts after step 2 is established
                    )
                    
                    // Step 3 - Activates when flow 2 reaches it
                    enhancedStepView(
                        number: 3,
                        icon: "calendar.badge.checkmark",
                        title: "Train for 14 Days",
                        description: "Follow your personalized plan and track your progress daily",
                        isActive: currentStep >= 2,
                        color: .green,
                        delay: 2.4  // Activates when flow 2 reaches it
                    )
                }
                .padding(.horizontal, 24)
                
                Spacer()
                    .frame(minHeight: 30)
                
                // Enhanced feature callout
                VStack(spacing: 16) {
                    featureRow(
                        icon: "clock.badge.checkmark",
                        title: "Takes under 2 minutes to set up",
                        color: .green,
                        isVisible: currentStep >= 2
                    )
                    
                    featureRow(
                        icon: "sparkles",
                        title: "Every workout is unique to you",
                        color: .blue,
                        isVisible: currentStep >= 2
                    )
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal, 24)
                .scaleEffect(currentStep >= 2 ? 1.0 : 0.95)
                .opacity(currentStep >= 2 ? 1.0 : 0.0)
                .animation(Animation.spring(response: 0.6, dampingFraction: 0.8).delay(3.8), value: currentStep)
                
                // Bottom spacing
                Spacer()
                    .frame(minHeight: 60)
            }
        }
        .onAppear {
            startEnhancedAnimation()
        }
    }
    
    private func enhancedStepView(
        number: Int,
        icon: String,
        title: String,
        description: String,
        isActive: Bool,
        color: Color,
        delay: Double
    ) -> some View {
        HStack(alignment: .top, spacing: 20) {
            // Enhanced step circle with gradient and shadow
            ZStack {
                // Outer glow ring
                Circle()
                    .stroke(color.opacity(0.3), lineWidth: 3)
                    .frame(width: 80, height: 80)
                    .scaleEffect(isActive ? 1.2 : 1.0)
                    .opacity(isActive ? 0.6 : 0.0)
                    .animation(
                        Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true).delay(delay),
                        value: isActive
                    )
                
                // Main circle with gradient
                Circle()
                    .fill(
                        isActive ?
                        LinearGradient(
                            gradient: Gradient(colors: [color, color.opacity(0.7)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)
                    .scaleEffect(isActive ? 1.0 : 0.8)
                    .shadow(
                        color: isActive ? color.opacity(0.4) : Color.clear,
                        radius: isActive ? 12 : 0,
                        x: 0,
                        y: 4
                    )
                    .animation(Animation.spring(response: 0.6, dampingFraction: 0.7).delay(delay), value: isActive)
                
                // Icon or number
                if isActive {
                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.white)
                        .scaleEffect(isActive ? 1.0 : 0.0)
                        .animation(Animation.spring(response: 0.4, dampingFraction: 0.6).delay(delay + 0.3), value: isActive)
                } else {
                    Text("\(number)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.gray)
                }
            }
            
            // Enhanced content with staggered animation
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(isActive ? .primary : .secondary)
                    .scaleEffect(isActive ? 1.0 : 0.95, anchor: .leading)
                    .animation(Animation.spring(response: 0.5, dampingFraction: 0.8).delay(delay + 0.1), value: isActive)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(isActive ? 1.0 : 0.6)
                    .offset(x: isActive ? 0 : 10)
                    .animation(Animation.spring(response: 0.5, dampingFraction: 0.8).delay(delay + 0.2), value: isActive)
            }
            
            Spacer()
        }
        .padding(.vertical, 6)
        .opacity(isActive ? 1.0 : 0.4)
        .animation(Animation.easeInOut(duration: 0.6).delay(delay), value: isActive)
    }
    
    // UPDATED: Much more compact connection flow
    private func compactConnectionFlow(isActive: Bool, delay: Double) -> some View {
        VStack(spacing: 2) {
            // Shorter connecting line
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            isActive ? Color.blue : Color.gray.opacity(0.3),
                            isActive ? Color.purple : Color.gray.opacity(0.2)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 3, height: 12)
                .offset(x: -15) // Align with step circles
                .scaleEffect(x: 1.0, y: isActive ? 1.0 : 0.0, anchor: UnitPoint.top)
                .animation(Animation.easeInOut(duration: 0.6).delay(delay), value: isActive)
            
            // Single flowing dot instead of 3
            Circle()
                .fill(isActive ? Color.blue.opacity(0.8) : Color.gray.opacity(0.3))
                .frame(width: 6, height: 6)
                .offset(x: -15) // Align with step circles
                .scaleEffect(isActive ? 1.0 : 0.3)
                .opacity(isActive ? 1.0 : 0.3)
                .animation(
                    Animation.easeInOut(duration: 0.4).delay(delay + 0.3),
                    value: isActive
                )
            
            // Shorter bottom connecting line
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            isActive ? Color.purple : Color.gray.opacity(0.2),
                            isActive ? Color.blue : Color.gray.opacity(0.3)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 3, height: 12)
                .offset(x: -15) // Align with step circles
                .scaleEffect(x: 1.0, y: isActive ? 1.0 : 0.0, anchor: UnitPoint.bottom)
                .animation(Animation.easeInOut(duration: 0.6).delay(delay + 0.6), value: isActive)
        }
        .frame(height: 30)
    }
    
    private func featureRow(icon: String, title: String, color: Color, isVisible: Bool) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .opacity(isVisible ? 1.0 : 0.0)
        .offset(y: isVisible ? 0 : 10)
        .animation(Animation.spring(response: 0.5, dampingFraction: 0.8), value: isVisible)
    }
    
    private func startEnhancedAnimation() {
        // Coordinated sequence animation for better flow
        DispatchQueue.main.async {
            currentStep = 0  // Step 1 activates immediately
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            currentStep = 1  // Triggers flow 1 (delay 0.6) and step 2 (delay 1.2)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            currentStep = 2  // Triggers flow 2 (delay 1.8) and step 3 (delay 2.4)
        }
    }
}

#Preview {
    HowItWorksOnboardingPage()
}
