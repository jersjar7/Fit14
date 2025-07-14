//
//  PermissionsOnboardingPage.swift
//  Fit14
//
//  Created by Jerson on 7/13/25.
//  Permissions and final setup page
//

import SwiftUI
import UserNotifications

struct PermissionsOnboardingPage: View {
    @State private var notificationPermissionStatus: PermissionStatus = .notRequested
    @State private var isRequestingPermissions = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(minHeight: 50)
            
            // Header
            VStack(spacing: 16) {
                Text("You're Almost Ready!")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                
                Text("Let's set up a few things to enhance your Fit14 experience")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            // Permissions list
            VStack(spacing: 20) {
                permissionCard(
                    icon: "bell.badge",
                    title: "Workout Reminders",
                    description: "Get gentle reminders to stay on track with your 14-day plan",
                    status: notificationPermissionStatus,
                    buttonText: notificationButtonText,
                    action: requestNotificationPermission
                )
                
                // Optional: Health app integration
                permissionCard(
                    icon: "heart.text.square",
                    title: "Health App Integration",
                    description: "Sync your workouts with Apple Health (optional)",
                    status: .optional,
                    buttonText: "Set Up Later",
                    action: { /* Handle health permission */ }
                )
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Benefits section
            VStack(spacing: 16) {
                Text("Why These Permissions Help")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                VStack(spacing: 12) {
                    benefitRow(
                        icon: "clock.badge.checkmark",
                        title: "Stay Consistent",
                        description: "Gentle reminders help you maintain your routine"
                    )
                    
                    benefitRow(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Track Progress",
                        description: "See your fitness journey in your Health app"
                    )
                    
                    benefitRow(
                        icon: "shield.checkerboard",
                        title: "Privacy First",
                        description: "All data stays on your device and in your control"
                    )
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
            .padding(.horizontal)
            
            // Bottom spacer to ensure floating buttons don't cover content
            Spacer()
                .frame(minHeight: 120)
        }
        .onAppear {
            checkNotificationPermissionStatus()
        }
    }
    
    private var notificationButtonText: String {
        switch notificationPermissionStatus {
        case .notRequested:
            return "Enable Reminders"
        case .granted:
            return "✓ Enabled"
        case .denied:
            return "Enable in Settings"
        case .optional:
            return "Skip"
        }
    }
    
    private func permissionCard(
        icon: String,
        title: String,
        description: String,
        status: PermissionStatus,
        buttonText: String,
        action: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                ZStack {
                    Circle()
                        .fill(permissionColor(for: status).opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(permissionColor(for: status))
                }
                
                VStack(alignment: .leading, spacing: 6) {
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
            
            if status != .granted {
                Button(action: action) {
                    Text(buttonText)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            status == .optional ? Color(.systemGray4) : permissionColor(for: status).opacity(0.2)
                        )
                        .foregroundColor(
                            status == .optional ? .secondary : permissionColor(for: status)
                        )
                        .cornerRadius(10)
                }
            } else {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("All set!")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private func benefitRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
    
    private func permissionColor(for status: PermissionStatus) -> Color {
        switch status {
        case .notRequested:
            return .blue
        case .granted:
            return .green
        case .denied:
            return .orange
        case .optional:
            return .gray
        }
    }
    
    private func checkNotificationPermissionStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized:
                    notificationPermissionStatus = .granted
                case .denied:
                    notificationPermissionStatus = .denied
                case .notDetermined:
                    notificationPermissionStatus = .notRequested
                default:
                    notificationPermissionStatus = .notRequested
                }
            }
        }
    }
    
    private func requestNotificationPermission() {
        guard notificationPermissionStatus == .notRequested else {
            if notificationPermissionStatus == .denied {
                // Open settings
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            return
        }
        
        isRequestingPermissions = true
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                isRequestingPermissions = false
                notificationPermissionStatus = granted ? .granted : .denied
            }
        }
    }
}

enum PermissionStatus {
    case notRequested
    case granted
    case denied
    case optional
}
