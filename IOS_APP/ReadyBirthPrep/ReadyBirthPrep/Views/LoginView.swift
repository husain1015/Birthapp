import SwiftUI

struct LoginView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var showProfileSetup = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.pink)
            
            Text("ReadyBirth Prep")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Your pregnancy & postpartum companion")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button(action: {
                showProfileSetup = true
            }) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.pink)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .sheet(isPresented: $showProfileSetup) {
            ProfileSetupView(showOnboarding: .constant(false))
        }
    }
}