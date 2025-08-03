import Foundation
import SwiftUI

class UserManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isFirstLaunch: Bool = true
    @Published var pregnancyAssessment: PregnancyAssessment?
    @Published var weeklyPlans: [WeeklyPlan] = []
    
    private let userDefaultsKey = "currentUser"
    private let firstLaunchKey = "isFirstLaunch"
    private let assessmentKey = "pregnancyAssessment"
    private let weeklyPlansKey = "weeklyPlans"
    
    init() {
        loadUser()
        checkFirstLaunch()
        loadAssessment()
        loadWeeklyPlans()
    }
    
    func checkFirstLaunch() {
        isFirstLaunch = UserDefaults.standard.object(forKey: firstLaunchKey) == nil
        if isFirstLaunch {
            UserDefaults.standard.set(false, forKey: firstLaunchKey)
        }
    }
    
    func createUser(_ user: User) {
        currentUser = user
        saveUser()
    }
    
    func updateUser(_ user: User) {
        currentUser = user
        saveUser()
    }
    
    func addBirthPlan(_ birthPlan: BirthPlan, for user: User) {
        var updatedUser = user
        if updatedUser.birthPlans == nil {
            updatedUser.birthPlans = []
        }
        updatedUser.birthPlans?.append(birthPlan)
        updateUser(updatedUser)
    }
    
    func deleteUser() {
        currentUser = nil
        pregnancyAssessment = nil
        weeklyPlans = []
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        UserDefaults.standard.removeObject(forKey: assessmentKey)
        UserDefaults.standard.removeObject(forKey: weeklyPlansKey)
    }
    
    // MARK: - Assessment Management
    func updateUserAssessment(_ assessment: PregnancyAssessment, for user: User) {
        guard currentUser?.id == user.id else { return }
        pregnancyAssessment = assessment
        
        if let encoded = try? JSONEncoder().encode(assessment) {
            UserDefaults.standard.set(encoded, forKey: assessmentKey)
        }
    }
    
    func getUserAssessment(for user: User) -> PregnancyAssessment? {
        guard currentUser?.id == user.id else { return nil }
        return pregnancyAssessment
    }
    
    private func loadAssessment() {
        if let assessmentData = UserDefaults.standard.data(forKey: assessmentKey),
           let decoded = try? JSONDecoder().decode(PregnancyAssessment.self, from: assessmentData) {
            pregnancyAssessment = decoded
        }
    }
    
    // MARK: - Weekly Plan Management
    func saveWeeklyPlan(_ plan: WeeklyPlan) {
        // Remove existing plan for the same week if exists
        weeklyPlans.removeAll { $0.weekNumber == plan.weekNumber }
        weeklyPlans.append(plan)
        
        if let encoded = try? JSONEncoder().encode(weeklyPlans) {
            UserDefaults.standard.set(encoded, forKey: weeklyPlansKey)
        }
    }
    
    func getWeeklyPlan(for week: Int) -> WeeklyPlan? {
        return weeklyPlans.first { $0.weekNumber == week }
    }
    
    func updateWeeklyPlan(_ plan: WeeklyPlan) {
        saveWeeklyPlan(plan)
    }
    
    private func loadWeeklyPlans() {
        if let plansData = UserDefaults.standard.data(forKey: weeklyPlansKey),
           let decoded = try? JSONDecoder().decode([WeeklyPlan].self, from: plansData) {
            weeklyPlans = decoded
        }
    }
    
    // MARK: - Private Methods
    private func saveUser() {
        guard let user = currentUser else { return }
        
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadUser() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return
        }
        
        currentUser = user
    }
    
    // MARK: - Helper Methods for User Data
    func addExerciseHistory(_ history: ExerciseHistory, for user: User) {
        var updatedUser = user
        if updatedUser.exerciseHistory == nil {
            updatedUser.exerciseHistory = []
        }
        updatedUser.exerciseHistory?.append(history)
        updateUser(updatedUser)
    }
    
    func addMeditation(_ meditation: Meditation, for user: User) {
        var updatedUser = user
        if updatedUser.meditations == nil {
            updatedUser.meditations = []
        }
        updatedUser.meditations?.append(meditation)
        updateUser(updatedUser)
    }
    
    func addJournalEntry(_ entry: JournalEntry, for user: User) {
        var updatedUser = user
        if updatedUser.journalEntries == nil {
            updatedUser.journalEntries = []
        }
        updatedUser.journalEntries?.append(entry)
        updateUser(updatedUser)
    }
    
    func addContraction(_ contraction: Contraction, for user: User) {
        var updatedUser = user
        if updatedUser.contractions == nil {
            updatedUser.contractions = []
        }
        updatedUser.contractions?.append(contraction)
        updateUser(updatedUser)
    }
}