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
        ScrollView {
            VStack(spacing: 0) {
                // Consistent top spacing
                Spacer()
                    .frame(minHeight: 20)
                
                // Header
                VStack(spacing: 16) {
                    Text("Track Your Journey")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                    
                    Text("Watch your progress grow over the perfect 14-day timeframe")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
                
                // 14-day timeline visualization
                VStack(spacing: 20) {
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
                                .foregroundColor(.blue)
                            
                            Text("Complete")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // 14-day grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                        ForEach(1...maxDays, id: \.self) { day in
                            dayCell(day: day)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 30)
                
                // Progress insights
                VStack(spacing: 20) {
                    progressBenefit(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Real Progress",
                        description: "See measurable improvements in strength and endurance",
                        color: .blue
                    )
                    
                    progressBenefit(
                        icon: "calendar.badge.checkmark",
                        title: "Habit Formation",
                        description: "Build sustainable fitness habits that last beyond 14 days",
                        color: .green
                    )
                    
                    progressBenefit(
                        icon: "trophy.fill",
                        title: "Achievement Focus",
                        description: "Celebrate completion and check your history",
                        color: .orange
                    )
                }
                .padding(.horizontal, 24)
                
                // Bottom spacing
                Spacer()
                    .frame(minHeight: 60)
            }
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
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: progressDay)
    }
    
    private func cellColor(for day: Int) -> Color {
        if day < progressDay {
            return Color.green
        } else if day == progressDay {
            return Color.blue
        } else {
            return Color.gray.opacity(0.2)
        }
    }
    
    private func progressBenefit(icon: String, title: String, description: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
    
    private func startProgressAnimation() {
        isAnimating = true
        
        // Animate progress day by day
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
            if progressDay < maxDays {
                progressDay += 1
            } else {
                timer.invalidate()
                
                // Reset after a pause
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    progressDay = 0
                    startProgressAnimation()
                }
            }
        }
    }
}
