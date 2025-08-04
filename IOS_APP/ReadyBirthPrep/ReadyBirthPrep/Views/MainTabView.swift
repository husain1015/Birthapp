import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            EnhancedDashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            PrenatalPrepView()
                .tabItem {
                    Label("Prenatal", systemImage: "figure.walk")
                }
                .tag(1)
            
            LaborBirthView()
                .tabItem {
                    Label("Labor", systemImage: "heart.text.square")
                }
                .tag(2)
            
            PostpartumView()
                .tabItem {
                    Label("Recovery", systemImage: "leaf.fill")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(4)
        }
        .accentColor(.pink)
    }
}