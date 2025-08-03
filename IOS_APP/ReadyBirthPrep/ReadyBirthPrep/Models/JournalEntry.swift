import Foundation

struct JournalEntry: Codable, Identifiable {
    let id: UUID
    var title: String
    var content: String
    var mood: MoodLevel
    var tags: [String]
    var createdAt: Date
    var updatedAt: Date
    
    init(title: String, content: String, mood: MoodLevel) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.mood = mood
        self.tags = []
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum MoodLevel: String, Codable, CaseIterable {
    case veryHappy = "Very Happy"
    case happy = "Happy"
    case neutral = "Neutral"
    case anxious = "Anxious"
    case sad = "Sad"
    case stressed = "Stressed"
}