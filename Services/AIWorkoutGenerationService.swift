//
//  AIWorkoutGenerationService.swift
//  Fit14
//
//  Created by Jerson on 7/3/25.
//  Updated to use Google Gemini API
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
            maxOutputTokens: 2048
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
    
    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Invalid API key. Please check your Gemini API configuration."
        case .networkError(let message):
            return "Network error: \(message)"
        case .invalidResponse:
            return "Invalid response from Gemini API"
        case .quotaExceeded:
            return "Daily quota exceeded. Try again tomorrow or upgrade to premium."
        case .parseError(let message):
            return "Failed to parse response: \(message)"
        case .geminiError(let message):
            return "Gemini API error: \(message)"
        }
    }
}

// MARK: - Google Gemini Service
class AIWorkoutGenerationService: ObservableObject {
    
    // MARK: - Configuration
    private let apiKey = APIKeys.googleGeminiAPIKey
    private let baseURL = APIKeys.geminiBaseURL
    private let timeout: TimeInterval = 30.0
    
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
        
        // Validate API key - FIXED VALIDATION
        guard !apiKey.isEmpty && apiKey != "PUT_YOUR_NEW_API_KEY_HERE" else {
            print("❌ API Key validation failed!")
            print("🔑 Key is empty: \(apiKey.isEmpty)")
            print("🔑 Key is placeholder: \(apiKey == "AIzaSyDKJzHzLrBIwxcH2GZA0VCcOD3TA-Ben5w")")
            
            // ADD THIS DEBUG LINE:
            print("🔑 Actual key value: '\(apiKey)'")
            
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
        
        REQUIREMENTS:
        - Create exactly 14 days of workouts
        - Each day must have exactly 5-6 exercises (NEVER less than 5, NEVER more than 6)
        - Mix cardio, strength, and/or flexibility exercises specific to achieve user goals
        - Consider the user's experience level, schedule, and goals
        - Provide specific sets, reps, or duration for each exercise
        - Use exercises appropriate for the user's available facilities (home, gym, etc.)
        - ALL QUANTITY VALUES MUST BE POSITIVE INTEGERS (no text like "AsManyAsPossible")
        - For "as many as possible" exercises, use a reasonable number like 8-15 reps
        - Make each day different and progressive throughout the 14 days
        
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
            }
          ]
        }
        
        CRITICAL FOR FIT14 APP - JSON REQUIREMENTS:
        - "quantity" must ALWAYS be a positive integer (1, 2, 3, etc.) - NEVER text or decimals
        - "sets" must ALWAYS be a positive integer (1, 2, 3, etc.)
        - "unit" must be exactly one of: "reps", "seconds", or "minutes"
        - NEVER use text values for numeric fields
        - Each day must have exactly 5-6 exercises in the array
        - Return exactly 14 days
        - dayNumber must be 1, 2, 3... up to 14
        
        CRITICAL: This response is for the Fit14 app's automatic parsing system. You MUST return ONLY valid JSON with no additional text, no explanations, no markdown formatting, no code blocks, no extra characters. The app will break if you add anything other than pure JSON. Start your response with { and end with }.
        """
    }
    
    private func makeGeminiRequest(prompt: String) async throws -> String {
        // FIXED: Construct URL with API key (baseURL already includes the full path)
        guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else {
            print("❌ Failed to create URL")
            print("🌐 BaseURL: \(baseURL)")
            print("🔑 API Key length: \(apiKey.count)")
            throw AIServiceError.invalidAPIKey
        }
        
        print("🔑 API Key length: \(apiKey.count)")
        print("🔑 API Key starts with: \(apiKey.hasPrefix("AIzaSy") ? "✅ AIzaSy" : "❌ Wrong prefix")")
        print("🌐 Full URL: \(url.absoluteString)")
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
            
            // Debug the request body
            if let requestString = String(data: requestData, encoding: .utf8) {
                print("📦 Request body: \(requestString.prefix(200))...")
            }
            
        } catch {
            print("❌ Failed to encode request: \(error)")
            throw AIServiceError.invalidResponse
        }
        
        do {
            // Make the request
            let (data, response) = try await urlSession.data(for: request)
            
            print("📡 Received response, checking...")
            
            // Debug the raw response
            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 Raw API Response (first 500 chars): \(responseString.prefix(500))...")
            }
            
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
                    throw AIServiceError.networkError("Server error (\(httpResponse.statusCode))")
                default:
                    throw AIServiceError.networkError("HTTP \(httpResponse.statusCode)")
                }
            }
            
            // Parse Gemini response
            let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
            
            // Check for API errors
            if let error = geminiResponse.error {
                print("❌ Gemini API error: \(error.message)")
                throw AIServiceError.geminiError("\(error.message) (Code: \(error.code))")
            }
            
            // Extract text from response
            guard let candidate = geminiResponse.candidates?.first,
                  let text = candidate.content.parts.first?.text else {
                print("❌ No valid response content")
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
    
    // TEMPORARY: Simple API test
    func testSimpleAPICall() async {
        print("🧪 Testing simple Gemini API call...")
        
        let testURL = "\(baseURL)?key=\(apiKey)"
        guard let url = URL(string: testURL) else {
            print("❌ Invalid test URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Minimal test request
        let testBody = """
        {
          "contents": [{
            "parts": [{"text": "Hello"}]
          }]
        }
        """
        request.httpBody = testBody.data(using: .utf8)
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("🧪 Test Status: \(httpResponse.statusCode)")
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("🧪 Test Response: \(responseString)")
            }
        } catch {
            print("🧪 Test Error: \(error)")
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
        
        // Fix common JSON issues that AI might introduce
        cleanedText = cleanJSONResponse(cleanedText)
        
        print("🧹 Cleaned response (first 200 chars): \(cleanedText.prefix(200))...")
        
        // Parse JSON response
        guard let jsonData = cleanedText.data(using: .utf8) else {
            throw AIServiceError.parseError("Could not convert response to data")
        }
        
        do {
            let aiResponse = try JSONDecoder().decode(GeminiWorkoutResponse.self, from: jsonData)
            print("✅ Successfully parsed JSON response")
            return convertToWorkoutPlan(aiResponse: aiResponse, userGoals: userGoals)
        } catch {
            print("❌ JSON parsing error: \(error)")
            print("📄 Response text: \(cleanedText)")
            throw AIServiceError.parseError("Invalid JSON format: \(error.localizedDescription)")
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
        
        // Ensure we have exactly 14 days
        while days.count < 14 {
            let dayNumber = days.count + 1
            let dayDate = Calendar.current.date(byAdding: .day, value: dayNumber - 1, to: startDate) ?? startDate
            
            // Create a basic day if AI didn't provide enough
            let basicExercises = [
                Exercise(name: "Rest day", sets: 1, quantity: 30, unit: .minutes)
            ]
            let day = Day(dayNumber: dayNumber, date: dayDate, exercises: basicExercises)
            days.append(day)
        }
        
        return WorkoutPlan(userGoals: userGoals, days: Array(days.prefix(14)))
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

// MARK: - Development Extensions (Keep for testing)
extension AIWorkoutGenerationService {
    
    /// Create a mock workout plan for testing (fallback if API fails)
    func generateMockWorkoutPlan(from userGoals: String) -> WorkoutPlan {
        print("🧪 Generating mock workout plan as fallback...")
        
        let mockExercises = [
            Exercise(name: "Push-ups", sets: 3, quantity: 12, unit: .reps),
            Exercise(name: "Squats", sets: 3, quantity: 15, unit: .reps),
            Exercise(name: "Plank", sets: 1, quantity: 45, unit: .seconds),
            Exercise(name: "Lunges", sets: 2, quantity: 10, unit: .reps),
            Exercise(name: "Jumping Jacks", sets: 3, quantity: 30, unit: .seconds),
            Exercise(name: "Burpees", sets: 2, quantity: 8, unit: .reps),
            Exercise(name: "Mountain Climbers", sets: 3, quantity: 20, unit: .seconds),
            Exercise(name: "Wall Sit", sets: 1, quantity: 60, unit: .seconds)
        ]
        
        var days: [Day] = []
        let startDate = Date()
        
        for i in 1...14 {
            let dayDate = Calendar.current.date(byAdding: .day, value: i-1, to: startDate) ?? startDate
            let exerciseCount = i % 7 == 0 ? 2 : 3 // Rest days have fewer exercises
            let selectedExercises = Array(mockExercises.shuffled().prefix(exerciseCount))
            
            let day = Day(dayNumber: i, date: dayDate, exercises: selectedExercises)
            days.append(day)
        }
        
        return WorkoutPlan(userGoals: userGoals, days: days)
    }
}
