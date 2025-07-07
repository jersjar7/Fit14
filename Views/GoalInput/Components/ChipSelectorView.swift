//
//  ChipSelectorView.swift
//  Fit14
//
//  Created for GoalInputView Enhancement
//  Container for essential information chips with layout and animation logic
//

import SwiftUI

// MARK: - Layout Configuration

enum ChipLayout {
    case adaptive       // Grid that adapts to screen size
    case flowing        // Tags-style flowing layout
    case stacked        // Vertical stack
    case compact        // Minimal space usage
    
    var spacing: CGFloat {
        switch self {
        case .adaptive: return 12
        case .flowing: return 8
        case .stacked: return 8
        case .compact: return 6
        }
    }
    
    var sectionSpacing: CGFloat {
        switch self {
        case .adaptive: return 20
        case .flowing: return 16
        case .stacked: return 16
        case .compact: return 12
        }
    }
}

// MARK: - Animation Configuration

struct ChipAnimationConfig {
    let appearanceDuration: TimeInterval = 0.4
    let disappearanceDuration: TimeInterval = 0.3
    let staggerDelay: TimeInterval = 0.08
    let springResponse: Double = 0.6
    let springDamping: Double = 0.8
    
    static let `default` = ChipAnimationConfig()
}

// MARK: - Chip Selector View

struct ChipSelectorView: View {
    
    // MARK: - Properties
    
    @Binding var userGoalData: UserGoalData
    let layout: ChipLayout
    let style: ChipStyle
    let showSectionHeaders: Bool
    let animationConfig: ChipAnimationConfig
    let onSelectionChanged: (ChipData) -> Void
    
    // MARK: - State
    
    @State private var selectedChip: ChipData?
    @State private var showingOptionSheet = false
    @State private var hasAppeared = false
    @State private var visibilityStates: [ChipType: Bool] = [:]
    
    // MARK: - Computed Properties
    
    private var essentialChips: [ChipData] {
        let chips = userGoalData.chips.values.filter { $0.category == .universal }
        return Array(chips).sortedForDisplay
    }
    
    private var allVisibleChips: [ChipData] {
        return essentialChips
    }
    
    // MARK: - Initialization
    
    init(
        userGoalData: Binding<UserGoalData>,
        layout: ChipLayout = .adaptive,
        style: ChipStyle = .standard,
        showSectionHeaders: Bool = true,
        animationConfig: ChipAnimationConfig = .default,
        onSelectionChanged: @escaping (ChipData) -> Void
    ) {
        self._userGoalData = userGoalData
        self.layout = layout
        self.style = style
        self.showSectionHeaders = showSectionHeaders
        self.animationConfig = animationConfig
        self.onSelectionChanged = onSelectionChanged
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: layout.sectionSpacing, pinnedViews: []) {
                // Essential Information Section
                essentialInformationSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            setupInitialState()
            withAnimation(.easeInOut(duration: 0.5).delay(0.2)) {
                hasAppeared = true
            }
        }
        .sheet(isPresented: $showingOptionSheet) {
            if let chip = selectedChip {
                ChipOptionSheet(
                    chipData: chip,
                    onSelection: { option, customValue in
                        handleChipSelection(chip: chip, option: option, customValue: customValue)
                    },
                    onCancel: {
                        selectedChip = nil
                    }
                )
            }
        }
    }
    
    // MARK: - Essential Information Section
    
    private var essentialInformationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            if showSectionHeaders {
                sectionHeader(
                    title: "Essential Information",
                    subtitle: "Required for generating your workout plan",
                    icon: "star.fill",
                    color: Color.orange
                )
            }
            
            // Chips Layout
            chipLayout(for: essentialChips)
        }
    }
    
    // MARK: - Layout Components
    
    private func sectionHeader(title: String, subtitle: String, icon: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
                .frame(width: 16, height: 16)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(Color.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 4)
    }
    
    private func chipLayout(for chips: [ChipData]) -> some View {
        Group {
            switch layout {
            case .adaptive:
                adaptiveGridLayout(chips: chips)
            case .flowing:
                flowingLayout(chips: chips)
            case .stacked:
                stackedLayout(chips: chips)
            case .compact:
                compactLayout(chips: chips)
            }
        }
    }
    
    private func adaptiveGridLayout(chips: [ChipData]) -> some View {
        LazyVGrid(
            columns: [
                GridItem(.adaptive(minimum: 140), spacing: layout.spacing)
            ],
            spacing: layout.spacing
        ) {
            ForEach(Array(chips.enumerated()), id: \.element.id) { index, chip in
                chipView(for: chip, index: index)
            }
        }
    }
    
    private func flowingLayout(chips: [ChipData]) -> some View {
        FlowLayout(spacing: layout.spacing) {
            ForEach(Array(chips.enumerated()), id: \.element.id) { index, chip in
                chipView(for: chip, index: index)
            }
        }
    }
    
    private func stackedLayout(chips: [ChipData]) -> some View {
        VStack(spacing: layout.spacing) {
            ForEach(Array(chips.enumerated()), id: \.element.id) { index, chip in
                chipView(for: chip, index: index)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private func compactLayout(chips: [ChipData]) -> some View {
        LazyVGrid(
            columns: [
                GridItem(.adaptive(minimum: 100), spacing: layout.spacing)
            ],
            spacing: layout.spacing
        ) {
            ForEach(Array(chips.enumerated()), id: \.element.id) { index, chip in
                chipView(for: chip, index: index, useCompactStyle: true)
            }
        }
    }
    
    private func chipView(for chip: ChipData, index: Int, useCompactStyle: Bool = false) -> some View {
        let isVisible = visibilityStates[chip.type] ?? true
        
        return GoalChipView(
            chipData: chip,
            style: useCompactStyle ? .compact : style,
            onTap: {
                handleChipTap(chip)
            }
        )
        .scaleEffect(isVisible ? 1.0 : 0.9)
        .opacity(isVisible ? 1.0 : 0.0)
        .animation(
            .spring(
                response: animationConfig.springResponse,
                dampingFraction: animationConfig.springDamping
            )
            .delay(Double(index) * animationConfig.staggerDelay),
            value: isVisible
        )
        .onAppear {
            // Animate essential chips in with a subtle stagger
            withAnimation(
                .spring(
                    response: animationConfig.springResponse,
                    dampingFraction: animationConfig.springDamping
                )
                .delay(Double(index) * animationConfig.staggerDelay)
            ) {
                visibilityStates[chip.type] = true
            }
        }
    }
    
    // MARK: - Event Handlers
    
    private func setupInitialState() {
        // Initialize visibility states for essential chips
        for chip in allVisibleChips {
            visibilityStates[chip.type] = false // Start hidden for animation
        }
    }
    
    private func handleChipTap(_ chip: ChipData) {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Set selected chip and show sheet
        selectedChip = chip
        showingOptionSheet = true
    }
    
    private func handleChipSelection(chip: ChipData, option: ChipOption, customValue: String?) {
        // Create updated chip with selection
        var updatedChip = chip
        updatedChip.select(option: option, customValue: customValue)
        
        // Update user goal data
        userGoalData.updateChip(updatedChip)
        
        // Notify parent
        onSelectionChanged(updatedChip)
        
        // Clear selection
        selectedChip = nil
        
        // Success haptic feedback
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
}

// MARK: - Convenience Initializers

extension ChipSelectorView {
    /// Create with default configuration
    static func standard(
        userGoalData: Binding<UserGoalData>,
        onSelectionChanged: @escaping (ChipData) -> Void
    ) -> ChipSelectorView {
        return ChipSelectorView(
            userGoalData: userGoalData,
            layout: .adaptive,
            style: .standard,
            showSectionHeaders: true,
            onSelectionChanged: onSelectionChanged
        )
    }
    
    /// Create compact version for small spaces
    static func compact(
        userGoalData: Binding<UserGoalData>,
        onSelectionChanged: @escaping (ChipData) -> Void
    ) -> ChipSelectorView {
        return ChipSelectorView(
            userGoalData: userGoalData,
            layout: .compact,
            style: .compact,
            showSectionHeaders: false,
            onSelectionChanged: onSelectionChanged
        )
    }
    
    /// Create flowing layout version
    static func flowing(
        userGoalData: Binding<UserGoalData>,
        onSelectionChanged: @escaping (ChipData) -> Void
    ) -> ChipSelectorView {
        return ChipSelectorView(
            userGoalData: userGoalData,
            layout: .flowing,
            style: .standard,
            showSectionHeaders: true,
            onSelectionChanged: onSelectionChanged
        )
    }
}

// MARK: - Preview Provider

#Preview("Standard Layout") {
    struct PreviewWrapper: View {
        @State private var userGoalData = UserGoalData()
        
        var body: some View {
            ChipSelectorView.standard(
                userGoalData: $userGoalData,
                onSelectionChanged: { chip in
                    print("Selected: \(chip.title)")
                }
            )
            .onAppear {
                setupSampleData()
            }
        }
        
        private func setupSampleData() {
            // Add essential chips only
            for chipType in ChipType.essentialTypes {
                var chip = ChipConfiguration.createChipData(for: chipType)
                chip.isVisible = true
                userGoalData.updateChip(chip)
            }
        }
    }
    
    return PreviewWrapper()
}

#Preview("Compact Layout") {
    struct PreviewWrapper: View {
        @State private var userGoalData = UserGoalData()
        
        var body: some View {
            ChipSelectorView.compact(
                userGoalData: $userGoalData,
                onSelectionChanged: { chip in
                    print("Selected: \(chip.title)")
                }
            )
            .onAppear {
                setupSampleData()
            }
        }
        
        private func setupSampleData() {
            for chipType in ChipType.essentialTypes.prefix(4) {
                var chip = ChipConfiguration.createChipData(for: chipType)
                chip.isVisible = true
                userGoalData.updateChip(chip)
            }
        }
    }
    
    return PreviewWrapper()
}

#Preview("Flowing Layout") {
    struct PreviewWrapper: View {
        @State private var userGoalData = UserGoalData()
        
        var body: some View {
            ChipSelectorView.flowing(
                userGoalData: $userGoalData,
                onSelectionChanged: { chip in
                    print("Selected: \(chip.title)")
                }
            )
            .onAppear {
                setupSampleData()
            }
        }
        
        private func setupSampleData() {
            for chipType in ChipType.essentialTypes {
                var chip = ChipConfiguration.createChipData(for: chipType)
                chip.isVisible = true
                userGoalData.updateChip(chip)
            }
        }
    }
    
    return PreviewWrapper()
}
