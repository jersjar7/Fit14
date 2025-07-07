//
//  GoalHelpSheet.swift
//  Fit14
//
//  Created by Jerson on 7/6/25.
//

import SwiftUI

// MARK: - Help Content Models

enum HelpSection: String, CaseIterable, Identifiable {
    case twoWeekPhilosophy = "two_week_philosophy"
    case writingEffectiveGoals = "writing_effective_goals"
    case usingSmartChips = "using_smart_chips"
    case aiGenerationTips = "ai_generation_tips"
    case exampleGoals = "example_goals"
    case troubleshooting = "troubleshooting"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .twoWeekPhilosophy:
            return "Why 2 Weeks?"
        case .writingEffectiveGoals:
            return "Writing Effective Goals"
        case .usingSmartChips:
            return "Using Smart Chips"
        case .aiGenerationTips:
            return "Better AI Results"
        case .exampleGoals:
            return "Goal Examples"
        case .troubleshooting:
            return "Troubleshooting"
        }
    }
    
    var icon: String {
        switch self {
        case .twoWeekPhilosophy:
            return "calendar.badge.clock"
        case .writingEffectiveGoals:
            return "pencil.and.outline"
        case .usingSmartChips:
            return "sparkles"
        case .aiGenerationTips:
            return "brain.head.profile"
        case .exampleGoals:
            return "lightbulb"
        case .troubleshooting:
            return "questionmark.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .twoWeekPhilosophy:
            return Color.blue
        case .writingEffectiveGoals:
            return Color.green
        case .usingSmartChips:
            return Color.purple
        case .aiGenerationTips:
            return Color.orange
        case .exampleGoals:
            return Color.yellow
        case .troubleshooting:
            return Color.red
        }
    }
}

struct GoalExample {
    let category: String
    let good: String
    let bad: String
    let explanation: String
}

// MARK: - Goal Help Sheet

struct GoalHelpSheet: View {
    
    // MARK: - Properties
    
    let userGoalData: UserGoalData?
    let onDismiss: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSection: HelpSection = .twoWeekPhilosophy
    @State private var showingDetailSection = false
    
    // MARK: - Initialization
    
    init(userGoalData: UserGoalData? = nil, onDismiss: @escaping () -> Void) {
        self.userGoalData = userGoalData
        self.onDismiss = onDismiss
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Section
                headerSection
                
                // Quick Tips or Section Selector
                if showingDetailSection {
                    detailContentView
                } else {
                    overviewContentView
                }
            }
            .navigationTitle("Goal Writing Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        handleDismiss()
                    }
                }
                
                if showingDetailSection {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Overview") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showingDetailSection = false
                            }
                        }
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // App Philosophy
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundColor(Color.blue)
                    
                    Text("Fit14 Philosophy")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Text("Transform your fitness in 14 days with AI-powered, personalized workout plans")
                    .font(.subheadline)
                    .foregroundColor(Color.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Current Goal Quality (if available)
            if let goalData = userGoalData {
                currentGoalQualitySection(goalData)
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
    
    private func currentGoalQualitySection(_ goalData: UserGoalData) -> some View {
        HStack(spacing: 12) {
            // Quality Indicator
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.3), lineWidth: 3)
                    .frame(width: 32, height: 32)
                
                Circle()
                    .trim(from: 0, to: goalData.completenessScore)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 32, height: 32)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: goalData.completenessScore)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Your Goal Quality")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Color.primary)
                
                Text("\(Int(goalData.completenessScore * 100))% Complete")
                    .font(.caption)
                    .foregroundColor(Color.secondary)
            }
            
            Spacer()
            
            if goalData.completenessScore < 0.7 {
                Button("Improve") {
                    selectedSection = .writingEffectiveGoals
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingDetailSection = true
                    }
                }
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(Color.blue)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color.green)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
    
    // MARK: - Overview Content
    
    private var overviewContentView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Quick Start Section
                quickStartSection
                
                // Help Sections Grid
                helpSectionsGrid
                
                // Feature Highlights
                featureHighlightsSection
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var quickStartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Start")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                quickTipRow(
                    icon: "1.circle.fill",
                    title: "Start with your main goal",
                    subtitle: "\"I want to lose 5 pounds\" or \"Build upper body strength\"",
                    color: Color.blue
                )
                
                quickTipRow(
                    icon: "2.circle.fill",
                    title: "Add your details",
                    subtitle: "Use the smart chips that appear as you type",
                    color: Color.green
                )
                
                quickTipRow(
                    icon: "3.circle.fill",
                    title: "Review & customize",
                    subtitle: "Perfect your AI-generated plan before starting",
                    color: Color.purple
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
    
    private func quickTipRow(icon: String, title: String, subtitle: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(Color.secondary)
            }
            
            Spacer()
        }
    }
    
    private var helpSectionsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.adaptive(minimum: 140), spacing: 12)
        ], spacing: 12) {
            ForEach(HelpSection.allCases) { section in
                helpSectionCard(section)
            }
        }
    }
    
    private func helpSectionCard(_ section: HelpSection) -> some View {
        Button(action: {
            selectedSection = section
            withAnimation(.easeInOut(duration: 0.3)) {
                showingDetailSection = true
            }
        }) {
            VStack(spacing: 8) {
                Image(systemName: section.icon)
                    .font(.title2)
                    .foregroundColor(section.color)
                    .frame(height: 32)
                
                Text(section.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .stroke(section.color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var featureHighlightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Why Fit14 Works")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                featureRow(
                    icon: "brain.head.profile",
                    title: "AI-Powered Personalization",
                    description: "Advanced algorithms create plans tailored to your specific goals and constraints"
                )
                
                featureRow(
                    icon: "calendar.badge.clock",
                    title: "2-Week Focus",
                    description: "Perfect timeframe to build habits without overwhelming commitment"
                )
                
                featureRow(
                    icon: "sparkles",
                    title: "Smart Suggestions",
                    description: "Contextual chips help you provide complete information for better results"
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
    
    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Color.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(Color.secondary)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Detail Content
    
    private var detailContentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                sectionContent(for: selectedSection)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
    }
    
    @ViewBuilder
    private func sectionContent(for section: HelpSection) -> some View {
        switch section {
        case .twoWeekPhilosophy:
            twoWeekPhilosophyContent
        case .writingEffectiveGoals:
            writingEffectiveGoalsContent
        case .usingSmartChips:
            usingSmartChipsContent
        case .aiGenerationTips:
            aiGenerationTipsContent
        case .exampleGoals:
            exampleGoalsContent
        case .troubleshooting:
            troubleshootingContent
        }
    }
    
    // MARK: - Section Content Views
    
    private var twoWeekPhilosophyContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Why 2 Weeks?", icon: "calendar.badge.clock", color: Color.blue)
            
            philosophyPoint(
                title: "Perfect Habit Window",
                description: "Research shows 14 days is ideal for establishing new routines without overwhelming commitment",
                icon: "brain"
            )
            
            philosophyPoint(
                title: "Visible Results",
                description: "Long enough to see meaningful progress in strength, endurance, and body composition",
                icon: "chart.line.uptrend.xyaxis"
            )
            
            philosophyPoint(
                title: "Sustainable Momentum",
                description: "Short enough to maintain motivation while building confidence for longer-term success",
                icon: "arrow.up.circle"
            )
            
            philosophyPoint(
                title: "Flexible Planning",
                description: "Complete a cycle, assess results, then start your next 14-day challenge",
                icon: "arrow.clockwise"
            )
        }
    }
    
    private func philosophyPoint(title: String, description: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Color.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(Color.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.blue.opacity(0.05))
        )
    }
    
    private var writingEffectiveGoalsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Writing Effective Goals", icon: "pencil.and.outline", color: Color.green)
            
            Text("Great goals are specific, achievable, and personally meaningful. Here's how to write them:")
                .font(.subheadline)
                .foregroundColor(Color.secondary)
            
            goalWritingTip(
                title: "Be Specific",
                good: "Lose 5 pounds in 2 weeks",
                bad: "Get fit",
                explanation: "Specific goals help the AI create targeted workouts"
            )
            
            goalWritingTip(
                title: "Include Timeline",
                good: "Build strength for hiking in 2 weeks",
                bad: "Get stronger eventually",
                explanation: "Clear timelines enable proper progression planning"
            )
            
            goalWritingTip(
                title: "Mention Constraints",
                good: "Gain muscle working out at home 30 minutes daily",
                bad: "Build muscle",
                explanation: "Constraints help create realistic, achievable plans"
            )
        }
    }
    
    private func goalWritingTip(title: String, good: String, bad: String, explanation: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color.green)
                        Text("Good")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(Color.green)
                    }
                    
                    Text("\"" + good + "\"")
                        .font(.caption)
                        .italic()
                        .foregroundColor(Color.primary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color.red)
                        Text("Avoid")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(Color.red)
                    }
                    
                    Text("\"" + bad + "\"")
                        .font(.caption)
                        .italic()
                        .foregroundColor(Color.secondary)
                }
            }
            
            Text(explanation)
                .font(.caption)
                .foregroundColor(Color.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.green.opacity(0.05))
        )
    }
    
    private var usingSmartChipsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Using Smart Chips", icon: "sparkles", color: Color.purple)
            
            Text("Smart chips help you provide complete information without overwhelming forms:")
                .font(.subheadline)
                .foregroundColor(Color.secondary)
            
            chipExplanation(
                category: "Essential Information",
                description: "Always visible chips for critical planning data",
                chips: ["Fitness Level", "Time Available", "Workout Location"],
                color: Color.orange
            )
            
            chipExplanation(
                category: "Smart Suggestions",
                description: "Appear based on keywords in your goal text",
                chips: ["Timeline", "Limitations", "Equipment"],
                color: Color.blue
            )
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Pro Tips")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                tipRow("Type naturally - relevant chips will appear automatically")
                tipRow("Fill in critical chips (marked with *) for best results")
                tipRow("Use custom input for specific needs not covered by options")
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.purple.opacity(0.05))
            )
        }
    }
    
    private func chipExplanation(category: String, description: String, chips: [String], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: category == "Essential Information" ? "star.fill" : "sparkles")
                    .foregroundColor(color)
                Text(category)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            Text(description)
                .font(.caption)
                .foregroundColor(Color.secondary)
            
            FlowLayout(spacing: 6) {
                ForEach(chips, id: \.self) { chip in
                    Text(chip)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(color.opacity(0.1))
                                .stroke(color.opacity(0.3), lineWidth: 1)
                        )
                        .foregroundColor(color)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.05))
        )
    }
    
    private var aiGenerationTipsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Better AI Results", icon: "brain.head.profile", color: Color.orange)
            
            aiTip(
                title: "Include Numbers",
                description: "\"Lose 10 pounds\" or \"Work out 4 times per week\"",
                icon: "number"
            )
            
            aiTip(
                title: "Mention Experience",
                description: "\"I'm a beginner\" or \"Former athlete getting back in shape\"",
                icon: "person.fill"
            )
            
            aiTip(
                title: "Specify Equipment",
                description: "\"Home gym with dumbbells\" or \"Bodyweight only\"",
                icon: "dumbbell"
            )
            
            aiTip(
                title: "Note Limitations",
                description: "\"Bad knee\" or \"No running due to ankle injury\"",
                icon: "exclamationmark.triangle"
            )
        }
    }
    
    private func aiTip(title: String, description: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Color.orange)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(Color.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.orange.opacity(0.05))
        )
    }
    
    private var exampleGoalsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Goal Examples", icon: "lightbulb", color: Color.yellow)
            
            ForEach(goalExamples, id: \.category) { example in
                goalExampleCard(example)
            }
        }
    }
    
    private func goalExampleCard(_ example: GoalExample) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(example.category)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.green)
                        .font(.caption)
                    
                    Text(example.good)
                        .font(.caption)
                        .foregroundColor(Color.primary)
                        .italic()
                }
                
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color.red)
                        .font(.caption)
                    
                    Text(example.bad)
                        .font(.caption)
                        .foregroundColor(Color.secondary)
                        .italic()
                        .strikethrough()
                }
            }
            
            Text(example.explanation)
                .font(.caption)
                .foregroundColor(Color.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.yellow.opacity(0.05))
        )
    }
    
    private var troubleshootingContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Troubleshooting", icon: "questionmark.circle", color: Color.red)
            
            troubleshootingItem(
                problem: "AI generation fails",
                solution: "Check internet connection and try simpler language"
            )
            
            troubleshootingItem(
                problem: "No smart chips appearing",
                solution: "Add more details about your specific goals and constraints"
            )
            
            troubleshootingItem(
                problem: "Plan doesn't match my goals",
                solution: "Review your goal description and update chip selections before regenerating"
            )
            
            troubleshootingItem(
                problem: "Exercises too difficult/easy",
                solution: "Adjust your fitness level selection and regenerate the plan"
            )
        }
    }
    
    private func troubleshootingItem(problem: String, solution: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(Color.orange)
                Text(problem)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color.green)
                
                Text(solution)
                    .font(.caption)
                    .foregroundColor(Color.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.red.opacity(0.05))
        )
    }
    
    // MARK: - Helper Views
    
    private func sectionHeader(_ title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
        }
    }
    
    private func tipRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(Color.yellow)
                .font(.caption)
            
            Text(text)
                .font(.caption)
                .foregroundColor(Color.secondary)
            
            Spacer()
        }
    }
    
    // MARK: - Event Handlers
    
    private func handleDismiss() {
        onDismiss()
        dismiss()
    }
    
    // MARK: - Sample Data
    
    private var goalExamples: [GoalExample] {
        [
            GoalExample(
                category: "Weight Loss",
                good: "Lose 8 pounds in 2 weeks through cardio and strength training at home",
                bad: "Lose weight",
                explanation: "Specific target, timeline, and method preferences help create targeted workouts"
            ),
            GoalExample(
                category: "Strength Building",
                good: "Build upper body strength for rock climbing, working out 45 minutes 4x per week",
                bad: "Get stronger",
                explanation: "Goal purpose, time commitment, and frequency enable proper progression planning"
            ),
            GoalExample(
                category: "Endurance",
                good: "Prepare for 5K run in 2 weeks, currently can jog 1 mile without stopping",
                bad: "Run better",
                explanation: "Specific event, timeline, and current ability level help calibrate training intensity"
            ),
            GoalExample(
                category: "Recovery",
                good: "Return to fitness after knee surgery, focusing on low-impact exercises",
                bad: "Exercise again",
                explanation: "Medical context and exercise restrictions ensure safe, appropriate workouts"
            )
        ]
    }
}

// MARK: - Preview Provider

#Preview("Help Overview") {
    GoalHelpSheet(
        onDismiss: { print("Help dismissed") }
    )
}

#Preview("Help with Goal Data") {
    let sampleGoalData = {
        var data = UserGoalData()
        data.updateFreeFormText("I want to lose 5 pounds in 2 weeks")
        return data
    }()
    
    return GoalHelpSheet(
        userGoalData: sampleGoalData,
        onDismiss: { print("Help dismissed") }
    )
}
