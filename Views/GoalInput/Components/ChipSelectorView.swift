//
//  ChipSelectorView.swift
//  Fit14
//
//  Created for GoalInputView Enhancement
//  Container for multiple chips with layout and animation logic
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
    
    private var universalChips: [ChipData] {
        let chips = userGoalData.chips.values.filter { $0.category == .universal }
        return Array(chips).sortedForDisplay
    }
    
    private var contextualChips: [ChipData] {
        let chips = userGoalData.chips.values.filter {
            $0.category == .contextual && $0.isVisible
        }
        return Array(chips).sortedForDisplay
    }
    
    private var hasVisibleContextualChips: Bool {
        return !contextualChips.isEmpty
    }
    
    private var allVisibleChips: [ChipData] {
        return universalChips + contextualChips
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
                // Universal Chips Section
                universalChipsSection
                
                // Contextual Chips Section
                if hasVisibleContextualChips {
                    contextualChipsSection
                }
                
                // Empty State for Contextual Chips
                if !hasVisibleContextualChips && hasAppeared {
                    emptyContextualState
                }
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
        .onChange(of: userGoalData.visibleChips) { _, newChips in
            handleVisibilityChanges(newChips)
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
    
    // MARK: - Universal Chips Section
    
    private var universalChipsSection: some View {
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
            chipLayout(for: universalChips, isContextual: false)
        }
    }
    
    // MARK: - Contextual Chips Section
    
    private var contextualChipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            if showSectionHeaders {
                sectionHeader(
                    title: "Smart Suggestions",
                    subtitle: "Based on what you've written",
                    icon: "sparkles",
                    color: Color.blue
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            // Chips Layout
            chipLayout(for: contextualChips, isContextual: true)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
        }
        .animation(
            .spring(response: animationConfig.springResponse, dampingFraction: animationConfig.springDamping),
            value: contextualChips.count
        )
    }
    
    // MARK: - Empty State
    
    private var emptyContextualState: some View {
        VStack(spacing: 12) {
            Image(systemName: "lightbulb")
                .font(.title2)
                .foregroundColor(Color.gray)
            
            VStack(spacing: 4) {
                Text("Smart suggestions will appear here")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color.primary)
                
                Text("Keep typing to get personalized recommendations")
                    .font(.caption)
                    .foregroundColor(Color.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
        .animation(
            .spring(response: 0.5, dampingFraction: 0.8).delay(0.3),
            value: hasAppeared
        )
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
    
    private func chipLayout(for chips: [ChipData], isContextual: Bool) -> some View {
        Group {
            switch layout {
            case .adaptive:
                adaptiveGridLayout(chips: chips, isContextual: isContextual)
            case .flowing:
                flowingLayout(chips: chips, isContextual: isContextual)
            case .stacked:
                stackedLayout(chips: chips, isContextual: isContextual)
            case .compact:
                compactLayout(chips: chips, isContextual: isContextual)
            }
        }
    }
    
    private func adaptiveGridLayout(chips: [ChipData], isContextual: Bool) -> some View {
        LazyVGrid(
            columns: [
                GridItem(.adaptive(minimum: 140), spacing: layout.spacing)
            ],
            spacing: layout.spacing
        ) {
            ForEach(Array(chips.enumerated()), id: \.element.id) { index, chip in
                chipView(for: chip, index: index, isContextual: isContextual)
            }
        }
    }
    
    private func flowingLayout(chips: [ChipData], isContextual: Bool) -> some View {
        FlowLayout(spacing: layout.spacing) {
            ForEach(Array(chips.enumerated()), id: \.element.id) { index, chip in
                chipView(for: chip, index: index, isContextual: isContextual)
            }
        }
    }
    
    private func stackedLayout(chips: [ChipData], isContextual: Bool) -> some View {
        VStack(spacing: layout.spacing) {
            ForEach(Array(chips.enumerated()), id: \.element.id) { index, chip in
                chipView(for: chip, index: index, isContextual: isContextual)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private func compactLayout(chips: [ChipData], isContextual: Bool) -> some View {
        LazyVGrid(
            columns: [
                GridItem(.adaptive(minimum: 100), spacing: layout.spacing)
            ],
            spacing: layout.spacing
        ) {
            ForEach(Array(chips.enumerated()), id: \.element.id) { index, chip in
                chipView(for: chip, index: index, isContextual: isContextual, useCompactStyle: true)
            }
        }
    }
    
    private func chipView(for chip: ChipData, index: Int, isContextual: Bool, useCompactStyle: Bool = false) -> some View {
        let isVisible = visibilityStates[chip.type] ?? (isContextual ? false : true)
        
        return GoalChipView(
            chipData: chip,
            style: useCompactStyle ? .compact : style,
            onTap: {
                handleChipTap(chip)
            }
        )
        .scaleEffect(isVisible ? 1.0 : (isContextual ? 0.8 : 1.0))
        .opacity(isVisible ? 1.0 : (isContextual ? 0.0 : 1.0))
        .animation(
            .spring(
                response: animationConfig.springResponse,
                dampingFraction: animationConfig.springDamping
            )
            .delay(isContextual ? Double(index) * animationConfig.staggerDelay : 0),
            value: isVisible
        )
        .onAppear {
            if isContextual {
                // Animate contextual chips in
                withAnimation(
                    .spring(
                        response: animationConfig.springResponse,
                        dampingFraction: animationConfig.springDamping
                    )
                    .delay(Double(index) * animationConfig.staggerDelay)
                ) {
                    visibilityStates[chip.type] = true
                }
            } else {
                // Universal chips appear immediately
                visibilityStates[chip.type] = true
            }
        }
    }
    
    // MARK: - Event Handlers
    
    private func setupInitialState() {
        // Initialize visibility states
        for chip in allVisibleChips {
            visibilityStates[chip.type] = chip.category == .universal
        }
    }
    
    private func handleVisibilityChanges(_ newChips: [ChipData]) {
        let newVisibleTypes = Set(newChips.map { $0.type })
        let currentVisibleTypes = Set(visibilityStates.keys.filter { visibilityStates[$0] == true })
        
        // Handle appearing chips
        let appearingTypes = newVisibleTypes.subtracting(currentVisibleTypes)
        for chipType in appearingTypes {
            withAnimation(
                .spring(
                    response: animationConfig.springResponse,
                    dampingFraction: animationConfig.springDamping
                )
                .delay(animationConfig.staggerDelay)
            ) {
                visibilityStates[chipType] = true
            }
        }
        
        // Handle disappearing chips
        let disappearingTypes = currentVisibleTypes.subtracting(newVisibleTypes)
        for chipType in disappearingTypes {
            withAnimation(
                .easeInOut(duration: animationConfig.disappearanceDuration)
            ) {
                visibilityStates[chipType] = false
            }
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

// MARK: - Flow Layout Helper

struct FlowLayout: Layout {
    let spacing: CGFloat
    
    init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        
        for (index, subview) in subviews.enumerated() {
            subview.place(at: result.frames[index].origin, proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let subviewSize = subview.sizeThatFits(.unspecified)
                
                if currentX + subviewSize.width > maxWidth && currentX > 0 {
                    // Move to next line
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(
                    x: currentX,
                    y: currentY,
                    width: subviewSize.width,
                    height: subviewSize.height
                ))
                
                currentX += subviewSize.width + spacing
                lineHeight = max(lineHeight, subviewSize.height)
            }
            
            size = CGSize(
                width: maxWidth,
                height: currentY + lineHeight
            )
        }
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
            // Add universal chips
            for chipType in ChipType.universalTypes {
                var chip = ChipConfiguration.createChipData(for: chipType)
                chip.isVisible = true
                userGoalData.updateChip(chip)
            }
            
            // Add some contextual chips
            let contextualTypes: [ChipType] = [.timeline, .limitations]
            for chipType in contextualTypes {
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
            for chipType in ChipType.universalTypes.prefix(4) {
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
            for chipType in ChipType.allCases {
                var chip = ChipConfiguration.createChipData(for: chipType)
                chip.isVisible = true
                userGoalData.updateChip(chip)
            }
        }
    }
    
    return PreviewWrapper()
}
