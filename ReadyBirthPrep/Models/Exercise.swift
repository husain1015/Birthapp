import Foundation

struct Exercise: Codable, Identifiable {
    let id: UUID
    var name: String
    var category: ExerciseCategory
    var benefit: ExerciseBenefit
    var description: String
    var instructions: [String]
    var duration: TimeInterval
    var trimesterSuitability: [Trimester]
    var videoURL: String?
    var thumbnailURL: String?
    var modificationOptions: [String]
    var contraindications: [String]
    var equipmentNeeded: [String]
    var createdBy: ProfessionalCredential
    
    init(name: String, category: ExerciseCategory, benefit: ExerciseBenefit, description: String, instructions: [String], duration: TimeInterval, trimesterSuitability: [Trimester], createdBy: ProfessionalCredential) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.benefit = benefit
        self.description = description
        self.instructions = instructions
        self.duration = duration
        self.trimesterSuitability = trimesterSuitability
        self.createdBy = createdBy
        self.modificationOptions = []
        self.contraindications = []
        self.equipmentNeeded = []
    }
}

enum ExerciseCategory: String, Codable, CaseIterable {
    case breathing = "Breathing Exercises"
    case pelvicFloor = "Pelvic Floor"
    case core = "Core Stability"
    case mobility = "Mobility & Stretching"
    case strength = "Strength Training"
    case laborPrep = "Labor Preparation"
    case relaxation = "Relaxation"
}

enum ExerciseBenefit: String, Codable, CaseIterable {
    case pelvicFloorRelaxation = "Pelvic Floor Relaxation"
    case pelvicFloorStrength = "Pelvic Floor Strengthening"
    case coreStability = "Core Stability"
    case hipOpening = "Hip Opening"
    case painRelief = "Pain Relief"
    case laborEndurance = "Labor Endurance"
    case posture = "Posture Improvement"
    case stressReduction = "Stress Reduction"
}

struct ExerciseRoutine: Codable, Identifiable {
    let id: UUID
    var name: String
    var description: String
    var exercises: [Exercise]
    var totalDuration: TimeInterval
    var trimester: Trimester
    var focusArea: ExerciseBenefit
    var difficulty: RoutineDifficulty
    
    var calculatedDuration: TimeInterval {
        exercises.reduce(0) { $0 + $1.duration }
    }
}

enum RoutineDifficulty: String, Codable, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
}

struct ProfessionalCredential: Codable {
    var name: String
    var title: String
    var certification: String
    var bio: String?
}