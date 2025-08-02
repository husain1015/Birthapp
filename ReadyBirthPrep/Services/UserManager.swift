import Foundation
import SwiftUI

class UserManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isFirstLaunch: Bool = true
    
    private let userDefaultsKey = "currentUser"
    private let firstLaunchKey = "isFirstLaunch"
    
    init() {
        loadUser()
        checkFirstLaunch()
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
    
    func deleteUser() {
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
    
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
}