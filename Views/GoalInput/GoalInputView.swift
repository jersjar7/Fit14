//
//  GoalInputView.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//

import SwiftUI

struct GoalInputView: View {
    @EnvironmentObject var viewModel: WorkoutPlanViewModel
    @State private var goalsText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.blue)
                            .font(.title2)
                        Text("What are your fitness goals?")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    
                    Text("Tell our AI about your goals for a personalized 14-day workout plan")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $goalsText)
                        .frame(minHeight: 140)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                        .disabled(viewModel.isGenerating)
                    
                    // Placeholder text overlay
                    if goalsText.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("For the best AI-generated plan, include:")
                                .foregroundColor(.secondary)
                                .fontWeight(.medium)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("• Your specific goal (lose weight, build muscle, get stronger, etc.)")
                                Text("• Age, gender, current weight, height")
                                Text("• Current fitness level and activity")
                                Text("• Time available for workouts")
                                Text("• Equipment access (home, gym, bodyweight only)")
                                Text("• Any injuries, limitations, or preferences")
                            }
                            .foregroundColor(.secondary)
                            
                            Text("\nExample:")
                                .foregroundColor(.secondary)
                                .fontWeight(.medium)
                                .padding(.top, 8)
                            
                            Text("I want to lose 5 pounds and build endurance in 2 weeks. I'm 28, female, 140 lbs, 5'4\". I'm a beginner and can work out 30-45 minutes daily except Sunday. I have access to a gym with weights and cardio machines.")
                                .foregroundColor(.secondary)
                                .italic()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                        .allowsHitTesting(false)
                        .font(.footnote)
                    }
                }
                
                Button(action: {
                    Task {
                        await generatePlan()
                    }
                }) {
                    HStack {
                        if viewModel.isGenerating {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "sparkles")
                        }
                        Text(viewModel.isGenerating ? "Creating Your Plan..." : "Generate AI Workout Plan")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(goalsText.isEmpty || viewModel.isGenerating ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(goalsText.isEmpty || viewModel.isGenerating)
                
                // Show existing plan options if available
                if viewModel.hasActivePlan && !viewModel.isGenerating {
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.orange)
                            Text("You already have an active workout plan")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 16) {
                            NavigationLink(destination: PlanListView().environmentObject(viewModel)) {
                                HStack {
                                    Image(systemName: "list.bullet")
                                    Text("View Current Plan")
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            
                            Button(action: {
                                viewModel.startOver()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.uturn.left")
                                    Text("Start Fresh")
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Fit14")
            .alert(errorAlertTitle, isPresented: $viewModel.showError) {
                Button("Try Again") {
                    viewModel.clearError()
                }
                
                if shouldShowHelpButton {
                    Button("Need Help?") {
                        viewModel.clearError()
                        // Could open a help view or provide tips
                    }
                }
            } message: {
                Text(errorAlertMessage)
            }
        }
    }
    
    // MARK: - Error Handling
    
    private var errorAlertTitle: String {
        guard let errorMessage = viewModel.errorMessage else { return "Error" }
        
        // Determine alert title based on error content
        if errorMessage.contains("network") || errorMessage.contains("connection") {
            return "Connection Problem"
        } else if errorMessage.contains("quota") || errorMessage.contains("limit") {
            return "Daily Limit Reached"
        } else if errorMessage.contains("API") || errorMessage.contains("service") {
            return "Service Temporarily Unavailable"
        } else {
            return "Plan Generation Failed"
        }
    }
    
    private var errorAlertMessage: String {
        guard let errorMessage = viewModel.errorMessage else {
            return "An unexpected error occurred. Please try again."
        }
        
        // Add helpful context to error messages
        if errorMessage.contains("network") || errorMessage.contains("connection") {
            return "\(errorMessage)\n\nTip: Make sure you have a stable internet connection and try again."
        } else if errorMessage.contains("quota") || errorMessage.contains("limit") {
            return "\(errorMessage)\n\nDon't worry - your limit will reset tomorrow, or you can try simplifying your goals description."
        } else if errorMessage.contains("truncated") || errorMessage.contains("cut off") {
            return "\(errorMessage)\n\nTip: Try using simpler language or fewer details in your goals description."
        } else {
            return "\(errorMessage)\n\nTip: Try rewording your goals or check your internet connection."
        }
    }
    
    private var shouldShowHelpButton: Bool {
        guard let errorMessage = viewModel.errorMessage else { return false }
        // Show help button for certain types of errors
        return errorMessage.contains("truncated") ||
               errorMessage.contains("invalid") ||
               errorMessage.contains("format")
    }
    
    // MARK: - Actions
    
    private func generatePlan() async {
        print("🎯 Generate Plan button tapped")
        print("📝 User input: \(goalsText)")
        
        await viewModel.generatePlanFromGoals(goalsText)
        
        // Clear the goals text after successful generation
        if viewModel.suggestedPlan != nil {
            goalsText = ""
        }
    }
}

#Preview {
    GoalInputView()
        .environmentObject(WorkoutPlanViewModel())
}
