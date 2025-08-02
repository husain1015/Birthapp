import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    var name: String
    var email: String
    var dueDate: Date
    var currentTrimester: Trimester
    var previousBirthHistory: [BirthHistory]?
    var fitnessLevel: FitnessLevel
    var goals: [PregnancyGoal]
    var concerns: [PregnancyConcern]
    var hasAcceptedDisclaimer: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(name: String, email: String, dueDate: Date, currentTrimester: Trimester, fitnessLevel: FitnessLevel) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.dueDate = dueDate
        self.currentTrimester = currentTrimester
        self.fitnessLevel = fitnessLevel
        self.previousBirthHistory = nil
        self.goals = []
        self.concerns = []
        self.hasAcceptedDisclaimer = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    var currentWeekOfPregnancy: Int {
        let calendar = Calendar.current
        let weeks = calendar.dateComponents([.weekOfYear], from: Date(), to: dueDate).weekOfYear ?? 0
        return max(1, 40 - weeks)
    }
    
    var daysUntilDueDate: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: Date(), to: dueDate).day ?? 0
    }
}

enum Trimester: String, Codable, CaseIterable {
    case first = "First Trimester"
    case second = "Second Trimester"
    case third = "Third Trimester"
}

enum FitnessLevel: String, Codable, CaseIterable {
    case sedentary = "Sedentary"
    case lightlyActive = "Lightly Active"
    case moderatelyActive = "Moderately Active"
    case veryActive = "Very Active"
    case athlete = "Athlete"
}

struct BirthHistory: Codable {
    var birthType: BirthType
    var year: Int
    var complications: String?
}

enum BirthType: String, Codable, CaseIterable {
    case vaginal = "Vaginal Birth"
    case cesarean = "C-Section"
    case vbac = "VBAC"
}

enum PregnancyGoal: String, Codable, CaseIterable {
    case naturalBirth = "Prepare for Natural Birth"
    case painManagement = "Learn Pain Management Techniques"
    case pelvicFloorHealth = "Strengthen Pelvic Floor"
    case reduceAnxiety = "Reduce Birth Anxiety"
    case vbacPrep = "Prepare for VBAC"
    case postpartumRecovery = "Optimize Postpartum Recovery"
}

enum PregnancyConcern: String, Codable, CaseIterable {
    case pelvicGirdlePain = "Pelvic Girdle Pain"
    case backPain = "Back Pain"
    case diastasisRecti = "Diastasis Recti"
    case incontinence = "Incontinence"
    case previousTrauma = "Previous Birth Trauma"
    case highRiskPregnancy = "High Risk Pregnancy"
}