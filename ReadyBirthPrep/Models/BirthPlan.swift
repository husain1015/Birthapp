import Foundation

struct BirthPlan: Codable, Identifiable {
    let id: UUID
    var userId: UUID
    var environment: BirthEnvironment
    var supportPeople: [SupportPerson]
    var painManagement: PainManagementPreferences
    var laboringPositions: [LaborPosition]
    var newbornProcedures: NewbornPreferences
    var additionalPreferences: String?
    var createdAt: Date
    var updatedAt: Date
    
    init(userId: UUID) {
        self.id = UUID()
        self.userId = userId
        self.environment = BirthEnvironment()
        self.supportPeople = []
        self.painManagement = PainManagementPreferences()
        self.laboringPositions = []
        self.newbornProcedures = NewbornPreferences()
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

struct BirthEnvironment: Codable {
    var lighting: LightingPreference = .dim
    var music: Bool = false
    var musicPlaylist: String?
    var aromatherapy: Bool = false
    var aromatherapyScents: [String] = []
    var temperature: TemperaturePreference = .cool
    var visitors: VisitorPreference = .limitedVisitors
}

enum LightingPreference: String, Codable, CaseIterable {
    case bright = "Bright Lights"
    case dim = "Dim Lights"
    case natural = "Natural Light Only"
    case candlelight = "Battery Candles"
}

enum TemperaturePreference: String, Codable, CaseIterable {
    case warm = "Warm"
    case cool = "Cool"
    case asNeeded = "Adjust as Needed"
}

enum VisitorPreference: String, Codable, CaseIterable {
    case noVisitors = "No Visitors"
    case limitedVisitors = "Limited Visitors"
    case openVisitation = "Open Visitation"
}

struct SupportPerson: Codable, Identifiable {
    let id: UUID = UUID()
    var name: String
    var relationship: String
    var role: String
    var contactNumber: String?
}

struct PainManagementPreferences: Codable {
    var naturalMethods: [NaturalPainManagement] = []
    var medicationOptions: [MedicationOption] = []
    var epiduralPreference: EpiduralPreference = .openToDiscuss
    var additionalNotes: String?
}

enum NaturalPainManagement: String, Codable, CaseIterable {
    case breathing = "Breathing Techniques"
    case massage = "Massage"
    case waterImmersion = "Water Immersion/Shower"
    case movement = "Movement and Position Changes"
    case heatCold = "Heat/Cold Therapy"
    case tens = "TENS Unit"
    case hypnobirthing = "Hypnobirthing"
    case acupressure = "Acupressure"
}

enum MedicationOption: String, Codable, CaseIterable {
    case none = "No Medication"
    case nitrous = "Nitrous Oxide"
    case iv = "IV Pain Medication"
    case epidural = "Epidural"
    case spinal = "Spinal Block"
}

enum EpiduralPreference: String, Codable, CaseIterable {
    case definitely = "Definitely Want"
    case probably = "Probably Want"
    case openToDiscuss = "Open to Discuss"
    case preferNot = "Prefer Not"
    case definitelyNot = "Definitely Not"
}

enum LaborPosition: String, Codable, CaseIterable {
    case standing = "Standing/Walking"
    case handsKnees = "Hands and Knees"
    case birtingBall = "Birthing Ball"
    case squatting = "Squatting"
    case sideLying = "Side-Lying"
    case semiReclined = "Semi-Reclined"
    case waterBirth = "Water Birth"
}

struct NewbornPreferences: Codable {
    var immediateSkintToSkin: Bool = true
    var delayedCordClamping: Bool = true
    var vitaminK: VitaminKPreference = .yes
    var eyeOintment: Bool = true
    var hepatitisB: Bool = true
    var circumcision: CircumcisionPreference = .no
    var feeding: FeedingPreference = .breastfeeding
}

enum VitaminKPreference: String, Codable, CaseIterable {
    case yes = "Yes"
    case no = "No"
    case oral = "Oral Only"
}

enum CircumcisionPreference: String, Codable, CaseIterable {
    case yes = "Yes"
    case no = "No"
    case notApplicable = "Not Applicable"
}

enum FeedingPreference: String, Codable, CaseIterable {
    case breastfeeding = "Breastfeeding"
    case formula = "Formula"
    case combination = "Combination"
    case pumping = "Pumping/Bottle"
}