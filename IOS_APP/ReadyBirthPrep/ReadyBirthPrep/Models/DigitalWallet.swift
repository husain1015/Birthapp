import Foundation
import SwiftUI

// MARK: - Digital Wallet Models

struct DigitalWallet: Codable {
    let userId: UUID
    var medicalRecords: [MedicalRecord] = []
    var ultrasounds: [UltrasoundRecord] = []
    var testResults: [TestResult] = []
    var insuranceCards: [InsuranceCard] = []
    var emergencyContacts: [EmergencyContact] = []
    var immunizationRecords: [ImmunizationRecord] = []
    var providerNotes: [ProviderNote] = []
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
}

struct MedicalRecord: Codable, Identifiable {
    var id: UUID = UUID()
    var title: String
    var category: MedicalRecordCategory
    var date: Date
    var provider: String?
    var notes: String?
    var fileData: Data?
    var fileName: String?
    var tags: [String] = []
    var createdAt: Date = Date()
}

enum MedicalRecordCategory: String, Codable, CaseIterable {
    case labReport = "Lab Report"
    case prescription = "Prescription"
    case visitSummary = "Visit Summary"
    case referral = "Referral"
    case imaging = "Imaging"
    case other = "Other"
}

struct UltrasoundRecord: Codable, Identifiable {
    var id: UUID = UUID()
    var gestationalAge: String
    var date: Date
    var type: UltrasoundType
    var imageData: Data?
    var measurements: [String: String] = [:]
    var findings: String?
    var provider: String?
    var facility: String?
    var notes: String?
    var isFavorite: Bool = false
}

enum UltrasoundType: String, Codable, CaseIterable {
    case dating = "Dating Scan"
    case nuchalTranslucency = "NT Scan"
    case anatomy = "Anatomy Scan"
    case growth = "Growth Scan"
    case biophysical = "Biophysical Profile"
    case other = "Other"
}

struct TestResult: Codable, Identifiable {
    var id: UUID = UUID()
    var testName: String
    var category: TestCategory
    var date: Date
    var result: String
    var normalRange: String?
    var isAbnormal: Bool = false
    var provider: String?
    var notes: String?
    var followUpRequired: Bool = false
    var fileData: Data?
}

enum TestCategory: String, Codable, CaseIterable {
    case bloodWork = "Blood Work"
    case urine = "Urine Test"
    case genetic = "Genetic Test"
    case glucose = "Glucose Test"
    case groupBStrep = "Group B Strep"
    case other = "Other"
}

struct InsuranceCard: Codable, Identifiable {
    var id: UUID = UUID()
    var insurerName: String
    var policyNumber: String
    var groupNumber: String?
    var memberId: String
    var cardFrontImage: Data?
    var cardBackImage: Data?
    var coverageType: String
    var phoneNumber: String?
    var website: String?
    var isPrimary: Bool = true
    var expirationDate: Date?
}

struct EmergencyContact: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var relationship: String
    var phoneNumber: String
    var alternatePhone: String?
    var email: String?
    var isPrimary: Bool = false
    var hasHealthcarePOA: Bool = false
    var notes: String?
}

struct ImmunizationRecord: Codable, Identifiable {
    var id: UUID = UUID()
    var vaccineName: String
    var dateGiven: Date
    var provider: String?
    var lotNumber: String?
    var nextDoseDate: Date?
    var notes: String?
}

struct ProviderNote: Codable, Identifiable {
    var id: UUID = UUID()
    var date: Date
    var provider: String
    var visitType: String
    var chiefComplaint: String?
    var assessment: String?
    var plan: String?
    var followUp: String?
    var vitals: VitalSigns?
}

struct VitalSigns: Codable {
    var bloodPressure: String?
    var heartRate: Int?
    var weight: Double?
    var temperature: Double?
    var fundalHeight: Double?
    var fetalHeartRate: Int?
}

// MARK: - Digital Wallet Manager

class DigitalWalletManager: ObservableObject {
    @Published var wallet: DigitalWallet
    private let userId: UUID
    private let storageKey = "DigitalWallet"
    
    init(userId: UUID) {
        self.userId = userId
        self.wallet = DigitalWallet(userId: userId)
        loadWallet()
    }
    
    // MARK: - Medical Records
    
    func addMedicalRecord(_ record: MedicalRecord) {
        wallet.medicalRecords.append(record)
        wallet.updatedAt = Date()
        saveWallet()
    }
    
    func deleteMedicalRecord(_ record: MedicalRecord) {
        wallet.medicalRecords.removeAll { $0.id == record.id }
        wallet.updatedAt = Date()
        saveWallet()
    }
    
    // MARK: - Ultrasounds
    
    func addUltrasound(_ ultrasound: UltrasoundRecord) {
        wallet.ultrasounds.append(ultrasound)
        wallet.updatedAt = Date()
        saveWallet()
    }
    
    func toggleUltrasoundFavorite(_ ultrasoundId: UUID) {
        if let index = wallet.ultrasounds.firstIndex(where: { $0.id == ultrasoundId }) {
            wallet.ultrasounds[index].isFavorite.toggle()
            wallet.updatedAt = Date()
            saveWallet()
        }
    }
    
    // MARK: - Test Results
    
    func addTestResult(_ result: TestResult) {
        wallet.testResults.append(result)
        wallet.updatedAt = Date()
        saveWallet()
    }
    
    func getAbnormalResults() -> [TestResult] {
        wallet.testResults.filter { $0.isAbnormal }
    }
    
    // MARK: - Insurance
    
    func addInsuranceCard(_ card: InsuranceCard) {
        if card.isPrimary {
            // Make all other cards non-primary
            for i in 0..<wallet.insuranceCards.count {
                wallet.insuranceCards[i].isPrimary = false
            }
        }
        wallet.insuranceCards.append(card)
        wallet.updatedAt = Date()
        saveWallet()
    }
    
    func getPrimaryInsurance() -> InsuranceCard? {
        wallet.insuranceCards.first { $0.isPrimary }
    }
    
    // MARK: - Emergency Contacts
    
    func addEmergencyContact(_ contact: EmergencyContact) {
        if contact.isPrimary {
            // Make all other contacts non-primary
            for i in 0..<wallet.emergencyContacts.count {
                wallet.emergencyContacts[i].isPrimary = false
            }
        }
        wallet.emergencyContacts.append(contact)
        wallet.updatedAt = Date()
        saveWallet()
    }
    
    func getPrimaryEmergencyContact() -> EmergencyContact? {
        wallet.emergencyContacts.first { $0.isPrimary }
    }
    
    // MARK: - Immunizations
    
    func addImmunization(_ record: ImmunizationRecord) {
        wallet.immunizationRecords.append(record)
        wallet.updatedAt = Date()
        saveWallet()
    }
    
    func getUpcomingImmunizations() -> [ImmunizationRecord] {
        wallet.immunizationRecords.filter { record in
            if let nextDose = record.nextDoseDate {
                return nextDose > Date()
            }
            return false
        }.sorted { $0.nextDoseDate! < $1.nextDoseDate! }
    }
    
    // MARK: - Provider Notes
    
    func addProviderNote(_ note: ProviderNote) {
        wallet.providerNotes.append(note)
        wallet.updatedAt = Date()
        saveWallet()
    }
    
    func getRecentProviderNotes(limit: Int = 5) -> [ProviderNote] {
        wallet.providerNotes
            .sorted { $0.date > $1.date }
            .prefix(limit)
            .map { $0 }
    }
    
    // MARK: - Search
    
    func searchRecords(query: String) -> (
        medicalRecords: [MedicalRecord],
        testResults: [TestResult],
        providerNotes: [ProviderNote]
    ) {
        let lowercaseQuery = query.lowercased()
        
        let medicalRecords = wallet.medicalRecords.filter { record in
            record.title.lowercased().contains(lowercaseQuery) ||
            record.notes?.lowercased().contains(lowercaseQuery) ?? false ||
            record.tags.contains { $0.lowercased().contains(lowercaseQuery) }
        }
        
        let testResults = wallet.testResults.filter { result in
            result.testName.lowercased().contains(lowercaseQuery) ||
            result.notes?.lowercased().contains(lowercaseQuery) ?? false
        }
        
        let providerNotes = wallet.providerNotes.filter { note in
            note.provider.lowercased().contains(lowercaseQuery) ||
            note.assessment?.lowercased().contains(lowercaseQuery) ?? false ||
            note.chiefComplaint?.lowercased().contains(lowercaseQuery) ?? false
        }
        
        return (medicalRecords, testResults, providerNotes)
    }
    
    // MARK: - Persistence
    
    private func loadWallet() {
        if let data = UserDefaults.standard.data(forKey: "\(storageKey)_\(userId)"),
           let decoded = try? JSONDecoder().decode(DigitalWallet.self, from: data) {
            self.wallet = decoded
        }
    }
    
    private func saveWallet() {
        if let encoded = try? JSONEncoder().encode(wallet) {
            UserDefaults.standard.set(encoded, forKey: "\(storageKey)_\(userId)")
        }
    }
    
    // MARK: - Export
    
    func exportAllData() -> Data? {
        return try? JSONEncoder().encode(wallet)
    }
}