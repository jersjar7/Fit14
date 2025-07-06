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
        
        // Get the workout generation prompt from AIPrompts
        let prompt = AIPrompts.workoutPrompt(for: userGoals)
        
        // Make API call to Gemini
        let geminiResponse = try await makeGeminiRequest(prompt: prompt)
        
        // Parse and convert to WorkoutPlan
        let workoutPlan = try parseWorkoutResponse(geminiResponse, userGoals: userGoals)
        
        print("✅ Successfully generated workout plan with \(workoutPlan.days.count) days")
        return workoutPlan
    }
    
    // MARK: - Private Methods
    
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
                
                // Use AIPrompts validation for allowed units
                guard AIPrompts.isValidUnit(exercise.unit) else {
                    throw AIServiceError.invalidJSONStructure("Exercise '\(exercise.name)' has invalid unit: '\(exercise.unit)'. Allowed units: \(AIPrompts.allowedUnits.sorted().joined(separator: ", "))")
                }
                
                guard !exercise.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    throw AIServiceError.invalidJSONStructure("Exercise has empty name on day \(day.dayNumber)")
                }
            }
        }
        
        print("✅ Workout plan validation passed - trusting AI fitness expertise")
        print("📊 Validated \(response.days.count) days with all 11 supported unit types")
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
        
        // Fix common AI mistakes in JSON for numeric values
        cleaned = cleaned.replacingOccurrences(of: "\"quantity\": AsManyAsPossible", with: "\"quantity\": 10")
        cleaned = cleaned.replacingOccurrences(of: "\"quantity\": AsLongAsPossible", with: "\"quantity\": 30")
        cleaned = cleaned.replacingOccurrences(of: "\"quantity\": \"AsManyAsPossible\"", with: "\"quantity\": 10")
        cleaned = cleaned.replacingOccurrences(of: "\"quantity\": \"AsLongAsPossible\"", with: "\"quantity\": 30")
        
        // Fix any other common text values that should be numbers
        cleaned = cleaned.replacingOccurrences(of: "\"quantity\": \"max\"", with: "\"quantity\": 12")
        cleaned = cleaned.replacingOccurrences(of: "\"quantity\": \"maximum\"", with: "\"quantity\": 12")
        cleaned = cleaned.replacingOccurrences(of: "\"sets\": \"max\"", with: "\"sets\": 3")
        
        // Fix common unit abbreviations that AI might use instead of full names
        cleaned = cleaned.replacingOccurrences(of: "\"unit\": \"sec\"", with: "\"unit\": \"seconds\"")
        cleaned = cleaned.replacingOccurrences(of: "\"unit\": \"min\"", with: "\"unit\": \"minutes\"")
        cleaned = cleaned.replacingOccurrences(of: "\"unit\": \"hr\"", with: "\"unit\": \"hours\"")
        cleaned = cleaned.replacingOccurrences(of: "\"unit\": \"m\"", with: "\"unit\": \"meters\"")
        cleaned = cleaned.replacingOccurrences(of: "\"unit\": \"km\"", with: "\"unit\": \"kilometers\"")
        cleaned = cleaned.replacingOccurrences(of: "\"unit\": \"mi\"", with: "\"unit\": \"miles\"")
        cleaned = cleaned.replacingOccurrences(of: "\"unit\": \"yd\"", with: "\"unit\": \"yards\"")
        cleaned = cleaned.replacingOccurrences(of: "\"unit\": \"ft\"", with: "\"unit\": \"feet\"")
        
        // Fix plural/singular inconsistencies
        cleaned = cleaned.replacingOccurrences(of: "\"unit\": \"rep\"", with: "\"unit\": \"reps\"")
        cleaned = cleaned.replacingOccurrences(of: "\"unit\": \"step\"", with: "\"unit\": \"steps\"")
        cleaned = cleaned.replacingOccurrences(of: "\"unit\": \"lap\"", with: "\"unit\": \"laps\"")
        cleaned = cleaned.replacingOccurrences(of: "\"unit\": \"second\"", with: "\"unit\": \"seconds\"")
        cleaned = cleaned.replacingOccurrences(of: "\"unit\": \"minute\"", with: "\"unit\": \"minutes\"")
        cleaned = cleaned.replacingOccurrences(of: "\"unit\": \"hour\"", with: "\"unit\": \"hours\"")
        cleaned = cleaned.replacingOccurrences(of: "\"unit\": \"meter\"", with: "\"unit\": \"meters\"")
        cleaned = cleaned.replacingOccurrences(of: "\"unit\": \"yard\"", with: "\"unit\": \"yards\"")
        cleaned = cleaned.replacingOccurrences(of: "\"unit\": \"foot\"", with: "\"unit\": \"feet\"")
        cleaned = cleaned.replacingOccurrences(of: "\"unit\": \"kilometer\"", with: "\"unit\": \"kilometers\"")
        cleaned = cleaned.replacingOccurrences(of: "\"unit\": \"mile\"", with: "\"unit\": \"miles\"")
        
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
            let exercises = aiDay.exercises.compactMap { aiExercise -> Exercise? in
                // Convert string unit to ExerciseUnit enum, with fallback validation
                guard let unit = ExerciseUnit(rawValue: aiExercise.unit.lowercased()) else {
                    print("⚠️ Unknown unit '\(aiExercise.unit)' for exercise '\(aiExercise.name)', defaulting to reps")
                    return Exercise(
                        name: aiExercise.name,
                        sets: aiExercise.sets,
                        quantity: aiExercise.quantity,
                        unit: .reps
                    )
                }
                
                // Validate quantity makes sense for the unit
                guard unit.isValidQuantity(aiExercise.quantity) else {
                    print("⚠️ Invalid quantity \(aiExercise.quantity) for unit \(unit.displayName) in exercise '\(aiExercise.name)'")
                    // Use a reasonable default within the suggested range
                    let reasonableQuantity = max(unit.suggestedRange.lowerBound, min(unit.suggestedRange.upperBound, aiExercise.quantity))
                    return Exercise(
                        name: aiExercise.name,
                        sets: aiExercise.sets,
                        quantity: reasonableQuantity,
                        unit: unit
                    )
                }
                
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
    
    // MARK: - Debug Helpers
    
    /// Get debug information about the current service configuration
    func getDebugInfo() -> String {
        return """
        AI Workout Generation Service Debug Info:
        \(AIPrompts.debugInfo)
        
        Service Configuration:
        - API Base URL: \(baseURL)
        - Timeout: \(timeout)s
        - API Key Status: \(apiKey.isEmpty ? "Missing" : "Present (\(apiKey.prefix(10))...)")
        """
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
