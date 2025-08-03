import Foundation

struct BirthPlan: Codable, Identifiable {
    let id: UUID
    var userId: UUID
    var environment: BirthEnvironment
    var supportPeople: [SupportPerson]
    var painManagement: PainManagementPreferences
    var laboringPositions: [LaborPosition]
    var newbornProcedures: NewbornPreferences
    var laborPreferences: LaborPreferences
    var postBirthPreferences: PostBirthPreferences
    var customPreferences: [CustomPreference]
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
        self.laborPreferences = LaborPreferences()
        self.postBirthPreferences = PostBirthPreferences()
        self.customPreferences = []
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

struct CustomPreference: Codable, Identifiable {
    let id: UUID = UUID()
    var category: String
    var preference: String
    var importance: ImportanceLevel
}

enum ImportanceLevel: String, Codable, CaseIterable {
    case mustHave = "Must Have"
    case prefer = "Prefer"
    case flexible = "Flexible"
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
    case waterImmersion = "Water Immersion/Shower/Bath"
    case movement = "Movement and Position Changes"
    case heatCold = "Heat/Cold Therapy"
    case tens = "TENS Machine"
    case hypnobirthing = "Hypnobirthing"
    case acupressure = "Acupressure Points"
    case combs = "Combs (Pain Management)"
    case counterPressure = "Counter Pressure"
    case meditation = "Meditation/Visualization"
    case music = "Music"
    case laughingGas = "Laughing Gas"
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
    case formula = "Formula Feeding"
    case combination = "Combination"
    case pumping = "Pumping"
    case noPacifiers = "No Pacifiers"
}

struct LaborPreferences: Codable {
    var laborAtHomeAsLongAsPossible: Bool = false
    var wearOwnClothing: Bool = true
    var continueEating: Bool = true
    var iceAndPopsiclesAvailable: Bool = true
    var limitedVaginalChecks: Bool = true
    var dimLighting: Bool = true
    var continuousFetalMonitoring: Bool = false
    var noIntravenousLine: Bool = false
    var useOfPitocin: Bool = false
    var birthBallForPositioning: Bool = true
    var aromatherapy: Bool = false
    var distractions: Bool = false
    var focalPoints: Bool = false
    var videoTaken: Bool = false
    var picturesTaken: Bool = true
    var partnerToCatchBaby: Bool = false
}

struct PostBirthPreferences: Codable {
    var delayedCordCutting: Bool = true
    var cordCutByPartner: Bool = false
    var savePlacenta: Bool = false
    var saveCordBlood: Bool = false
    var announceSexOfBaby: Bool = true
    var placeBabyImmediatelyOnChest: Bool = true
    var cleanBabyBeforeGiving: Bool = false
    var delayNewbornProcedures: Bool = true
    var deliverPlacentaWithoutIntervention: Bool = true
    var preferToTear: Bool = true
    var episiotomy: Bool = false
    var perinealMassage: Bool = true
    var chooseOwnBirthPosition: Bool = true
}