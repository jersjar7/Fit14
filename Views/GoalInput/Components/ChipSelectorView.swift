//
//  ChipSelectorView.swift
//  Fit14
//
//  Created by Jerson on 7/6/25.
//  Updated with enhanced essential information section and new grid layout
//

import SwiftUI

// MARK: - Enhanced Chip Selector View

struct EnhancedChipSelectorView: View {
    
    // MARK: - Bindings
    
    @ObservedObject var chipAssistant: EssentialChipAssistant
    
    // MARK: - Configuration
    
    let onChipTap: (EssentialChip) -> Void
    let onChipReset: (ChipType) -> Void
    let showProgressIndicator: Bool
    let layout: ChipGridLayout
    
    // MARK: - State
    
    @State private var hasAppeared = false
    
    // MARK: - Initialization
    
    init(
        chipAssistant: EssentialChipAssistant,
        onChipTap: @escaping (EssentialChip) -> Void,
        onChipReset: @escaping (ChipType) -> Void = { _ in },
        showProgressIndicator: Bool = true,
        layout: ChipGridLayout = .adaptive
    ) {
        self.chipAssistant = chipAssistant
        self.onChipTap = onChipTap
        self.onChipReset = onChipReset
        self.showProgressIndicator = showProgressIndicator
        self.layout = layout
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            sectionHeader
            
            // Enhanced chip grid
            chipGrid
            
            // Progress indicator
            if showProgressIndicator {
                progressSection
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).delay(0.2)) {
                hasAppeared = true
            }
        }
    }
    
    // MARK: - Section Header
    
    private var sectionHeader: some View {
        HStack {
            Image(systemName: "star.fill")
                .foregroundColor(.orange)
                .font(.title3)
            
            Text("Essential Information")
                .font(.headline)
                .fontWeight(.medium)
            
            Spacer()
        }
    }
    
    // MARK: - Chip Grid
    
    private var chipGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: 12) {
            ForEach(chipAssistant.sortedChips, id: \.id) { chip in
                EnhancedGoalChipView(
                    chip: chip,
                    onTap: {
                        onChipTap(chip)
                    },
                    onReset: {
                        onChipReset(chip.type)
                    }
                )
                .opacity(hasAppeared ? 1.0 : 0.0)
                .scaleEffect(hasAppeared ? 1.0 : 0.8)
                .animation(
                    .spring(response: 0.5, dampingFraction: 0.8)
                        .delay(Double(chipAssistant.sortedChips.firstIndex { $0.id == chip.id } ?? 0) * 0.1),
                    value: hasAppeared
                )
            }
        }
    }
    
    // MARK: - Progress Section
    
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Progress: \(chipAssistant.completedCount) of \(chipAssistant.totalCount) completed")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Completion percentage
                Text("\(Int(chipAssistant.completionPercentage * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(chipAssistant.completionPercentage > 0.5 ? .green : .orange)
            }
            
            ProgressView(value: chipAssistant.completionPercentage)
                .tint(.blue)
                .scaleEffect(y: 0.8)
                .animation(.easeInOut(duration: 0.3), value: chipAssistant.completionPercentage)
        }
    }
    
    // MARK: - Grid Configuration
    
    private var gridColumns: [GridItem] {
        switch layout {
        case .adaptive:
            return [
                GridItem(.flexible()),
                GridItem(.flexible())
            ]
        case .fixed(let count):
            return Array(repeating: GridItem(.flexible()), count: count)
        case .single:
            return [GridItem(.flexible())]
        }
    }
}

// MARK: - Legacy Chip Selector View (Backwards Compatibility)

struct ChipSelectorView: View {
    
    // MARK: - Bindings
    
    @Binding var userGoalData: UserGoalData
    
    // MARK: - Configuration
    
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
        VStack(alignment: .leading, spacing: layout.itemSpacing) {
            if showSectionHeaders {
                sectionHeader(
                    title: "Essential Information",
                    subtitle: "Help us create the perfect plan for you",
                    icon: "star.fill",
                    color: .orange
                )
            }
            
            // Chip grid
            LazyVGrid(columns: layout.gridColumns, spacing: layout.itemSpacing) {
                ForEach(allVisibleChips, id: \.id) { chipData in
                    chipView(for: chipData)
                        .opacity(visibilityStates[chipData.type] ?? false ? 1.0 : 0.0)
                        .scaleEffect(visibilityStates[chipData.type] ?? false ? 1.0 : 0.8)
                        .onAppear {
                            animateChipAppearance(for: chipData.type)
                        }
                }
            }
            
            // Completion status
            if allVisibleChips.contains(where: { $0.isSelected }) {
                completionStatusView
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
    
    // MARK: - Supporting Views
    
    private func sectionHeader(title: String, subtitle: String? = nil, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                    .fontWeight(.medium)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 32)
            }
        }
        .padding(.bottom, 8)
    }
    
    private func chipView(for chipData: ChipData) -> some View {
        GoalChipView(
            chipData: chipData,
            style: style,
            isSelected: chipData.isSelected,
            onTap: {
                handleChipTap(chipData)
            }
        )
    }
    
    private var completionStatusView: some View {
        let completedChips = allVisibleChips.filter { $0.isSelected }
        let totalChips = allVisibleChips.count
        let completionPercentage = Double(completedChips.count) / Double(totalChips)
        
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.caption)
                
                Text("Information Added")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(completedChips.count) of \(totalChips)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: completionPercentage)
                .tint(.green)
                .scaleEffect(y: 0.8)
                .animation(.easeInOut(duration: 0.3), value: completionPercentage)
            
            // Completed chips summary
            if !completedChips.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(completedChips, id: \.id) { chip in
                            completedChipPill(for: chip)
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.green.opacity(0.05))
                .stroke(Color.green.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func completedChipPill(for chipData: ChipData) -> some View {
        HStack(spacing: 6) {
            Image(systemName: chipData.icon)
                .foregroundColor(.green)
                .font(.caption2)
            
            Text(chipData.title)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            if let selectedOption = chipData.selection?.selectedOption {
                Text("•")
                    .foregroundColor(.secondary)
                    .font(.caption2)
                
                Text(selectedOption.displayText)
                    .font(.caption2)
                    .foregroundColor(.green)
                    .fontWeight(.medium)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color(.systemBackground))
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Helper Methods
    
    private func setupInitialState() {
        // Initialize visibility states
        for chip in allVisibleChips {
            visibilityStates[chip.type] = false
        }
    }
    
    private func animateChipAppearance(for chipType: ChipType) {
        let delay = Double(allVisibleChips.firstIndex { $0.type == chipType } ?? 0) * animationConfig.staggerDelay
        
        withAnimation(animationConfig.animation.delay(delay)) {
            visibilityStates[chipType] = true
        }
    }
    
    private func handleChipTap(_ chipData: ChipData) {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        selectedChip = chipData
        showingOptionSheet = true
    }
    
    private func handleChipSelection(chip: ChipData, option: ChipOption, customValue: String?) {
        // Update the chip data
        userGoalData.chips[chip.type]?.select(option: option, customValue: customValue)
        
        // Notify parent of selection change
        if let updatedChip = userGoalData.chips[chip.type] {
            onSelectionChanged(updatedChip)
        }
        
        selectedChip = nil
    }
}

// MARK: - Layout Configuration

enum ChipGridLayout {
    case adaptive
    case fixed(Int)
    case single
}

struct ChipLayout {
    let gridColumns: [GridItem]
    let itemSpacing: CGFloat
    let sectionSpacing: CGFloat
    
    static let adaptive = ChipLayout(
        gridColumns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ],
        itemSpacing: 12,
        sectionSpacing: 24
    )
    
    static let compact = ChipLayout(
        gridColumns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ],
        itemSpacing: 8,
        sectionSpacing: 16
    )
    
    static let single = ChipLayout(
        gridColumns: [GridItem(.flexible())],
        itemSpacing: 8,
        sectionSpacing: 16
    )
}

struct ChipAnimationConfig {
    let animation: Animation
    let staggerDelay: TimeInterval
    
    static let `default` = ChipAnimationConfig(
        animation: .spring(response: 0.5, dampingFraction: 0.8),
        staggerDelay: 0.1
    )
    
    static let fast = ChipAnimationConfig(
        animation: .spring(response: 0.3, dampingFraction: 0.7),
        staggerDelay: 0.05
    )
    
    static let slow = ChipAnimationConfig(
        animation: .spring(response: 0.8, dampingFraction: 0.9),
        staggerDelay: 0.2
    )
}

// MARK: - Preview

#Preview("Enhanced Chip Selector") {
    EnhancedChipSelectorView(
        chipAssistant: EssentialChipAssistant(),
        onChipTap: { chip in
            print("Chip tapped: \(chip.title)")
        },
        onChipReset: { chipType in
            print("Chip reset: \(chipType)")
        }
    )
    .padding()
}

#Preview("Legacy Chip Selector") {
    ChipSelectorView(
        userGoalData: .constant(UserGoalData()),
        layout: .adaptive,
        style: .standard,
        onSelectionChanged: { chipData in
            print("Selection changed: \(chipData.type.displayTitle)")
        }
    )
}
