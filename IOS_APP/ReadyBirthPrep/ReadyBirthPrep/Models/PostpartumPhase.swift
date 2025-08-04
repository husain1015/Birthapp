import Foundation

struct PostpartumPhase: Codable, Identifiable {
    let id: UUID
    var phase: RecoveryPhase
    var startDate: Date
    var endDate: Date?
    var exercises: [Exercise]
    var guidelines: [String]
    var redFlags: [String]
    var requiresMedicalClearance: Bool
    
    init(phase: RecoveryPhase, startDate: Date) {
        self.id = UUID()
        self.phase = phase
        self.startDate = startDate
        self.exercises = []
        self.guidelines = []
        self.redFlags = []
        self.requiresMedicalClearance = phase == .phase3
    }
    
    var isActive: Bool {
        endDate == nil
    }
    
    var weeksSinceBirth: Int {
        let calendar = Calendar.current
        let weeks = calendar.dateComponents([.weekOfYear], from: startDate, to: Date()).weekOfYear ?? 0
        return weeks
    }
}

enum RecoveryPhase: String, Codable, CaseIterable {
    case phase1 = "Phase 1: Immediate Recovery (0-2 weeks)"
    case phase2 = "Phase 2: Gentle Reconnection (2-6 weeks)"
    case phase3 = "Phase 3: Progressive Strengthening (6+ weeks)"
    
    var description: String {
        switch self {
        case .phase1:
            return "Focus on rest, gentle breathing, and basic pelvic floor awareness"
        case .phase2:
            return "Gentle core connection, posture work, and walking"
        case .phase3:
            return "Progressive strength training with medical clearance"
        }
    }
    
    var minimumWeeks: Int {
        switch self {
        case .phase1: return 0
        case .phase2: return 2
        case .phase3: return 6
        }
    }
}

struct PostpartumRecovery: Codable {
    var birthDate: Date
    var birthType: BirthType
    var currentPhase: RecoveryPhase
    var medicalClearanceDate: Date?
    var symptoms: [PostpartumSymptom]
    var completedExercises: [CompletedExercise]
    
    var daysSinceBirth: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: birthDate, to: Date()).day ?? 0
    }
    
    var weeksSinceBirth: Int {
        daysSinceBirth / 7
    }
}

struct PostpartumSymptom: Codable, Identifiable {
    var id: UUID = UUID()
    var symptom: SymptomType
    var severity: SymptomSeverity
    var dateReported: Date
    var notes: String?
}

enum SymptomType: String, Codable, CaseIterable {
    case bleeding = "Bleeding"
    case pain = "Pain/Discomfort"
    case incontinence = "Incontinence"
    case diastasisRecti = "Abdominal Separation"
    case backPain = "Back Pain"
    case moodChanges = "Mood Changes"
    case fatigue = "Extreme Fatigue"
}

enum SymptomSeverity: String, Codable, CaseIterable {
    case mild = "Mild"
    case moderate = "Moderate"
    case severe = "Severe"
}

struct CompletedExercise: Codable, Identifiable {
    var id: UUID = UUID()
    var exerciseId: UUID
    var completedAt: Date
    var duration: TimeInterval
    var notes: String?
    var difficulty: ExerciseDifficulty?
}

enum ExerciseDifficulty: String, Codable, CaseIterable {
    case tooEasy = "Too Easy"
    case justRight = "Just Right"
    case tooHard = "Too Hard"
}