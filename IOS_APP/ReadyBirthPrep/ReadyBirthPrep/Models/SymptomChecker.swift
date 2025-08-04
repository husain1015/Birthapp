import Foundation

// MARK: - Symptom Checker Models

struct Symptom: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var category: SymptomCategory
    var severity: SymptomSeverityLevel
    var description: String
    var commonInTrimester: [Trimester]
    var possibleCauses: [String]
    var selfCareRecommendations: [String]
    var warningSignsToWatch: [String]
    var whenToCallProvider: String
    var emergencySignsImmediate: [String]
    var relatedSymptoms: [String]
}

enum SymptomCategory: String, Codable, CaseIterable {
    case pain = "Pain & Discomfort"
    case digestive = "Digestive Issues"
    case bleeding = "Bleeding & Discharge"
    case respiratory = "Breathing & Heart"
    case neurological = "Head & Nervous System"
    case skin = "Skin Changes"
    case urinary = "Urinary Issues"
    case emotional = "Emotional Health"
    case movement = "Baby Movement"
    case other = "Other Symptoms"
}

enum SymptomSeverityLevel: String, Codable, CaseIterable {
    case mild = "Mild"
    case moderate = "Moderate"
    case severe = "Severe"
    case emergency = "Emergency"
}

struct SymptomAssessment: Codable, Identifiable {
    var id: UUID = UUID()
    let userId: UUID
    var symptom: Symptom
    var dateReported: Date
    var duration: SymptomDuration
    var frequency: SymptomFrequency
    var triggers: [String]
    var relievingFactors: [String]
    var associatedSymptoms: [String]
    var painScale: Int? // 1-10
    var affectingDailyLife: Bool
    var actionTaken: AssessmentAction
    var notes: String?
    var followUpDate: Date?
    var resolved: Bool = false
    var resolvedDate: Date?
}

enum SymptomDuration: String, Codable, CaseIterable {
    case justStarted = "Just Started"
    case hours = "Few Hours"
    case days = "1-3 Days"
    case week = "4-7 Days"
    case weeks = "More than a Week"
    case chronic = "Ongoing for Weeks"
}

enum SymptomFrequency: String, Codable, CaseIterable {
    case once = "One Time"
    case occasional = "Occasional"
    case daily = "Daily"
    case multiple = "Multiple Times Daily"
    case constant = "Constant"
}

enum AssessmentAction: String, Codable, CaseIterable {
    case selfCare = "Self-Care at Home"
    case callProvider = "Call Provider"
    case visitProvider = "Visit Provider"
    case emergency = "Seek Emergency Care"
    case monitoring = "Monitoring"
}

// MARK: - Symptom Database

struct SymptomDatabase {
    static let symptoms: [Symptom] = [
        // Pain & Discomfort
        Symptom(
            name: "Round Ligament Pain",
            category: .pain,
            severity: .mild,
            description: "Sharp, jabbing pain in the lower belly or groin area on one or both sides",
            commonInTrimester: [.second, .third],
            possibleCauses: ["Growing uterus stretching ligaments", "Sudden movements", "Position changes"],
            selfCareRecommendations: [
                "Move slowly when changing positions",
                "Support belly when coughing/sneezing",
                "Apply warm compress",
                "Gentle prenatal yoga",
                "Rest in comfortable position"
            ],
            warningSignsToWatch: ["Severe pain", "Pain with bleeding", "Fever", "Pain lasting hours"],
            whenToCallProvider: "Pain is severe, constant, or accompanied by other symptoms",
            emergencySignsImmediate: ["Heavy bleeding", "Severe abdominal pain", "Fever over 100.4°F"],
            relatedSymptoms: ["Back pain", "Pelvic pressure"]
        ),
        
        Symptom(
            name: "Back Pain",
            category: .pain,
            severity: .moderate,
            description: "Aching or sharp pain in the lower, middle, or upper back",
            commonInTrimester: [.second, .third],
            possibleCauses: ["Weight gain", "Posture changes", "Hormonal changes", "Stress on back muscles"],
            selfCareRecommendations: [
                "Practice good posture",
                "Wear supportive shoes",
                "Use pregnancy support belt",
                "Sleep with pillow between knees",
                "Gentle stretching exercises",
                "Warm bath or shower"
            ],
            warningSignsToWatch: ["Severe pain", "Pain with contractions", "Numbness/tingling", "Weakness in legs"],
            whenToCallProvider: "Pain is severe, persistent, or affects daily activities",
            emergencySignsImmediate: ["Back pain with regular contractions", "Loss of bladder control", "Severe pain with bleeding"],
            relatedSymptoms: ["Pelvic pain", "Sciatica", "Round ligament pain"]
        ),
        
        // Digestive Issues
        Symptom(
            name: "Morning Sickness",
            category: .digestive,
            severity: .mild,
            description: "Nausea and vomiting, especially in the morning but can occur any time",
            commonInTrimester: [.first],
            possibleCauses: ["Hormonal changes", "Enhanced smell sensitivity", "Low blood sugar", "Stress"],
            selfCareRecommendations: [
                "Eat small, frequent meals",
                "Keep crackers by bedside",
                "Stay hydrated with small sips",
                "Try ginger tea or candies",
                "Avoid trigger foods/smells",
                "Get fresh air",
                "Rest when possible"
            ],
            warningSignsToWatch: ["Can't keep fluids down", "Weight loss", "Dizziness", "Dark urine"],
            whenToCallProvider: "Vomiting more than 3 times daily or showing dehydration signs",
            emergencySignsImmediate: ["Severe dehydration", "Fainting", "Blood in vomit", "Severe abdominal pain"],
            relatedSymptoms: ["Fatigue", "Food aversions", "Heightened smell"]
        ),
        
        Symptom(
            name: "Heartburn",
            category: .digestive,
            severity: .mild,
            description: "Burning sensation in chest or throat, especially after eating",
            commonInTrimester: [.second, .third],
            possibleCauses: ["Hormones relaxing esophageal sphincter", "Growing uterus pressure", "Slower digestion"],
            selfCareRecommendations: [
                "Eat smaller meals",
                "Avoid spicy/fatty foods",
                "Don't lie down after eating",
                "Elevate head while sleeping",
                "Wear loose clothing",
                "Try antacids (provider-approved)"
            ],
            warningSignsToWatch: ["Severe chest pain", "Difficulty swallowing", "Weight loss", "Black stools"],
            whenToCallProvider: "Heartburn interferes with eating or sleeping",
            emergencySignsImmediate: ["Severe chest pain", "Shortness of breath", "Pain radiating to arm"],
            relatedSymptoms: ["Indigestion", "Nausea", "Bloating"]
        ),
        
        // Bleeding & Discharge
        Symptom(
            name: "Light Spotting",
            category: .bleeding,
            severity: .mild,
            description: "Light pink or brown spotting, less than a period",
            commonInTrimester: [.first],
            possibleCauses: ["Implantation bleeding", "Cervical changes", "After intercourse", "After pelvic exam"],
            selfCareRecommendations: [
                "Wear a panty liner",
                "Track amount and color",
                "Rest and avoid strenuous activity",
                "Stay hydrated",
                "Avoid intercourse until checked"
            ],
            warningSignsToWatch: ["Increasing bleeding", "Bright red blood", "Clots", "Cramping", "Dizziness"],
            whenToCallProvider: "Any bleeding should be reported to your provider",
            emergencySignsImmediate: ["Heavy bleeding (soaking pad in hour)", "Large clots", "Severe pain", "Dizziness/fainting"],
            relatedSymptoms: ["Cramping", "Back pain"]
        ),
        
        // Respiratory
        Symptom(
            name: "Shortness of Breath",
            category: .respiratory,
            severity: .moderate,
            description: "Feeling breathless or unable to take deep breaths",
            commonInTrimester: [.second, .third],
            possibleCauses: ["Growing uterus pressing on diaphragm", "Increased oxygen needs", "Anemia", "Normal pregnancy changes"],
            selfCareRecommendations: [
                "Sit or stand up straight",
                "Sleep propped up on pillows",
                "Take breaks during activities",
                "Practice breathing exercises",
                "Avoid overexertion"
            ],
            warningSignsToWatch: ["Sudden onset", "Chest pain", "Rapid heartbeat", "Coughing", "Wheezing"],
            whenToCallProvider: "Shortness of breath at rest or interfering with daily activities",
            emergencySignsImmediate: ["Sudden severe shortness of breath", "Chest pain", "Blue lips/fingers", "Coughing up blood"],
            relatedSymptoms: ["Fatigue", "Heart palpitations", "Dizziness"]
        ),
        
        // Movement
        Symptom(
            name: "Decreased Baby Movement",
            category: .movement,
            severity: .severe,
            description: "Noticeable decrease in baby's normal movement pattern",
            commonInTrimester: [.second, .third],
            possibleCauses: ["Baby sleeping", "Your activity level", "Position of placenta", "Less room as baby grows"],
            selfCareRecommendations: [
                "Lie on left side",
                "Drink cold water or juice",
                "Eat a snack",
                "Play music or talk to baby",
                "Do kick counts",
                "Rest in quiet environment"
            ],
            warningSignsToWatch: ["No movement for 2 hours", "Significant change in pattern", "Weak movements"],
            whenToCallProvider: "Less than 10 movements in 2 hours or significant change in pattern",
            emergencySignsImmediate: ["No movement despite stimulation", "Sudden complete stop of movement"],
            relatedSymptoms: ["Contractions", "Bleeding", "Fluid leaking"]
        ),
        
        // Neurological
        Symptom(
            name: "Severe Headache",
            category: .neurological,
            severity: .moderate,
            description: "Intense headache that doesn't respond to usual remedies",
            commonInTrimester: [.second, .third],
            possibleCauses: ["Hormonal changes", "Dehydration", "Tension", "High blood pressure", "Preeclampsia"],
            selfCareRecommendations: [
                "Rest in dark, quiet room",
                "Apply cold compress",
                "Stay hydrated",
                "Practice relaxation techniques",
                "Gentle neck stretches",
                "Check blood pressure if possible"
            ],
            warningSignsToWatch: ["Vision changes", "Swelling", "Upper abdominal pain", "Sudden onset"],
            whenToCallProvider: "Severe headache, especially with other symptoms",
            emergencySignsImmediate: ["Sudden severe headache", "Vision changes", "Confusion", "High blood pressure"],
            relatedSymptoms: ["Vision changes", "Nausea", "Swelling", "Upper abdominal pain"]
        ),
        
        // Urinary
        Symptom(
            name: "Painful Urination",
            category: .urinary,
            severity: .moderate,
            description: "Burning, stinging, or pain when urinating",
            commonInTrimester: [.first, .second, .third],
            possibleCauses: ["Urinary tract infection", "Vaginal infection", "Dehydration", "Kidney infection"],
            selfCareRecommendations: [
                "Drink plenty of water",
                "Urinate frequently",
                "Wipe front to back",
                "Avoid irritants",
                "Wear cotton underwear"
            ],
            warningSignsToWatch: ["Fever", "Back pain", "Blood in urine", "Frequent urination", "Cloudy urine"],
            whenToCallProvider: "Any painful urination needs evaluation",
            emergencySignsImmediate: ["High fever", "Severe back pain", "Vomiting", "Confusion"],
            relatedSymptoms: ["Frequent urination", "Urgency", "Lower abdominal pain"]
        ),
        
        // Emotional
        Symptom(
            name: "Severe Mood Changes",
            category: .emotional,
            severity: .moderate,
            description: "Extreme mood swings, persistent sadness, or anxiety",
            commonInTrimester: [.first, .second, .third],
            possibleCauses: ["Hormonal changes", "Stress", "Lack of sleep", "Depression", "Anxiety"],
            selfCareRecommendations: [
                "Talk to support system",
                "Regular exercise",
                "Adequate sleep",
                "Relaxation techniques",
                "Journaling",
                "Limit stressors"
            ],
            warningSignsToWatch: ["Thoughts of self-harm", "Panic attacks", "Unable to function", "Persistent sadness"],
            whenToCallProvider: "Mood changes interfering with daily life or lasting more than 2 weeks",
            emergencySignsImmediate: ["Thoughts of harming self or baby", "Severe panic", "Hallucinations"],
            relatedSymptoms: ["Sleep problems", "Appetite changes", "Fatigue", "Anxiety"]
        )
    ]
    
    static func getSymptomsByCategory(_ category: SymptomCategory) -> [Symptom] {
        symptoms.filter { $0.category == category }
    }
    
    static func getSymptomsByTrimester(_ trimester: Trimester) -> [Symptom] {
        symptoms.filter { $0.commonInTrimester.contains(trimester) }
    }
    
    static func searchSymptoms(query: String) -> [Symptom] {
        let lowercaseQuery = query.lowercased()
        return symptoms.filter { symptom in
            symptom.name.lowercased().contains(lowercaseQuery) ||
            symptom.description.lowercased().contains(lowercaseQuery) ||
            symptom.relatedSymptoms.contains { $0.lowercased().contains(lowercaseQuery) }
        }
    }
}

// MARK: - AI Symptom Assessment Engine

class SymptomAssessmentEngine {
    
    static func assessSymptom(
        symptom: Symptom,
        duration: SymptomDuration,
        frequency: SymptomFrequency,
        painScale: Int?,
        affectingDailyLife: Bool,
        associatedSymptoms: [String],
        currentTrimester: Trimester
    ) -> AssessmentRecommendation {
        
        var urgencyScore = 0
        var recommendedAction: AssessmentAction = .selfCare
        var recommendations: [String] = []
        var mustCallProviderReasons: [String] = []
        var emergencyReasons: [String] = []
        
        // Base severity score
        switch symptom.severity {
        case .mild:
            urgencyScore += 1
        case .moderate:
            urgencyScore += 3
        case .severe:
            urgencyScore += 5
        case .emergency:
            urgencyScore += 10
        }
        
        // Duration factor
        switch duration {
        case .justStarted, .hours:
            urgencyScore += 1
        case .days:
            urgencyScore += 2
        case .week, .weeks, .chronic:
            urgencyScore += 3
        }
        
        // Frequency factor
        switch frequency {
        case .once, .occasional:
            urgencyScore += 1
        case .daily:
            urgencyScore += 2
        case .multiple, .constant:
            urgencyScore += 3
        }
        
        // Pain scale factor
        if let pain = painScale {
            if pain >= 7 {
                urgencyScore += 3
                mustCallProviderReasons.append("Severe pain level (\(pain)/10)")
            } else if pain >= 5 {
                urgencyScore += 2
            }
        }
        
        // Daily life impact
        if affectingDailyLife {
            urgencyScore += 2
            mustCallProviderReasons.append("Significantly affecting daily activities")
        }
        
        // Associated symptoms check
        let warningSymptoms = ["Heavy bleeding", "Severe pain", "Fever", "Vision changes", "Chest pain"]
        let presentWarningSymptoms = associatedSymptoms.filter { warningSymptoms.contains($0) }
        if !presentWarningSymptoms.isEmpty {
            urgencyScore += 5
            emergencyReasons.append(contentsOf: presentWarningSymptoms)
        }
        
        // Determine action based on score and specific conditions
        if urgencyScore >= 10 || symptom.severity == .emergency {
            recommendedAction = .emergency
            recommendations = [
                "Seek immediate medical attention",
                "Call 911 or go to emergency room",
                "Do not wait or drive yourself if severe"
            ]
        } else if urgencyScore >= 7 || symptom.severity == .severe {
            recommendedAction = .visitProvider
            recommendations = [
                "Contact your provider today",
                "Request urgent appointment",
                "Monitor symptoms closely"
            ]
        } else if urgencyScore >= 5 {
            recommendedAction = .callProvider
            recommendations = [
                "Call your provider's office",
                "Discuss symptoms with nurse",
                "Follow their guidance"
            ]
        } else if urgencyScore >= 3 {
            recommendedAction = .monitoring
            recommendations = [
                "Monitor symptoms closely",
                "Try self-care measures",
                "Call if symptoms worsen"
            ]
        } else {
            recommendedAction = .selfCare
            recommendations = symptom.selfCareRecommendations
        }
        
        return AssessmentRecommendation(
            recommendedAction: recommendedAction,
            urgencyLevel: getUrgencyLevel(from: urgencyScore),
            recommendations: recommendations,
            warningSignsToWatch: symptom.warningSignsToWatch,
            mustCallProviderReasons: mustCallProviderReasons,
            emergencyReasons: emergencyReasons,
            selfCareInstructions: symptom.selfCareRecommendations
        )
    }
    
    private static func getUrgencyLevel(from score: Int) -> UrgencyLevel {
        switch score {
        case 0...3:
            return .low
        case 4...6:
            return .moderate
        case 7...9:
            return .high
        default:
            return .critical
        }
    }
}

struct AssessmentRecommendation {
    let recommendedAction: AssessmentAction
    let urgencyLevel: UrgencyLevel
    let recommendations: [String]
    let warningSignsToWatch: [String]
    let mustCallProviderReasons: [String]
    let emergencyReasons: [String]
    let selfCareInstructions: [String]
}

enum UrgencyLevel: String {
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
    case critical = "Critical"
    
    var color: String {
        switch self {
        case .low:
            return "green"
        case .moderate:
            return "yellow"
        case .high:
            return "orange"
        case .critical:
            return "red"
        }
    }
}

// MARK: - Symptom History Manager

class SymptomHistoryManager: ObservableObject {
    @Published var assessments: [SymptomAssessment] = []
    private let userId: UUID
    private let storageKey = "SymptomHistory"
    
    init(userId: UUID) {
        self.userId = userId
        loadAssessments()
    }
    
    func addAssessment(_ assessment: SymptomAssessment) {
        assessments.append(assessment)
        saveAssessments()
    }
    
    func updateAssessment(_ assessment: SymptomAssessment) {
        if let index = assessments.firstIndex(where: { $0.id == assessment.id }) {
            assessments[index] = assessment
            saveAssessments()
        }
    }
    
    func getActiveSymptoms() -> [SymptomAssessment] {
        assessments.filter { !$0.resolved }.sorted { $0.dateReported > $1.dateReported }
    }
    
    func getRecentAssessments(days: Int = 7) -> [SymptomAssessment] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return assessments.filter { $0.dateReported > cutoffDate }.sorted { $0.dateReported > $1.dateReported }
    }
    
    func getAssessmentsByCategory(_ category: SymptomCategory) -> [SymptomAssessment] {
        assessments.filter { $0.symptom.category == category }.sorted { $0.dateReported > $1.dateReported }
    }
    
    func markResolved(assessmentId: UUID) {
        if let index = assessments.firstIndex(where: { $0.id == assessmentId }) {
            assessments[index].resolved = true
            assessments[index].resolvedDate = Date()
            saveAssessments()
        }
    }
    
    private func loadAssessments() {
        if let data = UserDefaults.standard.data(forKey: "\(storageKey)_\(userId)"),
           let decoded = try? JSONDecoder().decode([SymptomAssessment].self, from: data) {
            assessments = decoded
        }
    }
    
    private func saveAssessments() {
        if let encoded = try? JSONEncoder().encode(assessments) {
            UserDefaults.standard.set(encoded, forKey: "\(storageKey)_\(userId)")
        }
    }
}