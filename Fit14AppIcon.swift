//
//  Fit14AppIcon.swift
//  Fit14
//
//  Created by Jerson on 7/14/25.
//

import SwiftUI

struct Fit14AppIcon: View {
    let size: CGFloat
    
    init(size: CGFloat = 120) {
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Background with gradient
            RoundedRectangle(cornerRadius: size * 0.2, style: .continuous)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.2, green: 0.8, blue: 1.0),  // Light cyan
                            Color(red: 0.1, green: 0.5, blue: 1.0)   // Deeper blue
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .shadow(color: Color.black.opacity(0.3), radius: size * 0.1, x: 0, y: size * 0.05)
            
            HStack(spacing: size * 0.05) {
                // Left dumbbell - positioned behind
                dumbbellIcon()
                    .frame(width: size * 0.18, height: size * 0.3)
                    .foregroundColor(Color.white.opacity(0.3))
                    .offset(x: size * 0.08) // Move slightly toward center
                
                // Main "14" text
                Text("14")
                    .font(.system(size: size * 0.45, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.2), radius: size * 0.02, x: 0, y: size * 0.02)
                    .zIndex(1) // Ensure text is on top
                
                // Right dumbbell - positioned behind
                dumbbellIcon()
                    .frame(width: size * 0.18, height: size * 0.3)
                    .foregroundColor(Color.white.opacity(0.3))
                    .offset(x: -size * 0.08) // Move slightly toward center
            }
        }
    }
    
    private func dumbbellIcon() -> some View {
        VStack(spacing: size * 0.008) {
            // Top weight plate
            RoundedRectangle(cornerRadius: size * 0.015, style: .continuous)
                .frame(width: size * 0.14, height: size * 0.08)
            
            // Handle (bar)
            RoundedRectangle(cornerRadius: size * 0.008, style: .continuous)
                .frame(width: size * 0.05, height: size * 0.12)
            
            // Bottom weight plate
            RoundedRectangle(cornerRadius: size * 0.015, style: .continuous)
                .frame(width: size * 0.14, height: size * 0.08)
        }
    }
}

// MARK: - Convenient Size Presets

extension Fit14AppIcon {
    /// Large size perfect for splash screens
    static var splash: some View {
        Fit14AppIcon(size: 120)
    }
    
    /// Medium size for headers
    static var header: some View {
        Fit14AppIcon(size: 80)
    }
    
    /// Small size for navigation
    static var nav: some View {
        Fit14AppIcon(size: 40)
    }
}

// MARK: - Preview

struct Fit14AppIcon_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            Text("Fit14 App Icon")
                .font(.title2)
                .fontWeight(.bold)
            
            // Show just the splash size
            Fit14AppIcon.splash
            
            Text("120pt - Perfect for splash screens!")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
