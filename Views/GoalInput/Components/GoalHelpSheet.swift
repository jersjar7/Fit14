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
    case usingEssentialChips = "using_essential_chips"
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
        case .usingEssentialChips:
            return "Essential Information"
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
        case .usingEssentialChips:
            return "star.fill"
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
        case .usingEssentialChips:
            return Color.orange
        case .aiGenerationTips:
            return Color.purple
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
                    subtitle: "\"Beat my 5K PR of 25 minutes\" or \"Do my first pull-up\"",
                    color: Color.blue
                )
                
                quickTipRow(
                    icon: "2.circle.fill",
                    title: "Add essential details",
                    subtitle: "Fill in the orange chips for personalized planning",
                    color: Color.green
                )
                
                quickTipRow(
                    icon: "3.circle.fill",
                    title: "Include any constraints",
                    subtitle: "Mention injuries, equipment, or schedule naturally in your text",
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
                    icon: "target",
                    title: "Versatile Goal Support",
                    description: "From PRs to skill building, our AI handles any fitness challenge"
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
        case .usingEssentialChips:
            usingEssentialChipsContent
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
                title: "Be Specific About Outcomes",
                good: "Improve my deadlift PR from 185 to 205 pounds",
                bad: "Get stronger",
                explanation: "Specific targets help the AI create progressive training"
            )
            
            goalWritingTip(
                title: "Include Performance Goals",
                good: "Run a 5K in under 24 minutes (current best is 26:30)",
                bad: "Run faster",
                explanation: "Current baseline enables proper pacing and progression"
            )
            
            goalWritingTip(
                title: "Mention Natural Constraints",
                good: "Build core strength while avoiding exercises that hurt my lower back",
                bad: "Work on abs",
                explanation: "Constraints help create safe, appropriate workouts"
            )
            
            // Add section about natural information inclusion
            VStack(alignment: .leading, spacing: 12) {
                Text("💡 Pro Tip: Include Details Naturally")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.green)
                
                Text("Feel free to mention injuries, equipment preferences, or schedule constraints directly in your goal text. Our AI understands natural language and will incorporate these details into your plan.")
                    .font(.caption)
                    .foregroundColor(Color.secondary)
                
                VStack(alignment: .leading, spacing: 6) {
                    naturalDetailExample("Equipment: \"using only resistance bands and bodyweight\"")
                    naturalDetailExample("Injuries: \"while being careful with my shoulder injury\"")
                    naturalDetailExample("Schedule: \"working around my busy weekday mornings\"")
                    naturalDetailExample("Preferences: \"avoiding high-impact exercises\"")
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.green.opacity(0.05))
            )
        }
    }
    
    private func naturalDetailExample(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Color.green)
                .font(.caption)
            
            Text(text)
                .font(.caption)
                .foregroundColor(Color.secondary)
                .italic()
            
            Spacer()
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
    
    private var usingEssentialChipsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Essential Information", icon: "star.fill", color: Color.orange)
            
            Text("Essential chips collect the core information needed for any workout plan:")
                .font(.subheadline)
                .foregroundColor(Color.secondary)
            
            chipExplanation(
                category: "Essential Information",
                description: "Critical data for safe and effective workout planning",
                chips: ["Fitness Level", "Time Available", "Workout Location", "Height & Weight"],
                color: Color.orange
            )
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Why These Matter")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                tipRow("Fitness Level: Ensures appropriate exercise difficulty and progression")
                tipRow("Time Available: Creates realistic workouts that fit your schedule")
                tipRow("Location: Determines available equipment and space considerations")
                tipRow("Body Stats: Helps with calorie calculations and exercise modifications")
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.orange.opacity(0.05))
            )
        }
    }
    
    private func chipExplanation(category: String, description: String, chips: [String], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "star.fill")
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
            sectionHeader("Better AI Results", icon: "brain.head.profile", color: Color.purple)
            
            aiTip(
                title: "Include Current Numbers",
                description: "\"My current 5K time is 28 minutes\" or \"I can bench press 135 pounds\"",
                icon: "number"
            )
            
            aiTip(
                title: "Mention Experience Level",
                description: "\"I'm returning to fitness after 2 years off\" or \"Former college athlete\"",
                icon: "person.fill"
            )
            
            aiTip(
                title: "Specify Equipment Access",
                description: "\"I have a home gym with dumbbells up to 50lbs\" or \"Bodyweight only\"",
                icon: "dumbbell"
            )
            
            aiTip(
                title: "Note Physical Considerations",
                description: "\"Avoiding overhead movements due to shoulder impingement\"",
                icon: "exclamationmark.triangle"
            )
        }
    }
    
    private func aiTip(title: String, description: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Color.purple)
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
                .fill(Color.purple.opacity(0.05))
        )
    }
    
    private var exampleGoalsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Goal Examples", icon: "lightbulb", color: Color.yellow)
            
            Text("Our AI can handle any fitness goal - from specific PRs to skill development:")
                .font(.subheadline)
                .foregroundColor(Color.secondary)
            
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
                problem: "Plan doesn't match my goals",
                solution: "Review your goal description and essential chip selections before regenerating"
            )
            
            troubleshootingItem(
                problem: "Exercises too difficult/easy",
                solution: "Adjust your fitness level selection and regenerate the plan"
            )
            
            troubleshootingItem(
                problem: "Missing equipment considerations",
                solution: "Mention your available equipment directly in your goal text"
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
                category: "Personal Records",
                good: "Beat my squat PR of 185 pounds and hit 200 pounds in two weeks",
                bad: "Get stronger",
                explanation: "Specific current PR and target gives the AI exact progression to plan for"
            ),
            GoalExample(
                category: "Skill Development",
                good: "Do my first unassisted pull-up (currently can do negatives for 8 seconds)",
                bad: "Learn pull-ups",
                explanation: "Current ability level helps create appropriate progressions"
            ),
            GoalExample(
                category: "Sport Performance",
                good: "Improve my tennis serve power and prepare for upcoming tournament",
                bad: "Get better at tennis",
                explanation: "Sport-specific goals enable targeted movement patterns and training"
            ),
            GoalExample(
                category: "Recovery & Rehabilitation",
                good: "Strengthen my glutes and core to help with my chronic lower back pain",
                bad: "Fix my back",
                explanation: "Specific muscle targets and health context create appropriate therapeutic exercise"
            ),
            GoalExample(
                category: "Endurance Goals",
                good: "Cut 2 minutes off my current 10K time of 52 minutes using interval training",
                bad: "Run faster",
                explanation: "Current time, target improvement, and preferred method guide training approach"
            ),
            GoalExample(
                category: "Functional Fitness",
                good: "Build the strength and mobility to keep up with my toddler at the playground",
                bad: "Get in shape for parenting",
                explanation: "Real-world application helps create functional movement patterns"
            )
        ]
    }
}

// MARK: - Flow Layout Helper (if not already defined elsewhere)

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

// MARK: - Preview Provider

#Preview("Help Overview") {
    GoalHelpSheet(
        onDismiss: { print("Help dismissed") }
    )
}

#Preview("Help with Goal Data") {
    let sampleGoalData = {
        var data = UserGoalData()
        data.updateFreeFormText("I want to beat my deadlift PR of 225 pounds")
        return data
    }()
    
    return GoalHelpSheet(
        userGoalData: sampleGoalData,
        onDismiss: { print("Help dismissed") }
    )
}
