//
//  ExpandableText.swift
//  Fit14
//
//  Created by Jerson on 7/11/25.
//  Reusable component for displaying expandable text with "see more" functionality
//

import SwiftUI

struct ExpandableText: View {
    // MARK: - Properties
    let text: String
    let maxLength: Int
    let font: Font
    let color: Color
    let multilineTextAlignment: TextAlignment
    let lineLimit: Int?
    let sheetTitle: String
    let sheetIcon: String
    let sheetHeaderTitle: String
    
    @State private var showingFullText = false
    
    // MARK: - Initializers
    
    /// Primary initializer with customization options
    init(
        text: String,
        maxLength: Int = 120,
        font: Font = .caption,
        color: Color = .secondary,
        multilineTextAlignment: TextAlignment = .leading,
        lineLimit: Int? = 3,
        sheetTitle: String = "Description",
        sheetIcon: String = "text.alignleft",
        sheetHeaderTitle: String = "Full Description"
    ) {
        self.text = text
        self.maxLength = maxLength
        self.font = font
        self.color = color
        self.multilineTextAlignment = multilineTextAlignment
        self.lineLimit = lineLimit
        self.sheetTitle = sheetTitle
        self.sheetIcon = sheetIcon
        self.sheetHeaderTitle = sheetHeaderTitle
    }
    
    /// Convenience initializer for challenge descriptions
    static func challengeDescription(
        _ text: String,
        maxLength: Int = 120
    ) -> ExpandableText {
        return ExpandableText(
            text: text,
            maxLength: maxLength,
            font: .caption,
            color: .secondary,
            multilineTextAlignment: .leading,
            lineLimit: 3,
            sheetTitle: "Challenge Description",
            sheetIcon: "target",
            sheetHeaderTitle: "Your Challenge Goal"
        )
    }
    
    /// Convenience initializer for plan summaries
    static func planSummary(
        _ text: String,
        maxLength: Int = 120
    ) -> ExpandableText {
        return ExpandableText(
            text: text,
            maxLength: maxLength,
            font: .subheadline,
            color: .secondary,
            multilineTextAlignment: .center,
            lineLimit: 3,
            sheetTitle: "Plan Summary",
            sheetIcon: "sparkles",
            sheetHeaderTitle: "AI Plan Summary"
        )
    }
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if text.count > maxLength {
                // Long text - show truncated version with "see more"
                Text(truncatedTextWithSeeMore)
                    .font(font)
                    .foregroundColor(color)
                    .multilineTextAlignment(multilineTextAlignment)
                    .onTapGesture {
                        showingFullText = true
                    }
            } else {
                // Short text - show normally
                Text(text)
                    .font(font)
                    .foregroundColor(color)
                    .multilineTextAlignment(multilineTextAlignment)
                    .lineLimit(lineLimit)
            }
        }
        .sheet(isPresented: $showingFullText) {
            FullTextSheet(
                text: text,
                title: sheetTitle,
                icon: sheetIcon,
                headerTitle: sheetHeaderTitle
            )
        }
    }
    
    // MARK: - Helper Computed Properties
    
    private var truncatedTextWithSeeMore: AttributedString {
        guard text.count > maxLength else {
            return AttributedString(text)
        }
        
        // Find a good place to truncate (preferably at a word boundary)
        let truncatedText = String(text.prefix(maxLength))
        let lastSpaceIndex = truncatedText.lastIndex(of: " ") ?? truncatedText.endIndex
        let finalText = String(truncatedText[..<lastSpaceIndex])
        
        // Create attributed string with colored "see more >"
        var attributedString = AttributedString(finalText + "... ")
        
        var seeMore = AttributedString("see more >")
        seeMore.foregroundColor = .blue
        seeMore.font = font
        
        attributedString.append(seeMore)
        
        return attributedString
    }
}

// MARK: - Full Text Sheet

struct FullTextSheet: View {
    let text: String
    let title: String
    let icon: String
    let headerTitle: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        Text(headerTitle)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Spacer()
                    }
                    
                    Text(text)
                        .font(.body)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(2)
                    
                    Spacer()
                }
                .padding(24)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.medium)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Preview

struct ExpandableText_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            // Short text example
            VStack(alignment: .leading, spacing: 8) {
                Text("Short Description")
                    .font(.headline)
                
                ExpandableText.challengeDescription("This is a short description that doesn't need truncation.")
            }
            
            // Long text example
            VStack(alignment: .leading, spacing: 8) {
                Text("Long Description")
                    .font(.headline)
                
                ExpandableText.challengeDescription(
                    "This is a much longer description that will definitely exceed the maximum character limit and should show the 'see more' functionality. It contains detailed information about the workout plan, goals, and expected outcomes over the 2-week period."
                )
            }
            
            // Plan summary example
            VStack(alignment: .leading, spacing: 8) {
                Text("Plan Summary")
                    .font(.headline)
                
                ExpandableText.planSummary(
                    "Progressive bodyweight training program focused on building functional strength and cardiovascular endurance for a male user who has an intermediate fitness level. This plan will help to reach their goals as long as it is followed with discipline and consistency throughout the 14-day period."
                )
            }
            
            // Custom styling example
            VStack(alignment: .leading, spacing: 8) {
                Text("Custom Styling")
                    .font(.headline)
                
                ExpandableText(
                    text: "This example shows custom styling with different font, color, and alignment options. You can customize the appearance to match your specific design needs.",
                    maxLength: 80,
                    font: .body,
                    color: .primary,
                    multilineTextAlignment: .center,
                    lineLimit: 2,
                    sheetTitle: "Custom Content",
                    sheetIcon: "star.fill",
                    sheetHeaderTitle: "Custom Header"
                )
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}
