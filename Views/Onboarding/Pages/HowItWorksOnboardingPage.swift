//
//  HowItWorksOnboardingPage.swift
//  Fit14
//
//  Created by Jerson on 7/13/25.
//  How it works process explanation page
//

import SwiftUI

struct HowItWorksOnboardingPage: View {
    @State private var currentStep = 0
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Header
            VStack(spacing: 16) {
                Text("How It Works")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                
                Text("Get your personalized plan in 3 simple steps")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            // Steps visualization
            VStack(spacing: 40) {
                stepView(
                    number: 1,
                    icon: "message.badge.filled.fill",
                    title: "Tell Us Your Goal",
                    description: "\"Beat my 5K PR of 25 minutes\"\n\"Do my first pull-up\"",
                    isActive: currentStep >= 0
                )
                
                connectionLine(isActive: currentStep >= 1)
                
                stepView(
                    number: 2,
                    icon: "brain.head.profile",
                    title: "AI Creates Your Plan",
                    description: "Our AI considers your fitness level, time, location, and equipment",
                    isActive: currentStep >= 1
                )
                
                connectionLine(isActive: currentStep >= 2)
                
                stepView(
                    number: 3,
                    icon: "calendar.badge.checkmark",
                    title: "Train for 14 Days",
                    description: "Follow your personalized plan and track your progress daily",
                    isActive: currentStep >= 2
                )
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Feature callout
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.green)
                    Text("Takes under 2 minutes to set up")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                    Text("Every workout is unique to you")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Spacer()
        }
        .onAppear {
            startStepAnimation()
        }
    }
    
    private func stepView(number: Int, icon: String, title: String, description: String, isActive: Bool) -> some View {
        HStack(alignment: .top, spacing: 20) {
            // Step number circle
            ZStack {
                Circle()
                    .fill(isActive ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .scaleEffect(isActive ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.5), value: isActive)
                
                if isActive {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(.white)
                } else {
                    Text("\(number)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(isActive ? .primary : .secondary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .opacity(isActive ? 1.0 : 0.6)
        .animation(.easeInOut(duration: 0.5), value: isActive)
    }
    
    private func connectionLine(isActive: Bool) -> some View {
        VStack {
            ForEach(0..<3, id: \.self) { _ in
                Circle()
                    .fill(isActive ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: 4, height: 4)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: isActive)
    }
    
    private func startStepAnimation() {
        currentStep = 0
        
        Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false) { _ in
            currentStep = 1
        }
        
        Timer.scheduledTimer(withTimeInterval: 1.6, repeats: false) { _ in
            currentStep = 2
        }
    }
}
