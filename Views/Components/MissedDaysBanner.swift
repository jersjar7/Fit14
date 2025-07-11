//
//  MissedDaysBanner.swift
//  Fit14
//
//  Created by Jerson on 7/11/25.
//  Banner component to show missed days information and encourage catch-up
//

import SwiftUI

struct MissedDaysBanner: View {
    @EnvironmentObject var viewModel: WorkoutPlanViewModel
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Main Banner Content
            mainBannerContent
            
            // Expandable Details (if user wants more info)
            if isExpanded {
                expandedContent
                    .transition(.slide)
            }
        }
        .background(bannerBackgroundColor)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
    }
    
    // MARK: - Main Banner Content
    
    private var mainBannerContent: some View {
        HStack(spacing: 12) {
            // Warning Icon
            ZStack {
                Circle()
                    .fill(iconBackgroundColor)
                    .frame(width: 36, height: 36)
                
                Image(systemName: bannerIcon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            
            // Message Content
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.missedDaysMessage)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(viewModel.motivationalMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Expand/Collapse Icon
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle()) // Make entire area tappable
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                isExpanded.toggle()
            }
        }
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        HStack(spacing: 8) {
            // Quick Action Button
            if viewModel.suggestedCatchUpDays > 0 {
                Button(action: {
                    // TODO: Implement quick catch-up action
                    print("Quick catch-up: \(viewModel.suggestedCatchUpDays) days")
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .font(.caption2)
                        Text("Catch Up")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Expand/Collapse Icon
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Expanded Content
    
    private var expandedContent: some View {
        VStack(spacing: 12) {
            Divider()
                .padding(.horizontal, 16)
            
            VStack(spacing: 8) {
                // Challenge Health Status
                HStack {
                    Text(viewModel.challengeHealthStatus.emoji)
                        .font(.title2)
                    
                    Text("Challenge Status: \(viewModel.challengeHealthStatus.description)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                
                // Quick Stats
                HStack(spacing: 16) {
                    statItem(
                        icon: "calendar.badge.clock",
                        value: "\(viewModel.missedDayCount)",
                        label: "Missed Days"
                    )
                    
                    statItem(
                        icon: "flame.fill",
                        value: "\(viewModel.currentStreak.days)", // Use .days property
                        label: "Streak"
                    )
                    
                    if viewModel.pastDueDayCount > 0 {
                        statItem(
                            icon: "percent",
                            value: "\(Int(viewModel.pastDaySuccessRate))",
                            label: "Success Rate"
                        )
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                
                // Helpful tip
                Text("💡 Tip: Tap the orange days below to catch up on missed workouts")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 12)
        }
    }
    
    // MARK: - Expanded Action Buttons
    
    private var actionButtonsExpanded: some View {
        HStack(spacing: 12) {
            // Catch Up Button
            if viewModel.suggestedCatchUpDays > 0 {
                Button(action: {
                    // TODO: Navigate to catch-up flow
                    print("Starting catch-up flow for \(viewModel.suggestedCatchUpDays) days")
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill")
                        Text("Do \(viewModel.suggestedCatchUpDays) Workout\(viewModel.suggestedCatchUpDays > 1 ? "s" : "")")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.orange)
                    .cornerRadius(8)
                }
            }
            
            // Restart Option (if recommended)
            if viewModel.shouldOfferRestart {
                Button(action: {
                    // TODO: Implement restart flow
                    print("Starting restart flow")
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                        Text("Fresh Start")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Helper Views
    
    private func statItem(icon: String, value: String, label: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var bannerBackgroundColor: Color {
        switch viewModel.challengeHealthStatus {
        case .excellent, .onTrack:
            return Color.green.opacity(0.1)
        case .slightlyBehind, .behindButRecoverable:
            return Color.orange.opacity(0.1)
        case .struggling, .needsSupport:
            return Color.red.opacity(0.1)
        }
    }
    
    private var iconBackgroundColor: Color {
        switch viewModel.challengeHealthStatus {
        case .excellent, .onTrack:
            return Color.green.opacity(0.2)
        case .slightlyBehind, .behindButRecoverable:
            return Color.orange.opacity(0.2)
        case .struggling, .needsSupport:
            return Color.red.opacity(0.2)
        }
    }
    
    private var iconColor: Color {
        switch viewModel.challengeHealthStatus {
        case .excellent, .onTrack:
            return Color.green
        case .slightlyBehind, .behindButRecoverable:
            return Color.orange
        case .struggling, .needsSupport:
            return Color.red
        }
    }
    
    private var bannerIcon: String {
        switch viewModel.challengeHealthStatus {
        case .excellent, .onTrack:
            return "checkmark.circle.fill"
        case .slightlyBehind, .behindButRecoverable:
            return "exclamationmark.triangle.fill"
        case .struggling, .needsSupport:
            return "heart.fill"
        }
    }
}

// MARK: - Preview

#Preview("Missed Days Banner - Slightly Behind") {
    // Create a sample ViewModel with missed days
    let viewModel = WorkoutPlanViewModel()
    
    // Mock some missed days data for preview
    // Note: In real implementation, this would come from actual plan data
    
    return VStack {
        MissedDaysBanner()
            .environmentObject(viewModel)
            .padding()
        
        Spacer()
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Missed Days Banner - Different States") {
    VStack(spacing: 16) {
        // Simulate different banner states
        Text("Simplified Banner States:")
            .font(.headline)
            .padding()
        
        // Note: In real app, these would be driven by actual ViewModel state
        VStack(spacing: 12) {
            // Slightly behind state
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.orange)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("You have 2 missed days available to complete")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("Life happens! A few catch-up sessions and you'll be done!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
            
            // Struggling state
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.2))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.red)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Ready for a fresh start? You can still complete your challenge")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("Every step counts! Ready to finish strong?")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.red.opacity(0.1))
            .cornerRadius(12)
        }
        .padding()
        
        Text("💡 Tip: Tap orange day rows below to catch up")
            .font(.caption)
            .foregroundColor(.secondary)
            .padding()
        
        Spacer()
    }
    .background(Color(.systemGroupedBackground))
}
