//
//  GoalInputHints.swift
//  Fit14
//
//  Created by Jerson on 7/16/25.
//  Completed chips summary components for GoalInputView
//

import SwiftUI

// MARK: - GoalInputView Completed Chips Summary Extension

extension GoalInputView {
    
    // MARK: - Completed Chips Summary
    
    var completedChipsSummary: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.caption)
                
                Text("Added Information")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(chipAssistant.completedCount) of \(chipAssistant.totalCount)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            // Completed chips in a horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(chipAssistant.sortedChips.filter { $0.isCompleted }, id: \.id) { chip in
                        completedChipPill(for: chip)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.green.opacity(0.05))
                .stroke(Color.green.opacity(0.2), lineWidth: 1)
        )
    }
    
    func completedChipPill(for chip: EssentialChip) -> some View {
        Button(action: {
            showChipOptions(for: chip)
        }) {
            HStack(spacing: 6) {
                Image(systemName: chip.icon)
                    .foregroundColor(.green)
                    .font(.caption2)
                
                Text(chip.title)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                if let selectedOption = chip.selectedOption,
                   !selectedOption.displayText.isEmpty {
                    Text("•")
                        .foregroundColor(.secondary)
                        .font(.caption2)
                    
                    Text(selectedOption.displayText)
                        .font(.caption2)
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                }
                
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
                    .font(.caption2)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color(.systemBackground))
                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
