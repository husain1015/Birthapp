import SwiftUI

struct ProfileSetupView: View {
    @EnvironmentObject var userManager: UserManager
    @Binding var showOnboarding: Bool
    
    @State private var name = ""
    @State private var email = ""
    @State private var dueDate = Date()
    @State private var currentTrimester: Trimester = .first
    @State private var fitnessLevel: FitnessLevel = .moderatelyActive
    @State private var selectedGoals: Set<PregnancyGoal> = []
    @State private var selectedConcerns: Set<PregnancyConcern> = []
    @State private var hasPreviousBirths = false
    @State private var previousBirthType: BirthType = .vaginal
    @State private var showComprehensiveAssessment = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Your Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }
                
                Section(header: Text("Pregnancy Details")) {
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                    
                    Picker("Current Trimester", selection: $currentTrimester) {
                        ForEach(Trimester.allCases, id: \.self) { trimester in
                            Text(trimester.rawValue).tag(trimester)
                        }
                    }
                }
                
                Section(header: Text("Fitness Level")) {
                    Picker("Current Activity Level", selection: $fitnessLevel) {
                        ForEach(FitnessLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Birth History")) {
                    Toggle("Previous births", isOn: $hasPreviousBirths)
                    
                    if hasPreviousBirths {
                        Picker("Previous birth type", selection: $previousBirthType) {
                            ForEach(BirthType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                Section(header: Text("Your Goals")) {
                    ForEach(PregnancyGoal.allCases, id: \.self) { goal in
                        MultipleSelectionRow(
                            title: goal.rawValue,
                            isSelected: selectedGoals.contains(goal)
                        ) {
                            if selectedGoals.contains(goal) {
                                selectedGoals.remove(goal)
                            } else {
                                selectedGoals.insert(goal)
                            }
                        }
                    }
                }
                
                Section(header: Text("Any Concerns?")) {
                    ForEach(PregnancyConcern.allCases, id: \.self) { concern in
                        MultipleSelectionRow(
                            title: concern.rawValue,
                            isSelected: selectedConcerns.contains(concern)
                        ) {
                            if selectedConcerns.contains(concern) {
                                selectedConcerns.remove(concern)
                            } else {
                                selectedConcerns.insert(concern)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Create Your Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Complete") {
                        createProfile()
                    }
                    .disabled(name.isEmpty || email.isEmpty)
                }
            }
        }
        .fullScreenCover(isPresented: $showComprehensiveAssessment) {
            ComprehensiveAssessmentView()
                .environmentObject(userManager)
        }
    }
    
    private func createProfile() {
        var user = User(
            name: name,
            email: email,
            dueDate: dueDate,
            currentTrimester: currentTrimester,
            fitnessLevel: fitnessLevel
        )
        
        user.goals = Array(selectedGoals)
        user.concerns = Array(selectedConcerns)
        user.hasAcceptedDisclaimer = true
        
        if hasPreviousBirths {
            user.previousBirthHistory = [BirthHistory(birthType: previousBirthType, year: Calendar.current.component(.year, from: Date()) - 2)]
        }
        
        userManager.createUser(user)
        
        // Show comprehensive assessment for personalized plan
        showComprehensiveAssessment = true
    }
}

struct MultipleSelectionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.pink)
                }
            }
        }
    }
}