//
//  UltraInstinctButton.swift
//  Fit14
//
//  Created by Jerson on 7/8/25.
//

import SwiftUI

struct UltraInstinctButton: View {
    
    // MARK: - Properties
    let action: () -> Void
    let isLoading: Bool
    let isEnabled: Bool
    let loadingText: String
    let defaultText: String
    let icon: String
    
    // MARK: - Animation State
    @State private var animatingDot: Int = 0
    @State private var shimmerOffset: CGFloat = -400
    @State private var cosmicPulse: Bool = false
    @State private var buttonPulse: Bool = false
    @State private var dotTimer: Timer?
    
    // MARK: - Initializer
    init(
        action: @escaping () -> Void,
        isLoading: Bool = false,
        isEnabled: Bool = true,
        loadingText: String = "Processing...",
        defaultText: String = "Continue",
        icon: String = "sparkles"
    ) {
        self.action = action
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.loadingText = loadingText
        self.defaultText = defaultText
        self.icon = icon
    }
    
    // MARK: - Body
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    // Ultra Instinct energy dots animation
                    HStack(spacing: 6) {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [Color.white, Color.purple.opacity(0.8)],
                                        center: .center,
                                        startRadius: 1,
                                        endRadius: 4
                                    )
                                )
                                .frame(width: 8, height: 8)
                                .scaleEffect(animatingDot == index ? 1.4 : 0.8)
                                .opacity(animatingDot == index ? 1.0 : 0.6)
                                .shadow(color: Color.purple.opacity(0.8), radius: 4)
                        }
                    }
                } else {
                    Image(systemName: icon)
                        .foregroundColor(.white)
                        .shadow(color: Color.purple.opacity(0.6), radius: 2)
                }
                
                Text(isLoading ? loadingText : defaultText)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .shadow(color: Color.purple.opacity(0.4), radius: 1)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(backgroundView)
            .overlay(borderView)
            .shadow(
                color: isLoading ?
                    Color.purple.opacity(0.5) : Color.blue.opacity(0.3),
                radius: isLoading ? 12 : 6,
                x: 0,
                y: isLoading ? 6 : 3
            )
            .scaleEffect(
                isLoading ?
                    (buttonPulse ? 1.02 : 0.98) : 1.0
            )
            .animation(
                isLoading ?
                    .easeInOut(duration: 1.0).repeatForever(autoreverses: true) :
                    .easeInOut(duration: 0.2),
                value: isLoading ? buttonPulse : false
            )
        }
        .disabled(!isEnabled)
        .onChange(of: isLoading) { _, newIsLoading in
            if newIsLoading {
                startUltraInstinctAnimations()
            } else {
                stopUltraInstinctAnimations()
            }
        }
        .onAppear {
            if isLoading {
                startUltraInstinctAnimations()
            }
        }
        .onDisappear {
            stopUltraInstinctAnimations()
        }
    }
    
    // MARK: - Background View
    private var backgroundView: some View {
        ZStack {
            // Base gradient background
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: isLoading ?
                            [
                                Color.purple.opacity(0.3),
                                Color.blue.opacity(0.4),
                                Color.indigo.opacity(0.3),
                                Color.purple.opacity(0.2)
                            ] :
                            isEnabled ?
                                [Color.blue, Color.indigo] :
                                [Color.gray, Color.gray.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .animation(
                    isLoading ?
                        .easeInOut(duration: 2.0).repeatForever(autoreverses: true) :
                        .easeInOut(duration: 0.3),
                    value: isLoading
                )
            
            // Glass morphism overlay
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .opacity(isLoading ? 0.4 : 0.2)
            
            // Ultra Instinct energy shimmer
            if isLoading {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(0.3),
                                Color.purple.opacity(0.2),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: shimmerOffset)
                    .animation(
                        .linear(duration: 1.8).repeatForever(autoreverses: false),
                        value: shimmerOffset
                    )
            }
            
            // Cosmic sparkle overlay
            if isLoading {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.purple.opacity(0.05),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 100
                        )
                    )
                    .scaleEffect(cosmicPulse ? 1.1 : 0.9)
                    .opacity(cosmicPulse ? 0.8 : 0.4)
                    .animation(
                        .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                        value: cosmicPulse
                    )
            }
        }
    }
    
    // MARK: - Border View
    private var borderView: some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(
                LinearGradient(
                    colors: isLoading ?
                        [
                            Color.white.opacity(0.6),
                            Color.purple.opacity(0.8),
                            Color.blue.opacity(0.6),
                            Color.white.opacity(0.4)
                        ] :
                        isEnabled ?
                            [Color.blue.opacity(0.6)] :
                            [Color.gray.opacity(0.4)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: isLoading ? 2 : 1
            )
            .animation(
                isLoading ?
                    .easeInOut(duration: 2.0).repeatForever(autoreverses: true) :
                    .easeInOut(duration: 0.3),
                value: isLoading
            )
    }
    
    // MARK: - Animation Functions
    private func startUltraInstinctAnimations() {
        // Start all animations
        buttonPulse = true
        cosmicPulse = true
        shimmerOffset = -400
        
        // Animate shimmer
        withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: false)) {
            shimmerOffset = 400
        }
        
        // Start dot animation
        startDotAnimation()
    }
    
    private func stopUltraInstinctAnimations() {
        buttonPulse = false
        cosmicPulse = false
        shimmerOffset = -400
        dotTimer?.invalidate()
        dotTimer = nil
    }
    
    private func startDotAnimation() {
        dotTimer?.invalidate()
        dotTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
            if !isLoading {
                timer.invalidate()
                return
            }
            
            withAnimation(.easeInOut(duration: 0.3)) {
                animatingDot = (animatingDot + 1) % 3
            }
        }
    }
}

// MARK: - Convenience Initializers
extension UltraInstinctButton {
    
    /// Generate AI Plan Button
    static func generatePlan(
        action: @escaping () -> Void,
        isGenerating: Bool,
        canGenerate: Bool
    ) -> UltraInstinctButton {
        UltraInstinctButton(
            action: action,
            isLoading: isGenerating,
            isEnabled: canGenerate,
            loadingText: "Creating Your Plan...",
            defaultText: "Generate AI Workout Plan",
            icon: "sparkles"
        )
    }
    
    /// Custom Button
    static func custom(
        action: @escaping () -> Void,
        isLoading: Bool = false,
        isEnabled: Bool = true,
        loadingText: String,
        defaultText: String,
        icon: String = "sparkles"
    ) -> UltraInstinctButton {
        UltraInstinctButton(
            action: action,
            isLoading: isLoading,
            isEnabled: isEnabled,
            loadingText: loadingText,
            defaultText: defaultText,
            icon: icon
        )
    }
}

// MARK: - Preview
#Preview("Ultra Instinct Button States") {
    VStack(spacing: 20) {
        // Default state
        UltraInstinctButton.generatePlan(
            action: { print("Generate tapped") },
            isGenerating: false,
            canGenerate: true
        )
        
        // Loading state
        UltraInstinctButton.generatePlan(
            action: { print("Generate tapped") },
            isGenerating: true,
            canGenerate: true
        )
        
        // Disabled state
        UltraInstinctButton.generatePlan(
            action: { print("Generate tapped") },
            isGenerating: false,
            canGenerate: false
        )
        
        // Custom button
        UltraInstinctButton.custom(
            action: { print("Custom tapped") },
            isLoading: false,
            isEnabled: true,
            loadingText: "Processing...",
            defaultText: "Custom Action",
            icon: "bolt.fill"
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
