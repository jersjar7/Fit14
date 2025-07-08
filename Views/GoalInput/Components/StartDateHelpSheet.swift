//
//  StartDateHelpSheet.swift
//  Fit14
//
//  Created by Jerson on 7/7/25.
//  Standalone help component for start date planning and selection
//

import SwiftUI

struct StartDateHelpSheet: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header Section
                    headerSection
                    
                    // Date Picker Benefits Section
                    datePickerBenefitsSection
                    
                    // Natural Language Examples Section
                    naturalLanguageSection
                    
                    // Important Warning Section
                    warningSection
                    
                    // Tips Section
                    tipsSection
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Start Date Planning")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.medium)
                }
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(.blue)
                    .font(.title2)
                    .fontWeight(.medium)
                
                Text("Start Date Planning")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Text("Choose when your 14-day fitness challenge begins. You can either use the date picker for precision or mention it naturally in your goal description.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(nil)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Date Picker Benefits Section
    
    private var datePickerBenefitsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                icon: "calendar.circle.fill",
                title: "Using the Date Picker",
                color: .green
            )
            
            VStack(alignment: .leading, spacing: 12) {
                BenefitRow(
                    icon: "target",
                    title: "Precise Control",
                    description: "Select exactly when you want to start your challenge"
                )
                
                BenefitRow(
                    icon: "brain.head.profile",
                    title: "AI Priority",
                    description: "The AI will use your selected date instead of guessing from text"
                )
                
                BenefitRow(
                    icon: "calendar.badge.checkmark",
                    title: "Smart Scheduling",
                    description: "Rest days and workout timing aligned with your preferred start date"
                )
            }
        }
    }
    
    // MARK: - Natural Language Section
    
    private var naturalLanguageSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                icon: "text.bubble.fill",
                title: "Mentioning Dates in Your Goal",
                color: .blue
            )
            
            VStack(alignment: .leading, spacing: 6) {
                Text("💡 Want to start on a specific day? Include it in your description:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 7.0)
                
                VStack(alignment: .leading, spacing: 4) {
                    startDateExample("\"...starting next Monday\"")
                    startDateExample("\"...begin tomorrow\"")
                    startDateExample("\"...start on January 15th\"")
                    startDateExample("\"...beginning this weekend\"")
                    startDateExample("\"...kick off next week\"")
                }
                .padding(.leading, 14)
                
                Text("The AI understands natural timing references and will calculate the appropriate start date for your plan.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 7.0)
                    .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Warning Section
    
    private var warningSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.title3)
                
                Text("Important")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Text("⚠️ If not mentioned, your plan will start today")
                .font(.caption)
                .foregroundColor(.orange)
                .fontWeight(.medium)
                .padding(.leading, 7.0)
            
            Text("If you don't select a date or mention timing in your goal, the AI will create a plan that starts immediately. This is perfect if you're ready to begin right away!")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.leading, 7.0)
        }
        .padding(16)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Tips Section
    
    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                icon: "lightbulb.fill",
                title: "Pro Tips",
                color: .yellow
            )
            
            VStack(alignment: .leading, spacing: 12) {
                TipRow(
                    icon: "calendar.day.timeline.left",
                    tip: "Consider your weekly schedule when choosing a start date"
                )
                
                TipRow(
                    icon: "moon.zzz.fill",
                    tip: "Starting on Monday? The AI can plan lighter workouts for weekends"
                )
                
                TipRow(
                    icon: "figure.run",
                    tip: "Mention preferred rest days: \"I can't work out on Sundays\""
                )
                
                TipRow(
                    icon: "clock.badge.checkmark",
                    tip: "Both date picker and text preferences work together for optimal scheduling"
                )
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func startDateExample(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "quote.bubble.fill")
                .foregroundColor(.blue.opacity(0.6))
                .font(.caption2)
            
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(6)
            
            Spacer()
        }
    }
}

// MARK: - Supporting Views

struct SectionHeader: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
                .fontWeight(.medium)
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

struct BenefitRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .font(.body)
                .fontWeight(.medium)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
            }
            
            Spacer()
        }
        .padding(.horizontal, 8)
    }
}

struct TipRow: View {
    let icon: String
    let tip: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.yellow)
                .font(.body)
                .fontWeight(.medium)
                .frame(width: 20)
            
            Text(tip)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(nil)
            
            Spacer()
        }
        .padding(.horizontal, 8)
    }
}

// MARK: - Preview

#Preview {
    StartDateHelpSheet()
}
