import Foundation

// MARK: - Pregnancy Assessment Models

struct PregnancyAssessment: Codable {
    let id: UUID
    let userId: UUID
    var basicInfo: BasicPregnancyInfo
    var medicalHistory: MedicalHistory
    var lifestyleFactors: LifestyleFactors
    var pregnancyHistory: PregnancyHistory
    var currentSymptoms: CurrentSymptoms
    var fitnessLevel: FitnessAssessment
    var nutritionProfile: NutritionProfile
    var mentalHealthProfile: MentalHealthProfile
    var supportSystem: SupportSystemAssessment
    var preferences: PregnancyPreferences
    var riskFactors: [RiskFactor]
    var completedAt: Date
    
    init(userId: UUID) {
        self.id = UUID()
        self.userId = userId
        self.basicInfo = BasicPregnancyInfo()
        self.medicalHistory = MedicalHistory()
        self.lifestyleFactors = LifestyleFactors()
        self.pregnancyHistory = PregnancyHistory()
        self.currentSymptoms = CurrentSymptoms()
        self.fitnessLevel = FitnessAssessment()
        self.nutritionProfile = NutritionProfile()
        self.mentalHealthProfile = MentalHealthProfile()
        self.supportSystem = SupportSystemAssessment()
        self.preferences = PregnancyPreferences()
        self.riskFactors = []
        self.completedAt = Date()
    }
}

struct BasicPregnancyInfo: Codable {
    var age: Int?
    var dueDate: Date?
    var lastMenstrualPeriod: Date?
    var currentWeek: Int?
    var currentTrimester: Int?
    var height: Double? // in inches
    var prePregnancyWeight: Double? // in pounds
    var currentWeight: Double? // in pounds
    var isFirstPregnancy: Bool = true
    var multiplePregnancy: Bool = false
    var numberOfBabies: Int = 1
}

struct MedicalHistory: Codable {
    var chronicConditions: [ChronicCondition] = []
    var medications: [String] = []
    var allergies: [String] = []
    var previousSurgeries: [String] = []
    var familyHistory: FamilyMedicalHistory = FamilyMedicalHistory()
    var bloodType: String?
    var rhFactor: String?
}

struct ChronicCondition: Codable {
    enum ConditionType: String, Codable, CaseIterable {
        case diabetes = "Diabetes"
        case hypertension = "Hypertension"
        case thyroid = "Thyroid Disorder"
        case asthma = "Asthma"
        case heartDisease = "Heart Disease"
        case autoimmune = "Autoimmune Disorder"
        case mentalHealth = "Mental Health Condition"
        case epilepsy = "Epilepsy"
        case kidneydisease = "Kidney Disease"
        case other = "Other"
    }
    
    var type: ConditionType
    var details: String?
    var managementPlan: String?
}

struct FamilyMedicalHistory: Codable {
    var geneticConditions: [String] = []
    var pregnancyComplications: [String] = []
    var birthDefects: [String] = []
    var chromosomalAbnormalities: Bool = false
    var consanguinity: Bool = false // Blood relation with partner
}

struct LifestyleFactors: Codable {
    var occupation: String?
    var workHoursPerWeek: Int?
    var physicallyDemandingJob: Bool = false
    var exposureToChemicals: Bool = false
    var smoking: SmokingStatus = .never
    var alcoholUse: AlcoholUse = .none
    var caffeineCupsPerDay: Int = 0
    var sleepHoursPerNight: Double = 8.0
    var stressLevel: StressLevel = .moderate
}

enum SmokingStatus: String, Codable, CaseIterable {
    case never = "Never Smoked"
    case quit = "Quit Before Pregnancy"
    case quitDuringPregnancy = "Quit During Pregnancy"
    case current = "Currently Smoking"
}

enum AlcoholUse: String, Codable, CaseIterable {
    case none = "No Alcohol"
    case occasional = "Occasional (Stopped)"
    case regular = "Regular (Stopped)"
}

enum StressLevel: String, Codable, CaseIterable {
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
    case veryHigh = "Very High"
}

struct PregnancyHistory: Codable {
    var previousPregnancies: Int = 0
    var liveBirths: Int = 0
    var miscarriages: Int = 0
    var stillbirths: Int = 0
    var previousCSection: Bool = false
    var previousPregnancyComplications: [PregnancyComplication] = []
    var previousBirthWeights: [BirthWeight] = []
}

struct PregnancyComplication: Codable {
    enum ComplicationType: String, Codable, CaseIterable {
        case gestationalDiabetes = "Gestational Diabetes"
        case preeclampsia = "Preeclampsia"
        case pretermLabor = "Preterm Labor"
        case placentaPrevia = "Placenta Previa"
        case iugr = "IUGR (Growth Restriction)"
        case postpartumHemorrhage = "Postpartum Hemorrhage"
        case other = "Other"
    }
    
    var type: ComplicationType
    var details: String?
}

struct BirthWeight: Codable {
    var weightInPounds: Double
    var gestationalAgeWeeks: Int
}

struct CurrentSymptoms: Codable {
    var nausea: SeverityLevel = .none
    var fatigue: SeverityLevel = .none
    var backPain: SeverityLevel = .none
    var pelvicPain: SeverityLevel = .none
    var swelling: SeverityLevel = .none
    var headaches: SeverityLevel = .none
    var shortessOfBreath: SeverityLevel = .none
    var heartburn: SeverityLevel = .none
    var constipation: SeverityLevel = .none
    var moodChanges: SeverityLevel = .none
}

enum SeverityLevel: String, Codable, CaseIterable {
    case none = "None"
    case mild = "Mild"
    case moderate = "Moderate"
    case severe = "Severe"
}

struct FitnessAssessment: Codable {
    var prePregnancyActivityLevel: ActivityLevel = .moderate
    var currentActivityLevel: ActivityLevel = .light
    var exerciseFrequencyPerWeek: Int = 3
    var exerciseTypes: [ExerciseType] = []
    var exerciseLimitations: [String] = []
    var pelvicFloorAwareness: Bool = false
    var diastasisRectiConcern: Bool = false
}

enum ActivityLevel: String, Codable, CaseIterable {
    case sedentary = "Sedentary"
    case light = "Light Activity"
    case moderate = "Moderate Activity"
    case active = "Active"
    case veryActive = "Very Active"
}

enum ExerciseType: String, Codable, CaseIterable {
    case walking = "Walking"
    case swimming = "Swimming"
    case yoga = "Yoga"
    case pilates = "Pilates"
    case strengthTraining = "Strength Training"
    case running = "Running"
    case cycling = "Cycling"
    case dance = "Dance"
    case other = "Other"
}

struct NutritionProfile: Codable {
    var dietaryRestrictions: [DietaryRestriction] = []
    var supplementsTaken: [Supplement] = []
    var waterIntakeGlassesPerDay: Int = 8
    var mealsPerDay: Int = 3
    var cravings: [String] = []
    var aversions: [String] = []
}

enum DietaryRestriction: String, Codable, CaseIterable {
    case vegetarian = "Vegetarian"
    case vegan = "Vegan"
    case glutenFree = "Gluten Free"
    case dairyFree = "Dairy Free"
    case nutAllergy = "Nut Allergy"
    case gestationalDiabetesDiet = "Gestational Diabetes Diet"
    case other = "Other"
}

enum Supplement: String, Codable, CaseIterable {
    case prenatalVitamin = "Prenatal Vitamin"
    case folicAcid = "Folic Acid"
    case iron = "Iron"
    case calcium = "Calcium"
    case vitaminD = "Vitamin D"
    case omega3 = "Omega-3"
    case probiotics = "Probiotics"
    case other = "Other"
}

struct MentalHealthProfile: Codable {
    var anxietyLevel: SeverityLevel = .none
    var depressionSymptoms: SeverityLevel = .none
    var previousMentalHealthHistory: Bool = false
    var currentTherapy: Bool = false
    var meditationPractice: Bool = false
    var stressManagementTechniques: [String] = []
}

struct SupportSystemAssessment: Codable {
    var partnerSupport: SupportLevel = .high
    var familySupport: SupportLevel = .moderate
    var friendsSupport: SupportLevel = .moderate
    var workplaceSupport: SupportLevel = .moderate
    var financialStability: StabilityLevel = .stable
    var childcareArrangements: Bool = false
}

enum SupportLevel: String, Codable, CaseIterable {
    case none = "No Support"
    case low = "Low Support"
    case moderate = "Moderate Support"
    case high = "High Support"
}

enum StabilityLevel: String, Codable, CaseIterable {
    case unstable = "Unstable"
    case somewhatStable = "Somewhat Stable"
    case stable = "Stable"
    case veryStable = "Very Stable"
}

struct PregnancyPreferences: Codable {
    var birthLocationPreference: BirthLocation = .hospital
    var careProviderType: CareProvider = .obgyn
    var painManagementPreference: PainPreference = .openToOptions
    var breastfeedingIntention: BreastfeedingPlan = .exclusive
    var postpartumSupport: Bool = true
}

enum BirthLocation: String, Codable, CaseIterable {
    case hospital = "Hospital"
    case birthCenter = "Birth Center"
    case home = "Home"
    case undecided = "Undecided"
}

enum CareProvider: String, Codable, CaseIterable {
    case obgyn = "OB/GYN"
    case midwife = "Midwife"
    case familyDoctor = "Family Doctor"
    case combination = "Combination"
}

enum PainPreference: String, Codable, CaseIterable {
    case natural = "Natural/Unmedicated"
    case epidural = "Epidural"
    case openToOptions = "Open to Options"
    case undecided = "Undecided"
}

enum BreastfeedingPlan: String, Codable, CaseIterable {
    case exclusive = "Exclusive Breastfeeding"
    case combination = "Combination Feeding"
    case formula = "Formula Feeding"
    case undecided = "Undecided"
}

struct RiskFactor: Codable, Identifiable {
    let id: UUID = UUID()
    var category: RiskCategory
    var factor: String
    var severity: RiskSeverity
    var recommendations: [String]
}

enum RiskCategory: String, Codable, CaseIterable {
    case maternal = "Maternal Health"
    case fetal = "Fetal Development"
    case lifestyle = "Lifestyle"
    case environmental = "Environmental"
    case psychosocial = "Psychosocial"
}

enum RiskSeverity: String, Codable, CaseIterable {
    case low = "Low Risk"
    case moderate = "Moderate Risk"
    case high = "High Risk"
}