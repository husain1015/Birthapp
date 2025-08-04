import Foundation
import UserNotifications

// MARK: - Medication & Supplement Models

struct Medication: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var type: MedicationType
    var dosage: String
    var unit: DosageUnit
    var frequency: MedicationFrequency
    var timeSlots: [MedicationTimeSlot]
    var startDate: Date
    var endDate: Date?
    var prescribedBy: String?
    var reasonForTaking: String
    var instructions: String?
    var sideEffects: [String] = []
    var interactions: [String] = []
    var pregnancyCategory: PregnancyCategory?
    var isActive: Bool = true
    var remindersEnabled: Bool = true
    var notes: String?
    var refillDate: Date?
    var pharmacyInfo: PharmacyInfo?
    var color: String = "pink" // For visual identification
}

enum MedicationType: String, Codable, CaseIterable {
    case prescription = "Prescription"
    case overthecounter = "Over-the-Counter"
    case vitamin = "Vitamin"
    case supplement = "Supplement"
    case prenatal = "Prenatal Vitamin"
    case herbal = "Herbal"
}

enum DosageUnit: String, Codable, CaseIterable {
    case mg = "mg"
    case mcg = "mcg"
    case g = "g"
    case ml = "ml"
    case drops = "drops"
    case tablets = "tablets"
    case capsules = "capsules"
    case units = "units"
}

enum MedicationFrequency: String, Codable, CaseIterable {
    case asNeeded = "As Needed"
    case onceDaily = "Once Daily"
    case twiceDaily = "Twice Daily"
    case threeTimesDaily = "Three Times Daily"
    case fourTimesDaily = "Four Times Daily"
    case everyOtherDay = "Every Other Day"
    case weekly = "Weekly"
    case custom = "Custom"
}

struct MedicationTimeSlot: Codable, Identifiable {
    var id: UUID = UUID()
    var time: Date
    var label: String // e.g., "Morning", "With Lunch", "Bedtime"
    var taken: Bool = false
    var takenAt: Date?
    var skipped: Bool = false
    var skipReason: String?
}

enum PregnancyCategory: String, Codable, CaseIterable {
    case categoryA = "Category A - Safe"
    case categoryB = "Category B - Likely Safe"
    case categoryC = "Category C - Use with Caution"
    case categoryD = "Category D - Evidence of Risk"
    case categoryX = "Category X - Contraindicated"
    case notRated = "Not Rated"
}

struct PharmacyInfo: Codable {
    var name: String
    var phone: String?
    var address: String?
    var rxNumber: String?
}

struct MedicationLog: Codable, Identifiable {
    var id: UUID = UUID()
    let medicationId: UUID
    let medicationName: String
    let scheduledTime: Date
    let actualTime: Date?
    let status: LogStatus
    let dose: String
    let notes: String?
    let sideEffectsReported: [String] = []
}

enum LogStatus: String, Codable {
    case taken = "Taken"
    case skipped = "Skipped"
    case missed = "Missed"
    case pending = "Pending"
}

// MARK: - Safety Database

struct MedicationSafetyDatabase {
    static let pregnancySafeMedications: [String: PregnancyCategory] = [
        // Common safe medications
        "Acetaminophen": .categoryB,
        "Tylenol": .categoryB,
        "Diphenhydramine": .categoryB,
        "Benadryl": .categoryB,
        "Loratadine": .categoryB,
        "Claritin": .categoryB,
        "Cetirizine": .categoryB,
        "Zyrtec": .categoryB,
        
        // Prenatal vitamins
        "Prenatal Vitamin": .categoryA,
        "Folic Acid": .categoryA,
        "Iron": .categoryA,
        "Vitamin D": .categoryA,
        "Calcium": .categoryA,
        "DHA": .categoryA,
        "Vitamin B6": .categoryA,
        
        // Common antibiotics
        "Amoxicillin": .categoryB,
        "Azithromycin": .categoryB,
        "Cephalexin": .categoryB,
        "Penicillin": .categoryB,
        
        // Medications to avoid
        "Ibuprofen": .categoryD,
        "Aspirin": .categoryD,
        "Naproxen": .categoryD,
        "Isotretinoin": .categoryX,
        "Accutane": .categoryX,
        "Warfarin": .categoryX
    ]
    
    static let commonInteractions: [String: [String]] = [
        "Iron": ["Calcium", "Antacids", "Dairy products - take 2 hours apart"],
        "Calcium": ["Iron", "Thyroid medication - take 4 hours apart"],
        "Prenatal Vitamin": ["Take with food to reduce nausea"],
        "DHA": ["May interact with blood thinners"]
    ]
    
    static func checkSafety(medicationName: String) -> PregnancyCategory {
        // Check exact match first
        if let category = pregnancySafeMedications[medicationName] {
            return category
        }
        
        // Check partial match
        let lowercaseName = medicationName.lowercased()
        for (med, category) in pregnancySafeMedications {
            if lowercaseName.contains(med.lowercased()) {
                return category
            }
        }
        
        return .notRated
    }
    
    static func getInteractions(for medication: String) -> [String] {
        return commonInteractions[medication] ?? []
    }
}

// MARK: - Medication Manager

class MedicationManager: ObservableObject {
    @Published var medications: [Medication] = []
    @Published var medicationLogs: [MedicationLog] = []
    @Published var todaysMedications: [MedicationScheduleItem] = []
    
    private let userId: UUID
    private let storageKey = "Medications"
    private let logsKey = "MedicationLogs"
    private let notificationManager = MedicationNotificationManager()
    
    init(userId: UUID) {
        self.userId = userId
        loadData()
        updateTodaysSchedule()
        setupDailyRefresh()
    }
    
    // MARK: - Medication Management
    
    func addMedication(_ medication: Medication) {
        var newMedication = medication
        
        // Check safety
        newMedication.pregnancyCategory = MedicationSafetyDatabase.checkSafety(medicationName: medication.name)
        newMedication.interactions = MedicationSafetyDatabase.getInteractions(for: medication.name)
        
        medications.append(newMedication)
        
        // Schedule notifications
        if newMedication.remindersEnabled {
            scheduleNotifications(for: newMedication)
        }
        
        saveData()
        updateTodaysSchedule()
    }
    
    func updateMedication(_ medication: Medication) {
        if let index = medications.firstIndex(where: { $0.id == medication.id }) {
            // Cancel old notifications
            notificationManager.cancelNotifications(for: medications[index].id)
            
            medications[index] = medication
            
            // Reschedule notifications
            if medication.remindersEnabled && medication.isActive {
                scheduleNotifications(for: medication)
            }
            
            saveData()
            updateTodaysSchedule()
        }
    }
    
    func deleteMedication(_ medication: Medication) {
        medications.removeAll { $0.id == medication.id }
        notificationManager.cancelNotifications(for: medication.id)
        saveData()
        updateTodaysSchedule()
    }
    
    func toggleMedicationActive(_ medicationId: UUID) {
        if let index = medications.firstIndex(where: { $0.id == medicationId }) {
            medications[index].isActive.toggle()
            
            if medications[index].isActive && medications[index].remindersEnabled {
                scheduleNotifications(for: medications[index])
            } else {
                notificationManager.cancelNotifications(for: medicationId)
            }
            
            saveData()
            updateTodaysSchedule()
        }
    }
    
    // MARK: - Logging
    
    func logMedication(medicationId: UUID, timeSlot: MedicationTimeSlot, taken: Bool, notes: String? = nil) {
        guard let medication = medications.first(where: { $0.id == medicationId }) else { return }
        
        let log = MedicationLog(
            medicationId: medicationId,
            medicationName: medication.name,
            scheduledTime: timeSlot.time,
            actualTime: taken ? Date() : nil,
            status: taken ? .taken : .skipped,
            dose: "\(medication.dosage) \(medication.unit.rawValue)",
            notes: notes
        )
        
        medicationLogs.append(log)
        saveLogs()
        updateTodaysSchedule()
    }
    
    func getMedicationHistory(for medicationId: UUID, days: Int = 30) -> [MedicationLog] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return medicationLogs
            .filter { $0.medicationId == medicationId && $0.scheduledTime > cutoffDate }
            .sorted { $0.scheduledTime > $1.scheduledTime }
    }
    
    func getAdherenceRate(for medicationId: UUID, days: Int = 30) -> Double {
        let logs = getMedicationHistory(for: medicationId, days: days)
        let takenCount = logs.filter { $0.status == .taken }.count
        guard logs.count > 0 else { return 0 }
        return Double(takenCount) / Double(logs.count) * 100
    }
    
    // MARK: - Today's Schedule
    
    func updateTodaysSchedule() {
        let calendar = Calendar.current
        let today = Date()
        var scheduleItems: [MedicationScheduleItem] = []
        
        for medication in medications where medication.isActive {
            // Check if medication should be taken today
            if let endDate = medication.endDate, endDate < today {
                continue
            }
            
            if medication.startDate > today {
                continue
            }
            
            // Check frequency
            switch medication.frequency {
            case .everyOtherDay:
                let daysSinceStart = calendar.dateComponents([.day], from: medication.startDate, to: today).day ?? 0
                if daysSinceStart % 2 != 0 {
                    continue
                }
            case .weekly:
                let startWeekday = calendar.component(.weekday, from: medication.startDate)
                let todayWeekday = calendar.component(.weekday, from: today)
                if startWeekday != todayWeekday {
                    continue
                }
            default:
                break
            }
            
            // Add time slots for today
            for timeSlot in medication.timeSlots {
                let scheduledTime = calendar.date(bySettingHour: calendar.component(.hour, from: timeSlot.time),
                                                minute: calendar.component(.minute, from: timeSlot.time),
                                                second: 0,
                                                of: today) ?? timeSlot.time
                
                // Check if already logged
                let isLogged = medicationLogs.contains { log in
                    log.medicationId == medication.id &&
                    calendar.isDate(log.scheduledTime, inSameDayAs: scheduledTime)
                }
                
                let scheduleItem = MedicationScheduleItem(
                    medication: medication,
                    timeSlot: timeSlot,
                    scheduledTime: scheduledTime,
                    isLogged: isLogged,
                    logStatus: isLogged ? getLogStatus(for: medication.id, on: scheduledTime) : nil
                )
                
                scheduleItems.append(scheduleItem)
            }
        }
        
        todaysMedications = scheduleItems.sorted { $0.scheduledTime < $1.scheduledTime }
    }
    
    private func getLogStatus(for medicationId: UUID, on date: Date) -> LogStatus? {
        let calendar = Calendar.current
        return medicationLogs.first { log in
            log.medicationId == medicationId &&
            calendar.isDate(log.scheduledTime, inSameDayAs: date)
        }?.status
    }
    
    // MARK: - Notifications
    
    private func scheduleNotifications(for medication: Medication) {
        for timeSlot in medication.timeSlots {
            notificationManager.scheduleNotification(
                for: medication,
                timeSlot: timeSlot
            )
        }
    }
    
    // MARK: - Refill Reminders
    
    func getMedicationsNeedingRefill(withinDays: Int = 7) -> [Medication] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: withinDays, to: Date()) ?? Date()
        return medications.filter { medication in
            if let refillDate = medication.refillDate {
                return refillDate <= cutoffDate && medication.isActive
            }
            return false
        }
    }
    
    // MARK: - Safety Checks
    
    func checkInteractions(for newMedication: String) -> [String] {
        var interactions: [String] = []
        
        // Check against current medications
        for medication in medications where medication.isActive {
            if let interaction = MedicationSafetyDatabase.commonInteractions[medication.name] {
                if interaction.contains(where: { $0.contains(newMedication) }) {
                    interactions.append("May interact with \(medication.name)")
                }
            }
        }
        
        return interactions
    }
    
    // MARK: - Persistence
    
    private func loadData() {
        // Load medications
        if let data = UserDefaults.standard.data(forKey: "\(storageKey)_\(userId)"),
           let decoded = try? JSONDecoder().decode([Medication].self, from: data) {
            medications = decoded
        }
        
        // Load logs
        if let data = UserDefaults.standard.data(forKey: "\(logsKey)_\(userId)"),
           let decoded = try? JSONDecoder().decode([MedicationLog].self, from: data) {
            medicationLogs = decoded
        }
    }
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(medications) {
            UserDefaults.standard.set(encoded, forKey: "\(storageKey)_\(userId)")
        }
    }
    
    private func saveLogs() {
        if let encoded = try? JSONEncoder().encode(medicationLogs) {
            UserDefaults.standard.set(encoded, forKey: "\(logsKey)_\(userId)")
        }
    }
    
    // MARK: - Daily Refresh
    
    private func setupDailyRefresh() {
        // Refresh schedule at midnight
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        let midnight = calendar.startOfDay(for: tomorrow)
        let timeInterval = midnight.timeIntervalSince(Date())
        
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { _ in
            self.updateTodaysSchedule()
            self.setupDailyRefresh() // Schedule next refresh
        }
    }
}

// MARK: - Supporting Models

struct MedicationScheduleItem: Identifiable {
    let id = UUID()
    let medication: Medication
    let timeSlot: MedicationTimeSlot
    let scheduledTime: Date
    let isLogged: Bool
    let logStatus: LogStatus?
    
    var isPastDue: Bool {
        !isLogged && scheduledTime < Date()
    }
    
    var isUpcoming: Bool {
        !isLogged && scheduledTime > Date()
    }
}

// MARK: - Notification Manager

class MedicationNotificationManager {
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            }
        }
    }
    
    func scheduleNotification(for medication: Medication, timeSlot: MedicationTimeSlot) {
        let content = UNMutableNotificationContent()
        content.title = "Medication Reminder"
        content.body = "Time to take \(medication.name) - \(medication.dosage) \(medication.unit.rawValue)"
        content.sound = .default
        content.categoryIdentifier = "MEDICATION_REMINDER"
        content.userInfo = [
            "medicationId": medication.id.uuidString,
            "timeSlotId": timeSlot.id.uuidString
        ]
        
        // Create daily trigger
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: timeSlot.time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "\(medication.id.uuidString)_\(timeSlot.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func cancelNotifications(for medicationId: UUID) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiersToRemove = requests
                .filter { $0.identifier.contains(medicationId.uuidString) }
                .map { $0.identifier }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
        }
    }
}