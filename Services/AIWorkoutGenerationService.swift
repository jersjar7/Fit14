//
//  AIWorkoutGenerationService.swift
//  Fit14
//
//  Created by Jerson on 7/3/25.
//  Updated to use Google Gemini API with flexible rest day support
//

import Foundation

// MARK: - Gemini API Models
struct GeminiRequest: Codable {
    let contents: [GeminiContent]
    let generationConfig: GeminiGenerationConfig?
    
    init(prompt: String) {
        self.contents = [GeminiContent(parts: [GeminiPart(text: prompt)])]
        self.generationConfig = GeminiGenerationConfig(
            temperature: 0.7,
            topK: 40,
            topP: 0.8,
            maxOutputTokens: 8192  // Increased from 2048 to handle full 14-day plans
        )
    }
}

struct GeminiContent: Codable {
    let parts: [GeminiPart]
}

struct GeminiPart: Codable {
    let text: String
}

struct GeminiGenerationConfig: Codable {
    let temperature: Double
    let topK: Int
    let topP: Double
    let maxOutputTokens: Int
}

struct GeminiResponse: Codable {
    let candidates: [GeminiCandidate]?
    let error: GeminiError?
}

struct GeminiCandidate: Codable {
    let content: GeminiContent
    let finishReason: String?
}

struct GeminiError: Codable {
    let code: Int
    let message: String
    let status: String
}

// MARK: - Service Errors
enum AIServiceError: Error, LocalizedError {
    case invalidAPIKey
    case networkError(String)
    case invalidResponse
    case quotaExceeded
    case parseError(String)
    case geminiError(String)
    case incompleteResponse
    case invalidJSONStructure(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Unable to connect to AI service. Please check your internet connection and try again."
        case .networkError(let message):
            return "Network connection failed. Please check your internet and try again.\n\nDetails: \(message)"
        case .invalidResponse:
            return "The AI service returned an unexpected response. Please try again."
        case .quotaExceeded:
            return "You've reached the daily limit for AI-generated workout plans. Please try again tomorrow."
        case .parseError(let message):
            return "Failed to process the AI response. This might be a temporary issue - please try again.\n\nTechnical details: \(message)"
        case .geminiError(let message):
            return "AI service error: \(message)\n\nPlease try again in a few moments."
        case .incompleteResponse:
            return "The AI response was cut off unexpectedly. This usually means the workout plan was too complex. Please try simplifying your goals and try again."
        case .invalidJSONStructure(let details):
            return "The AI generated an invalid workout plan format. Please try again with slightly different wording.\n\nTechnical details: \(details)"
        }
    }
}

// MARK: - Google Gemini Service
class AIWorkoutGenerationService: ObservableObject {
    
    // MARK: - Configuration
    private let apiKey = APIKeys.googleGeminiAPIKey
    private let baseURL = APIKeys.geminiBaseURL
    private let timeout: TimeInterval = 45.0  // Increased timeout for larger responses
    
    // MARK: - URLSession
    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout * 2
        return URLSession(configuration: config)
    }()
    
    // MARK: - Public Methods
    
    /// Generate workout plan from user goals using Google Gemini
    func generateWorkoutPlan(from userGoals: String) async throws -> WorkoutPlan {
        print("🤖 Starting Gemini workout generation...")
        print("📝 User goals: \(userGoals)")
        
        // Validate input
        guard !userGoals.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AIServiceError.invalidResponse
        }
        
        // Validate API key
        guard !apiKey.isEmpty && apiKey != "PUT_YOUR_NEW_API_KEY_HERE" else {
            print("❌ API Key validation failed!")
            throw AIServiceError.invalidAPIKey
        }
        
        print("✅ API Key validation passed")
        print("🔑 Using API key (first 10 chars): \(String(apiKey.prefix(10)))...")
        
        // Create the workout generation prompt
        let prompt = createWorkoutPrompt(from: userGoals)
        
        // Make API call to Gemini
        let geminiResponse = try await makeGeminiRequest(prompt: prompt)
        
        // Parse and convert to WorkoutPlan
        let workoutPlan = try parseWorkoutResponse(geminiResponse, userGoals: userGoals)
        
        print("✅ Successfully generated workout plan with \(workoutPlan.days.count) days")
        return workoutPlan
    }
    
    // MARK: - Private Methods
    
    private func createWorkoutPrompt(from userGoals: String) -> String {
        return """
        IMPORTANT: You are generating a workout plan for the Fit14 mobile app. This response will be parsed automatically by the app's code, so EXACT JSON formatting is critical for the app to function properly.
        
        You are a professional fitness trainer AI creating a personalized 14-day workout plan for a Fit14 app user.
        
        USER GOALS: \(userGoals)
        
        WORKOUT PLAN REQUIREMENTS:
        - Create exactly 14 days of workouts
        - Include 1-2 rest or active recovery days throughout the 14-day period
        - Regular workout days must have 4-6 exercises
        - Rest/recovery days should have 1-3 light activities (stretching, walking, yoga, mobility work)
        - Mix cardio, strength, and/or flexibility exercises specific to achieve user goals
        - Consider the user's experience level, schedule, and goals
        - Provide specific sets, reps, or duration for each exercise
        - Use exercises appropriate for the user's available facilities (home, gym, etc.)
        - ALL QUANTITY VALUES MUST BE POSITIVE INTEGERS (no text like "AsManyAsPossible")
        - For "as many as possible" exercises, use a reasonable number like 8-15 reps
        - Make each day different and progressive throughout the 14 days
        
        REST DAY GUIDELINES:
        - Rest days are important for recovery and should be included
        - Rest day activities can include: light walking, gentle stretching, yoga, meditation, foam rolling, mobility work, or complete rest
        - Rest day activities should be 15-30 minutes in duration
        - Label rest days with focus like "Active Recovery", "Rest and Recovery", "Mobility Day", etc.
        - Rest days typically have 1-2 activities, maximum 3
        
        WORKOUT DAY GUIDELINES:
        - Regular workout days should have 4-6 exercises
        - Focus areas can include: Upper Body, Lower Body, Full Body, Cardio, Strength, etc.
        - Workout days are typically 30-60 minutes total
        
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
                  "name": "Dumbbell Rows",
                  "sets": 3,
                  "quantity": 10,
                  "unit": "reps",
                  "instructions": "Pull weight to chest, squeeze shoulder blades"
                }
              ]
            },
            {
              "dayNumber": 7,
              "focus": "Active Recovery",
              "exercises": [
                {
                  "name": "Gentle Walking",
                  "sets": 1,
                  "quantity": 20,
                  "unit": "minutes",
                  "instructions": "Walk at a comfortable, relaxed pace"
                },
                {
                  "name": "Full Body Stretching",
                  "sets": 1,
                  "quantity": 10,
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
        - "unit" must be exactly one of: "reps", "seconds", or "minutes"
        - NEVER use text values for numeric fields
        - Regular workout days should have 4-6 exercises in the array
        - Rest/recovery days should have 1-3 activities in the array
        - Return exactly 14 days
        - dayNumber must be 1, 2, 3... up to 14
        
        CRITICAL: This response is for the Fit14 app's automatic parsing system. You MUST return ONLY valid JSON with no additional text, no explanations, no markdown formatting, no code blocks, no extra characters. The app will break if you add anything other than pure JSON. Start your response with { and end with }.
        """
    }
    
    private func makeGeminiRequest(prompt: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else {
            print("❌ Failed to create URL")
            throw AIServiceError.invalidAPIKey
        }
        
        print("🚀 About to make workout generation request...")
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create request body
        let geminiRequest = GeminiRequest(prompt: prompt)
        
        do {
            let requestData = try JSONEncoder().encode(geminiRequest)
            request.httpBody = requestData
            
        } catch {
            print("❌ Failed to encode request: \(error)")
            throw AIServiceError.invalidResponse
        }
        
        do {
            // Make the request
            let (data, response) = try await urlSession.data(for: request)
            
            print("📡 Received response, checking...")
            
            // Check HTTP status
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Gemini API Response Status: \(httpResponse.statusCode)")
                
                switch httpResponse.statusCode {
                case 200...299:
                    print("✅ API call successful")
                    break // Success
                case 429:
                    throw AIServiceError.quotaExceeded
                case 403:
                    print("❌ 403 Forbidden - API key issue")
                    throw AIServiceError.invalidAPIKey
                case 400...499:
                    print("❌ 4xx Client Error")
                    throw AIServiceError.invalidResponse
                case 500...599:
                    throw AIServiceError.networkError("Server error (Code: \(httpResponse.statusCode))")
                default:
                    throw AIServiceError.networkError("Unexpected response (Code: \(httpResponse.statusCode))")
                }
            }
            
            // Parse Gemini response
            let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
            
            // Check for API errors
            if let error = geminiResponse.error {
                print("❌ Gemini API error: \(error.message)")
                throw AIServiceError.geminiError("\(error.message)")
            }
            
            // Extract text from response
            guard let candidate = geminiResponse.candidates?.first else {
                print("❌ No candidates in response")
                throw AIServiceError.invalidResponse
            }
            
            // Check if response was truncated
            if let finishReason = candidate.finishReason, finishReason == "MAX_TOKENS" {
                print("⚠️ Response was truncated due to token limit")
                throw AIServiceError.incompleteResponse
            }
            
            guard let text = candidate.content.parts.first?.text else {
                print("❌ No text content in response")
                throw AIServiceError.invalidResponse
            }
            
            print("✅ Successfully extracted response text")
            return text
            
        } catch let error as AIServiceError {
            throw error
        } catch {
            print("❌ Network error: \(error.localizedDescription)")
            throw AIServiceError.networkError(error.localizedDescription)
        }
    }
    
    private func parseWorkoutResponse(_ responseText: String, userGoals: String) throws -> WorkoutPlan {
        print("🔍 Parsing Gemini response...")
        
        // Clean the response text (remove any markdown formatting)
        var cleanedText = responseText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if response appears to be truncated
        if !cleanedText.hasSuffix("}") {
            print("⚠️ Response appears to be truncated - doesn't end with }")
            throw AIServiceError.incompleteResponse
        }
        
        // Fix common JSON issues that AI might introduce
        cleanedText = cleanJSONResponse(cleanedText)
        
        print("🧹 Cleaned response length: \(cleanedText.count) characters")
        
        // Parse JSON response
        guard let jsonData = cleanedText.data(using: .utf8) else {
            throw AIServiceError.parseError("Could not convert response to data")
        }
        
        do {
            let aiResponse = try JSONDecoder().decode(GeminiWorkoutResponse.self, from: jsonData)
            print("✅ Successfully parsed JSON response")
            
            // Validate the response structure
            try validateWorkoutResponse(aiResponse)
            
            return convertToWorkoutPlan(aiResponse: aiResponse, userGoals: userGoals)
        } catch let decodingError as DecodingError {
            print("❌ JSON parsing error: \(decodingError)")
            let errorDetails = formatDecodingError(decodingError)
            throw AIServiceError.invalidJSONStructure(errorDetails)
        } catch let validationError as AIServiceError {
            throw validationError
        } catch {
            print("❌ Unexpected parsing error: \(error)")
            throw AIServiceError.parseError("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    private func validateWorkoutResponse(_ response: GeminiWorkoutResponse) throws {
        // Check if we have exactly 14 days
        guard response.days.count == 14 else {
            throw AIServiceError.invalidJSONStructure("Expected 14 days, got \(response.days.count) days")
        }
        
        // Validate basic structural integrity
        for (index, day) in response.days.enumerated() {
            guard day.dayNumber == index + 1 else {
                throw AIServiceError.invalidJSONStructure("Day \(index + 1) has incorrect dayNumber: \(day.dayNumber)")
            }
            
            // Ensure each day has at least one exercise/activity
            guard !day.exercises.isEmpty else {
                throw AIServiceError.invalidJSONStructure("Day \(day.dayNumber) has no exercises")
            }
            
            // Validate each exercise has valid basic data
            for exercise in day.exercises {
                guard exercise.sets > 0 else {
                    throw AIServiceError.invalidJSONStructure("Exercise '\(exercise.name)' has invalid sets: \(exercise.sets)")
                }
                
                guard exercise.quantity > 0 else {
                    throw AIServiceError.invalidJSONStructure("Exercise '\(exercise.name)' has invalid quantity: \(exercise.quantity)")
                }
                
                guard ["reps", "seconds", "minutes"].contains(exercise.unit.lowercased()) else {
                    throw AIServiceError.invalidJSONStructure("Exercise '\(exercise.name)' has invalid unit: \(exercise.unit)")
                }
                
                guard !exercise.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    throw AIServiceError.invalidJSONStructure("Exercise has empty name on day \(day.dayNumber)")
                }
            }
        }
        
        print("✅ Workout plan validation passed - trusting AI fitness expertise")
    }
    

    
    private func formatDecodingError(_ error: DecodingError) -> String {
        switch error {
        case .keyNotFound(let key, let context):
            return "Missing required field '\(key.stringValue)' at path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))"
        case .typeMismatch(let type, let context):
            return "Type mismatch for \(type) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))"
        case .valueNotFound(let type, let context):
            return "Missing value for \(type) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))"
        case .dataCorrupted(let context):
            return "Data corrupted: \(context.debugDescription)"
        @unknown default:
            return "Unknown decoding error: \(error.localizedDescription)"
        }
    }
    
    private func cleanJSONResponse(_ jsonText: String) -> String {
        var cleaned = jsonText
        
        // Fix common AI mistakes in JSON
        cleaned = cleaned.replacingOccurrences(of: "\"quantity\": AsManyAsPossible", with: "\"quantity\": 10")
        cleaned = cleaned.replacingOccurrences(of: "\"quantity\": AsLongAsPossible", with: "\"quantity\": 30")
        cleaned = cleaned.replacingOccurrences(of: "\"quantity\": \"AsManyAsPossible\"", with: "\"quantity\": 10")
        cleaned = cleaned.replacingOccurrences(of: "\"quantity\": \"AsLongAsPossible\"", with: "\"quantity\": 30")
        
        // Fix any other common text values that should be numbers
        cleaned = cleaned.replacingOccurrences(of: "\"quantity\": \"max\"", with: "\"quantity\": 12")
        cleaned = cleaned.replacingOccurrences(of: "\"quantity\": \"maximum\"", with: "\"quantity\": 12")
        cleaned = cleaned.replacingOccurrences(of: "\"sets\": \"max\"", with: "\"sets\": 3")
        
        // Handle empty exercise arrays by ensuring at least one exercise
        if cleaned.contains("\"exercises\": []") {
            let restExercise = """
            "exercises": [
              {
                "name": "Rest Day",
                "sets": 1,
                "quantity": 30,
                "unit": "minutes",
                "instructions": "Take a rest day to allow your body to recover"
              }
            ]
            """
            cleaned = cleaned.replacingOccurrences(of: "\"exercises\": []", with: restExercise)
        }
        
        return cleaned
    }
    
    private func convertToWorkoutPlan(aiResponse: GeminiWorkoutResponse, userGoals: String) -> WorkoutPlan {
        var days: [Day] = []
        let startDate = Date()
        
        for aiDay in aiResponse.days {
            let exercises = aiDay.exercises.map { aiExercise in
                // Convert string unit to ExerciseUnit enum
                let unit = ExerciseUnit(rawValue: aiExercise.unit.lowercased()) ?? .reps
                
                return Exercise(
                    name: aiExercise.name,
                    sets: aiExercise.sets,
                    quantity: aiExercise.quantity,
                    unit: unit
                )
            }
            
            let dayDate = Calendar.current.date(byAdding: .day, value: aiDay.dayNumber - 1, to: startDate) ?? startDate
            
            let day = Day(
                dayNumber: aiDay.dayNumber,
                date: dayDate,
                exercises: exercises
            )
            
            days.append(day)
        }
        
        return WorkoutPlan(userGoals: userGoals, days: days)
    }
}

// MARK: - Gemini Response Models
struct GeminiWorkoutResponse: Codable {
    let summary: String?
    let days: [GeminiWorkoutDay]
}

struct GeminiWorkoutDay: Codable {
    let dayNumber: Int
    let focus: String?
    let exercises: [GeminiWorkoutExercise]
}

struct GeminiWorkoutExercise: Codable {
    let name: String
    let sets: Int
    let quantity: Int
    let unit: String
    let instructions: String?
}
