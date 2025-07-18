//
//  PersonalizationOnboardingPage.swift
//  Fit14
//
//  Created by Jerson on 7/13/25.
//  AI personalization power demonstration page
//

import SwiftUI

struct PersonalizationOnboardingPage: View {
    @State private var animationPhase = 0
    @State private var selectedFactor = 0
    
    private let personalizationFactors = [
        PersonalizationFactor(
            icon: "figure.strengthtraining.traditional",
            title: "Fitness Level",
            description: "From complete beginner to advanced athlete",
            examples: ["Beginner", "Intermediate", "Advanced"],
            color: Color.red
        ),
        PersonalizationFactor(
            icon: "clock",
            title: "Time Available",
            description: "Workouts that fit your schedule",
            examples: ["15 min", "30 min", "45+ min"],
            color: Color.blue
        ),
        PersonalizationFactor(
            icon: "location",
            title: "Workout Location",
            description: "Exercises designed for your space",
            examples: ["Home", "Gym", "Outdoor"],
            color: Color.green
        ),
        PersonalizationFactor(
            icon: "dumbbell",
            title: "Equipment",
            description: "Plans that use what you have",
            examples: ["None", "Basic", "Full Gym"],
            color: Color.purple
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Consistent top spacing
                Spacer()
                    .frame(minHeight: 20)
                
                // Header
                VStack(spacing: 16) {
                    Text("Deep Personalization")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                    
                    Text("Our AI considers everything about you to create the perfect plan")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
                
                // Central AI brain visualization
                VStack(spacing: 24) {
                    ZStack {
                        // Central brain
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.1)]),
                                    center: .center,
                                    startRadius: 20,
                                    endRadius: 80
                                )
                            )
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 40, weight: .light))
                            .foregroundColor(.blue)
                        
                        // Orbiting factor icons
                        ForEach(Array(personalizationFactors.enumerated()), id: \.offset) { index, factor in
                            factorOrbit(factor: factor, index: index)
                        }
                    }
                    .frame(height: 280)
                    
                    // Selected factor details
                    VStack(spacing: 12) {
                        Text(currentFactor.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(currentFactor.color)
                        
                        Text(currentFactor.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        HStack(spacing: 12) {
                            ForEach(currentFactor.examples, id: \.self) { example in
                                Text(example)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(currentFactor.color.opacity(0.2))
                                    .foregroundColor(currentFactor.color)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                }
                .padding(.horizontal, 24)
                
                // Bottom spacing
                Spacer()
                    .frame(minHeight: 60)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private var currentFactor: PersonalizationFactor {
        personalizationFactors[selectedFactor]
    }
    
    private func factorOrbit(factor: PersonalizationFactor, index: Int) -> some View {
        let angle = Double(index) * (360.0 / Double(personalizationFactors.count)) + Double(animationPhase) * 90
        let radius: CGFloat = 100
        let x = cos(angle * .pi / 180) * radius
        let y = sin(angle * .pi / 180) * radius
        
        return Button(action: {
            selectedFactor = index
        }) {
            ZStack {
                Circle()
                    .fill(factor.color.opacity(selectedFactor == index ? 0.3 : 0.2))
                    .frame(width: 50, height: 50)
                    .scaleEffect(selectedFactor == index ? 1.2 : 1.0)
                    .shadow(color: factor.color.opacity(0.3), radius: selectedFactor == index ? 8 : 0)
                
                Image(systemName: factor.icon)
                    .font(.title3)
                    .foregroundColor(factor.color)
            }
        }
        .offset(x: x, y: y)
        .animation(.easeInOut(duration: 0.5), value: selectedFactor)
        .animation(.linear(duration: 8.0).repeatForever(autoreverses: false), value: animationPhase)
    }
    
    private func startAnimations() {
        // Start orbital animation
        withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
            animationPhase = 4
        }
        
        // Auto-cycle through factors
        Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                selectedFactor = (selectedFactor + 1) % personalizationFactors.count
            }
        }
    }
}

struct PersonalizationFactor {
    let icon: String
    let title: String
    let description: String
    let examples: [String]
    let color: Color
}
