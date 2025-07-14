//
//  GoalFlexibilityOnboardingPage.swift
//  Fit14
//
//  Created by Jerson on 7/13/25.
//  Goal flexibility and examples demonstration page
//

import SwiftUI

struct GoalFlexibilityOnboardingPage: View {
    @State private var selectedGoalIndex = 0
    @State private var isTyping = false
    
    private let sampleGoals = [
        OnboardingGoalExample(
            category: "Weight Loss",
            goal: "Lose 15 pounds for my wedding",
            chips: ["Beginner", "Home", "Cardio Focus", "5x/week"],
            icon: "figure.walk",
            color: Color.pink
        ),
        OnboardingGoalExample(
            category: "Strength",
            goal: "Do my first pull-up",
            chips: ["Beginner", "Home", "No Equipment", "3x/week"],
            icon: "figure.strengthtraining.traditional",
            color: Color.red
        ),
        OnboardingGoalExample(
            category: "Cardio",
            goal: "Beat my 5K PR of 25 minutes",
            chips: ["Intermediate", "Outdoor", "Running", "4x/week"],
            icon: "figure.run",
            color: Color.green
        ),
        OnboardingGoalExample(
            category: "Skill",
            goal: "Learn to do a handstand",
            chips: ["Beginner", "Home", "Bodyweight", "Daily"],
            icon: "figure.gymnastics",
            color: Color.purple
        )
    ]
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Header
            VStack(spacing: 16) {
                Text("Any Fitness Goal")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                
                Text("Our AI understands and adapts to all types of fitness goals")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal)
            
            // Interactive goal demo
            VStack(spacing: 20) {
                // Mock goal input interface
                VStack(alignment: .leading, spacing: 12) {
                    Text("What's your fitness goal?")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    // Animated typing goal
                    HStack {
                        Text(currentGoalText)
                            .font(.title3)
                            .foregroundColor(.primary)
                            .animation(.none, value: currentGoalText)
                        
                        if isTyping {
                            Rectangle()
                                .fill(Color.blue)
                                .frame(width: 2, height: 20)
                                .opacity(0.8)
                                .animation(
                                    Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true),
                                    value: isTyping
                                )
                        }
                        
                        Spacer()
                    }
                    .frame(height: 40)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Essential info chips
                    Text("Essential Information")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        ForEach(currentGoal.chips, id: \.self) { chip in
                            Text(chip)
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(currentGoal.color.opacity(0.2))
                                .foregroundColor(currentGoal.color)
                                .cornerRadius(16)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                
                // Goal category selector - centered
                HStack {
                    Spacer()
                    HStack(spacing: 20) {
                        ForEach(Array(sampleGoals.enumerated()), id: \.offset) { index, goal in
                            goalCategoryButton(goal: goal, index: index)
                        }
                    }
                    Spacer()
                }
            }
            .padding(.horizontal)
            
            // Key message - closer spacing
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(.blue)
                    Text("AI analyzes your goal and creates a custom plan")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                HStack {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(.purple)
                    Text("Adapts to your fitness level, time, and equipment")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            
            // Bottom spacer to ensure floating buttons don't cover content
            Spacer()
                .frame(minHeight: 120) // Ensures space for floating buttons on all screen sizes
        }
        .onAppear {
            startGoalAnimation()
        }
    }
    
    private var currentGoal: OnboardingGoalExample {
        sampleGoals[selectedGoalIndex]
    }
    
    private var currentGoalText: String {
        if isTyping {
            return String(currentGoal.goal.prefix(min(currentGoal.goal.count, typewriterProgress)))
        }
        return currentGoal.goal
    }
    
    @State private var typewriterProgress = 0
    
    private func goalCategoryButton(goal: OnboardingGoalExample, index: Int) -> some View {
        Button(action: {
            selectedGoalIndex = index
            startTypingAnimation()
        }) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(goal.color.opacity(selectedGoalIndex == index ? 0.3 : 0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: goal.icon)
                        .font(.title2)
                        .foregroundColor(goal.color)
                }
                
                Text(goal.category)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(selectedGoalIndex == index ? goal.color : .secondary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func startGoalAnimation() {
        startTypingAnimation()
        
        // Auto-cycle through goals
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            selectedGoalIndex = (selectedGoalIndex + 1) % sampleGoals.count
            startTypingAnimation()
        }
    }
    
    private func startTypingAnimation() {
        isTyping = true
        typewriterProgress = 0
        
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if typewriterProgress < currentGoal.goal.count {
                typewriterProgress += 1
            } else {
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isTyping = false
                }
            }
        }
    }
}

struct OnboardingGoalExample {
    let category: String
    let goal: String
    let chips: [String]
    let icon: String
    let color: Color
}
