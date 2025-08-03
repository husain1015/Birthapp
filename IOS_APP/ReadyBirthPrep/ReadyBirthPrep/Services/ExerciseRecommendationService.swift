import Foundation
import SwiftUI

class ExerciseRecommendationService: ObservableObject {
    @Published var todaysRecommendation: DailyExerciseRecommendation?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let userDefaults = UserDefaults.standard
    private let exerciseHistoryKey = "exerciseHistory"
    private let recommendationKey = "dailyRecommendation"
    private let apiKey = ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"] ?? ""
    
    func getExerciseHistory(for userId: UUID) -> [ExerciseHistory] {
        guard let data = userDefaults.data(forKey: "\(exerciseHistoryKey)_\(userId.uuidString)"),
              let history = try? JSONDecoder().decode([ExerciseHistory].self, from: data) else {
            return []
        }
        return history
    }
    
    func saveExerciseCompletion(_ exercise: Exercise, userId: UUID, duration: TimeInterval) {
        var history = getExerciseHistory(for: userId)
        let completion = ExerciseHistory(
            userId: userId,
            exerciseId: exercise.id,
            exerciseName: exercise.name,
            category: exercise.category,
            duration: duration
        )
        history.append(completion)
        
        if let encoded = try? JSONEncoder().encode(history) {
            userDefaults.set(encoded, forKey: "\(exerciseHistoryKey)_\(userId.uuidString)")
        }
    }
    
    func generateDailyRecommendations(for user: User) async {
        isLoading = true
        errorMessage = nil
        
        // Check if we already have today's recommendation
        if let cached = getCachedRecommendation(for: user.id),
           Calendar.current.isDateInToday(cached.date) {
            todaysRecommendation = cached
            isLoading = false
            return
        }
        
        do {
            let recommendation = try await fetchRecommendationFromClaude(for: user)
            todaysRecommendation = recommendation
            cacheRecommendation(recommendation, for: user.id)
        } catch {
            errorMessage = "Failed to generate recommendations: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func fetchRecommendationFromClaude(for user: User) async throws -> DailyExerciseRecommendation {
        let history = getExerciseHistory(for: user.id)
        let recentHistory = history.filter { exercise in
            exercise.completedAt > Date().addingTimeInterval(-7 * 24 * 60 * 60) // Last 7 days
        }
        
        let prompt = createPrompt(for: user, history: recentHistory)
        
        // Create the API request
        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("anthropic-version", forHTTPHeaderField: "anthropic-version")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        
        let body: [String: Any] = [
            "model": "claude-3-5-sonnet-20241022",
            "max_tokens": 1000,
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(ClaudeResponse.self, from: data)
        
        // Parse the response and create recommendations
        let recommendedExercises = parseRecommendations(from: response.content.first?.text ?? "")
        
        return DailyExerciseRecommendation(
            userId: user.id,
            weekOfPregnancy: user.currentWeekOfPregnancy,
            recommendedExercises: recommendedExercises.exercises,
            reasoning: recommendedExercises.reasoning,
            focusAreas: recommendedExercises.focusAreas,
            safetyNotes: recommendedExercises.safetyNotes
        )
    }
    
    private func createPrompt(for user: User, history: [ExerciseHistory]) -> String {
        let historyDescription = history.isEmpty ? "No exercises completed in the last 7 days" :
            history.map { "\($0.exerciseName) (\($0.category.rawValue)) on \($0.completedAt.formatted(date: .abbreviated, time: .omitted))" }.joined(separator: ", ")
        
        return """
        You are a prenatal fitness expert. Create a personalized daily exercise recommendation for a pregnant woman.
        
        User Information:
        - Current week of pregnancy: \(user.currentWeekOfPregnancy)
        - Trimester: \(user.currentTrimester.rawValue)
        - Days until due date: \(user.daysUntilDueDate)
        - Fitness level: \(user.fitnessLevel.rawValue)
        - Recent exercise history: \(historyDescription)
        
        Please recommend 3-4 exercises for today that are:
        1. Safe and appropriate for week \(user.currentWeekOfPregnancy) of pregnancy
        2. Varied from recent exercises to prevent boredom and work different muscle groups
        3. Aligned with preparing for labor and maintaining fitness
        
        Format your response as JSON with the following structure:
        {
            "exercises": [
                {
                    "name": "Exercise Name",
                    "category": "Category",
                    "duration": minutes as number,
                    "reason": "Why this exercise today"
                }
            ],
            "reasoning": "Overall reasoning for today's selection",
            "focusAreas": ["Area 1", "Area 2"],
            "safetyNotes": ["Note 1", "Note 2"]
        }
        
        Available exercise categories: Breathing Exercises, Pelvic Floor, Core Stability, Mobility & Stretching, Strength Training, Labor Preparation, Relaxation
        """
    }
    
    private func parseRecommendations(from response: String) -> (exercises: [Exercise], reasoning: String, focusAreas: [String], safetyNotes: [String]) {
        // Parse JSON response from Claude
        guard let data = response.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return ([], "Unable to parse recommendations", [], [])
        }
        
        let reasoning = json["reasoning"] as? String ?? ""
        let focusAreas = json["focusAreas"] as? [String] ?? []
        let safetyNotes = json["safetyNotes"] as? [String] ?? []
        
        var exercises: [Exercise] = []
        
        if let exerciseData = json["exercises"] as? [[String: Any]] {
            for item in exerciseData {
                if let name = item["name"] as? String,
                   let categoryString = item["category"] as? String,
                   let duration = item["duration"] as? Double {
                    
                    // Find matching exercise from our database
                    let exercise = createExerciseFromRecommendation(
                        name: name,
                        category: categoryString,
                        duration: duration * 60 // Convert to seconds
                    )
                    exercises.append(exercise)
                }
            }
        }
        
        return (exercises, reasoning, focusAreas, safetyNotes)
    }
    
    private func createExerciseFromRecommendation(name: String, category: String, duration: TimeInterval) -> Exercise {
        // Map to our exercise categories
        let exerciseCategory = ExerciseCategory.allCases.first { $0.rawValue == category } ?? .breathing
        
        // Create a basic exercise (in real app, would fetch from database)
        return Exercise(
            name: name,
            category: exerciseCategory,
            benefit: .coreStability,
            description: "Recommended exercise for today",
            instructions: ["Follow the guidance in the exercise library"],
            duration: duration,
            trimesterSuitability: [.first, .second, .third],
            createdBy: ProfessionalCredential(
                name: "AI Assistant",
                title: "Claude-powered Recommendations",
                certification: "AI-Generated",
                bio: "Personalized recommendations based on your pregnancy journey"
            )
        )
    }
    
    private func getCachedRecommendation(for userId: UUID) -> DailyExerciseRecommendation? {
        guard let data = userDefaults.data(forKey: "\(recommendationKey)_\(userId.uuidString)"),
              let recommendation = try? JSONDecoder().decode(DailyExerciseRecommendation.self, from: data) else {
            return nil
        }
        return recommendation
    }
    
    private func cacheRecommendation(_ recommendation: DailyExerciseRecommendation, for userId: UUID) {
        if let encoded = try? JSONEncoder().encode(recommendation) {
            userDefaults.set(encoded, forKey: "\(recommendationKey)_\(userId.uuidString)")
        }
    }
}

// Claude API Response Models
struct ClaudeResponse: Codable {
    let content: [ClaudeContent]
}

struct ClaudeContent: Codable {
    let text: String
}