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
    
    init(userGoals: String) {
        self.userGoals = userGoals
        self.requestId = UUID().uuidString
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
    let reps: Int
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
                Exercise(
                    name: aiExercise.name,
                    sets: aiExercise.sets,
                    reps: aiExercise.reps
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
        
        // This is for testing - replace with real AI call
        let mockExercises = [
            Exercise(name: "Push-ups", sets: 3, reps: 12),
            Exercise(name: "Squats", sets: 3, reps: 15),
            Exercise(name: "Plank", sets: 1, reps: 45),
            Exercise(name: "Lunges", sets: 2, reps: 10),
            Exercise(name: "Jumping Jacks", sets: 3, reps: 20)
        ]
        
        var days: [Day] = []
        let startDate = Date()
        
        for i in 1...14 {
            let dayDate = Calendar.current.date(byAdding: .day, value: i-1, to: startDate) ?? startDate
            let shuffledExercises = Array(mockExercises.shuffled().prefix(3))
            let day = Day(dayNumber: i, date: dayDate, exercises: shuffledExercises)
            days.append(day)
        }
        
        return WorkoutPlan(userGoals: userGoals, days: days)
    }
}
