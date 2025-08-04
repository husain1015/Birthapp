import SwiftUI

struct EnhancedDashboardView: View {
    @EnvironmentObject var userManager: UserManager
    @StateObject private var digitalWalletManager: DigitalWalletManager
    @StateObject private var medicationManager: MedicationManager
    @StateObject private var mentalHealthManager: MentalHealthManager
    @StateObject private var emergencyManager: EmergencyManager
    
    @State private var showingEmergencyView = false
    @State private var showingSymptomChecker = false
    @State private var showingMentalHealth = false
    @State private var showingMedications = false
    @State private var showingDigitalWallet = false
    
    init() {
        let userId = UserManager().currentUser?.id ?? UUID()
        _digitalWalletManager = StateObject(wrappedValue: DigitalWalletManager(userId: userId))
        _medicationManager = StateObject(wrappedValue: MedicationManager(userId: userId))
        _mentalHealthManager = StateObject(wrappedValue: MentalHealthManager(userId: userId))
        _emergencyManager = StateObject(wrappedValue: EmergencyManager(userId: userId))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // User Welcome Section
                    if let user = userManager.currentUser {
                        WelcomeCard(user: user)
                            .padding(.horizontal)
                    }
                    
                    // Emergency Quick Access
                    if emergencyManager.quickContractionTimer.isTimingContraction ||
                       emergencyManager.quickContractionTimer.pattern == .timeToGo {
                        EmergencyQuickAccessCard(
                            emergencyManager: emergencyManager,
                            onTap: { showingEmergencyView = true }
                        )
                        .padding(.horizontal)
                    }
                    
                    // Quick Actions Grid
                    QuickActionsGrid(
                        onEmergencyTap: { showingEmergencyView = true },
                        onSymptomTap: { showingSymptomChecker = true },
                        onMentalHealthTap: { showingMentalHealth = true },
                        onMedicationTap: { showingMedications = true }
                    )
                    .padding(.horizontal)
                    
                    // Today's Overview
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Today's Overview")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        // Medications Due
                        if !medicationManager.todaysMedications.filter({ !$0.isLogged }).isEmpty {
                            MedicationReminderCard(
                                medicationManager: medicationManager,
                                onTap: { showingMedications = true }
                            )
                            .padding(.horizontal)
                        }
                        
                        // Mental Health Check-in
                        if mentalHealthManager.getTodaysMoodEntry() == nil {
                            MentalHealthReminderCard(
                                onTap: { showingMentalHealth = true }
                            )
                            .padding(.horizontal)
                        }
                        
                        // Weekly Exercise Plan
                        WeeklyPlanCard()
                            .padding(.horizontal)
                    }
                    
                    // Health Insights
                    HealthInsightsSection(
                        mentalHealthManager: mentalHealthManager,
                        medicationManager: medicationManager
                    )
                    .padding(.horizontal)
                    
                    // Quick Access Cards
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Quick Access")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack(spacing: 12) {
                            QuickFeatureCard(
                                title: "Digital Wallet",
                                icon: "folder.fill",
                                color: .blue,
                                badge: "\(digitalWalletManager.wallet.medicalRecords.count + digitalWalletManager.wallet.testResults.count)",
                                onTap: { showingDigitalWallet = true }
                            )
                            
                            QuickFeatureCard(
                                title: "Symptom Check",
                                icon: "stethoscope",
                                color: .orange,
                                badge: nil,
                                onTap: { showingSymptomChecker = true }
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Educational Content
                    EducationalContentSection()
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Ready Birth Prep")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingEmergencyView) {
                EmergencyView(userId: userManager.currentUser?.id ?? UUID())
            }
            .sheet(isPresented: $showingSymptomChecker) {
                SymptomCheckerView(userId: userManager.currentUser?.id ?? UUID())
            }
            .sheet(isPresented: $showingMentalHealth) {
                MentalHealthView(userId: userManager.currentUser?.id ?? UUID())
            }
            .sheet(isPresented: $showingMedications) {
                MedicationTrackerView(userId: userManager.currentUser?.id ?? UUID())
            }
            .sheet(isPresented: $showingDigitalWallet) {
                DigitalWalletView(userId: userManager.currentUser?.id ?? UUID())
            }
        }
    }
}

// MARK: - Welcome Card

struct WelcomeCard: View {
    let user: User
    
    var pregnancyWeek: Int {
        user.currentWeekOfPregnancy
    }
    
    var daysUntilDue: Int {
        user.daysUntilDueDate
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hello, \(user.name)!")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Week \(pregnancyWeek)")
                        .font(.headline)
                        .foregroundColor(.pink)
                    Text(user.currentTrimester.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                    .frame(height: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(daysUntilDue) days")
                        .font(.headline)
                        .foregroundColor(.purple)
                    Text("Until due date")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.pink.opacity(0.1), .purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
    }
}

// MARK: - Emergency Quick Access Card

struct EmergencyQuickAccessCard: View {
    @ObservedObject var emergencyManager: EmergencyManager
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        if emergencyManager.quickContractionTimer.isTimingContraction {
                            Text("Timing Contraction")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Tap to view timer")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        } else if emergencyManager.quickContractionTimer.pattern == .timeToGo {
                            Text("Time to Call Provider")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("5-1-1 rule met")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                }
                
                if !emergencyManager.quickContractionTimer.contractions.isEmpty {
                    HStack(spacing: 20) {
                        Text("\(emergencyManager.quickContractionTimer.contractions.count) contractions")
                        Text("Avg: \(Int(emergencyManager.quickContractionTimer.averageInterval / 60))m apart")
                    }
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding()
            .background(Color.red)
            .cornerRadius(12)
        }
    }
}

// MARK: - Quick Actions Grid

struct QuickActionsGrid: View {
    let onEmergencyTap: () -> Void
    let onSymptomTap: () -> Void
    let onMentalHealthTap: () -> Void
    let onMedicationTap: () -> Void
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            QuickActionButton(
                title: "Emergency",
                icon: "phone.fill",
                color: .red,
                onTap: onEmergencyTap
            )
            
            QuickActionButton(
                title: "Symptoms",
                icon: "stethoscope",
                color: .orange,
                onTap: onSymptomTap
            )
            
            QuickActionButton(
                title: "Mental Health",
                icon: "heart.fill",
                color: .purple,
                onTap: onMentalHealthTap
            )
            
            QuickActionButton(
                title: "Medications",
                icon: "pills.fill",
                color: .green,
                onTap: onMedicationTap
            )
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(color)
            .cornerRadius(12)
        }
    }
}

// MARK: - Medication Reminder Card

struct MedicationReminderCard: View {
    @ObservedObject var medicationManager: MedicationManager
    let onTap: () -> Void
    
    var upcomingCount: Int {
        medicationManager.todaysMedications.filter { !$0.isLogged }.count
    }
    
    var nextMedication: MedicationScheduleItem? {
        medicationManager.todaysMedications
            .filter { !$0.isLogged && $0.scheduledTime > Date() }
            .sorted { $0.scheduledTime < $1.scheduledTime }
            .first
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: "pills.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(upcomingCount) medications today")
                        .font(.headline)
                    
                    if let next = nextMedication {
                        Text("Next: \(next.medication.name) at \(next.scheduledTime, style: .time)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .foregroundColor(.primary)
    }
}

// MARK: - Mental Health Reminder Card

struct MentalHealthReminderCard: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: "heart.text.square")
                    .font(.title2)
                    .foregroundColor(.purple)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily mood check-in")
                        .font(.headline)
                    Text("Take a moment to reflect on how you're feeling")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .foregroundColor(.primary)
    }
}

// MARK: - Weekly Plan Card

struct WeeklyPlanCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Exercise Plan")
                        .font(.headline)
                    Text("30 minutes • Pelvic floor & stretching")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            ProgressView(value: 0.3)
                .accentColor(.blue)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Health Insights Section

struct HealthInsightsSection: View {
    @ObservedObject var mentalHealthManager: MentalHealthManager
    @ObservedObject var medicationManager: MedicationManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Health Insights")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Mood Trend
                    InsightCard(
                        title: "Mood Trend",
                        value: String(format: "%.1f", mentalHealthManager.getAverageMood()),
                        subtitle: "7-day average",
                        color: .purple,
                        icon: "chart.line.uptrend.xyaxis"
                    )
                    
                    // Medication Adherence
                    InsightCard(
                        title: "Med Adherence",
                        value: "85%",
                        subtitle: "This week",
                        color: .green,
                        icon: "checkmark.circle.fill"
                    )
                    
                    // Exercise Streak
                    InsightCard(
                        title: "Exercise Streak",
                        value: "5",
                        subtitle: "Days",
                        color: .orange,
                        icon: "flame.fill"
                    )
                }
            }
        }
    }
}

struct InsightCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(width: 120)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Quick Feature Card

struct QuickFeatureCard: View {
    let title: String
    let icon: String
    let color: Color
    let badge: String?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: icon)
                        .font(.title)
                        .foregroundColor(color)
                    
                    if let badge = badge {
                        Text(badge)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .clipShape(Capsule())
                            .offset(x: 12, y: -8)
                    }
                }
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        .foregroundColor(.primary)
    }
}

// MARK: - Educational Content Section

struct EducationalContentSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Learning")
                .font(.headline)
            
            VStack(spacing: 12) {
                EducationalCard(
                    title: "Week 28: Third Trimester Begins",
                    description: "Learn about your baby's development and what to expect",
                    icon: "book.fill",
                    color: .indigo
                )
                
                EducationalCard(
                    title: "Preparing for Labor",
                    description: "Essential tips for the final weeks of pregnancy",
                    icon: "lightbulb.fill",
                    color: .yellow
                )
            }
        }
    }
}

struct EducationalCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}