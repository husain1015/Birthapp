import Foundation

// MARK: - Mental Health Models

struct MoodEntry: Codable, Identifiable {
    var id: UUID = UUID()
    let userId: UUID
    var date: Date
    var overallMood: MentalHealthMoodLevel
    var emotions: [Emotion]
    var physicalSymptoms: [PhysicalSymptom]
    var sleepQuality: SleepQuality?
    var sleepHours: Double?
    var appetiteLevel: AppetiteLevel?
    var energyLevel: EnergyLevel?
    var anxietyLevel: Int? // 0-10 scale
    var stressLevel: Int? // 0-10 scale
    var babyBondingLevel: Int? // 0-10 scale
    var supportLevel: Int? // 0-10 scale
    var triggers: [String]
    var copingStrategiesUsed: [CopingStrategy]
    var notes: String?
    var needsSupport: Bool = false
    var createdAt: Date = Date()
}

enum MentalHealthMoodLevel: Int, Codable, CaseIterable {
    case veryLow = 1
    case low = 2
    case neutral = 3
    case good = 4
    case veryGood = 5
    
    var emoji: String {
        switch self {
        case .veryLow: return "😢"
        case .low: return "😔"
        case .neutral: return "😐"
        case .good: return "🙂"
        case .veryGood: return "😊"
        }
    }
    
    var description: String {
        switch self {
        case .veryLow: return "Very Low"
        case .low: return "Low"
        case .neutral: return "Neutral"
        case .good: return "Good"
        case .veryGood: return "Very Good"
        }
    }
}

enum Emotion: String, Codable, CaseIterable {
    // Positive
    case happy = "Happy"
    case calm = "Calm"
    case grateful = "Grateful"
    case hopeful = "Hopeful"
    case confident = "Confident"
    case loved = "Loved"
    case excited = "Excited"
    case peaceful = "Peaceful"
    
    // Negative
    case sad = "Sad"
    case anxious = "Anxious"
    case overwhelmed = "Overwhelmed"
    case irritable = "Irritable"
    case guilty = "Guilty"
    case lonely = "Lonely"
    case angry = "Angry"
    case scared = "Scared"
    case disconnected = "Disconnected"
    case inadequate = "Inadequate"
    case numb = "Numb"
    
    var isPositive: Bool {
        switch self {
        case .happy, .calm, .grateful, .hopeful, .confident, .loved, .excited, .peaceful:
            return true
        default:
            return false
        }
    }
}

enum PhysicalSymptom: String, Codable, CaseIterable {
    case headache = "Headache"
    case fatigue = "Fatigue"
    case insomnia = "Insomnia"
    case appetiteLoss = "Loss of Appetite"
    case overeating = "Overeating"
    case nausea = "Nausea"
    case muscleAches = "Muscle Aches"
    case chestTightness = "Chest Tightness"
    case rapidHeartbeat = "Rapid Heartbeat"
    case dizziness = "Dizziness"
    case hotFlashes = "Hot Flashes"
    case nightSweats = "Night Sweats"
}

enum SleepQuality: String, Codable, CaseIterable {
    case terrible = "Terrible"
    case poor = "Poor"
    case fair = "Fair"
    case good = "Good"
    case excellent = "Excellent"
}

enum AppetiteLevel: String, Codable, CaseIterable {
    case none = "No Appetite"
    case low = "Low"
    case normal = "Normal"
    case increased = "Increased"
    case excessive = "Excessive"
}

enum EnergyLevel: String, Codable, CaseIterable {
    case veryLow = "Very Low"
    case low = "Low"
    case moderate = "Moderate"
    case good = "Good"
    case high = "High"
}

enum CopingStrategy: String, Codable, CaseIterable {
    case deepBreathing = "Deep Breathing"
    case meditation = "Meditation"
    case exercise = "Exercise"
    case talkingToFriend = "Talked to Friend"
    case talkingToPartner = "Talked to Partner"
    case journaling = "Journaling"
    case shower = "Shower/Bath"
    case music = "Listened to Music"
    case nature = "Time in Nature"
    case sleep = "Rest/Sleep"
    case professionalHelp = "Professional Help"
    case medication = "Medication"
    case prayerSpirituality = "Prayer/Spirituality"
    case creative = "Creative Activity"
    case reading = "Reading"
}

// MARK: - Screening Tools

struct EPDSScreening: Codable, Identifiable {
    var id: UUID = UUID()
    let userId: UUID
    var date: Date
    var responses: [EPDSQuestion: Int]
    var totalScore: Int
    var riskLevel: RiskLevel
    var suicidalIdeation: Bool
    var completedPostpartum: Bool
    var weeksPostpartum: Int?
    
    init(userId: UUID, responses: [EPDSQuestion: Int], weeksPostpartum: Int? = nil) {
        self.userId = userId
        self.date = Date()
        self.responses = responses
        self.totalScore = responses.values.reduce(0, +)
        self.suicidalIdeation = (responses[.selfHarm] ?? 0) > 0
        self.riskLevel = EPDSScreening.calculateRiskLevel(score: totalScore, suicidalIdeation: suicidalIdeation)
        self.completedPostpartum = weeksPostpartum != nil
        self.weeksPostpartum = weeksPostpartum
    }
    
    static func calculateRiskLevel(score: Int, suicidalIdeation: Bool) -> RiskLevel {
        if suicidalIdeation {
            return .critical
        } else if score >= 13 {
            return .high
        } else if score >= 10 {
            return .moderate
        } else {
            return .low
        }
    }
}

enum EPDSQuestion: String, Codable, CaseIterable {
    case laugh = "I have been able to laugh and see the funny side of things"
    case enjoyment = "I have looked forward with enjoyment to things"
    case blame = "I have blamed myself unnecessarily when things went wrong"
    case anxious = "I have been anxious or worried for no good reason"
    case scared = "I have felt scared or panicky for no very good reason"
    case overwhelmed = "Things have been getting on top of me"
    case unhappy = "I have been so unhappy that I have had difficulty sleeping"
    case sad = "I have felt sad or miserable"
    case crying = "I have been so unhappy that I have been crying"
    case selfHarm = "The thought of harming myself has occurred to me"
    
    var options: [(text: String, score: Int)] {
        switch self {
        case .laugh, .enjoyment:
            return [
                ("As much as I always could", 0),
                ("Not quite so much now", 1),
                ("Definitely not so much now", 2),
                ("Not at all", 3)
            ]
        case .blame:
            return [
                ("Yes, most of the time", 3),
                ("Yes, some of the time", 2),
                ("Not very often", 1),
                ("No, never", 0)
            ]
        case .anxious, .scared, .overwhelmed, .unhappy, .sad, .crying:
            return [
                ("Yes, most of the time", 3),
                ("Yes, sometimes", 2),
                ("No, not much", 1),
                ("No, not at all", 0)
            ]
        case .selfHarm:
            return [
                ("Yes, quite often", 3),
                ("Sometimes", 2),
                ("Hardly ever", 1),
                ("Never", 0)
            ]
        }
    }
}

enum RiskLevel: String, Codable {
    case low = "Low Risk"
    case moderate = "Moderate Risk"
    case high = "High Risk"
    case critical = "Critical - Immediate Support Needed"
    
    var color: String {
        switch self {
        case .low: return "green"
        case .moderate: return "yellow"
        case .high: return "orange"
        case .critical: return "red"
        }
    }
    
    var recommendations: [String] {
        switch self {
        case .low:
            return [
                "Continue self-care practices",
                "Maintain regular check-ins with healthcare provider",
                "Stay connected with support system"
            ]
        case .moderate:
            return [
                "Consider talking to your healthcare provider",
                "Increase support from family and friends",
                "Consider joining a support group",
                "Practice daily self-care activities"
            ]
        case .high:
            return [
                "Contact your healthcare provider within 24-48 hours",
                "Consider therapy or counseling",
                "Reach out to trusted support people",
                "Evaluate need for additional help with baby care"
            ]
        case .critical:
            return [
                "Contact your healthcare provider immediately",
                "Call crisis hotline if having thoughts of self-harm",
                "Do not be alone - reach out to someone now",
                "Emergency services: 911 or 988 (Suicide & Crisis Lifeline)"
            ]
        }
    }
}

// MARK: - Support Resources

struct SupportResource: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var type: ResourceType
    var description: String
    var phoneNumber: String?
    var website: String?
    var hours: String?
    var isCrisis: Bool
    var cost: String?
}

enum ResourceType: String, Codable, CaseIterable {
    case hotline = "Crisis Hotline"
    case supportGroup = "Support Group"
    case therapy = "Therapy/Counseling"
    case onlineResource = "Online Resource"
    case app = "Mobile App"
    case medical = "Medical Provider"
    case community = "Community Resource"
}

// MARK: - Mental Health Manager

class MentalHealthManager: ObservableObject {
    @Published var moodEntries: [MoodEntry] = []
    @Published var screenings: [EPDSScreening] = []
    @Published var currentStreak: Int = 0
    @Published var supportResources: [SupportResource] = []
    
    private let userId: UUID
    private let storageKey = "MentalHealthEntries"
    private let screeningsKey = "MentalHealthScreenings"
    
    init(userId: UUID) {
        self.userId = userId
        loadData()
        loadDefaultResources()
        updateStreak()
    }
    
    // MARK: - Mood Tracking
    
    func addMoodEntry(_ entry: MoodEntry) {
        moodEntries.append(entry)
        updateStreak()
        checkForConcerningPatterns()
        saveData()
    }
    
    func updateMoodEntry(_ entry: MoodEntry) {
        if let index = moodEntries.firstIndex(where: { $0.id == entry.id }) {
            moodEntries[index] = entry
            saveData()
        }
    }
    
    func getTodaysMoodEntry() -> MoodEntry? {
        let calendar = Calendar.current
        return moodEntries.first { entry in
            calendar.isDateInToday(entry.date)
        }
    }
    
    func getMoodTrend(days: Int = 7) -> [MoodEntry] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return moodEntries
            .filter { $0.date > cutoffDate }
            .sorted { $0.date < $1.date }
    }
    
    func getAverageMood(days: Int = 7) -> Double {
        let recentEntries = getMoodTrend(days: days)
        guard !recentEntries.isEmpty else { return 3.0 }
        
        let total = recentEntries.reduce(0) { $0 + $1.overallMood.rawValue }
        return Double(total) / Double(recentEntries.count)
    }
    
    // MARK: - Screening
    
    func addScreening(_ screening: EPDSScreening) {
        screenings.append(screening)
        saveScreenings()
        
        if screening.riskLevel == .critical {
            // Trigger immediate support resources
        }
    }
    
    func getLatestScreening() -> EPDSScreening? {
        screenings.sorted { $0.date > $1.date }.first
    }
    
    func shouldPromptForScreening(weeksPostpartum: Int) -> Bool {
        // Recommended screening times: 2 weeks, 6 weeks, 3 months, 6 months
        let screeningWeeks = [2, 6, 12, 24]
        
        guard screeningWeeks.contains(weeksPostpartum) else { return false }
        
        // Check if already screened in the past week
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let recentScreening = screenings.first { screening in
            screening.date > oneWeekAgo &&
            screening.weeksPostpartum == weeksPostpartum
        }
        
        return recentScreening == nil
    }
    
    // MARK: - Pattern Detection
    
    private func checkForConcerningPatterns() {
        let recentEntries = getMoodTrend(days: 14)
        
        // Check for consistent low mood
        let lowMoodDays = recentEntries.filter { $0.overallMood.rawValue <= 2 }.count
        if lowMoodDays >= 7 {
            // Flag for provider notification
        }
        
        // Check for severe symptoms
        let severeAnxiety = recentEntries.filter { ($0.anxietyLevel ?? 0) >= 8 }.count
        let poorSleep = recentEntries.filter { $0.sleepQuality == .terrible || $0.sleepQuality == .poor }.count
        
        if severeAnxiety >= 5 || poorSleep >= 7 {
            // Suggest resources
        }
    }
    
    // MARK: - Insights
    
    func generateInsights() -> [MentalHealthInsight] {
        var insights: [MentalHealthInsight] = []
        
        let recentMood = getAverageMood(days: 7)
        let previousMood = getAverageMood(days: 14) // Previous week
        
        // Mood trend
        if recentMood > previousMood + 0.5 {
            insights.append(MentalHealthInsight(
                type: .positive,
                title: "Mood Improving",
                message: "Your mood has been trending upward this week. Keep up the great work!",
                icon: "arrow.up.circle.fill"
            ))
        } else if recentMood < previousMood - 0.5 {
            insights.append(MentalHealthInsight(
                type: .concern,
                title: "Mood Declining",
                message: "Your mood has been lower this week. Consider reaching out for support.",
                icon: "arrow.down.circle.fill"
            ))
        }
        
        // Sleep patterns
        let recentEntries = getMoodTrend(days: 7)
        let avgSleepHours = recentEntries.compactMap { $0.sleepHours }.reduce(0, +) / Double(recentEntries.count)
        
        if avgSleepHours < 5 {
            insights.append(MentalHealthInsight(
                type: .concern,
                title: "Low Sleep",
                message: "You're averaging less than 5 hours of sleep. Prioritize rest when possible.",
                icon: "moon.zzz.fill"
            ))
        }
        
        // Coping strategies
        let copingStrategies = recentEntries.flatMap { $0.copingStrategiesUsed }
        let uniqueStrategies = Set(copingStrategies).count
        
        if uniqueStrategies >= 5 {
            insights.append(MentalHealthInsight(
                type: .positive,
                title: "Great Coping Skills",
                message: "You're using diverse coping strategies. This variety is beneficial!",
                icon: "star.fill"
            ))
        }
        
        return insights
    }
    
    // MARK: - Streak Management
    
    private func updateStreak() {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = Date()
        
        while true {
            if moodEntries.contains(where: { calendar.isDate($0.date, inSameDayAs: currentDate) }) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? Date()
            } else {
                break
            }
        }
        
        currentStreak = streak
    }
    
    // MARK: - Resources
    
    private func loadDefaultResources() {
        supportResources = [
            SupportResource(
                name: "988 Suicide & Crisis Lifeline",
                type: .hotline,
                description: "24/7 crisis support via call or text",
                phoneNumber: "988",
                website: "https://988lifeline.org",
                hours: "24/7",
                isCrisis: true,
                cost: "Free"
            ),
            SupportResource(
                name: "Postpartum Support International Helpline",
                type: .hotline,
                description: "Support for postpartum mental health",
                phoneNumber: "1-800-944-4773",
                website: "https://www.postpartum.net",
                hours: "24/7",
                isCrisis: false,
                cost: "Free"
            ),
            SupportResource(
                name: "Crisis Text Line",
                type: .hotline,
                description: "Text HOME to 741741 for crisis support",
                phoneNumber: "741741",
                website: "https://www.crisistextline.org",
                hours: "24/7",
                isCrisis: true,
                cost: "Free"
            ),
            SupportResource(
                name: "SAMHSA National Helpline",
                type: .hotline,
                description: "Treatment referral and information service",
                phoneNumber: "1-800-662-4357",
                website: "https://www.samhsa.gov/find-help/national-helpline",
                hours: "24/7",
                isCrisis: false,
                cost: "Free"
            ),
            SupportResource(
                name: "The Blue Dot Project",
                type: .onlineResource,
                description: "Anonymous support chat for maternal mental health",
                website: "https://thebluedotproject.org",
                isCrisis: false,
                cost: "Free"
            ),
            SupportResource(
                name: "Postpartum Progress",
                type: .onlineResource,
                description: "Information and support for postpartum mental health",
                website: "https://postpartumprogress.org",
                isCrisis: false,
                cost: "Free"
            )
        ]
    }
    
    // MARK: - Persistence
    
    private func loadData() {
        // Load mood entries
        if let data = UserDefaults.standard.data(forKey: "\(storageKey)_\(userId)"),
           let decoded = try? JSONDecoder().decode([MoodEntry].self, from: data) {
            moodEntries = decoded
        }
        
        // Load screenings
        if let data = UserDefaults.standard.data(forKey: "\(screeningsKey)_\(userId)"),
           let decoded = try? JSONDecoder().decode([EPDSScreening].self, from: data) {
            screenings = decoded
        }
    }
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(moodEntries) {
            UserDefaults.standard.set(encoded, forKey: "\(storageKey)_\(userId)")
        }
    }
    
    private func saveScreenings() {
        if let encoded = try? JSONEncoder().encode(screenings) {
            UserDefaults.standard.set(encoded, forKey: "\(screeningsKey)_\(userId)")
        }
    }
}

// MARK: - Supporting Models

struct MentalHealthInsight {
    let type: InsightType
    let title: String
    let message: String
    let icon: String
}

enum InsightType {
    case positive
    case neutral
    case concern
}