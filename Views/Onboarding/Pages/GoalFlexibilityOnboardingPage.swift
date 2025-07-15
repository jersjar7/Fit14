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
            category: "Strength",
            goal: "I want to do my first unassisted pull-up within 14 days",
            icon: "figure.strengthtraining.traditional",
            color: .red
        ),
        OnboardingGoalExample(
            category: "Cardio",
            goal: "Beat my 5K personal record of 25:30 and get under 25 minutes",
            icon: "figure.run",
            color: .blue
        ),
        OnboardingGoalExample(
            category: "Flexibility",
            goal: "Improve my hip mobility and touch my toes comfortably",
            icon: "figure.yoga",
            color: .green
        ),
        OnboardingGoalExample(
            category: "Weight Loss",
            goal: "Lose 5 pounds through consistent daily movement",
            icon: "figure.walk",
            color: .orange
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(minHeight: 50)
            
            // Header
            VStack(spacing: 16) {
                Text("Any Goal Works")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                
                Text("Our AI adapts to create the perfect plan for your specific goal")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal)
            .padding(.bottom, 25)
            
            // Goal selection interface
            VStack(spacing: 20) {
                // Goal categories
                HStack(spacing: 16) {
                    ForEach(Array(sampleGoals.enumerated()), id: \.offset) { index, goal in
                        goalCategoryButton(goal: goal, index: index)
                    }
                }
                .padding(.horizontal)
                
                // Typewriter goal display
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "quote.opening")
                            .foregroundColor(.secondary)
                            .font(.title2)
                        
                        Spacer()
                    }
                    
                    Text(currentGoalText)
                        .font(.title2)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .animation(.none, value: currentGoalText) // Disable animation for typewriter effect
                    
                    HStack {
                        Spacer()
                        
                        Image(systemName: "quote.closing")
                            .foregroundColor(.secondary)
                            .font(.title2)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                .frame(minHeight: 200)
            }
            
            Spacer()
            
            // Key benefits callout
            VStack(alignment: .leading, spacing: 16) {
                Text("Flexible & Adaptive")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                HStack {
                    Image(systemName: "target")
                        .foregroundColor(.blue)
                    Text("Works for any fitness goal, from beginners to athletes")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                HStack {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(.blue)
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
            
            // FIXED: Proper bottom spacing for floating buttons
            Spacer().frame(minHeight: 100)
        }
        .padding(.bottom, 30)
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
        .scaleEffect(selectedGoalIndex == index ? 1.1 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedGoalIndex)
    }
    
    private func startGoalAnimation() {
        // Auto-cycle through goals every 4 seconds
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            selectedGoalIndex = (selectedGoalIndex + 1) % sampleGoals.count
            startTypingAnimation()
        }
        
        // Start with initial typing animation
        startTypingAnimation()
    }
    
    private func startTypingAnimation() {
        isTyping = true
        typewriterProgress = 0
        
        let goal = currentGoal.goal
        let typingSpeed = 0.05 // seconds per character
        
        Timer.scheduledTimer(withTimeInterval: typingSpeed, repeats: true) { timer in
            if typewriterProgress < goal.count {
                typewriterProgress += 1
            } else {
                timer.invalidate()
                
                // Hold complete text for a moment, then stop typing state
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    isTyping = false
                }
            }
        }
    }
}

struct OnboardingGoalExample {
    let category: String
    let goal: String
    let icon: String
    let color: Color
}
