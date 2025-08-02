import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var showOnboarding = false
    
    var body: some View {
        Group {
            if userManager.isFirstLaunch || showOnboarding {
                OnboardingView(showOnboarding: $showOnboarding)
            } else if userManager.currentUser == nil {
                LoginView()
            } else {
                MainTabView()
            }
        }
        .onAppear {
            userManager.checkFirstLaunch()
        }
    }
}