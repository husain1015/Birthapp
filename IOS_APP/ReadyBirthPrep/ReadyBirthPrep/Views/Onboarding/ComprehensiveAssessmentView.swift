import SwiftUI

struct ComprehensiveAssessmentView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var assessment = PregnancyAssessment(userId: UUID())
    @State private var currentSection = 0
    @State private var showingWeeklyPlan = false
    
    let sections = [
        "Basic Information",
        "Medical History",
        "Previous Pregnancies",
        "Lifestyle Factors",
        "Current Symptoms",
        "Fitness Level",
        "Nutrition",
        "Mental Health",
        "Support System",
        "Preferences"
    ]
    
    var body: some View {
        VStack {
            // Progress indicator
            ProgressView(value: Double(currentSection + 1), total: Double(sections.count))
                .progressViewStyle(LinearProgressViewStyle(tint: AppConstants.primaryColor))
                .padding()
            
            Text(sections[currentSection])
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            TabView(selection: $currentSection) {
                BasicInfoSection(assessment: $assessment)
                    .tag(0)
                
                MedicalHistorySection(assessment: $assessment)
                    .tag(1)
                
                PregnancyHistorySection(assessment: $assessment)
                    .tag(2)
                
                LifestyleSection(assessment: $assessment)
                    .tag(3)
                
                CurrentSymptomsSection(assessment: $assessment)
                    .tag(4)
                
                FitnessSection(assessment: $assessment)
                    .tag(5)
                
                NutritionSection(assessment: $assessment)
                    .tag(6)
                
                MentalHealthSection(assessment: $assessment)
                    .tag(7)
                
                SupportSystemSection(assessment: $assessment)
                    .tag(8)
                
                PreferencesSection(assessment: $assessment)
                    .tag(9)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Navigation buttons
            HStack {
                if currentSection > 0 {
                    Button(action: {
                        withAnimation {
                            currentSection -= 1
                        }
                    }) {
                        Label("Previous", systemImage: "chevron.left")
                    }
                }
                
                Spacer()
                
                if currentSection < sections.count - 1 {
                    Button(action: {
                        withAnimation {
                            currentSection += 1
                        }
                    }) {
                        Label("Next", systemImage: "chevron.right")
                    }
                } else {
                    Button(action: completeAssessment) {
                        Label("Complete Assessment", systemImage: "checkmark.circle")
                            .fontWeight(.bold)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
        .navigationTitle("Pregnancy Assessment")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showingWeeklyPlan) {
            WeeklyPlanView()
                .environmentObject(userManager)
        }
    }
    
    private func completeAssessment() {
        // Calculate risk factors
        assessment.riskFactors = calculateRiskFactors()
        
        // Create a new assessment with the correct userId
        if let user = userManager.currentUser {
            var finalAssessment = PregnancyAssessment(userId: user.id)
            finalAssessment.basicInfo = assessment.basicInfo
            finalAssessment.medicalHistory = assessment.medicalHistory
            finalAssessment.lifestyleFactors = assessment.lifestyleFactors
            finalAssessment.pregnancyHistory = assessment.pregnancyHistory
            finalAssessment.currentSymptoms = assessment.currentSymptoms
            finalAssessment.fitnessLevel = assessment.fitnessLevel
            finalAssessment.nutritionProfile = assessment.nutritionProfile
            finalAssessment.mentalHealthProfile = assessment.mentalHealthProfile
            finalAssessment.supportSystem = assessment.supportSystem
            finalAssessment.preferences = assessment.preferences
            finalAssessment.riskFactors = assessment.riskFactors
            
            // Save assessment to user profile
            userManager.updateUserAssessment(finalAssessment, for: user)
        }
        
        showingWeeklyPlan = true
    }
    
    private func calculateRiskFactors() -> [RiskFactor] {
        var risks: [RiskFactor] = []
        
        // Age-related risks
        if let age = assessment.basicInfo.age {
            if age < 18 {
                risks.append(RiskFactor(
                    category: .maternal,
                    factor: "Teen pregnancy",
                    severity: .moderate,
                    recommendations: ["Extra nutritional support", "Close monitoring", "Social support services"]
                ))
            } else if age >= 35 {
                risks.append(RiskFactor(
                    category: .maternal,
                    factor: "Advanced maternal age",
                    severity: age >= 40 ? .high : .moderate,
                    recommendations: ["Genetic counseling", "Additional screening", "Close monitoring"]
                ))
            }
        }
        
        // BMI-related risks
        if let height = assessment.basicInfo.height,
           let weight = assessment.basicInfo.prePregnancyWeight {
            let bmi = (weight / (height * height)) * 703
            if bmi < 18.5 {
                risks.append(RiskFactor(
                    category: .maternal,
                    factor: "Underweight",
                    severity: .moderate,
                    recommendations: ["Nutritional counseling", "Weight gain monitoring", "Supplement support"]
                ))
            } else if bmi >= 30 {
                risks.append(RiskFactor(
                    category: .maternal,
                    factor: "Obesity",
                    severity: bmi >= 35 ? .high : .moderate,
                    recommendations: ["Nutritional guidance", "Exercise plan", "Glucose monitoring"]
                ))
            }
        }
        
        // Medical history risks
        for condition in assessment.medicalHistory.chronicConditions {
            let severity: RiskSeverity = {
                switch condition.type {
                case .diabetes, .hypertension, .heartDisease:
                    return .high
                case .thyroid, .autoimmune, .epilepsy:
                    return .moderate
                default:
                    return .low
                }
            }()
            
            risks.append(RiskFactor(
                category: .maternal,
                factor: condition.type.rawValue,
                severity: severity,
                recommendations: ["Specialist consultation", "Medication review", "Close monitoring"]
            ))
        }
        
        // Previous pregnancy complications
        for complication in assessment.pregnancyHistory.previousPregnancyComplications {
            risks.append(RiskFactor(
                category: .maternal,
                factor: "History of \(complication.type.rawValue)",
                severity: .moderate,
                recommendations: ["Early screening", "Preventive measures", "Specialist care"]
            ))
        }
        
        // Lifestyle risks
        if assessment.lifestyleFactors.smoking == .current {
            risks.append(RiskFactor(
                category: .lifestyle,
                factor: "Current smoking",
                severity: .high,
                recommendations: ["Smoking cessation program", "Support resources", "Close monitoring"]
            ))
        }
        
        if assessment.lifestyleFactors.stressLevel == .veryHigh {
            risks.append(RiskFactor(
                category: .psychosocial,
                factor: "High stress levels",
                severity: .moderate,
                recommendations: ["Stress management", "Mental health support", "Relaxation techniques"]
            ))
        }
        
        return risks
    }
}

// MARK: - Assessment Sections

struct BasicInfoSection: View {
    @Binding var assessment: PregnancyAssessment
    
    var body: some View {
        Form {
            Section(header: Text("Personal Information")) {
                HStack {
                    Text("Age")
                    Spacer()
                    TextField("Age", value: $assessment.basicInfo.age, format: .number)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 60)
                }
                
                DatePicker("Due Date", selection: Binding(
                    get: { assessment.basicInfo.dueDate ?? Date() },
                    set: { assessment.basicInfo.dueDate = $0 }
                ), displayedComponents: .date)
                
                DatePicker("Last Menstrual Period", selection: Binding(
                    get: { assessment.basicInfo.lastMenstrualPeriod ?? Date() },
                    set: { assessment.basicInfo.lastMenstrualPeriod = $0 }
                ), displayedComponents: .date)
            }
            
            Section(header: Text("Physical Information")) {
                HStack {
                    Text("Height")
                    Spacer()
                    TextField("Feet", value: Binding(
                        get: { Int((assessment.basicInfo.height ?? 0) / 12) },
                        set: { feet in
                            let inches = (assessment.basicInfo.height ?? 0).truncatingRemainder(dividingBy: 12)
                            assessment.basicInfo.height = Double(feet * 12) + inches
                        }
                    ), format: .number)
                    .keyboardType(.numberPad)
                    .frame(width: 40)
                    Text("ft")
                    
                    TextField("Inches", value: Binding(
                        get: { Int((assessment.basicInfo.height ?? 0).truncatingRemainder(dividingBy: 12)) },
                        set: { inches in
                            let feet = Int((assessment.basicInfo.height ?? 0) / 12)
                            assessment.basicInfo.height = Double(feet * 12 + inches)
                        }
                    ), format: .number)
                    .keyboardType(.numberPad)
                    .frame(width: 40)
                    Text("in")
                }
                
                HStack {
                    Text("Pre-pregnancy Weight")
                    Spacer()
                    TextField("Weight", value: $assessment.basicInfo.prePregnancyWeight, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                    Text("lbs")
                }
                
                HStack {
                    Text("Current Weight")
                    Spacer()
                    TextField("Weight", value: $assessment.basicInfo.currentWeight, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                    Text("lbs")
                }
            }
            
            Section(header: Text("Pregnancy Details")) {
                Toggle("First Pregnancy", isOn: $assessment.basicInfo.isFirstPregnancy)
                Toggle("Multiple Pregnancy (Twins, etc.)", isOn: $assessment.basicInfo.multiplePregnancy)
                
                if assessment.basicInfo.multiplePregnancy {
                    Stepper("Number of Babies: \(assessment.basicInfo.numberOfBabies)",
                           value: $assessment.basicInfo.numberOfBabies,
                           in: 2...5)
                }
            }
        }
    }
}

struct MedicalHistorySection: View {
    @Binding var assessment: PregnancyAssessment
    @State private var showingConditionPicker = false
    @State private var newMedication = ""
    @State private var newAllergy = ""
    
    var body: some View {
        Form {
            Section(header: Text("Chronic Conditions")) {
                ForEach(assessment.medicalHistory.chronicConditions.indices, id: \.self) { index in
                    VStack(alignment: .leading) {
                        Text(assessment.medicalHistory.chronicConditions[index].type.rawValue)
                            .font(.headline)
                        if let details = assessment.medicalHistory.chronicConditions[index].details {
                            Text(details)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Button(action: { showingConditionPicker = true }) {
                    Label("Add Condition", systemImage: "plus.circle")
                }
            }
            
            Section(header: Text("Current Medications")) {
                ForEach(assessment.medicalHistory.medications, id: \.self) { medication in
                    Text(medication)
                }
                
                HStack {
                    TextField("Add medication", text: $newMedication)
                    Button("Add") {
                        if !newMedication.isEmpty {
                            assessment.medicalHistory.medications.append(newMedication)
                            newMedication = ""
                        }
                    }
                }
            }
            
            Section(header: Text("Allergies")) {
                ForEach(assessment.medicalHistory.allergies, id: \.self) { allergy in
                    Text(allergy)
                }
                
                HStack {
                    TextField("Add allergy", text: $newAllergy)
                    Button("Add") {
                        if !newAllergy.isEmpty {
                            assessment.medicalHistory.allergies.append(newAllergy)
                            newAllergy = ""
                        }
                    }
                }
            }
            
            Section(header: Text("Blood Type")) {
                Picker("Blood Type", selection: Binding(
                    get: { assessment.medicalHistory.bloodType ?? "Unknown" },
                    set: { assessment.medicalHistory.bloodType = $0 }
                )) {
                    Text("Unknown").tag("Unknown")
                    Text("A+").tag("A+")
                    Text("A-").tag("A-")
                    Text("B+").tag("B+")
                    Text("B-").tag("B-")
                    Text("AB+").tag("AB+")
                    Text("AB-").tag("AB-")
                    Text("O+").tag("O+")
                    Text("O-").tag("O-")
                }
            }
        }
        .sheet(isPresented: $showingConditionPicker) {
            AddChronicConditionView(conditions: $assessment.medicalHistory.chronicConditions)
        }
    }
}

struct PregnancyHistorySection: View {
    @Binding var assessment: PregnancyAssessment
    
    var body: some View {
        Form {
            Section(header: Text("Previous Pregnancies")) {
                Stepper("Total Pregnancies: \(assessment.pregnancyHistory.previousPregnancies)",
                       value: $assessment.pregnancyHistory.previousPregnancies,
                       in: 0...20)
                
                if assessment.pregnancyHistory.previousPregnancies > 0 {
                    Stepper("Live Births: \(assessment.pregnancyHistory.liveBirths)",
                           value: $assessment.pregnancyHistory.liveBirths,
                           in: 0...assessment.pregnancyHistory.previousPregnancies)
                    
                    Stepper("Miscarriages: \(assessment.pregnancyHistory.miscarriages)",
                           value: $assessment.pregnancyHistory.miscarriages,
                           in: 0...assessment.pregnancyHistory.previousPregnancies)
                    
                    Stepper("Stillbirths: \(assessment.pregnancyHistory.stillbirths)",
                           value: $assessment.pregnancyHistory.stillbirths,
                           in: 0...assessment.pregnancyHistory.previousPregnancies)
                    
                    Toggle("Previous C-Section", isOn: $assessment.pregnancyHistory.previousCSection)
                }
            }
            
            if assessment.pregnancyHistory.previousPregnancies > 0 {
                Section(header: Text("Previous Complications")) {
                    ForEach(PregnancyComplication.ComplicationType.allCases, id: \.self) { type in
                        MultipleSelectionRow(
                            title: type.rawValue,
                            isSelected: assessment.pregnancyHistory.previousPregnancyComplications.contains { $0.type == type }
                        ) {
                            if let index = assessment.pregnancyHistory.previousPregnancyComplications.firstIndex(where: { $0.type == type }) {
                                assessment.pregnancyHistory.previousPregnancyComplications.remove(at: index)
                            } else {
                                assessment.pregnancyHistory.previousPregnancyComplications.append(
                                    PregnancyComplication(type: type)
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

struct LifestyleSection: View {
    @Binding var assessment: PregnancyAssessment
    
    var body: some View {
        Form {
            Section(header: Text("Work & Environment")) {
                TextField("Occupation", text: Binding(
                    get: { assessment.lifestyleFactors.occupation ?? "" },
                    set: { assessment.lifestyleFactors.occupation = $0.isEmpty ? nil : $0 }
                ))
                
                Stepper("Work Hours/Week: \(assessment.lifestyleFactors.workHoursPerWeek ?? 0)",
                       value: Binding(
                        get: { assessment.lifestyleFactors.workHoursPerWeek ?? 0 },
                        set: { assessment.lifestyleFactors.workHoursPerWeek = $0 }
                       ),
                       in: 0...80)
                
                Toggle("Physically Demanding Job", isOn: $assessment.lifestyleFactors.physicallyDemandingJob)
                Toggle("Chemical Exposure", isOn: $assessment.lifestyleFactors.exposureToChemicals)
            }
            
            Section(header: Text("Habits")) {
                Picker("Smoking Status", selection: $assessment.lifestyleFactors.smoking) {
                    ForEach(SmokingStatus.allCases, id: \.self) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
                
                Picker("Alcohol Use", selection: $assessment.lifestyleFactors.alcoholUse) {
                    ForEach(AlcoholUse.allCases, id: \.self) { use in
                        Text(use.rawValue).tag(use)
                    }
                }
                
                Stepper("Caffeine Cups/Day: \(assessment.lifestyleFactors.caffeineCupsPerDay)",
                       value: $assessment.lifestyleFactors.caffeineCupsPerDay,
                       in: 0...10)
            }
            
            Section(header: Text("Sleep & Stress")) {
                HStack {
                    Text("Sleep Hours/Night")
                    Spacer()
                    Text("\(assessment.lifestyleFactors.sleepHoursPerNight, specifier: "%.1f")")
                    Stepper("", value: $assessment.lifestyleFactors.sleepHoursPerNight, in: 4...12, step: 0.5)
                        .labelsHidden()
                }
                
                Picker("Stress Level", selection: $assessment.lifestyleFactors.stressLevel) {
                    ForEach(StressLevel.allCases, id: \.self) { level in
                        Text(level.rawValue).tag(level)
                    }
                }
            }
        }
    }
}

struct CurrentSymptomsSection: View {
    @Binding var assessment: PregnancyAssessment
    
    var body: some View {
        Form {
            Section(header: Text("Rate Your Current Symptoms")) {
                AssessmentSymptomRow(symptom: "Nausea", severity: $assessment.currentSymptoms.nausea)
                AssessmentSymptomRow(symptom: "Fatigue", severity: $assessment.currentSymptoms.fatigue)
                AssessmentSymptomRow(symptom: "Back Pain", severity: $assessment.currentSymptoms.backPain)
                AssessmentSymptomRow(symptom: "Pelvic Pain", severity: $assessment.currentSymptoms.pelvicPain)
                AssessmentSymptomRow(symptom: "Swelling", severity: $assessment.currentSymptoms.swelling)
                AssessmentSymptomRow(symptom: "Headaches", severity: $assessment.currentSymptoms.headaches)
                AssessmentSymptomRow(symptom: "Shortness of Breath", severity: $assessment.currentSymptoms.shortessOfBreath)
                AssessmentSymptomRow(symptom: "Heartburn", severity: $assessment.currentSymptoms.heartburn)
                AssessmentSymptomRow(symptom: "Constipation", severity: $assessment.currentSymptoms.constipation)
                AssessmentSymptomRow(symptom: "Mood Changes", severity: $assessment.currentSymptoms.moodChanges)
            }
        }
    }
}

struct FitnessSection: View {
    @Binding var assessment: PregnancyAssessment
    
    var body: some View {
        Form {
            Section(header: Text("Activity Levels")) {
                Picker("Pre-Pregnancy Activity", selection: $assessment.fitnessLevel.prePregnancyActivityLevel) {
                    ForEach(ActivityLevel.allCases, id: \.self) { level in
                        Text(level.rawValue).tag(level)
                    }
                }
                
                Picker("Current Activity", selection: $assessment.fitnessLevel.currentActivityLevel) {
                    ForEach(ActivityLevel.allCases, id: \.self) { level in
                        Text(level.rawValue).tag(level)
                    }
                }
                
                Stepper("Exercise Days/Week: \(assessment.fitnessLevel.exerciseFrequencyPerWeek)",
                       value: $assessment.fitnessLevel.exerciseFrequencyPerWeek,
                       in: 0...7)
            }
            
            Section(header: Text("Exercise Types")) {
                ForEach(ExerciseType.allCases, id: \.self) { type in
                    MultipleSelectionRow(
                        title: type.rawValue,
                        isSelected: assessment.fitnessLevel.exerciseTypes.contains(type)
                    ) {
                        if assessment.fitnessLevel.exerciseTypes.contains(type) {
                            assessment.fitnessLevel.exerciseTypes.removeAll { $0 == type }
                        } else {
                            assessment.fitnessLevel.exerciseTypes.append(type)
                        }
                    }
                }
            }
            
            Section(header: Text("Special Considerations")) {
                Toggle("Pelvic Floor Awareness", isOn: $assessment.fitnessLevel.pelvicFloorAwareness)
                Toggle("Diastasis Recti Concern", isOn: $assessment.fitnessLevel.diastasisRectiConcern)
            }
        }
    }
}

struct NutritionSection: View {
    @Binding var assessment: PregnancyAssessment
    
    var body: some View {
        Form {
            Section(header: Text("Dietary Information")) {
                ForEach(DietaryRestriction.allCases, id: \.self) { restriction in
                    MultipleSelectionRow(
                        title: restriction.rawValue,
                        isSelected: assessment.nutritionProfile.dietaryRestrictions.contains(restriction)
                    ) {
                        if assessment.nutritionProfile.dietaryRestrictions.contains(restriction) {
                            assessment.nutritionProfile.dietaryRestrictions.removeAll { $0 == restriction }
                        } else {
                            assessment.nutritionProfile.dietaryRestrictions.append(restriction)
                        }
                    }
                }
            }
            
            Section(header: Text("Supplements")) {
                ForEach(Supplement.allCases, id: \.self) { supplement in
                    MultipleSelectionRow(
                        title: supplement.rawValue,
                        isSelected: assessment.nutritionProfile.supplementsTaken.contains(supplement)
                    ) {
                        if assessment.nutritionProfile.supplementsTaken.contains(supplement) {
                            assessment.nutritionProfile.supplementsTaken.removeAll { $0 == supplement }
                        } else {
                            assessment.nutritionProfile.supplementsTaken.append(supplement)
                        }
                    }
                }
            }
            
            Section(header: Text("Daily Intake")) {
                Stepper("Water Glasses/Day: \(assessment.nutritionProfile.waterIntakeGlassesPerDay)",
                       value: $assessment.nutritionProfile.waterIntakeGlassesPerDay,
                       in: 0...20)
                
                Stepper("Meals/Day: \(assessment.nutritionProfile.mealsPerDay)",
                       value: $assessment.nutritionProfile.mealsPerDay,
                       in: 1...6)
            }
        }
    }
}

struct MentalHealthSection: View {
    @Binding var assessment: PregnancyAssessment
    
    var body: some View {
        Form {
            Section(header: Text("Mental Health Assessment")) {
                AssessmentSymptomRow(symptom: "Anxiety", severity: $assessment.mentalHealthProfile.anxietyLevel)
                AssessmentSymptomRow(symptom: "Depression", severity: $assessment.mentalHealthProfile.depressionSymptoms)
                
                Toggle("Previous Mental Health History", isOn: $assessment.mentalHealthProfile.previousMentalHealthHistory)
                Toggle("Currently in Therapy", isOn: $assessment.mentalHealthProfile.currentTherapy)
                Toggle("Practice Meditation", isOn: $assessment.mentalHealthProfile.meditationPractice)
            }
            
            Section(header: Text("Stress Management")) {
                Text("What stress management techniques do you use?")
                    .font(.caption)
                ForEach(["Deep Breathing", "Exercise", "Journaling", "Music", "Nature Walks", "Yoga"], id: \.self) { technique in
                    MultipleSelectionRow(
                        title: technique,
                        isSelected: assessment.mentalHealthProfile.stressManagementTechniques.contains(technique)
                    ) {
                        if assessment.mentalHealthProfile.stressManagementTechniques.contains(technique) {
                            assessment.mentalHealthProfile.stressManagementTechniques.removeAll { $0 == technique }
                        } else {
                            assessment.mentalHealthProfile.stressManagementTechniques.append(technique)
                        }
                    }
                }
            }
        }
    }
}

struct SupportSystemSection: View {
    @Binding var assessment: PregnancyAssessment
    
    var body: some View {
        Form {
            Section(header: Text("Support Network")) {
                SupportLevelRow(title: "Partner Support", level: $assessment.supportSystem.partnerSupport)
                SupportLevelRow(title: "Family Support", level: $assessment.supportSystem.familySupport)
                SupportLevelRow(title: "Friends Support", level: $assessment.supportSystem.friendsSupport)
                SupportLevelRow(title: "Workplace Support", level: $assessment.supportSystem.workplaceSupport)
            }
            
            Section(header: Text("Practical Considerations")) {
                Picker("Financial Stability", selection: $assessment.supportSystem.financialStability) {
                    ForEach(StabilityLevel.allCases, id: \.self) { level in
                        Text(level.rawValue).tag(level)
                    }
                }
                
                Toggle("Childcare Arrangements Made", isOn: $assessment.supportSystem.childcareArrangements)
            }
        }
    }
}

struct PreferencesSection: View {
    @Binding var assessment: PregnancyAssessment
    
    var body: some View {
        Form {
            Section(header: Text("Birth Preferences")) {
                Picker("Birth Location", selection: $assessment.preferences.birthLocationPreference) {
                    ForEach(BirthLocation.allCases, id: \.self) { location in
                        Text(location.rawValue).tag(location)
                    }
                }
                
                Picker("Care Provider", selection: $assessment.preferences.careProviderType) {
                    ForEach(CareProvider.allCases, id: \.self) { provider in
                        Text(provider.rawValue).tag(provider)
                    }
                }
                
                Picker("Pain Management", selection: $assessment.preferences.painManagementPreference) {
                    ForEach(PainPreference.allCases, id: \.self) { preference in
                        Text(preference.rawValue).tag(preference)
                    }
                }
            }
            
            Section(header: Text("Postpartum Plans")) {
                Picker("Feeding Plan", selection: $assessment.preferences.breastfeedingIntention) {
                    ForEach(BreastfeedingPlan.allCases, id: \.self) { plan in
                        Text(plan.rawValue).tag(plan)
                    }
                }
                
                Toggle("Want Postpartum Support", isOn: $assessment.preferences.postpartumSupport)
            }
        }
    }
}

// MARK: - Helper Views

struct AssessmentSymptomRow: View {
    let symptom: String
    @Binding var severity: SeverityLevel
    
    var body: some View {
        HStack {
            Text(symptom)
            Spacer()
            Picker("", selection: $severity) {
                ForEach(SeverityLevel.allCases, id: \.self) { level in
                    Text(level.rawValue).tag(level)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 200)
        }
    }
}

struct SupportLevelRow: View {
    let title: String
    @Binding var level: SupportLevel
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Picker("", selection: $level) {
                ForEach(SupportLevel.allCases, id: \.self) { support in
                    Text(support.rawValue).tag(support)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .frame(width: 150)
        }
    }
}

struct AddChronicConditionView: View {
    @Binding var conditions: [ChronicCondition]
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedType: ChronicCondition.ConditionType = .other
    @State private var details = ""
    
    var body: some View {
        NavigationView {
            Form {
                Picker("Condition Type", selection: $selectedType) {
                    ForEach(ChronicCondition.ConditionType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                
                TextField("Additional Details", text: $details)
            }
            .navigationTitle("Add Condition")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Add") {
                    conditions.append(ChronicCondition(
                        type: selectedType,
                        details: details.isEmpty ? nil : details
                    ))
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}