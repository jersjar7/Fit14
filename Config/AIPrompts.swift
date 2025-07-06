//
//  AIPrompts.swift
//  Fit14
//
//  Created by Jerson on 7/6/25.
//

import Foundation

struct AIPrompts {
    
    // MARK: - Version Tracking
    static let promptVersion = "1.2.0"
    static let lastUpdated = "2025-07-06"
    
    // MARK: - Workout Generation Prompt
    static let workoutGenerationPrompt: String = """
        IMPORTANT: You are generating a workout plan for the Fit14 mobile app. This response will be parsed automatically by the app's code, so EXACT JSON formatting is critical for the app to function properly.
        
        You are a professional fitness trainer AI creating a personalized 14-day workout plan for a Fit14 app user.
        
        USER GOALS: {USER_GOALS}
        
        WORKOUT PLAN REQUIREMENTS:
        - Create exactly 14 days of workouts
        - Include 1-2 rest or active recovery days throughout the 14-day period
        - Regular workout days must have 4-6 exercises
        - Rest/recovery days should have 1-3 light activities
        - Generate exercises specific to achieve user goals
        - Consider the user's experience level, schedule, and goals
        - Provide specific sets and quantities for each exercise
        - Use exercises appropriate for the user's available facilities (home, gym, etc.)
        - ALL QUANTITY VALUES MUST BE POSITIVE INTEGERS (no text like "AsManyAsPossible")
        - For "as many as possible" exercises, use a reasonable number like 8-15 reps
        - Make each day different and progressive throughout the 14 days
        
        REST DAY GUIDELINES:
        - Rest days are important for recovery and should be included
        - Rest day activities should be 15-30 minutes in duration
        - Label rest days with focus like "Active Recovery", "Rest and Recovery", "Mobility Day", etc.
        - Rest days typically have 1-2 activities
        
        WORKOUT DAY GUIDELINES:
        - Regular workout days should have 4-6 exercises
        - Focus areas can include: Upper Body, Lower Body, Full Body, Cardio, Strength, etc.
        - Workout days are typically 30-60 minutes total
        
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
        
        RESPONSE FORMAT (JSON):
        {
          "summary": "Brief description of the plan",
          "days": [
            {
              "dayNumber": 1,
              "focus": "Upper body strength",
              "exercises": [
                {
                  "name": "Push-ups",
                  "sets": 3,
                  "quantity": 12,
                  "unit": "reps",
                  "instructions": "Keep your body straight, lower chest to floor"
                },
                {
                  "name": "Plank Hold",
                  "sets": 3,
                  "quantity": 30,
                  "unit": "seconds",
                  "instructions": "Keep core tight, body straight"
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
                  "instructions": "Walk at a comfortable, relaxed pace"
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
        
        CRITICAL FOR FIT14 APP - JSON REQUIREMENTS:
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
    
    // MARK: - Alternative Prompts (for future use)
    
    static let regenerationPrompt: String = """
        You are regenerating a workout plan while preserving user customizations. Follow the same JSON format and unit restrictions as the original workout generation prompt.
        
        Original user goals: {USER_GOALS}
        
        Use the same 11 allowed units: reps, seconds, minutes, hours, meters, yards, feet, kilometers, miles, steps, laps.
        
        Create a fresh 14-day plan that's different from the previous generation but maintains the same quality and structure.
        """
    
    static let quickWorkoutPrompt: String = """
        Generate a single day quick workout based on these constraints:
        - User goals: {USER_GOALS}
        - Time available: {TIME_AVAILABLE}
        - Equipment: {EQUIPMENT}
        
        Return only JSON format with the same structure as the 14-day plan, but with just one day.
        Use only the 11 allowed units: reps, seconds, minutes, hours, meters, yards, feet, kilometers, miles, steps, laps.
        """
    
    // MARK: - Helper Methods
    
    /// Replace placeholder with actual user goals
    static func workoutPrompt(for userGoals: String) -> String {
        return workoutGenerationPrompt.replacingOccurrences(of: "{USER_GOALS}", with: userGoals)
    }
    
    /// Get regeneration prompt with user goals
    static func regenerationPrompt(for userGoals: String) -> String {
        return regenerationPrompt.replacingOccurrences(of: "{USER_GOALS}", with: userGoals)
    }
    
    /// Get quick workout prompt with parameters
    static func quickWorkoutPrompt(for userGoals: String, timeAvailable: String, equipment: String) -> String {
        return quickWorkoutPrompt
            .replacingOccurrences(of: "{USER_GOALS}", with: userGoals)
            .replacingOccurrences(of: "{TIME_AVAILABLE}", with: timeAvailable)
            .replacingOccurrences(of: "{EQUIPMENT}", with: equipment)
    }
    
    // MARK: - Validation
    
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
    
    // MARK: - Debugging
    
    /// Get prompt info for debugging
    static var debugInfo: String {
        return """
        Prompt Version: \(promptVersion)
        Last Updated: \(lastUpdated)
        Allowed Units: \(allowedUnits.sorted().joined(separator: ", "))
        """
    }
}
