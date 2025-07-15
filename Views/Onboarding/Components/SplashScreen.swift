//
//  SplashScreen.swift
//  Fit14
//
//  Created by Jerson on 7/13/25.
//  Splash screen with brand introduction and loading
//

import SwiftUI

struct SplashScreen: View {
    @State private var isAnimating = false
    @State private var opacity = 0.0
    @State private var scale = 0.8
    @State private var loadingProgress = 0.0
    
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            // Animated background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.8),
                    Color.purple.opacity(0.8),
                    Color.blue.opacity(0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .hueRotation(.degrees(isAnimating ? 30 : 0))
            .animation(
                Animation.easeInOut(duration: 3.0).repeatForever(autoreverses: true),
                value: isAnimating
            )
            
            VStack(spacing: 40) {
                Spacer()
                
                // Main logo and branding
                VStack(spacing: 24) {
                    // Animated logo
                    ZStack {
                        // Outer pulsing ring
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            .frame(width: 160, height: 160)
                            .scaleEffect(isAnimating ? 1.2 : 1.0)
                            .opacity(isAnimating ? 0.4 : 0.8)
                            .animation(
                                Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                                value: isAnimating
                            )
                        
                        // Inner logo circle
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.white, Color.white.opacity(0.9)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .scaleEffect(scale)
                            .overlay(
                                Text("14")
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .foregroundColor(.blue)
                                    .opacity(opacity)
                            )
                    }
                    
                    VStack(spacing: 8) {
                        Text("Fit14")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .opacity(opacity)
                        
                        Text("AI-Powered Personal Training")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .opacity(opacity)
                    }
                    .animation(.easeInOut(duration: 1.5).delay(0.5), value: opacity)
                }
                
                Spacer()
                
                // Loading section
                VStack(spacing: 16) {
                    // Progress indicator
                    VStack(spacing: 8) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.2)
                            .opacity(opacity)
                        
                        Text("Initializing AI Training System...")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .opacity(opacity)
                    }
                    .animation(.easeInOut(duration: 1.5).delay(1.0), value: opacity)
                    
                    // Loading progress bar
                    VStack(spacing: 4) {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.white.opacity(0.3))
                                    .frame(height: 4)
                                    .cornerRadius(2)
                                
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(width: geometry.size.width * loadingProgress, height: 4)
                                    .cornerRadius(2)
                                    .animation(.easeInOut(duration: 0.3), value: loadingProgress)
                            }
                        }
                        .frame(height: 4)
                        
                        Text("\(Int(loadingProgress * 100))% Complete")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .opacity(opacity)
                    .animation(.easeInOut(duration: 1.5).delay(1.5), value: opacity)
                }
                .padding(.horizontal, 60)
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Start background animation
        isAnimating = true
        
        // Fade in content
        withAnimation(.easeInOut(duration: 1.0)) {
            opacity = 1.0
            scale = 1.0
        }
        
        // FIXED: Simulate loading progress with perfect 100% completion
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            loadingProgress += 0.025  // Changed from 0.03 to 0.025 (40 iterations = exactly 100%)
            
            // IMPROVED: Clamp to exactly 1.0 to prevent overshoot
            if loadingProgress >= 1.0 {
                loadingProgress = 1.0  // Ensure it never exceeds 100%
                timer.invalidate()
                
                // Complete splash screen after a brief moment
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        opacity = 0.0
                        scale = 1.1
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        onComplete()
                    }
                }
            }
        }
    }
}

// Preview
struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen(onComplete: {})
    }
}
