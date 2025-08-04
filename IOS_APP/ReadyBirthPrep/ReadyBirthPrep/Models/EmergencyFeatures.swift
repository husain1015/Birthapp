import Foundation
import CoreLocation
import UIKit

// MARK: - Emergency Models

struct EmergencyInfo: Codable {
    let userId: UUID
    var hospitalInfo: HospitalInfo?
    var emergencyContacts: [EmergencyContact]
    var medicalInfo: EmergencyMedicalInfo
    var quickAccessItems: [QuickAccessItem]
    var laborSignsChecklist: LaborSignsChecklist
    var updatedAt: Date = Date()
}

struct HospitalInfo: Codable {
    var name: String
    var address: String
    var phoneNumber: String
    var laborAndDeliveryPhone: String?
    var parkingInfo: String?
    var entranceInfo: String?
    var preRegistrationNumber: String?
    var latitude: Double?
    var longitude: Double?
    
    var location: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

struct EmergencyMedicalInfo: Codable {
    var bloodType: String?
    var allergies: [String]
    var medications: [String]
    var medicalConditions: [String]
    var obProviderName: String
    var obProviderPhone: String
    var insuranceInfo: String?
    var specialInstructions: String?
}

struct QuickAccessItem: Codable, Identifiable {
    var id: UUID = UUID()
    var type: QuickAccessType
    var isEnabled: Bool = true
    var customLabel: String?
    var customAction: String?
}

enum QuickAccessType: String, Codable, CaseIterable {
    case contractionTimer = "Contraction Timer"
    case callHospital = "Call Hospital"
    case callProvider = "Call Provider"
    case emergencyContacts = "Emergency Contacts"
    case hospitalDirections = "Hospital Directions"
    case laborSigns = "Labor Signs"
    case hospitalBag = "Hospital Bag"
    case birthPlan = "Birth Plan"
    case insurance = "Insurance Info"
    case custom = "Custom"
    
    var icon: String {
        switch self {
        case .contractionTimer: return "timer"
        case .callHospital: return "phone.fill"
        case .callProvider: return "stethoscope"
        case .emergencyContacts: return "person.2.fill"
        case .hospitalDirections: return "map.fill"
        case .laborSigns: return "exclamationmark.triangle.fill"
        case .hospitalBag: return "bag.fill"
        case .birthPlan: return "doc.text.fill"
        case .insurance: return "creditcard.fill"
        case .custom: return "star.fill"
        }
    }
    
    var defaultColor: String {
        switch self {
        case .contractionTimer: return "purple"
        case .callHospital, .callProvider: return "red"
        case .emergencyContacts: return "orange"
        case .hospitalDirections: return "blue"
        case .laborSigns: return "pink"
        case .hospitalBag: return "green"
        case .birthPlan: return "indigo"
        case .insurance: return "teal"
        case .custom: return "gray"
        }
    }
}

struct LaborSignsChecklist: Codable {
    var regularContractions: LaborSign
    var waterBreaking: LaborSign
    var bloodyShow: LaborSign
    var backPain: LaborSign
    var pelvicPressure: LaborSign
    var nausea: LaborSign
    var diarrhea: LaborSign
    var nestingInstinct: LaborSign
    
    init() {
        regularContractions = LaborSign(
            name: "Regular Contractions",
            description: "Contractions coming every 5 minutes, lasting 1 minute, for at least 1 hour",
            isEmergency: false
        )
        waterBreaking = LaborSign(
            name: "Water Breaking",
            description: "Clear fluid or a gush of water from vagina",
            isEmergency: false,
            emergencyIf: "Fluid is green, brown, or has a foul odor"
        )
        bloodyShow = LaborSign(
            name: "Bloody Show",
            description: "Pink or blood-tinged mucus discharge",
            isEmergency: false,
            emergencyIf: "Heavy bleeding like a period"
        )
        backPain = LaborSign(
            name: "Lower Back Pain",
            description: "Persistent lower back pain that comes and goes",
            isEmergency: false
        )
        pelvicPressure = LaborSign(
            name: "Pelvic Pressure",
            description: "Feeling like baby is pushing down",
            isEmergency: false
        )
        nausea = LaborSign(
            name: "Nausea/Vomiting",
            description: "Upset stomach or vomiting",
            isEmergency: false
        )
        diarrhea = LaborSign(
            name: "Loose Bowels",
            description: "Diarrhea or frequent bowel movements",
            isEmergency: false
        )
        nestingInstinct = LaborSign(
            name: "Nesting Instinct",
            description: "Sudden burst of energy and urge to prepare",
            isEmergency: false
        )
    }
    
    var allSigns: [LaborSign] {
        [regularContractions, waterBreaking, bloodyShow, backPain, 
         pelvicPressure, nausea, diarrhea, nestingInstinct]
    }
}

struct LaborSign: Codable {
    var name: String
    var description: String
    var isEmergency: Bool
    var emergencyIf: String?
    var isPresent: Bool = false
    var startTime: Date?
}

// MARK: - Emergency Warning Signs

struct EmergencyWarningSign: Identifiable {
    let id = UUID()
    let title: String
    let symptoms: [String]
    let action: String
    let severity: WarningSeverity
}

enum WarningSeverity {
    case immediate // Call 911
    case urgent    // Go to hospital now
    case soon      // Call provider immediately
}

struct EmergencyWarningDatabase {
    static let warningSignsPregnancy = [
        EmergencyWarningSign(
            title: "Severe Bleeding",
            symptoms: [
                "Soaking through one pad per hour",
                "Large blood clots",
                "Tissue passing from vagina"
            ],
            action: "Call 911 immediately",
            severity: .immediate
        ),
        EmergencyWarningSign(
            title: "Severe Abdominal Pain",
            symptoms: [
                "Sudden, severe pain",
                "Pain that doesn't go away",
                "Pain with fever or bleeding"
            ],
            action: "Go to emergency room",
            severity: .urgent
        ),
        EmergencyWarningSign(
            title: "Vision Changes",
            symptoms: [
                "Blurred vision",
                "Seeing spots or flashing lights",
                "Temporary loss of vision"
            ],
            action: "Call provider immediately",
            severity: .soon
        ),
        EmergencyWarningSign(
            title: "Severe Headache",
            symptoms: [
                "Sudden severe headache",
                "Headache with vision changes",
                "Headache with swelling"
            ],
            action: "Go to hospital",
            severity: .urgent
        ),
        EmergencyWarningSign(
            title: "Decreased Baby Movement",
            symptoms: [
                "No movement for 2 hours",
                "Significant decrease in movement",
                "No response to stimulation"
            ],
            action: "Call provider immediately",
            severity: .soon
        ),
        EmergencyWarningSign(
            title: "Signs of Preeclampsia",
            symptoms: [
                "Severe swelling of face/hands",
                "Sudden weight gain",
                "Upper abdominal pain"
            ],
            action: "Go to hospital",
            severity: .urgent
        )
    ]
    
    static let warningSignsLabor = [
        EmergencyWarningSign(
            title: "Cord Prolapse Signs",
            symptoms: [
                "Feeling something in vagina",
                "Visible umbilical cord",
                "Sudden change in baby movement"
            ],
            action: "Call 911 - Get on hands and knees",
            severity: .immediate
        ),
        EmergencyWarningSign(
            title: "Heavy Bleeding During Labor",
            symptoms: [
                "Bright red bleeding",
                "Continuous bleeding",
                "Feeling faint or dizzy"
            ],
            action: "Alert medical staff immediately",
            severity: .immediate
        ),
        EmergencyWarningSign(
            title: "Baby's Heart Rate Issues",
            symptoms: [
                "Monitor showing concerning patterns",
                "Staff expressing concern",
                "Sudden position changes requested"
            ],
            action: "Follow staff instructions",
            severity: .urgent
        )
    ]
}

// MARK: - Quick Contraction Timer

struct QuickContraction: Codable, Identifiable {
    var id: UUID = UUID()
    var startTime: Date
    var endTime: Date?
    var duration: TimeInterval {
        let end = endTime ?? Date()
        return end.timeIntervalSince(startTime)
    }
    var intervalFromPrevious: TimeInterval?
}

class QuickContractionTimer: ObservableObject {
    @Published var contractions: [QuickContraction] = []
    @Published var currentContraction: QuickContraction?
    @Published var isTimingContraction = false
    @Published var averageDuration: TimeInterval = 0
    @Published var averageInterval: TimeInterval = 0
    @Published var pattern: ContractionPattern = .irregular
    
    enum ContractionPattern {
        case irregular
        case establishing  // Starting to show pattern
        case active       // 5-1-1 rule approaching
        case timeToGo    // Meeting 5-1-1 rule
        
        var description: String {
            switch self {
            case .irregular:
                return "Contractions are irregular"
            case .establishing:
                return "Pattern establishing"
            case .active:
                return "Active pattern developing"
            case .timeToGo:
                return "Time to call provider - 5-1-1 rule met"
            }
        }
        
        var color: String {
            switch self {
            case .irregular: return "gray"
            case .establishing: return "blue"
            case .active: return "orange"
            case .timeToGo: return "red"
            }
        }
    }
    
    func startContraction() {
        currentContraction = QuickContraction(startTime: Date())
        isTimingContraction = true
    }
    
    func stopContraction() {
        guard var contraction = currentContraction else { return }
        
        contraction.endTime = Date()
        
        // Calculate interval from previous
        if let lastContraction = contractions.last {
            contraction.intervalFromPrevious = contraction.startTime.timeIntervalSince(lastContraction.startTime)
        }
        
        contractions.append(contraction)
        currentContraction = nil
        isTimingContraction = false
        
        updateAnalytics()
    }
    
    func deleteContraction(_ contraction: QuickContraction) {
        contractions.removeAll { $0.id == contraction.id }
        updateAnalytics()
    }
    
    private func updateAnalytics() {
        // Calculate averages for last hour
        let oneHourAgo = Date().addingTimeInterval(-3600)
        let recentContractions = contractions.filter { $0.startTime > oneHourAgo }
        
        guard recentContractions.count >= 3 else {
            pattern = .irregular
            return
        }
        
        // Average duration
        let totalDuration = recentContractions.reduce(0) { $0 + $1.duration }
        averageDuration = totalDuration / Double(recentContractions.count)
        
        // Average interval
        let intervals = recentContractions.compactMap { $0.intervalFromPrevious }
        if !intervals.isEmpty {
            averageInterval = intervals.reduce(0, +) / Double(intervals.count)
        }
        
        // Determine pattern (5-1-1 rule: contractions every 5 minutes, lasting 1 minute, for 1 hour)
        if recentContractions.count >= 12 && // At least 12 in an hour
           averageInterval <= 300 && // Every 5 minutes or less
           averageDuration >= 60 {   // Lasting 1 minute or more
            pattern = .timeToGo
        } else if averageInterval <= 420 { // Every 7 minutes
            pattern = .active
        } else if averageInterval <= 600 { // Every 10 minutes
            pattern = .establishing
        } else {
            pattern = .irregular
        }
    }
    
    func reset() {
        contractions = []
        currentContraction = nil
        isTimingContraction = false
        averageDuration = 0
        averageInterval = 0
        pattern = .irregular
    }
}

// MARK: - Emergency Manager

class EmergencyManager: ObservableObject {
    @Published var emergencyInfo: EmergencyInfo
    @Published var quickContractionTimer = QuickContractionTimer()
    
    private let userId: UUID
    private let storageKey = "EmergencyInfo"
    
    init(userId: UUID) {
        self.userId = userId
        
        // Initialize with defaults
        self.emergencyInfo = EmergencyInfo(
            userId: userId,
            emergencyContacts: [],
            medicalInfo: EmergencyMedicalInfo(
                allergies: [],
                medications: [],
                medicalConditions: [],
                obProviderName: "",
                obProviderPhone: ""
            ),
            quickAccessItems: EmergencyManager.defaultQuickAccessItems(),
            laborSignsChecklist: LaborSignsChecklist()
        )
        
        loadEmergencyInfo()
    }
    
    static func defaultQuickAccessItems() -> [QuickAccessItem] {
        return [
            QuickAccessItem(type: .contractionTimer),
            QuickAccessItem(type: .callHospital),
            QuickAccessItem(type: .hospitalDirections),
            QuickAccessItem(type: .laborSigns),
            QuickAccessItem(type: .emergencyContacts),
            QuickAccessItem(type: .hospitalBag)
        ]
    }
    
    // MARK: - Hospital Info
    
    func updateHospitalInfo(_ info: HospitalInfo) {
        emergencyInfo.hospitalInfo = info
        emergencyInfo.updatedAt = Date()
        saveEmergencyInfo()
    }
    
    func callHospital() {
        guard let phone = emergencyInfo.hospitalInfo?.phoneNumber,
              let url = URL(string: "tel://\(phone.replacingOccurrences(of: " ", with: ""))") else { return }
        UIApplication.shared.open(url)
    }
    
    func getDirectionsToHospital() {
        guard let hospital = emergencyInfo.hospitalInfo else { return }
        
        let address = hospital.address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "maps://?address=\(address)") {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Medical Info
    
    func updateMedicalInfo(_ info: EmergencyMedicalInfo) {
        emergencyInfo.medicalInfo = info
        emergencyInfo.updatedAt = Date()
        saveEmergencyInfo()
    }
    
    // MARK: - Quick Access
    
    func toggleQuickAccessItem(_ itemId: UUID) {
        if let index = emergencyInfo.quickAccessItems.firstIndex(where: { $0.id == itemId }) {
            emergencyInfo.quickAccessItems[index].isEnabled.toggle()
            saveEmergencyInfo()
        }
    }
    
    func reorderQuickAccessItems(_ items: [QuickAccessItem]) {
        emergencyInfo.quickAccessItems = items
        saveEmergencyInfo()
    }
    
    // MARK: - Labor Signs
    
    func updateLaborSign(_ signName: String, isPresent: Bool) {
        switch signName {
        case "Regular Contractions":
            emergencyInfo.laborSignsChecklist.regularContractions.isPresent = isPresent
            if isPresent {
                emergencyInfo.laborSignsChecklist.regularContractions.startTime = Date()
            }
        case "Water Breaking":
            emergencyInfo.laborSignsChecklist.waterBreaking.isPresent = isPresent
            if isPresent {
                emergencyInfo.laborSignsChecklist.waterBreaking.startTime = Date()
            }
        case "Bloody Show":
            emergencyInfo.laborSignsChecklist.bloodyShow.isPresent = isPresent
            if isPresent {
                emergencyInfo.laborSignsChecklist.bloodyShow.startTime = Date()
            }
        // Add other cases...
        default:
            break
        }
        
        saveEmergencyInfo()
    }
    
    func getActiveLaborSigns() -> [LaborSign] {
        emergencyInfo.laborSignsChecklist.allSigns.filter { $0.isPresent }
    }
    
    // MARK: - Emergency Summary
    
    func generateEmergencySummary() -> String {
        var summary = "EMERGENCY INFORMATION\n\n"
        
        // Patient Info
        summary += "PATIENT: \(emergencyInfo.medicalInfo.obProviderName)'s patient\n"
        if let bloodType = emergencyInfo.medicalInfo.bloodType {
            summary += "Blood Type: \(bloodType)\n"
        }
        summary += "\n"
        
        // Medical Info
        if !emergencyInfo.medicalInfo.allergies.isEmpty {
            summary += "ALLERGIES:\n"
            summary += emergencyInfo.medicalInfo.allergies.map { "• \($0)" }.joined(separator: "\n")
            summary += "\n\n"
        }
        
        if !emergencyInfo.medicalInfo.medications.isEmpty {
            summary += "MEDICATIONS:\n"
            summary += emergencyInfo.medicalInfo.medications.map { "• \($0)" }.joined(separator: "\n")
            summary += "\n\n"
        }
        
        if !emergencyInfo.medicalInfo.medicalConditions.isEmpty {
            summary += "MEDICAL CONDITIONS:\n"
            summary += emergencyInfo.medicalInfo.medicalConditions.map { "• \($0)" }.joined(separator: "\n")
            summary += "\n\n"
        }
        
        // Labor Signs
        let activeSigns = getActiveLaborSigns()
        if !activeSigns.isEmpty {
            summary += "ACTIVE LABOR SIGNS:\n"
            for sign in activeSigns {
                summary += "• \(sign.name)"
                if let startTime = sign.startTime {
                    let formatter = DateFormatter()
                    formatter.timeStyle = .short
                    summary += " (started \(formatter.string(from: startTime)))"
                }
                summary += "\n"
            }
            summary += "\n"
        }
        
        // Contractions
        if !quickContractionTimer.contractions.isEmpty {
            summary += "CONTRACTIONS:\n"
            summary += "Pattern: \(quickContractionTimer.pattern.description)\n"
            summary += "Average Duration: \(Int(quickContractionTimer.averageDuration)) seconds\n"
            summary += "Average Interval: \(Int(quickContractionTimer.averageInterval / 60)) minutes\n"
        }
        
        return summary
    }
    
    // MARK: - Persistence
    
    private func loadEmergencyInfo() {
        if let data = UserDefaults.standard.data(forKey: "\(storageKey)_\(userId)"),
           let decoded = try? JSONDecoder().decode(EmergencyInfo.self, from: data) {
            self.emergencyInfo = decoded
        }
    }
    
    private func saveEmergencyInfo() {
        if let encoded = try? JSONEncoder().encode(emergencyInfo) {
            UserDefaults.standard.set(encoded, forKey: "\(storageKey)_\(userId)")
        }
    }
}