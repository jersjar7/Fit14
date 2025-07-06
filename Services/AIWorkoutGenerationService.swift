//
//  AIWorkoutGenerationService.swift
//  Fit14
//
//  Created by Jerson on 7/3/25.
//

import Foundation

// MARK: - Request/Response Models
struct AIWorkoutRequest: Codable {
    let userGoals: String
    let requestId: String
    let regeneration: Bool
    let preservedDays: [Int]? // Day numbers to preserve (for future use)
    
    init(userGoals: String, regeneration: Bool = false, preservedDays: [Int]? = nil) {
        self.userGoals = userGoals
        self.requestId = UUID().uuidString
        self.regeneration = regeneration
        self.preservedDays = preservedDays
    }
}

struct AIWorkoutResponse: Codable {
    let success: Bool
    let message: String?
    let workoutPlan: AIGeneratedPlan?
    let error: String?
}

struct AIGeneratedPlan: Codable {
    let summary: String
    let totalDays: Int
    let estimatedCaloriesBurn: Int?
    let recommendations: String?
    let days: [AIGeneratedDay]
}

struct AIGeneratedDay: Codable {
    let dayNumber: Int
    let focus: String
    let exercises: [AIGeneratedExercise]
}

struct AIGeneratedExercise: Codable {
    let name: String
    let sets: Int
    let quantity: Int
    let unit: String // Will be converted to ExerciseUnit enum
    let instructions: String?
    let difficulty: String?
}

// MARK: - Service Errors
enum AIServiceError: Error, LocalizedError {
    case invalidURL
    case noInternetConnection
    case invalidResponse
    case decodingError(String)
    case serverError(String)
    case rateLimitExceeded
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL configuration"
        case .noInternetConnection:
            return "Please check your internet connection"
        case .invalidResponse:
            return "Received invalid response from server"
        case .decodingError(let detail):
            return "Failed to process server response: \(detail)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .rateLimitExceeded:
            return "Too many requests. Please try again later"
        case .unknown(let message):
            return "Unexpected error: \(message)"
        }
    }
}

// MARK: - AI Workout Generation Service
class AIWorkoutGenerationService: ObservableObject {
    
    // MARK: - Configuration
    private let baseURL = "https://api.8n8.ai" // Replace with actual 8n8 API URL
    private let apiKey = "your-8n8-api-key" // Replace with actual API key
    private let timeout: TimeInterval = 30.0
    
    // MARK: - URLSession
    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout * 2
        return URLSession(configuration: config)
    }()
    
    // MARK: - Public Methods
    
    /// Generate workout plan from user goals
    func generateWorkoutPlan(from userGoals: String) async throws -> WorkoutPlan {
        print("🤖 Starting AI workout generation...")
        print("📝 User goals: \(userGoals)")
        
        // Validate input
        guard !userGoals.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AIServiceError.invalidResponse
        }
        
        // Create request
        let request = try createRequest(for: userGoals)
        
        // Make API call
        let aiResponse = try await makeAPICall(request: request)
        
        // Convert AI response to our models
        let workoutPlan = try convertToWorkoutPlan(aiResponse: aiResponse, userGoals: userGoals)
        
        print("✅ Successfully generated workout plan with \(workoutPlan.days.count) days")
        return workoutPlan
    }
    
    /// Regenerate workout plan (potentially preserving certain days)
    func regenerateWorkoutPlan(from userGoals: String, preservingDayNumbers: [Int] = []) async throws -> WorkoutPlan {
        print("🔄 Starting AI workout regeneration...")
        print("📝 User goals: \(userGoals)")
        print("🔒 Preserving days: \(preservingDayNumbers)")
        
        // Validate input
        guard !userGoals.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AIServiceError.invalidResponse
        }
        
        // Create regeneration request
        let request = try createRegenerationRequest(for: userGoals, preservingDays: preservingDayNumbers)
        
        // Make API call
        let aiResponse = try await makeAPICall(request: request)
        
        // Convert AI response to our models
        let workoutPlan = try convertToWorkoutPlan(aiResponse: aiResponse, userGoals: userGoals)
        
        print("✅ Successfully regenerated workout plan with \(workoutPlan.days.count) days")
        return workoutPlan
    }
    
    // MARK: - Private Methods
    
    private func createRequest(for userGoals: String) throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)/generate-workout") else {
            throw AIServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let requestBody = AIWorkoutRequest(userGoals: userGoals)
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        return request
    }
    
    private func createRegenerationRequest(for userGoals: String, preservingDays: [Int]) throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)/regenerate-workout") else {
            throw AIServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let requestBody = AIWorkoutRequest(
            userGoals: userGoals,
            regeneration: true,
            preservedDays: preservingDays.isEmpty ? nil : preservingDays
        )
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        return request
    }
    
    private func makeAPICall(request: URLRequest) async throws -> AIWorkoutResponse {
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            // Check HTTP status
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 API Response Status: \(httpResponse.statusCode)")
                
                switch httpResponse.statusCode {
                case 200...299:
                    break // Success
                case 429:
                    throw AIServiceError.rateLimitExceeded
                case 400...499:
                    throw AIServiceError.invalidResponse
                case 500...599:
                    throw AIServiceError.serverError("Server error (\(httpResponse.statusCode))")
                default:
                    throw AIServiceError.unknown("HTTP \(httpResponse.statusCode)")
                }
            }
            
            // Parse response
            let aiResponse = try JSONDecoder().decode(AIWorkoutResponse.self, from: data)
            
            // Check if AI generation was successful
            guard aiResponse.success else {
                let errorMessage = aiResponse.error ?? "Unknown AI generation error"
                throw AIServiceError.serverError(errorMessage)
            }
            
            return aiResponse
            
        } catch let error as AIServiceError {
            throw error
        } catch {
            // Handle network and decoding errors
            if error is DecodingError {
                throw AIServiceError.decodingError(error.localizedDescription)
            } else {
                throw AIServiceError.noInternetConnection
            }
        }
    }
    
    private func convertToWorkoutPlan(aiResponse: AIWorkoutResponse, userGoals: String) throws -> WorkoutPlan {
        guard let aiPlan = aiResponse.workoutPlan else {
            throw AIServiceError.invalidResponse
        }
        
        // Convert AI exercises to our Exercise model
        var days: [Day] = []
        let startDate = Date()
        
        for aiDay in aiPlan.days {
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
        
        // Ensure we have 14 days (fill missing days if needed)
        while days.count < 14 {
            let dayNumber = days.count + 1
            let dayDate = Calendar.current.date(byAdding: .day, value: dayNumber - 1, to: startDate) ?? startDate
            
            // Create a rest day or repeat last day's exercises
            let exercises = days.last?.exercises ?? []
            let day = Day(dayNumber: dayNumber, date: dayDate, exercises: exercises)
            days.append(day)
        }
        
        return WorkoutPlan(userGoals: userGoals, days: Array(days.prefix(14)))
    }
}

// MARK: - Extension for testing/development
extension AIWorkoutGenerationService {
    
    /// Create a mock workout plan for testing (remove this in production)
    func generateMockWorkoutPlan(from userGoals: String) -> WorkoutPlan {
        print("🧪 Generating mock workout plan for testing...")
        
        // Enhanced mock exercises with more variety and different units
        let mockExercises = [
            Exercise(name: "Push-ups", sets: 3, quantity: 12, unit: .reps),
            Exercise(name: "Squats", sets: 3, quantity: 15, unit: .reps),
            Exercise(name: "Plank", sets: 1, quantity: 45, unit: .seconds),
            Exercise(name: "Lunges", sets: 2, quantity: 10, unit: .reps),
            Exercise(name: "Jumping Jacks", sets: 3, quantity: 20, unit: .reps),
            Exercise(name: "Burpees", sets: 2, quantity: 8, unit: .reps),
            Exercise(name: "Mountain Climbers", sets: 3, quantity: 15, unit: .reps),
            Exercise(name: "Tricep Dips", sets: 2, quantity: 12, unit: .reps),
            Exercise(name: "High Knees", sets: 3, quantity: 30, unit: .seconds),
            Exercise(name: "Wall Sit", sets: 1, quantity: 60, unit: .seconds),
            Exercise(name: "Side Plank", sets: 2, quantity: 30, unit: .seconds),
            Exercise(name: "Cardio Intervals", sets: 1, quantity: 5, unit: .minutes)
        ]
        
        var days: [Day] = []
        let startDate = Date()
        
        for i in 1...14 {
            let dayDate = Calendar.current.date(byAdding: .day, value: i-1, to: startDate) ?? startDate
            
            // Create variety in exercise selection
            let exerciseCount = i % 7 == 0 ? 2 : (i % 5 == 0 ? 4 : 3) // Rest days have fewer exercises
            let selectedExercises = Array(mockExercises.shuffled().prefix(exerciseCount))
            
            let day = Day(dayNumber: i, date: dayDate, exercises: selectedExercises)
            days.append(day)
        }
        
        return WorkoutPlan(userGoals: userGoals, days: days)
    }
    
    /// Create a mock regenerated workout plan (with some variation)
    func generateMockRegeneratedPlan(from userGoals: String, preservingDayNumbers: [Int] = []) -> WorkoutPlan {
        print("🧪 Generating mock regenerated workout plan...")
        print("🔒 Would preserve days: \(preservingDayNumbers) (mock ignores this)")
        
        // For mock, just generate a new plan with slightly different exercises
        let originalPlan = generateMockWorkoutPlan(from: userGoals)
        
        // Add some variation to make it feel like a regeneration
        var modifiedDays = originalPlan.days
        for i in 0..<modifiedDays.count {
            if !preservingDayNumbers.contains(i + 1) {
                // Modify non-preserved days slightly
                let exercises = modifiedDays[i].exercises.map { exercise in
                    // Slightly vary the sets/quantity
                    let newSets = max(1, exercise.sets + Int.random(in: -1...1))
                    let newQuantity = max(1, exercise.quantity + Int.random(in: -2...2))
                    return Exercise(name: exercise.name, sets: newSets, quantity: newQuantity, unit: exercise.unit)
                }
                modifiedDays[i] = Day(
                    dayNumber: modifiedDays[i].dayNumber,
                    date: modifiedDays[i].date,
                    exercises: exercises
                )
            }
        }
        
        return WorkoutPlan(userGoals: userGoals, days: modifiedDays)
    }
}
