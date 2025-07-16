//
//  StartDateSection.swift
//  Fit14
//
//  Created by Jerson on 7/16/25.
//  Start date components for GoalInputView
//

import SwiftUI

// MARK: - GoalInputView Start Date Section Extension

extension GoalInputView {
    
    // MARK: - Enhanced Start Date Section
    
    var enhancedStartDateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                    .font(.title3)
                
                Text("Plan's Start Date")
                    .font(.headline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Button(action: {
                    showingStartDateHelp = true
                }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                }
            }
            
            Button(action: {
                showingDatePicker = true
            }) {
                HStack {
                    Text(viewModel.startDateDisplayText)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(viewModel.hasExplicitStartDate ? .blue : .primary)
                    
                    Spacer()
                    
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.1))
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Start Date Picker Sheet
    
    var startDatePickerSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                DatePicker(
                    "",
                    selection: Binding(
                        get: { viewModel.selectedStartDate },
                        set: { newDate in
                            viewModel.updateStartDate(newDate)
                        }
                    ),
                    in: Date()...,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding(.horizontal, 60)
                
                if viewModel.hasExplicitStartDate {
                    Button(action: {
                        viewModel.clearStartDate()
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset to Today")
                        }
                        .font(.subheadline)
                        .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
            }
            .navigationTitle("Select Start Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingDatePicker = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingDatePicker = false
                    }
                    .fontWeight(.medium)
                }
            }
        }
        .presentationDetents([.height(400)])
    }
}
