//
//  CategoryUnitPicker.swift
//  Fit14
//
//  Created by Jerson on 7/6/25.
//

import SwiftUI

// MARK: - Unit Category Enum
enum UnitCategory: String, CaseIterable {
    case count = "Count"
    case time = "Time"
    case distance = "Distance"
    
    var displayName: String {
        return self.rawValue
    }
    
    var systemImage: String {
        switch self {
        case .count:
            return "number"
        case .time:
            return "clock"
        case .distance:
            return "location"
        }
    }
}

// MARK: - CategoryUnitPicker
struct CategoryUnitPicker: View {
    @Binding var selectedUnit: ExerciseUnit
    
    @State private var selectedCategory: UnitCategory
    @State private var selectedUnitInCategory: ExerciseUnit
    
    // MARK: - Unit Categories Mapping
    private let unitsByCategory: [UnitCategory: [ExerciseUnit]] = [
        .count: [.reps, .steps, .laps],
        .time: [.seconds, .minutes, .hours],
        .distance: [.meters, .yards, .feet, .kilometers, .miles]
    ]
    
    // MARK: - Initialization
    init(selectedUnit: Binding<ExerciseUnit>) {
        self._selectedUnit = selectedUnit
        
        // Determine initial category and unit
        let initialCategory = Self.categoryForUnit(selectedUnit.wrappedValue)
        self._selectedCategory = State(initialValue: initialCategory)
        self._selectedUnitInCategory = State(initialValue: selectedUnit.wrappedValue)
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Category and Unit Picker
            HStack(spacing: 0) {
                // Category Picker (Left Wheel)
                Picker("Category", selection: $selectedCategory) {
                    ForEach(UnitCategory.allCases, id: \.self) { category in
                        HStack {
                            Image(systemName: category.systemImage)
                            Text(category.displayName)
                        }
                        .tag(category)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                .clipped()
                
                // Unit Picker (Right Wheel)
                Picker("Unit", selection: $selectedUnitInCategory) {
                    ForEach(unitsForSelectedCategory, id: \.self) { unit in
                        Text(unit.displayName.capitalized)
                            .tag(unit)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                .clipped()
            }
            .frame(height: 150)
            
            // Selected Unit Display
            HStack {
                Image(systemName: selectedCategory.systemImage)
                    .foregroundColor(.blue)
                    .font(.caption)
                
                Text("\(selectedUnitInCategory.displayName.capitalized)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Text("(\(selectedCategory.displayName))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .padding(.top, 8)
        }
        .onChange(of: selectedCategory) { oldCategory, newCategory in
            handleCategoryChange(from: oldCategory, to: newCategory)
        }
        .onChange(of: selectedUnitInCategory) { _, newUnit in
            selectedUnit = newUnit
        }
    }
    
    // MARK: - Computed Properties
    
    private var unitsForSelectedCategory: [ExerciseUnit] {
        return unitsByCategory[selectedCategory] ?? []
    }
    
    // MARK: - Helper Methods
    
    private func handleCategoryChange(from oldCategory: UnitCategory, to newCategory: UnitCategory) {
        // When category changes, select the first unit in the new category
        if let firstUnitInNewCategory = unitsByCategory[newCategory]?.first {
            selectedUnitInCategory = firstUnitInNewCategory
            selectedUnit = firstUnitInNewCategory
        }
    }
    
    // MARK: - Static Helper Methods
    
    /// Determine which category a unit belongs to
    static func categoryForUnit(_ unit: ExerciseUnit) -> UnitCategory {
        switch unit {
        case .reps, .steps, .laps:
            return .count
        case .seconds, .minutes, .hours:
            return .time
        case .meters, .yards, .feet, .kilometers, .miles:
            return .distance
        }
    }
    
    /// Get all units for a category
    static func unitsForCategory(_ category: UnitCategory) -> [ExerciseUnit] {
        switch category {
        case .count:
            return [.reps, .steps, .laps]
        case .time:
            return [.seconds, .minutes, .hours]
        case .distance:
            return [.meters, .yards, .feet, .kilometers, .miles]
        }
    }
    
    /// Get a smart default unit for an exercise name
    static func smartDefaultUnit(for exerciseName: String) -> ExerciseUnit {
        let lowercaseName = exerciseName.lowercased()
        
        // Distance-based exercises
        if lowercaseName.contains("run") || lowercaseName.contains("jog") ||
           lowercaseName.contains("sprint") || lowercaseName.contains("dash") {
            return .meters
        }
        
        if lowercaseName.contains("walk") || lowercaseName.contains("step") {
            return .steps
        }
        
        if lowercaseName.contains("swim") || lowercaseName.contains("lap") {
            return .laps
        }
        
        if lowercaseName.contains("bike") || lowercaseName.contains("cycle") ||
           lowercaseName.contains("ride") {
            return .kilometers
        }
        
        // Time-based exercises
        if lowercaseName.contains("plank") || lowercaseName.contains("hold") ||
           lowercaseName.contains("wall sit") || lowercaseName.contains("bridge") {
            return .seconds
        }
        
        if lowercaseName.contains("cardio") || lowercaseName.contains("treadmill") ||
           lowercaseName.contains("elliptical") || lowercaseName.contains("stretch") {
            return .minutes
        }
        
        if lowercaseName.contains("hike") || lowercaseName.contains("trek") {
            return .hours
        }
        
        // Default to reps for most exercises
        return .reps
    }
}

// MARK: - Preview
#Preview {
    struct PreviewWrapper: View {
        @State private var selectedUnit: ExerciseUnit = .reps
        
        var body: some View {
            VStack(spacing: 20) {
                Text("Selected Unit: \(selectedUnit.displayName)")
                    .font(.headline)
                
                CategoryUnitPicker(selectedUnit: $selectedUnit)
                    .padding()
                    .background(Color(.systemGroupedBackground))
                    .cornerRadius(12)
                
                // Test buttons
                HStack {
                    Button("Reps") { selectedUnit = .reps }
                    Button("Minutes") { selectedUnit = .minutes }
                    Button("Meters") { selectedUnit = .meters }
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
    }
    
    return PreviewWrapper()
}

// MARK: - Alternative Compact Version
struct CompactCategoryUnitPicker: View {
    @Binding var selectedUnit: ExerciseUnit
    @State private var showingPicker = false
    
    var body: some View {
        Button(action: {
            showingPicker = true
        }) {
            HStack {
                Image(systemName: CategoryUnitPicker.categoryForUnit(selectedUnit).systemImage)
                    .foregroundColor(.blue)
                
                Text(selectedUnit.displayName.capitalized)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.up.chevron.down")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .sheet(isPresented: $showingPicker) {
            NavigationView {
                CategoryUnitPicker(selectedUnit: $selectedUnit)
                    .navigationTitle("Select Unit")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showingPicker = false
                            }
                        }
                    }
            }
            .presentationDetents([.medium])
        }
    }
}

#Preview("Compact Version") {
    struct CompactPreviewWrapper: View {
        @State private var selectedUnit: ExerciseUnit = .reps
        
        var body: some View {
            VStack(spacing: 20) {
                Text("Selected: \(selectedUnit.displayName)")
                
                CompactCategoryUnitPicker(selectedUnit: $selectedUnit)
                    .padding()
            }
        }
    }
    
    return CompactPreviewWrapper()
}
