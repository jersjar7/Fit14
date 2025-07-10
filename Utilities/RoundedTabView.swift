//
//  CustomTabBarStyles.swift
//  Fit14
//
//  Various tab bar style implementations
//

import SwiftUI

// MARK: - 1. Floating Rounded Tab Bar (Most Popular)

struct FloatingTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content area
            TabView(selection: $selectedTab) {
                HomeContent()
                    .tag(0)
                WorkoutContent()
                    .tag(1)
                ProgressContent()
                    .tag(2)
                ProfileContent()
                    .tag(3)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Custom floating tab bar
            HStack(spacing: 0) {
                TabBarButton(
                    icon: "house.fill",
                    title: "Home",
                    isSelected: selectedTab == 0
                ) {
                    selectedTab = 0
                }
                
                TabBarButton(
                    icon: "figure.strengthtraining.traditional",
                    title: "Workout",
                    isSelected: selectedTab == 1
                ) {
                    selectedTab = 1
                }
                
                TabBarButton(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Progress",
                    isSelected: selectedTab == 2
                ) {
                    selectedTab = 2
                }
                
                TabBarButton(
                    icon: "person.fill",
                    title: "Profile",
                    isSelected: selectedTab == 3
                ) {
                    selectedTab = 3
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .blue : .gray)
                
                Text(title)
                    .font(.caption2)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 2. Capsule Tab Bar with Background Blur

struct CapsuleTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeContent().tag(0)
                WorkoutContent().tag(1)
                ProgressContent().tag(2)
                ProfileContent().tag(3)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Capsule tab bar
            HStack(spacing: 30) {
                CapsuleTabButton(icon: "house", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                CapsuleTabButton(icon: "dumbbell", isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
                CapsuleTabButton(icon: "chart.bar", isSelected: selectedTab == 2) {
                    selectedTab = 2
                }
                CapsuleTabButton(icon: "person", isSelected: selectedTab == 3) {
                    selectedTab = 3
                }
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 15)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .padding(.bottom, 40)
        }
    }
}

struct CapsuleTabButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: isSelected ? "\(icon).fill" : icon)
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(isSelected ? Color.blue : Color.clear)
                        .scaleEffect(isSelected ? 1.0 : 0.8)
                )
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 3. Minimal Bottom Bar

struct MinimalTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Content
            TabView(selection: $selectedTab) {
                HomeContent().tag(0)
                WorkoutContent().tag(1)
                ProgressContent().tag(2)
                ProfileContent().tag(3)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Minimal tab bar
            HStack {
                MinimalTabButton(icon: "house", title: "Home", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                MinimalTabButton(icon: "dumbbell", title: "Workout", isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
                MinimalTabButton(icon: "chart.line.uptrend.xyaxis", title: "Progress", isSelected: selectedTab == 2) {
                    selectedTab = 2
                }
                MinimalTabButton(icon: "person", title: "Profile", isSelected: selectedTab == 3) {
                    selectedTab = 3
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 30)
            .background(Color(.systemBackground))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color(.systemGray5)),
                alignment: .top
            )
        }
    }
}

struct MinimalTabButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? "\(icon).fill" : icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(isSelected ? .blue : .gray)
                
                Text(title)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .blue : .gray)
                
                // Selection indicator
                Circle()
                    .fill(isSelected ? Color.blue : Color.clear)
                    .frame(width: 4, height: 4)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 4. Sidebar Style Tab Bar

struct SidebarTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            VStack(spacing: 20) {
                Spacer()
                
                SidebarTabButton(icon: "house", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                SidebarTabButton(icon: "dumbbell", isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
                SidebarTabButton(icon: "chart.bar", isSelected: selectedTab == 2) {
                    selectedTab = 2
                }
                SidebarTabButton(icon: "person", isSelected: selectedTab == 3) {
                    selectedTab = 3
                }
                
                Spacer()
            }
            .frame(width: 70)
            .background(Color(.systemGray6))
            
            // Content
            TabView(selection: $selectedTab) {
                HomeContent().tag(0)
                WorkoutContent().tag(1)
                ProgressContent().tag(2)
                ProfileContent().tag(3)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
    }
}

struct SidebarTabButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: isSelected ? "\(icon).fill" : icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(isSelected ? .white : .gray)
                .frame(width: 45, height: 45)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.blue : Color.clear)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 5. Animated Tab Bar with Morphing Background

struct AnimatedTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeContent().tag(0)
                WorkoutContent().tag(1)
                ProgressContent().tag(2)
                ProfileContent().tag(3)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Animated tab bar
            HStack {
                AnimatedTabButton(icon: "house", isSelected: selectedTab == 0) {
                    withAnimation(.spring()) { selectedTab = 0 }
                }
                AnimatedTabButton(icon: "dumbbell", isSelected: selectedTab == 1) {
                    withAnimation(.spring()) { selectedTab = 1 }
                }
                AnimatedTabButton(icon: "chart.bar", isSelected: selectedTab == 2) {
                    withAnimation(.spring()) { selectedTab = 2 }
                }
                AnimatedTabButton(icon: "person", isSelected: selectedTab == 3) {
                    withAnimation(.spring()) { selectedTab = 3 }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        // Moving background indicator
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.blue.opacity(0.3))
                            .frame(width: 60, height: 50)
                            .offset(x: CGFloat(selectedTab - 1) * 80, y: 0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
                    )
            )
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
}

struct AnimatedTabButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: isSelected ? "\(icon).fill" : icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(isSelected ? .blue : .gray)
                .frame(width: 60, height: 50)
                .scaleEffect(isSelected ? 1.2 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Sample Content Views

struct HomeContent: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Home")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
            .navigationTitle("Home")
        }
    }
}

struct WorkoutContent: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Workout")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
            .navigationTitle("Workout")
        }
    }
}

struct ProgressContent: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Progress")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
            .navigationTitle("Progress")
        }
    }
}

struct ProfileContent: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
            .navigationTitle("Profile")
        }
    }
}

// MARK: - Preview Selection

struct TabBarStyleDemo: View {
    @State private var selectedStyle = 0
    
    var body: some View {
        VStack {
            Picker("Tab Style", selection: $selectedStyle) {
                Text("Floating").tag(0)
                Text("Capsule").tag(1)
                Text("Minimal").tag(2)
                Text("Sidebar").tag(3)
                Text("Animated").tag(4)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Group {
                switch selectedStyle {
                case 0: FloatingTabView()
                case 1: CapsuleTabView()
                case 2: MinimalTabView()
                case 3: SidebarTabView()
                case 4: AnimatedTabView()
                default: FloatingTabView()
                }
            }
        }
    }
}

#Preview {
    TabBarStyleDemo()
}
