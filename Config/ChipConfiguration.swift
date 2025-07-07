//
//  ChipConfiguration.swift
//  Fit14
//
//  Created by Jerson on 7/6/25.
//

import Foundation

// MARK: - Chip Configuration Manager

/// Central configuration manager for all chip types and their options
struct ChipConfiguration {
    
    // MARK: - Universal Chip Options
    
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
        ChipOption(value: "flexible", displayText: "Flexible schedule", description: "Adapt based on availability"),
        ChipOption.customInput
    ]
    
    // MARK: - Contextual Chip Options
    
    /// Timeline options - emphasizes Fit14's 2-week philosophy
    static let timelineOptions: [ChipOption] = [
        ChipOption(value: "2 weeks", displayText: "2 weeks (recommended)", description: "Perfect for building habits and seeing initial results"),
        ChipOption(value: "1 month", displayText: "1 month", description: "Extended goal with multiple milestones"),
        ChipOption(value: "3 months", displayText: "3 months", description: "Long-term transformation goal"),
        ChipOption(value: "6+ months", displayText: "6+ months", description: "Major lifestyle change commitment"),
        ChipOption.customInput
    ]
    
    /// Common injury/limitation options - for safety
    static let limitationsOptions: [ChipOption] = [
        ChipOption(value: "lower back pain", displayText: "Lower back pain", description: "Avoid exercises that strain the lower back"),
        ChipOption(value: "knee problems", displayText: "Knee problems", description: "Low-impact alternatives for joint protection"),
        ChipOption(value: "shoulder injury", displayText: "Shoulder injury", description: "Modified upper body movements"),
        ChipOption(value: "ankle/foot issues", displayText: "Ankle/foot issues", description: "Limited weight-bearing exercises"),
        ChipOption(value: "wrist/elbow pain", displayText: "Wrist/elbow pain", description: "Avoid high-impact arm exercises"),
        ChipOption(value: "recent surgery", displayText: "Recent surgery", description: "Following medical restrictions"),
        ChipOption(value: "chronic condition", displayText: "Chronic condition", description: "Working with ongoing health considerations"),
        ChipOption.customInput
    ]
    
    /// Schedule restriction options - for workout timing
    static let scheduleOptions: [ChipOption] = [
        ChipOption(value: "early morning only", displayText: "Early morning only", description: "Before work/commitments"),
        ChipOption(value: "lunch break workouts", displayText: "Lunch break workouts", description: "Quick midday sessions"),
        ChipOption(value: "evening after work", displayText: "Evening after work", description: "End-of-day fitness routine"),
        ChipOption(value: "weekends only", displayText: "Weekends only", description: "Saturday and Sunday focused"),
        ChipOption(value: "flexible weekdays", displayText: "Flexible weekdays", description: "Adapt to daily schedule"),
        ChipOption(value: "avoid Sundays", displayText: "Avoid Sundays", description: "Sunday rest day preference"),
        ChipOption.customInput
    ]
    
    /// Equipment availability options - affects exercise selection
    static let equipmentOptions: [ChipOption] = [
        ChipOption(value: "no equipment", displayText: "No equipment", description: "Bodyweight exercises only"),
        ChipOption(value: "basic home gym", displayText: "Basic home gym", description: "Dumbbells, resistance bands, mat"),
        ChipOption(value: "full home gym", displayText: "Full home gym", description: "Weights, machines, cardio equipment"),
        ChipOption(value: "gym membership", displayText: "Gym membership", description: "Access to all gym equipment"),
        ChipOption(value: "outdoor gear", displayText: "Outdoor gear", description: "Running shoes, bike, hiking equipment"),
        ChipOption(value: "resistance bands only", displayText: "Resistance bands only", description: "Portable, versatile equipment"),
        ChipOption(value: "dumbbells only", displayText: "Dumbbells only", description: "Adjustable or fixed weight dumbbells"),
        ChipOption.customInput
    ]
    
    /// Previous experience options - helps calibrate expectations
    static let experienceOptions: [ChipOption] = [
        ChipOption(value: "complete beginner", displayText: "Complete beginner", description: "Never exercised regularly before"),
        ChipOption(value: "used to be active", displayText: "Used to be active", description: "Was fit in the past, returning to fitness"),
        ChipOption(value: "some experience", displayText: "Some experience", description: "Occasional workouts, basic knowledge"),
        ChipOption(value: "former athlete", displayText: "Former athlete", description: "Competitive sports background"),
        ChipOption(value: "gym regular", displayText: "Gym regular", description: "Consistent gym-goer for months/years"),
        ChipOption(value: "personal trainer", displayText: "Personal trainer background", description: "Professional fitness knowledge"),
        ChipOption.customInput
    ]
    
    /// Exercise preference options - for enjoyment and adherence
    static let preferencesOptions: [ChipOption] = [
        ChipOption(value: "love cardio", displayText: "Love cardio", description: "Running, cycling, high-energy workouts"),
        ChipOption(value: "prefer strength training", displayText: "Prefer strength training", description: "Weight lifting, resistance exercises"),
        ChipOption(value: "enjoy yoga/stretching", displayText: "Enjoy yoga/stretching", description: "Flexibility and mindfulness focus"),
        ChipOption(value: "like variety", displayText: "Like variety", description: "Mix of different exercise types"),
        ChipOption(value: "hate running", displayText: "Hate running", description: "Avoid traditional cardio activities"),
        ChipOption(value: "no gym intimidation", displayText: "Gym intimidation", description: "Prefer home or outdoor workouts"),
        ChipOption(value: "team sports", displayText: "Team sports", description: "Social, competitive activities"),
        ChipOption(value: "solo workouts", displayText: "Solo workouts", description: "Independent, self-motivated training"),
        ChipOption.customInput
    ]
    
    // MARK: - Chip Factory Methods
    
    /// Create a default ChipData instance for any chip type
    static func createChipData(for chipType: ChipType) -> ChipData {
        let options = getOptions(for: chipType)
        return ChipData(type: chipType, options: options)
    }
    
    /// Get all available options for a specific chip type
    static func getOptions(for chipType: ChipType) -> [ChipOption] {
        switch chipType {
        // Universal chips
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
            
        // Contextual chips
        case .timeline:
            return timelineOptions
        case .limitations:
            return limitationsOptions
        case .schedule:
            return scheduleOptions
        case .equipment:
            return equipmentOptions
        case .experience:
            return experienceOptions
        case .preferences:
            return preferencesOptions
        }
    }
    
    /// Get the default/recommended option for a chip type
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
        case .timeline:
            return timelineOptions.first { $0.value == "2 weeks" } // Emphasize Fit14's philosophy
        default:
            return getOptions(for: chipType).first
        }
    }
    
    // MARK: - Complete Chip Set Factory
    
    /// Create a complete set of all chips with default configurations
    static func createAllChips() -> [ChipType: ChipData] {
        var chips: [ChipType: ChipData] = [:]
        
        for chipType in ChipType.allCases {
            chips[chipType] = createChipData(for: chipType)
        }
        
        return chips
    }
    
    /// Create only universal chips (always visible)
    static func createUniversalChips() -> [ChipType: ChipData] {
        var chips: [ChipType: ChipData] = [:]
        
        for chipType in ChipType.universalTypes {
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
            break // Most chips don't need special validation
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
    
    /// Get display configuration for chip types
    static func getDisplayConfig(for chipType: ChipType) -> ChipDisplayConfig {
        switch chipType {
        case .fitnessLevel:
            return ChipDisplayConfig(
                showInCompactMode: true,
                allowMultipleSelection: false,
                sortOrder: 1,
                animationDelay: 0.0
            )
        case .timeAvailable:
            return ChipDisplayConfig(
                showInCompactMode: true,
                allowMultipleSelection: false,
                sortOrder: 2,
                animationDelay: 0.1
            )
        case .timeline:
            return ChipDisplayConfig(
                showInCompactMode: false,
                allowMultipleSelection: false,
                sortOrder: 10,
                animationDelay: 0.3,
                highlightRecommended: true
            )
        case .limitations:
            return ChipDisplayConfig(
                showInCompactMode: false,
                allowMultipleSelection: true,
                sortOrder: 15,
                animationDelay: 0.2,
                requiresAttention: true
            )
        default:
            return ChipDisplayConfig(
                showInCompactMode: false,
                allowMultipleSelection: false,
                sortOrder: chipType.importance.rawValue,
                animationDelay: 0.2
            )
        }
    }
    
    // MARK: - Smart Defaults
    
    /// Get smart default selections based on common patterns
    static func getSmartDefaults(for text: String) -> [ChipType: ChipOption] {
        var defaults: [ChipType: ChipOption] = [:]
        let lowercasedText = text.lowercased()
        
        // Timeline smart defaults
        if lowercasedText.contains("2 weeks") || lowercasedText.contains("quickly") {
            defaults[.timeline] = timelineOptions.first { $0.value == "2 weeks" }
        }
        
        // Fitness level smart defaults
        if lowercasedText.contains("beginner") || lowercasedText.contains("new to") {
            defaults[.fitnessLevel] = fitnessLevelOptions.first { $0.value == "beginner" }
        } else if lowercasedText.contains("experienced") || lowercasedText.contains("advanced") {
            defaults[.fitnessLevel] = fitnessLevelOptions.first { $0.value == "advanced" }
        }
        
        // Location smart defaults
        if lowercasedText.contains("home") || lowercasedText.contains("no gym") {
            defaults[.workoutLocation] = workoutLocationOptions.first { $0.value == "at home" }
        } else if lowercasedText.contains("gym") {
            defaults[.workoutLocation] = workoutLocationOptions.first { $0.value == "at the gym" }
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
                    "sortOrder": displayConfig.sortOrder
                ]
            ]
        }
        
        return ChipConfigurationExport(
            version: "1.0",
            generatedAt: Date(),
            chipConfigurations: chipConfigs
        )
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
