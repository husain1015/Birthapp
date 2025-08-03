import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var showingEditProfile = false
    
    var body: some View {
        NavigationView {
            List {
                if let user = userManager.currentUser {
                    Section {
                        ProfileHeaderView(user: user)
                    }
                    
                    Section(header: Text("Pregnancy Details")) {
                        InfoRow(label: "Due Date", value: user.dueDate, formatter: dateFormatter)
                        InfoRow(label: "Current Week", value: "Week \(user.currentWeekOfPregnancy)")
                        InfoRow(label: "Trimester", value: user.currentTrimester.rawValue)
                        InfoRow(label: "Days to Go", value: "\(user.daysUntilDueDate) days")
                    }
                    
                    Section(header: Text("Settings")) {
                        NavigationLink(destination: NotificationSettingsView()) {
                            SettingRow(icon: "bell", title: "Notifications", color: .blue)
                        }
                        
                        NavigationLink(destination: PrivacySettingsView()) {
                            SettingRow(icon: "lock", title: "Privacy & Security", color: .green)
                        }
                        
                        NavigationLink(destination: AboutView()) {
                            SettingRow(icon: "info.circle", title: "About", color: .gray)
                        }
                    }
                    
                    Section(header: Text("Resources")) {
                        NavigationLink(destination: ProfessionalCreditsView()) {
                            SettingRow(icon: "person.2", title: "Our Professionals", color: .purple)
                        }
                        
                        Link(destination: URL(string: AppConstants.supportURL)!) {
                            SettingRow(icon: "questionmark.circle", title: "Support", color: .orange)
                        }
                    }
                    
                    Section {
                        Button(action: {
                            userManager.deleteUser()
                        }) {
                            Text("Sign Out")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Profile")
            .navigationBarItems(trailing: Button("Edit") {
                showingEditProfile = true
            })
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}

struct ProfileHeaderView: View {
    let user: User
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.pink)
            
            Text(user.name)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(user.email)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
    }
}

struct InfoRow<Value>: View {
    let label: String
    let value: Value
    var formatter: Formatter? = nil
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            
            Spacer()
            
            if let formatter = formatter {
                Text(value as! NSObject, formatter: formatter)
                    .fontWeight(.medium)
            } else {
                Text(String(describing: value))
                    .fontWeight(.medium)
            }
        }
    }
}

struct SettingRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 28)
            
            Text(title)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

struct EditProfileView: View {
    @EnvironmentObject var userManager: UserManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var email = ""
    @State private var dueDate = Date()
    @State private var fitnessLevel: FitnessLevel = .moderatelyActive
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }
                
                Section(header: Text("Pregnancy Details")) {
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                }
                
                Section(header: Text("Fitness Level")) {
                    Picker("Activity Level", selection: $fitnessLevel) {
                        ForEach(FitnessLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveProfile()
                }
            )
            .onAppear {
                loadCurrentProfile()
            }
        }
    }
    
    private func loadCurrentProfile() {
        guard let user = userManager.currentUser else { return }
        name = user.name
        email = user.email
        dueDate = user.dueDate
        fitnessLevel = user.fitnessLevel
    }
    
    private func saveProfile() {
        guard var user = userManager.currentUser else { return }
        user.name = name
        user.email = email
        user.dueDate = dueDate
        user.fitnessLevel = fitnessLevel
        user.updatedAt = Date()
        
        userManager.updateUser(user)
        presentationMode.wrappedValue.dismiss()
    }
}

struct NotificationSettingsView: View {
    @AppStorage("dailyExerciseReminder") private var dailyExerciseReminder = true
    @AppStorage("reminderTime") private var reminderTime = Date()
    @AppStorage("weeklyTips") private var weeklyTips = true
    
    var body: some View {
        Form {
            Section(header: Text("Exercise Reminders")) {
                Toggle("Daily Exercise Reminder", isOn: $dailyExerciseReminder)
                
                if dailyExerciseReminder {
                    DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                }
            }
            
            Section(header: Text("Educational Content")) {
                Toggle("Weekly Pregnancy Tips", isOn: $weeklyTips)
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivacySettingsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Your Privacy Matters")
                    .font(.headline)
                
                Text("ReadyBirth Prep is committed to protecting your personal health information. Here's how we keep your data safe:")
                    .font(.body)
                
                PrivacyPoint(
                    icon: "lock.shield",
                    title: "Encrypted Storage",
                    description: "All your personal data is encrypted and stored securely on your device."
                )
                
                PrivacyPoint(
                    icon: "iphone",
                    title: "Local First",
                    description: "Your exercise history and birth plan are stored locally on your device."
                )
                
                PrivacyPoint(
                    icon: "hand.raised",
                    title: "No Data Sharing",
                    description: "We never share your personal health information with third parties."
                )
                
                PrivacyPoint(
                    icon: "trash",
                    title: "Data Deletion",
                    description: "You can delete all your data at any time from the Profile settings."
                )
            }
            .padding()
        }
        .navigationTitle("Privacy & Security")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivacyPoint: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.green)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 5)
    }
}

struct AboutView: View {
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Build")
                    Spacer()
                    Text("2025.1")
                        .foregroundColor(.secondary)
                }
            }
            
            Section(header: Text("Legal")) {
                Link("Terms of Service", destination: URL(string: AppConstants.termsURL)!)
                Link("Privacy Policy", destination: URL(string: AppConstants.privacyURL)!)
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProfessionalCreditsView: View {
    let professionals = [
        ProfessionalCredential(
            name: "Dr. Jennifer Vohra",
            title: "DPT, Pelvic Floor Specialist",
            certification: "Bloom Pelvic Health & Wellness",
            bio: "Expert in prenatal and postpartum pelvic health rehabilitation"
        )
    ]
    
    var body: some View {
        List {
            ForEach(professionals, id: \.name) { professional in
                VStack(alignment: .leading, spacing: 10) {
                    Text(professional.name)
                        .font(.headline)
                    
                    Text(professional.title)
                        .font(.subheadline)
                        .foregroundColor(.pink)
                    
                    Text(professional.certification)
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    if let bio = professional.bio {
                        Text(bio)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 5)
            }
        }
        .navigationTitle("Our Professionals")
        .navigationBarTitleDisplayMode(.inline)
    }
}