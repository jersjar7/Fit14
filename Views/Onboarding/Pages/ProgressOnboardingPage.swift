//
//  ProgressOnboardingPage.swift
//  Fit14
//
//  Created by Jerson on 7/13/25.
//  Progress tracking and 14-day timeline demonstration page
//

import SwiftUI

struct ProgressOnboardingPage: View {
    @State private var progressDay = 0
    @State private var isAnimating = false
    
    private let maxDays = 14
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(minHeight: 50)
            
            // Header
            VStack(spacing: 12) {
                Text("Track Your Journey")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                
                Text("Watch your progress grow over the perfect 14-day timeframe")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal)
            .padding(.vertical)
            
            // 14-day timeline visualization
            VStack(spacing: 8) {
                // Progress header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Day \(progressDay)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Text("of 14")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(Int((Double(progressDay) / Double(maxDays)) * 100))%")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("Complete")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                
                // Calendar grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                    ForEach(1...maxDays, id: \.self) { day in
                        dayCell(day: day)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                
                // Progress benefits
                VStack(spacing: 16) {
                    progressBenefit(
                        icon: "brain.head.profile",
                        title: "Habit Formation",
                        description: "14 days is scientifically proven to start building lasting habits",
                        color: .purple
                    )
                    
                    progressBenefit(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Visible Progress",
                        description: "See real improvements without overwhelming commitment",
                        color: .green
                    )
                    
                    progressBenefit(
                        icon: "trophy.fill",
                        title: "Achievement Focus",
                        description: "Celebrate completion and check your history",
                        color: .orange
                    )
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            // Key message
            VStack(spacing: 12) {
                Text("Perfect Timeframe")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text("Not too short to see results, not too long to feel overwhelming")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .padding(.horizontal)
            
            // Bottom spacer to ensure floating buttons don't cover content
            Spacer()
                .frame(minHeight: 120)
        }
        .onAppear {
            startProgressAnimation()
        }
    }
    
    private func dayCell(day: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(cellColor(for: day))
                .frame(height: 40)
            
            if day <= progressDay {
                Image(systemName: day == progressDay ? "clock.fill" : "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            } else {
                Text("\(day)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
        .scaleEffect(day == progressDay && isAnimating ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: progressDay)
        .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isAnimating)
    }
    
    private func cellColor(for day: Int) -> Color {
        if day < progressDay {
            return .green
        } else if day == progressDay {
            return .blue
        } else {
            return Color(.systemGray5)
        }
    }
    
    private func progressBenefit(icon: String, title: String, description: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
    
    private func startProgressAnimation() {
        progressDay = 0
        isAnimating = true
        
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
            if progressDay < 8 {
                progressDay += 1
            } else {
                timer.invalidate()
                // Reset and restart after a pause
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    startProgressAnimation()
                }
            }
        }
    }
}
