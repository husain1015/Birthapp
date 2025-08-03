import Foundation

struct ExerciseHistory: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let exerciseId: UUID
    let exerciseName: String
    let category: ExerciseCategory
    let completedAt: Date
    let duration: TimeInterval
    let notes: String?
    let difficultyRating: Int? // 1-5 scale
    let feelingAfter: FeelingAfterExercise?
    
    init(userId: UUID, exerciseId: UUID, exerciseName: String, category: ExerciseCategory, duration: TimeInterval) {
        self.id = UUID()
        self.userId = userId
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.category = category
        self.completedAt = Date()
        self.duration = duration
        self.notes = nil
        self.difficultyRating = nil
        self.feelingAfter = nil
    }
}

enum FeelingAfterExercise: String, Codable, CaseIterable {
    case energized = "Energized"
    case relaxed = "Relaxed"
    case tired = "Tired"
    case sore = "Sore"
    case accomplished = "Accomplished"
}

struct DailyExerciseRecommendation: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let date: Date
    let weekOfPregnancy: Int
    let recommendedExercises: [Exercise]
    let reasoning: String
    let focusAreas: [String]
    let safetyNotes: [String]
    let createdAt: Date
    
    init(userId: UUID, weekOfPregnancy: Int, recommendedExercises: [Exercise], reasoning: String, focusAreas: [String], safetyNotes: [String]) {
        self.id = UUID()
        self.userId = userId
        self.date = Date()
        self.weekOfPregnancy = weekOfPregnancy
        self.recommendedExercises = recommendedExercises
        self.reasoning = reasoning
        self.focusAreas = focusAreas
        self.safetyNotes = safetyNotes
        self.createdAt = Date()
    }
}