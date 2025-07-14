//
//  AIPrompts.swift
//  Fit14
//
//  Created by Jerson on 7/6/25.
//  Enhanced with structured chip data support for essential information
//  Updated to support user-specified start dates
//  Enhanced with explicit start date prioritization
//

import Foundation

struct AIPrompts {
    
    // MARK: - Version Tracking
    static let promptVersion = "2.3.0"
    static let lastUpdated = "2025-07-07"
    
    // MARK: - Enhanced Workout Generation Prompt
        static let workoutGenerationPrompt: String = """
            IMPORTANT: You are generating a workout plan for the Fit14 mobile app. This response will be parsed automatically by the app's code, so EXACT JSON formatting is critical for the app to function properly.
            
            You are a professional fitness trainer AI creating a personalized 14-day workout plan for a Fit14 app user.
            
            USER PROFILE AND STRUCTURED DATA:
            {USER_PROFILE}
            
            USER'S COMPLETE GOALS:
            {USER_GOALS}
            
            START DATE HANDLING (PRIORITY ORDER):
            {EXPLICIT_START_DATE}
            
            WORKOUT PLAN REQUIREMENTS:
            - Create exactly 14 days of workouts optimized for the user's profile
            - Include 1-2 rest or active recovery days throughout the 14-day period
            - Regular workout days must have 4-6 exercises
            - Rest/recovery days should have 1-3 light activities
            - Generate exercises specific to achieve user goals and fitness level
            - Consider the user's available time, location, and equipment
            - Provide specific sets and quantities appropriate for their fitness level
            - Use exercises suitable for their workout location and available equipment
            - ALL QUANTITY VALUES MUST BE POSITIVE INTEGERS (no text like "AsManyAsPossible")
            - For "as many as possible" exercises, use a reasonable number based on their fitness level
            - Make each day different and progressive throughout the 14 days
            - Adapt difficulty and intensity to their experience level
            - Parse the user's goal text for additional constraints like injuries, equipment preferences, or schedule restrictions
            
            FITNESS LEVEL ADAPTATION:
            - Beginner: Focus on form, basic movements, lower intensity, more rest
            - Intermediate: Moderate intensity, compound movements, balanced programming
            - Advanced: Higher intensity, complex movements, sport-specific training
            
            TIME CONSTRAINTS:
            - Respect the user's available workout duration
            - Include warm-up and cool-down in time estimates
            - Provide efficient exercises that maximize results within time limits
            
            LOCATION AND EQUIPMENT CONSIDERATIONS:
            - At home: Bodyweight, minimal equipment exercises
            - At the gym: Full range of equipment, machines, free weights
            - Outdoors: Running, walking, bodyweight, park equipment
            - Flexible: Mix of locations with equipment alternatives
            - Pay attention to equipment mentions in the user's goal text
            
            NATURAL LANGUAGE PROCESSING:
            - Carefully read the user's goal text for mentions of:
              * Injuries or physical limitations (e.g., "bad knee", "shoulder injury")
              * Equipment preferences (e.g., "resistance bands", "no weights")
              * Schedule constraints (e.g., "busy mornings", "weekends only")
              * Specific goals (e.g., "beat my 5K time", "first pull-up")
              * Training preferences (e.g., "hate running", "love swimming")
              * Day-of-week preferences (e.g., "no workouts on Sundays", "gym only on weekdays")
            - Incorporate these natural language details into the workout design
            - Use start date preferences to align rest days and schedule preferences correctly
            
            REST DAY GUIDELINES:
            - Rest days are crucial for recovery and should be included
            - Rest day activities should be 15-30 minutes in duration
            - Label rest days with focus like "Active Recovery", "Rest and Recovery", "Mobility Day"
            - Rest days typically have 1-2 light activities (stretching, walking, etc.)
            - RESPECT day-of-week preferences (e.g., if user wants Sundays off, plan accordingly based on start date)
            
            WORKOUT DAY GUIDELINES:
            - Regular workout days should have 4-6 exercises depending on user's time availability
            - Focus areas can include: Upper Body, Lower Body, Full Body, Cardio, Strength, etc.
            - Workout days should fit within the user's available time
            - Progress difficulty throughout the 14 days
            - CONSIDER day-of-week patterns (e.g., easier workouts on weekends if user mentions time constraints)
            
            CRITICAL UNIT RESTRICTIONS:
            You MUST only use these exact 11 units in your JSON response:
            - "reps" for counted movements (push-ups, squats, etc.)
            - "seconds" for short durations (planks, holds)
            - "minutes" for medium durations (cardio, stretching)
            - "hours" for long durations (hiking, long bike rides)
            - "meters" for short distances (sprints, swimming)
            - "yards" for field/track distances
            - "feet" for short distances (jumping, movement)
            - "kilometers" for medium/long distances (running, cycling)
            - "miles" for long distances (running, walking)
            - "steps" for walking/step counting exercises
            - "laps" for swimming, track running
            
            DO NOT USE: lbs, kg, pounds, kilograms, km, min, sec, reps, repetitions, or any other units.
            DO NOT specify weight amounts - users choose their own weights.
            
            PLAN TITLE REQUIREMENTS:
            - Create a concise "planTitle" that is exactly 7-9 words long
            - The title should capture the essence of the workout plan (goals, focus area, or style)
            - Examples: "Beginner Full Body Strength Building Plan", "Advanced HIIT Fat Loss Challenge", "Home Bodyweight Muscle Building Program"
            - Make it descriptive but brief for use in the Plan History Page
            - Avoid generic titles - make it specific to the user's profile and goals
            
            RESPONSE FORMAT (JSON):
            {
              "startDay": "today",
              "planTitle": "Beginner Full Body Strength Building Plan",
              "summary": "Brief description of the plan tailored to user's profile",
              "days": [
                {
                  "dayNumber": 1,
                  "focus": "Upper body strength (beginner-friendly)",
                  "exercises": [
                    {
                      "name": "Push-ups",
                      "sets": 3,
                      "quantity": 12,
                      "unit": "reps",
                      "instructions": "Keep your body straight, lower chest to floor. Modify on knees if needed."
                    },
                    {
                      "name": "Plank Hold",
                      "sets": 3,
                      "quantity": 30,
                      "unit": "seconds",
                      "instructions": "Keep core tight, body straight. Start with shorter holds if needed."
                    }
                  ]
                },
                {
                  "dayNumber": 7,
                  "focus": "Active Recovery",
                  "exercises": [
                    {
                      "name": "Light Walking",
                      "sets": 1,
                      "quantity": 2000,
                      "unit": "steps",
                      "instructions": "Walk at a comfortable, relaxed pace. Can be done indoors or outdoors."
                    },
                    {
                      "name": "Full Body Stretching",
                      "sets": 1,
                      "quantity": 15,
                      "unit": "minutes",
                      "instructions": "Focus on major muscle groups, hold each stretch 15-30 seconds"
                    }
                  ]
                }
              ]
            }
            
            START DAY FIELD REQUIREMENTS:
            - "startDay" must be either "today" or a date in YYYY-MM-DD format (e.g., "2025-01-13")
            - If user explicitly selected a start date, prioritize that date
            - If user mentions "starting Monday" or similar in text, calculate the appropriate date
            - If user mentions "tomorrow", use "tomorrow" as the value
            - If user mentions "next week" or "next Monday", calculate the specific date
            - If NO start timing is mentioned anywhere, use "today"
            - Consider the current context - if generating on Friday and user says "starting Monday", use the upcoming Monday's date
            
            CRITICAL FOR FIT14 APP - JSON REQUIREMENTS:
            - "startDay" must be present and either "today", "tomorrow", or YYYY-MM-DD format
            - "planTitle" must be present and exactly 7-9 words long
            - "quantity" must ALWAYS be a positive integer (1, 2, 3, etc.) - NEVER text or decimals
            - "sets" must ALWAYS be a positive integer (1, 2, 3, etc.)
            - "unit" must be exactly one of the 11 allowed units listed above
            - NEVER use text values for numeric fields
            - Regular workout days should have 4-6 exercises in the array
            - Rest/recovery days should have 1-3 activities in the array
            - Return exactly 14 days
            - dayNumber must be 1, 2, 3... up to 14
            
            CRITICAL: This response is for the Fit14 app's automatic parsing system. You MUST return ONLY valid JSON with no additional text, no explanations, no markdown formatting, no code blocks, no extra characters. The app will break if you add anything other than pure JSON. Start your response with { and end with }.
            """
    
    // MARK: - Structured Data Conversion Methods
    
    /// Convert UserGoalData's essential information to user profile for AI
    static func buildUserProfile(from goalData: UserGoalData) -> String {
        var profileComponents: [String] = []
        
        // Add start date information first if explicitly set
        if goalData.hasExplicitStartDate {
            profileComponents.append("START DATE: User explicitly selected \(goalData.startDateDisplayText) (\(goalData.startDateForPrompt))")
        }
        
        // Build profile sections based on selected essential chips only
        for chip in goalData.selectedChips {
            guard let selection = chip.selection,
                  let value = selection.effectiveValue else { continue }
            
            switch chip.type {
            case .fitnessLevel:
                profileComponents.append("FITNESS LEVEL: \(value)")
                
            case .sex:
                profileComponents.append("SEX: \(value)")
                
            case .physicalStats:
                profileComponents.append("PHYSICAL STATS: \(value)")
                
            case .timeAvailable:
                profileComponents.append("TIME AVAILABLE: \(value) per workout session")
                
            case .workoutLocation:
                profileComponents.append("WORKOUT LOCATION: \(value)")
                
            case .weeklyFrequency:
                profileComponents.append("WEEKLY FREQUENCY: \(value)")
            }
        }
        
        // If no structured data, provide minimal profile
        if profileComponents.isEmpty || (profileComponents.count == 1 && goalData.hasExplicitStartDate) {
            let baseProfile = "No essential information provided. Please create a balanced, beginner-friendly plan suitable for home workouts. Parse the user's goal text carefully for any additional constraints, equipment, or preferences mentioned naturally."
            
            if goalData.hasExplicitStartDate {
                return "\(profileComponents.first!)\n\n\(baseProfile)"
            } else {
                return baseProfile
            }
        }
        
        return profileComponents.joined(separator: "\n")
    }
    
    /// Build explicit start date instructions for AI prompt
    static func buildStartDateInstructions(from goalData: UserGoalData) -> String {
        if goalData.hasExplicitStartDate {
            return """
            1. PRIORITY: User explicitly selected start date as \(goalData.startDateDisplayText) (\(goalData.startDateForPrompt))
            2. USE THIS EXACT DATE: Set "startDay" to "\(goalData.startDateForPrompt)" in your JSON response
            3. SECONDARY: If the user's goal text mentions additional start date preferences, consider them for scheduling rest days and workout timing, but maintain the explicitly selected start date
            4. FALLBACK: If something goes wrong with the explicit date, default to "today"
            
            IMPORTANT: The user specifically chose \(goalData.startDateDisplayText) as their start date. Honor this choice exactly.
            """
        } else {
            return """
            1. CAREFULLY parse the user's goal text for any mention of when they want to start
            2. Look for phrases like: "starting Monday", "begin next week", "start tomorrow", "starting on [date]"
            3. If NO start date is mentioned in the goal text, default to "today"
            4. Consider day-of-week preferences when interpreting start dates (e.g., if they say "no Sundays" and want to start Monday)
            5. Use YYYY-MM-DD format for specific dates, or "today" for immediate start
            6. The startDay you choose will determine Day 1 of the 14-day plan
            
            Since no explicit start date was selected, rely on natural language processing of the goal text.
            """
        }
    }
    
    // MARK: - Enhanced Prompt Building Methods
    
    /// Build complete prompt with UserGoalData (primary method)
    static func buildWorkoutPrompt(from goalData: UserGoalData) -> String {
        let userProfile = buildUserProfile(from: goalData)
        let userGoals = goalData.completeGoalText
        let startDateInstructions = buildStartDateInstructions(from: goalData)
        
        return workoutGenerationPrompt
            .replacingOccurrences(of: "{USER_PROFILE}", with: userProfile)
            .replacingOccurrences(of: "{USER_GOALS}", with: userGoals)
            .replacingOccurrences(of: "{EXPLICIT_START_DATE}", with: startDateInstructions)
    }
    
    /// Legacy method for backward compatibility - uses just text
    static func workoutPrompt(for userGoals: String) -> String {
        // For backward compatibility, create minimal goal data with just text
        var emptyGoalData = UserGoalData()
        emptyGoalData.updateFreeFormText(userGoals)
        return buildWorkoutPrompt(from: emptyGoalData)
    }
    
    // MARK: - Alternative Prompts (Enhanced)
    
    static let regenerationPromptTemplate: String = """
        You are regenerating a workout plan while preserving user customizations. Follow the same JSON format and unit restrictions as the original workout generation prompt.
        
        USER PROFILE:
        {USER_PROFILE}
        
        Original user goals: {USER_GOALS}
        
        START DATE HANDLING:
        {EXPLICIT_START_DATE}
        
        Use the same 11 allowed units: reps, seconds, minutes, hours, meters, yards, feet, kilometers, miles, steps, laps.
        Include the "startDay" field in your response - follow the start date instructions above.
        
        Create a fresh 14-day plan that's different from the previous generation but maintains the same quality, difficulty level, and structure appropriate for the user's profile. Parse the user's goal text for any naturally mentioned constraints.
        """
    
    static let quickWorkoutPromptTemplate: String = """
        Generate a single day quick workout based on these constraints:
        
        USER PROFILE:
        {USER_PROFILE}
        
        User goals: {USER_GOALS}
        Time available: {TIME_AVAILABLE}
        Equipment: {EQUIPMENT}
        
        START DATE HANDLING:
        {EXPLICIT_START_DATE}
        
        Return only JSON format with the same structure as the 14-day plan, but with just one day.
        Use only the 11 allowed units: reps, seconds, minutes, hours, meters, yards, feet, kilometers, miles, steps, laps.
        Ensure the workout fits within the specified time and uses only available equipment.
        Parse the user's goal text for additional naturally mentioned preferences or constraints.
        """
    
    // MARK: - Enhanced Helper Methods
    
    /// Get regeneration prompt with UserGoalData
    static func regenerationPrompt(from goalData: UserGoalData) -> String {
        let userProfile = buildUserProfile(from: goalData)
        let userGoals = goalData.completeGoalText
        let startDateInstructions = buildStartDateInstructions(from: goalData)
        
        return regenerationPromptTemplate
            .replacingOccurrences(of: "{USER_PROFILE}", with: userProfile)
            .replacingOccurrences(of: "{USER_GOALS}", with: userGoals)
            .replacingOccurrences(of: "{EXPLICIT_START_DATE}", with: startDateInstructions)
    }
    
    /// Legacy regeneration method for backward compatibility
    static func regenerationPrompt(for userGoals: String) -> String {
        var emptyGoalData = UserGoalData()
        emptyGoalData.updateFreeFormText(userGoals)
        return regenerationPrompt(from: emptyGoalData)
    }
    
    /// Get quick workout prompt with UserGoalData
    static func quickWorkoutPrompt(from goalData: UserGoalData, timeAvailable: String, equipment: String) -> String {
        let userProfile = buildUserProfile(from: goalData)
        let userGoals = goalData.completeGoalText
        let startDateInstructions = buildStartDateInstructions(from: goalData)
        
        return quickWorkoutPromptTemplate
            .replacingOccurrences(of: "{USER_PROFILE}", with: userProfile)
            .replacingOccurrences(of: "{USER_GOALS}", with: userGoals)
            .replacingOccurrences(of: "{TIME_AVAILABLE}", with: timeAvailable)
            .replacingOccurrences(of: "{EQUIPMENT}", with: equipment)
            .replacingOccurrences(of: "{EXPLICIT_START_DATE}", with: startDateInstructions)
    }
    
    /// Legacy quick workout method for backward compatibility
    static func quickWorkoutPrompt(for userGoals: String, timeAvailable: String, equipment: String) -> String {
        var emptyGoalData = UserGoalData()
        emptyGoalData.updateFreeFormText(userGoals)
        return quickWorkoutPrompt(from: emptyGoalData, timeAvailable: timeAvailable, equipment: equipment)
    }
    
    // MARK: - Data Quality Assessment
    
    /// Assess the quality of UserGoalData for AI generation
    static func assessDataQuality(_ goalData: UserGoalData) -> DataQualityAssessment {
        var strengths: [String] = []
        var weaknesses: [String] = []
        var suggestions: [String] = []
        
        // Check free-form text quality
        let textLength = goalData.freeFormText.trimmingCharacters(in: .whitespacesAndNewlines).count
        if textLength > 50 {
            strengths.append("Detailed goal description provided")
        } else if textLength > 10 {
            strengths.append("Basic goal description provided")
        } else {
            weaknesses.append("Very brief goal description")
            suggestions.append("Consider adding more detail about what you want to achieve")
        }
        
        // Check critical essential chips
        let criticalChips = goalData.selectedChips.filter { $0.type.importance == .critical }
        if criticalChips.count >= 2 {
            strengths.append("Essential fitness information provided")
        } else {
            weaknesses.append("Missing critical fitness information")
            suggestions.append("Add your fitness level and available workout time")
        }
        
        // Check explicit start date
        if goalData.hasExplicitStartDate {
            strengths.append("Start date explicitly selected (\(goalData.startDateDisplayText))")
        }
        
        // Check for safety information in text
        let lowercaseText = goalData.freeFormText.lowercased()
        if lowercaseText.contains("injury") || lowercaseText.contains("pain") || lowercaseText.contains("hurt") {
            strengths.append("Safety considerations mentioned")
        }
        
        // Check for equipment mentions in text
        if lowercaseText.contains("equipment") || lowercaseText.contains("weights") || lowercaseText.contains("bands") {
            strengths.append("Equipment preferences specified")
        }
        
        // Check for timeline mentions in text
        if lowercaseText.contains("week") || lowercaseText.contains("month") || lowercaseText.contains("day") {
            strengths.append("Timeline considerations included")
        } else {
            suggestions.append("Consider mentioning your timeline (2 weeks recommended)")
        }
        
        // Check for start date mentions in text (if no explicit date)
        if !goalData.hasExplicitStartDate {
            if lowercaseText.contains("starting") || lowercaseText.contains("begin") || lowercaseText.contains("start") {
                strengths.append("Start timing preferences mentioned in text")
            } else {
                suggestions.append("Consider using the start date picker for precise timing")
            }
        }
        
        // Overall completeness
        let completeness = goalData.completenessScore
        let qualityScore: DataQualityScore
        
        if completeness >= 0.8 {
            qualityScore = .excellent
        } else if completeness >= 0.6 {
            qualityScore = .good
        } else if completeness >= 0.4 {
            qualityScore = .fair
        } else {
            qualityScore = .poor
        }
        
        return DataQualityAssessment(
            score: qualityScore,
            completenessPercentage: Int(completeness * 100),
            strengths: strengths,
            weaknesses: weaknesses,
            suggestions: suggestions,
            isSufficient: goalData.isSufficientForAI
        )
    }
    
    // MARK: - 2-Week Focus Methods
    
    /// Get messaging that emphasizes 2-week goals
    static func getTwoWeekFocusMessage() -> String {
        return """
        🎯 Why 2 weeks? Research shows that 2-week goals are:
        • Achievable and motivating
        • Long enough to see real progress
        • Short enough to maintain focus
        • Perfect for building lasting habits
        
        After completing your 2-week plan, you can start a new challenge with updated goals!
        """
    }
    
    /// Get success message for completed 2-week plans
    static func getTwoWeekCompletionMessage() -> String {
        return """
        🎉 Congratulations on completing your 2-week fitness challenge!
        
        You've proven that you can stick to a plan and make real progress. 
        
        Ready for your next 2-week challenge? Your body has adapted and you're ready to level up!
        """
    }
    
    /// Get next challenge suggestions based on completed plan
    static func getNextChallengeSuggestions(from completedGoalData: UserGoalData) -> [String] {
        var suggestions: [String] = []
        
        // Base suggestion
        suggestions.append("Level up your current routine with increased intensity")
        
        // Specific suggestions based on previous choices
        if let fitnessLevel = completedGoalData.getChip(.fitnessLevel)?.selection?.effectiveValue {
            if fitnessLevel == "beginner" {
                suggestions.append("Progress to intermediate-level exercises")
            } else if fitnessLevel == "intermediate" {
                suggestions.append("Try advanced variations and new challenges")
            }
        }
        
        if let location = completedGoalData.getChip(.workoutLocation)?.selection?.effectiveValue {
            if location.contains("home") {
                suggestions.append("Try outdoor workouts or explore gym options")
            } else if location.contains("gym") {
                suggestions.append("Mix in some home workouts for variety")
            }
        }
        
        // Generic progression suggestions
        suggestions.append("Focus on a specific area like strength or cardio")
        suggestions.append("Try a completely different workout style")
        suggestions.append("Set a new 2-week goal to continue your progress")
        
        return suggestions
    }
    
    // MARK: - Validation (Unchanged)
    
    /// List of all allowed units for validation
    static let allowedUnits: Set<String> = [
        "reps", "seconds", "minutes", "hours",
        "meters", "yards", "feet", "kilometers", "miles",
        "steps", "laps"
    ]
    
    /// Check if a unit is valid
    static func isValidUnit(_ unit: String) -> Bool {
        return allowedUnits.contains(unit.lowercased())
    }
    
    // MARK: - Debugging (Enhanced)
    
    /// Get enhanced debug information
    static var debugInfo: String {
        return """
        Enhanced AI Prompts Debug Info:
        Prompt Version: \(promptVersion)
        Last Updated: \(lastUpdated)
        
        Features:
        - UserGoalData integration
        - Essential chip data support
        - Natural language processing for constraints
        - Enhanced user profiling
        - 2-week goal focus
        - Data quality assessment
        - EXPLICIT START DATE PRIORITIZATION
        - Start date parsing and handling
        - Backward compatibility maintained
        
        Allowed Units: \(allowedUnits.sorted().joined(separator: ", "))
        
        Supported Essential Chip Types:
        \(ChipType.essentialTypes.map { $0.displayTitle }.joined(separator: ", "))
        
        Natural Language Processing:
        - Automatically detects injuries/limitations in goal text
        - Identifies equipment preferences and constraints
        - Recognizes schedule restrictions
        - Processes specific performance goals and timelines
        - Parses start date preferences and timing
        - PRIORITIZES explicit start date selections over text parsing
        """
    }
    
    /// Debug method to show how UserGoalData will be converted to prompt
    static func debugPromptGeneration(from goalData: UserGoalData) -> String {
        let profile = buildUserProfile(from: goalData)
        let goals = goalData.completeGoalText
        let startDateInstructions = buildStartDateInstructions(from: goalData)
        let quality = assessDataQuality(goalData)
        
        return """
        === USER GOAL DATA DEBUG ===
        
        Free-form text: "\(goalData.freeFormText)"
        Selected essential chips: \(goalData.selectedChips.count)
        Explicit start date: \(goalData.hasExplicitStartDate ? goalData.startDateDisplayText : "None")
        Completeness: \(Int(goalData.completenessScore * 100))%
        Quality: \(quality.score.rawValue)
        
        === GENERATED PROFILE ===
        \(profile)
        
        === COMPLETE GOALS ===
        \(goals)
        
        === START DATE INSTRUCTIONS ===
        \(startDateInstructions)
        
        === QUALITY ASSESSMENT ===
        Sufficient for AI: \(goalData.isSufficientForAI)
        Strengths: \(quality.strengths.joined(separator: ", "))
        Suggestions: \(quality.suggestions.joined(separator: ", "))
        """
    }
}

// MARK: - Supporting Models

enum DataQualityScore: String, CaseIterable {
    case excellent = "Excellent"
    case good = "Good"
    case fair = "Fair"
    case poor = "Poor"
    
    var emoji: String {
        switch self {
        case .excellent: return "🌟"
        case .good: return "✅"
        case .fair: return "⚠️"
        case .poor: return "❌"
        }
    }
}

struct DataQualityAssessment {
    let score: DataQualityScore
    let completenessPercentage: Int
    let strengths: [String]
    let weaknesses: [String]
    let suggestions: [String]
    let isSufficient: Bool
    
    var displayMessage: String {
        return "\(score.emoji) \(score.rawValue) (\(completenessPercentage)% complete)"
    }
}
