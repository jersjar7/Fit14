//
//  GoalInputView.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//

import SwiftUI

struct GoalInputView: View {
    @State private var goalsText = ""
    @State private var isGenerating = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("What are your fitness goals?")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("For better results, include your personal details below")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $goalsText)
                        .frame(minHeight: 120)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                    
                    // Placeholder text overlay
                    if goalsText.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("For better results, include:")
                                .foregroundColor(.secondary)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("• Your specific goal (lose weight, build muscle, etc.)")
                                Text("• Age, gender, current weight, height")
                                Text("• Current activity level")
                                Text("• Time available for workouts")
                                Text("• Any exercise preferences or limitations")
                            }
                            .foregroundColor(.secondary)
                            
                            Text("\nExample:")
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                            
                            Text("I want to lose 3 pounds in 2 weeks. I'm 28, female, 140 lbs, 5'4\", and can work out 30 to 60 minutes daily except for Sunday.")
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 30.0)
                        .padding(.vertical, 25.0)
                        .allowsHitTesting(false)
                        .font(.footnote)
                    }
                }
                
                
                
                Button(action: generatePlan) {
                    HStack {
                        if isGenerating {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "sparkles")
                        }
                        Text(isGenerating ? "Generating..." : "Generate My Plan")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(goalsText.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(goalsText.isEmpty || isGenerating)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Fit14")
        }
    }
    
    private func generatePlan() {
        isGenerating = true
        // TODO: Implement AI generation
        print("Generating plan for: \(goalsText)")
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isGenerating = false
            // TODO: Navigate to plan list
        }
    }
}

#Preview {
    GoalInputView()
}
