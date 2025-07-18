//
//  PermissionsOnboardingPage.swift
//  Fit14
//
//  Created by Jerson on 7/13/25.
//  Permissions and final setup page
//

import SwiftUI
import UserNotifications

enum NotificationPermissionStatus {
    case notRequested
    case granted
    case denied
    case optional
}

struct PermissionsOnboardingPage: View {
    let onComplete: () -> Void
    @State private var notificationPermissionStatus: NotificationPermissionStatus = .notRequested
    @State private var isRequestingPermission = false
    @State private var showGetStartedButton = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Consistent top spacing
                Spacer()
                    .frame(minHeight: 20)
                
                // Header
                VStack(spacing: 24) {
                    // Permission icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.1)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "bell.badge")
                            .font(.system(size: 40, weight: .light))
                            .foregroundColor(.blue)
                    }
                    
                    Text("Stay on Track")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                    
                    Text("Optional reminders to help you complete your 14-day journey")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                
                // Permission request button
                VStack(spacing: 16) {
                    Button(action: handleNotificationPermission) {
                        HStack(spacing: 12) {
                            if isRequestingPermission {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: notificationPermissionStatus == .granted ? "checkmark" : "bell")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            
                            Text(notificationButtonText)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(
                            notificationPermissionStatus == .granted ?
                            LinearGradient(
                                gradient: Gradient(colors: [Color.green, Color.blue]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ) :
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                        .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .disabled(isRequestingPermission || notificationPermissionStatus == .granted)
                    
                    // Get Started button appears after permission interaction or after delay
                    if showGetStartedButton {
                        Button(action: onComplete) {
                            HStack(spacing: 12) {
                                Text("Get Started")
                                    .fontWeight(.semibold)
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.green, Color.blue]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(25)
                            .shadow(color: Color.green.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .scaleEffect(showGetStartedButton ? 1.0 : 0.8)
                        .opacity(showGetStartedButton ? 1.0 : 0.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showGetStartedButton)
                    }
                    
                    if notificationPermissionStatus == .denied {
                        Text("You can enable notifications later in Settings")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                
                // Benefits of notifications
                VStack(spacing: 16) {
                    Text("Why Enable Reminders?")
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
                .padding(.horizontal, 24)
                
                // Bottom spacing
                Spacer()
                    .frame(minHeight: 60)
            }
        }
        .onAppear {
            checkNotificationPermissionStatus()
            
            // Show Get Started button after a delay if user doesn't interact
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                if !showGetStartedButton {
                    showGetStartedButton = true
                }
            }
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
    
    private func benefitRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
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
    
    private func handleNotificationPermission() {
        switch notificationPermissionStatus {
        case .notRequested:
            requestNotificationPermission()
        case .denied:
            openAppSettings()
        case .granted, .optional:
            break
        }
    }
    
    private func requestNotificationPermission() {
        isRequestingPermission = true
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                isRequestingPermission = false
                
                if granted {
                    notificationPermissionStatus = .granted
                } else {
                    notificationPermissionStatus = .denied
                }
                
                // Show Get Started button after permission interaction
                if !showGetStartedButton {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showGetStartedButton = true
                    }
                }
            }
        }
    }
    
    private func checkNotificationPermissionStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional:
                    notificationPermissionStatus = .granted
                    showGetStartedButton = true
                case .denied:
                    notificationPermissionStatus = .denied
                case .notDetermined:
                    notificationPermissionStatus = .notRequested
                case .ephemeral:
                    notificationPermissionStatus = .optional
                @unknown default:
                    notificationPermissionStatus = .notRequested
                }
            }
        }
    }
    
    private func openAppSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}
