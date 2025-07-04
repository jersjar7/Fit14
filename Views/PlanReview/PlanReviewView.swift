//
//  PlanReviewView.swift
//  Fit14
//
//  Created by Jerson on 7/3/25.
//

import SwiftUI

struct PlanReviewView: View {
    @EnvironmentObject var viewModel: WorkoutPlanViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDayId: UUID?
    @State private var showDayEdit = false
    @State private var showRegenerateConfirmation = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Section
                VStack(spacing: 16) {
                    // AI Generated Badge
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.blue)
                        Text("AI Generated Plan")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                    
                    // Plan Info
                    VStack(spacing: 8) {
                        Text("Your 14-Day Fitness Plan")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if let suggestedPlan = viewModel.suggestedPlan {
                            Text(suggestedPlan.userGoals)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(3)
                        }
                        
                        Text("Review and customize your plan below")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
                
                Divider()
                
                // Days List
                if let suggestedPlan = viewModel.suggestedPlan {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(suggestedPlan.days) { day in
                                DayPreviewRow(day: day) {
                                    selectedDayId = day.id
                                    showDayEdit = true
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.vertical, 16)
                    }
                    .background(Color(.systemGroupedBackground))
                } else {
                    // No suggested plan available
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(.orange)
                        
                        Text("No Plan Available")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("There was an issue loading your suggested plan")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
                }
                
                // Bottom CTAs
                VStack(spacing: 12) {
                    Divider()
                    
                    VStack(spacing: 8) {
                        // Primary CTA - Accept Plan
                        Button(action: acceptPlan) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Accept Plan")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        // Secondary CTAs
                        HStack(spacing: 12) {
                            Button(action: {
                                showRegenerateConfirmation = true
                            }) {
                                HStack {
                                    Image(systemName: "arrow.clockwise")
                                    Text("Regenerate")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            
                            Button(action: startOver) {
                                HStack {
                                    Image(systemName: "arrow.uturn.left")
                                    Text("Start Over")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
            }
            .navigationTitle("Review Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showDayEdit) {
                if let dayId = selectedDayId,
                   let day = viewModel.getSuggestedDay(by: dayId) {
                    DayEditView(day: day, dayId: dayId)
                        .environmentObject(viewModel)
                }
            }
            .alert("Regenerate Plan", isPresented: $showRegenerateConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Regenerate", role: .destructive) {
                    Task {
                        await regeneratePlan()
                    }
                }
            } message: {
                Text("This will create a new plan and remove your current customizations. Are you sure?")
            }
        }
    }
    
    // MARK: - Actions
    
    private func acceptPlan() {
        viewModel.acceptSuggestedPlan()
        dismiss()
    }
    
    private func regeneratePlan() async {
        await viewModel.regeneratePlan()
    }
    
    private func startOver() {
        viewModel.startOver()
        dismiss()
    }
}

#Preview {
    // Create a sample suggested plan for preview
    let viewModel = WorkoutPlanViewModel()
    viewModel.suggestedPlan = SampleData.sampleSuggestedPlan
    
    return PlanReviewView()
        .environmentObject(viewModel)
}
