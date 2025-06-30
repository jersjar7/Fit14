//
//  SwiftUIView.swift
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
                    
                    Text("Describe what you want to achieve in the next 2 weeks")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                TextEditor(text: $goalsText)
                    .frame(minHeight: 120)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                
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
