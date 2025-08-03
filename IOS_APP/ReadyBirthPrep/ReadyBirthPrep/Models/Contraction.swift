import Foundation

struct Contraction: Codable, Identifiable {
    let id: UUID
    var startTime: Date
    var endTime: Date?
    var duration: TimeInterval {
        guard let endTime = endTime else { return 0 }
        return endTime.timeIntervalSince(startTime)
    }
    var intensity: ContractionIntensity?
    var notes: String?
    
    init(startTime: Date = Date()) {
        self.id = UUID()
        self.startTime = startTime
    }
}

enum ContractionIntensity: Int, Codable, CaseIterable {
    case mild = 1
    case moderate = 2
    case strong = 3
    case veryStrong = 4
    
    var description: String {
        switch self {
        case .mild:
            return "Mild"
        case .moderate:
            return "Moderate"
        case .strong:
            return "Strong"
        case .veryStrong:
            return "Very Strong"
        }
    }
}

struct ContractionSession: Codable, Identifiable {
    let id: UUID
    var startTime: Date
    var contractions: [Contraction]
    var isActive: Bool
    
    init() {
        self.id = UUID()
        self.startTime = Date()
        self.contractions = []
        self.isActive = true
    }
    
    var averageFrequency: Double? {
        guard contractions.count > 1 else { return nil }
        
        let sortedContractions = contractions.sorted { $0.startTime < $1.startTime }
        var intervals: [TimeInterval] = []
        
        for i in 1..<sortedContractions.count {
            let interval = sortedContractions[i].startTime.timeIntervalSince(sortedContractions[i-1].startTime)
            intervals.append(interval)
        }
        
        guard !intervals.isEmpty else { return nil }
        let averageInterval = intervals.reduce(0, +) / Double(intervals.count)
        return 60.0 / averageInterval
    }
    
    var averageDuration: TimeInterval? {
        let completedContractions = contractions.filter { $0.endTime != nil }
        guard !completedContractions.isEmpty else { return nil }
        
        let totalDuration = completedContractions.reduce(0) { $0 + $1.duration }
        return totalDuration / Double(completedContractions.count)
    }
    
    var lastHourContractions: [Contraction] {
        let oneHourAgo = Date().addingTimeInterval(-3600)
        return contractions.filter { $0.startTime >= oneHourAgo }
    }
}