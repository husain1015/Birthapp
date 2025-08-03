import Foundation

struct Meditation: Codable, Identifiable {
    let id: UUID
    var type: MeditationType
    var duration: TimeInterval
    var completedAt: Date
    var notes: String?
    
    init(type: MeditationType, duration: TimeInterval) {
        self.id = UUID()
        self.type = type
        self.duration = duration
        self.completedAt = Date()
    }
}

enum MeditationType: String, Codable, CaseIterable {
    case breathing = "Breathing Exercise"
    case bodyScanning = "Body Scanning"
    case visualization = "Visualization"
    case guidedImagery = "Guided Imagery"
    case affirmations = "Affirmations"
    case movement = "Movement Meditation"
}