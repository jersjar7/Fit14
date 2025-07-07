//
//  ChipConfiguration.swift
//  Fit14
//
//  Created by Jerson on 7/6/25.
//  Updated for essential chips only approach
//

import Foundation

// MARK: - Chip Configuration Manager

/// Central configuration manager for essential chip types and their options
struct ChipConfiguration {
    
    // MARK: - Essential Chip Options
    
    /// Fitness level options - critical for AI plan generation
    static let fitnessLevelOptions: [ChipOption] = [
        ChipOption(value: "beginner", displayText: "Beginner", description: "New to fitness or returning after a long break"),
        ChipOption(value: "intermediate", displayText: "Intermediate", description: "Exercise regularly, comfortable with basic movements"),
        ChipOption(value: "advanced", displayText: "Advanced", description: "Very experienced, ready for challenging workouts")
    ]
    
    /// Biological sex options - for exercise and calorie planning
    static let sexOptions: [ChipOption] = [
        ChipOption(value: "male", displayText: "Male"),
        ChipOption(value: "female", displayText: "Female"),
        ChipOption(value: "prefer not to say", displayText: "Prefer not to say")
    ]
    
    /// Physical stats options - height and weight for personalization
    static let physicalStatsOptions: [ChipOption] = [
        ChipOption(value: "custom", displayText: "Enter height & weight", description: "Tap to enter your measurements", isCustom: true)
    ]
    
    /// Time available per workout session - critical for plan structure
    static let timeAvailableOptions: [ChipOption] = [
        ChipOption(value: "15-30 minutes", displayText: "15-30 minutes", description: "Quick, efficient workouts"),
        ChipOption(value: "30-45 minutes", displayText: "30-45 minutes", description: "Standard workout duration"),
        ChipOption(value: "45-60 minutes", displayText: "45-60 minutes", description: "Longer, comprehensive sessions"),
        ChipOption(value: "60+ minutes", displayText: "60+ minutes", description: "Extended training sessions"),
        ChipOption.customInput
    ]
    
    /// Workout location options - affects equipment availability
    static let workoutLocationOptions: [ChipOption] = [
        ChipOption(value: "at home", displayText: "At Home", description: "Bodyweight and minimal equipment exercises"),
        ChipOption(value: "at the gym", displayText: "At the Gym", description: "Full equipment access"),
        ChipOption(value: "outdoors", displayText: "Outdoors", description: "Running, hiking, outdoor activities"),
        ChipOption(value: "home and gym", displayText: "Home & Gym", description: "Flexible between locations"),
        ChipOption.customInput
    ]
    
    /// Weekly frequency options - for rest day planning
    static let weeklyFrequencyOptions: [ChipOption] = [
        ChipOption(value: "3 days", displayText: "3 days per week", description: "Balanced approach with recovery time"),
        ChipOption(value: "4-5 days", displayText: "4-5 days per week", description: "Regular, consistent training"),
        ChipOption(value: "6+ days", displayText: "6+ days per week", description: "High-frequency training"),
        ChipOption(value: "daily except Sunday", displayText: "Daily except Sunday", description: "6 days per week with Sunday rest"),
        ChipOption.customInput
    ]
    
    // MARK: - Chip Factory Methods
    
    /// Create a default ChipData instance for any essential chip type
    static func createChipData(for chipType: ChipType) -> ChipData {
        let options = getOptions(for: chipType)
        return ChipData(type: chipType, options: options)
    }
    
    /// Get all available options for a specific essential chip type
    static func getOptions(for chipType: ChipType) -> [ChipOption] {
        switch chipType {
        case .fitnessLevel:
            return fitnessLevelOptions
        case .sex:
            return sexOptions
        case .physicalStats:
            return physicalStatsOptions
        case .timeAvailable:
            return timeAvailableOptions
        case .workoutLocation:
            return workoutLocationOptions
        case .weeklyFrequency:
            return weeklyFrequencyOptions
        }
    }
    
    /// Get the default/recommended option for an essential chip type
    static func getDefaultOption(for chipType: ChipType) -> ChipOption? {
        switch chipType {
        case .fitnessLevel:
            return fitnessLevelOptions.first { $0.value == "beginner" }
        case .timeAvailable:
            return timeAvailableOptions.first { $0.value == "30-45 minutes" }
        case .workoutLocation:
            return workoutLocationOptions.first { $0.value == "at home" }
        case .weeklyFrequency:
            return weeklyFrequencyOptions.first { $0.value == "3 days" }
        default:
            return getOptions(for: chipType).first
        }
    }
    
    // MARK: - Complete Chip Set Factory
    
    /// Create a complete set of all essential chips with default configurations
    static func createAllChips() -> [ChipType: ChipData] {
        var chips: [ChipType: ChipData] = [:]
        
        for chipType in ChipType.allCases {
            chips[chipType] = createChipData(for: chipType)
        }
        
        return chips
    }
    
    /// Create essential chips (all chips are essential now)
    static func createEssentialChips() -> [ChipType: ChipData] {
        var chips: [ChipType: ChipData] = [:]
        
        for chipType in ChipType.essentialTypes {
            var chipData = createChipData(for: chipType)
            chipData.isVisible = true
            chips[chipType] = chipData
        }
        
        return chips
    }
    
    // MARK: - Validation and Rules
    
    /// Validate that a chip selection is appropriate
    static func validateSelection(_ selection: ChipSelection) -> ValidationResult {
        guard let value = selection.effectiveValue else {
            return ValidationResult(isValid: false, errors: ["No value selected"])
        }
        
        var errors: [String] = []
        
        // Type-specific validation
        switch selection.chipType {
        case .physicalStats:
            if selection.customValue != nil {
                errors.append(contentsOf: validatePhysicalStats(selection.customValue ?? ""))
            }
        case .timeAvailable:
            if selection.customValue != nil {
                errors.append(contentsOf: validateTimeValue(selection.customValue ?? ""))
            }
        default:
            break // Most essential chips don't need special validation
        }
        
        return ValidationResult(isValid: errors.isEmpty, errors: errors)
    }
    
    private static func validatePhysicalStats(_ input: String) -> [String] {
        var errors: [String] = []
        
        // Simple validation for height/weight input
        let lowercased = input.lowercased()
        let hasHeight = lowercased.contains("ft") || lowercased.contains("cm") || lowercased.contains("'")
        let hasWeight = lowercased.contains("lbs") || lowercased.contains("kg") || lowercased.contains("pounds")
        
        if !hasHeight && !hasWeight {
            errors.append("Please include both height and weight (e.g., '5'6\", 140 lbs')")
        }
        
        return errors
    }
    
    private static func validateTimeValue(_ input: String) -> [String] {
        var errors: [String] = []
        
        let lowercased = input.lowercased()
        let hasTimeUnit = lowercased.contains("min") || lowercased.contains("hour") || lowercased.contains("hr")
        
        if !hasTimeUnit {
            errors.append("Please specify time units (e.g., '45 minutes', '1 hour')")
        }
        
        return errors
    }
    
    // MARK: - Display Configuration
    
    /// Get display configuration for essential chip types
    static func getDisplayConfig(for chipType: ChipType) -> ChipDisplayConfig {
        switch chipType {
        case .fitnessLevel:
            return ChipDisplayConfig(
                showInCompactMode: true,
                allowMultipleSelection: false,
                sortOrder: 1,
                animationDelay: 0.0,
                requiresAttention: true  // Critical for safety
            )
        case .timeAvailable:
            return ChipDisplayConfig(
                showInCompactMode: true,
                allowMultipleSelection: false,
                sortOrder: 2,
                animationDelay: 0.1,
                requiresAttention: true  // Critical for planning
            )
        case .sex:
            return ChipDisplayConfig(
                showInCompactMode: true,
                allowMultipleSelection: false,
                sortOrder: 3,
                animationDelay: 0.15
            )
        case .workoutLocation:
            return ChipDisplayConfig(
                showInCompactMode: true,
                allowMultipleSelection: false,
                sortOrder: 4,
                animationDelay: 0.2
            )
        case .physicalStats:
            return ChipDisplayConfig(
                showInCompactMode: false,
                allowMultipleSelection: false,
                sortOrder: 5,
                animationDelay: 0.25
            )
        case .weeklyFrequency:
            return ChipDisplayConfig(
                showInCompactMode: false,
                allowMultipleSelection: false,
                sortOrder: 6,
                animationDelay: 0.3
            )
        }
    }
    
    // MARK: - Smart Defaults
    
    /// Get smart default selections based on common patterns in goal text
    static func getSmartDefaults(for text: String) -> [ChipType: ChipOption] {
        var defaults: [ChipType: ChipOption] = [:]
        let lowercasedText = text.lowercased()
        
        // Fitness level smart defaults
        if lowercasedText.contains("beginner") || lowercasedText.contains("new to") || lowercasedText.contains("never") {
            defaults[.fitnessLevel] = fitnessLevelOptions.first { $0.value == "beginner" }
        } else if lowercasedText.contains("experienced") || lowercasedText.contains("advanced") || lowercasedText.contains("athlete") {
            defaults[.fitnessLevel] = fitnessLevelOptions.first { $0.value == "advanced" }
        } else if lowercasedText.contains("regular") || lowercasedText.contains("intermediate") {
            defaults[.fitnessLevel] = fitnessLevelOptions.first { $0.value == "intermediate" }
        }
        
        // Location smart defaults
        if lowercasedText.contains("home") || lowercasedText.contains("no gym") || lowercasedText.contains("apartment") {
            defaults[.workoutLocation] = workoutLocationOptions.first { $0.value == "at home" }
        } else if lowercasedText.contains("gym") || lowercasedText.contains("fitness center") {
            defaults[.workoutLocation] = workoutLocationOptions.first { $0.value == "at the gym" }
        } else if lowercasedText.contains("outdoor") || lowercasedText.contains("running") || lowercasedText.contains("hiking") {
            defaults[.workoutLocation] = workoutLocationOptions.first { $0.value == "outdoors" }
        }
        
        // Time availability smart defaults
        if lowercasedText.contains("quick") || lowercasedText.contains("15") || lowercasedText.contains("20") {
            defaults[.timeAvailable] = timeAvailableOptions.first { $0.value == "15-30 minutes" }
        } else if lowercasedText.contains("45") || lowercasedText.contains("hour") {
            defaults[.timeAvailable] = timeAvailableOptions.first { $0.value == "45-60 minutes" }
        } else if lowercasedText.contains("30") {
            defaults[.timeAvailable] = timeAvailableOptions.first { $0.value == "30-45 minutes" }
        }
        
        // Frequency smart defaults
        if lowercasedText.contains("every day") || lowercasedText.contains("daily") {
            defaults[.weeklyFrequency] = weeklyFrequencyOptions.first { $0.value == "6+ days" }
        } else if lowercasedText.contains("3 times") || lowercasedText.contains("three times") {
            defaults[.weeklyFrequency] = weeklyFrequencyOptions.first { $0.value == "3 days" }
        }
        
        return defaults
    }
    
    // MARK: - Export/Import Configuration
    
    /// Export chip configuration for debugging or customization
    static func exportConfiguration() -> ChipConfigurationExport {
        var chipConfigs: [String: [String: Any]] = [:]
        
        for chipType in ChipType.allCases {
            let options = getOptions(for: chipType)
            let displayConfig = getDisplayConfig(for: chipType)
            
            chipConfigs[chipType.rawValue] = [
                "displayTitle": chipType.displayTitle,
                "importance": chipType.importance.rawValue,
                "category": chipType.category.rawValue,
                "options": options.map { ["value": $0.value, "displayText": $0.displayText] },
                "displayConfig": [
                    "showInCompactMode": displayConfig.showInCompactMode,
                    "allowMultipleSelection": displayConfig.allowMultipleSelection,
                    "sortOrder": displayConfig.sortOrder,
                    "requiresAttention": displayConfig.requiresAttention
                ]
            ]
        }
        
        return ChipConfigurationExport(
            version: "2.0",
            generatedAt: Date(),
            chipConfigurations: chipConfigs
        )
    }
    
    // MARK: - Helper Methods
    
    /// Check if a chip type requires immediate attention
    static func requiresImmediateAttention(_ chipType: ChipType) -> Bool {
        return chipType.importance == .critical
    }
    
    /// Get minimum required chips for AI generation
    static func getMinimumRequiredChips() -> [ChipType] {
        return ChipType.criticalTypes
    }
    
    /// Get all essential chip types in recommended order
    static func getRecommendedOrder() -> [ChipType] {
        return ChipType.sortedByImportance
    }
}

// MARK: - Supporting Models

struct ValidationResult {
    let isValid: Bool
    let errors: [String]
    
    var errorMessage: String? {
        return errors.isEmpty ? nil : errors.joined(separator: ". ")
    }
}

struct ChipDisplayConfig {
    let showInCompactMode: Bool
    let allowMultipleSelection: Bool
    let sortOrder: Int
    let animationDelay: TimeInterval
    let highlightRecommended: Bool
    let requiresAttention: Bool
    
    init(showInCompactMode: Bool = false, allowMultipleSelection: Bool = false, sortOrder: Int = 50, animationDelay: TimeInterval = 0.2, highlightRecommended: Bool = false, requiresAttention: Bool = false) {
        self.showInCompactMode = showInCompactMode
        self.allowMultipleSelection = allowMultipleSelection
        self.sortOrder = sortOrder
        self.animationDelay = animationDelay
        self.highlightRecommended = highlightRecommended
        self.requiresAttention = requiresAttention
    }
}

struct ChipConfigurationExport: Codable {
    let version: String
    let generatedAt: Date
    let chipConfigurations: [String: [String: Any]]
    
    enum CodingKeys: String, CodingKey {
        case version, generatedAt, chipConfigurations
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
        try container.encode(generatedAt, forKey: .generatedAt)
        // Note: chipConfigurations would need custom encoding for [String: Any]
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decode(String.self, forKey: .version)
        generatedAt = try container.decode(Date.self, forKey: .generatedAt)
        chipConfigurations = [:] // Would need custom decoding
    }
    
    init(version: String, generatedAt: Date, chipConfigurations: [String: [String: Any]]) {
        self.version = version
        self.generatedAt = generatedAt
        self.chipConfigurations = chipConfigurations
    }
}
