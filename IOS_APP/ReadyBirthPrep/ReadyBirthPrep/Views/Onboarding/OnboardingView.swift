import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @State private var currentPage = 0
    
    var body: some View {
        TabView(selection: $currentPage) {
            WelcomeView()
                .tag(0)
            
            HealthDisclaimerView()
                .tag(1)
            
            ProfileSetupView(showOnboarding: $showOnboarding)
                .tag(2)
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    }
}

struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.pink)
            
            Text("Welcome to ReadyBirth Prep")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Your comprehensive companion for pelvic floor health, birth preparation, and postpartum recovery")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .foregroundColor(.secondary)
            
            Spacer()
            
            VStack(spacing: 20) {
                FeatureRow(icon: "figure.walk", title: "Evidence-based exercises", description: "Vetted by certified professionals")
                FeatureRow(icon: "calendar", title: "Personalized journey", description: "Tailored to your trimester and needs")
                FeatureRow(icon: "shield.checkered", title: "Safe and secure", description: "Your data is protected and private")
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
        .padding()
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.pink)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}