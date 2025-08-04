import SwiftUI

struct SymptomCheckerView: View {
    @StateObject private var historyManager: SymptomHistoryManager
    @EnvironmentObject var userManager: UserManager
    @State private var showingAssessment = false
    @State private var selectedSymptom: Symptom?
    @State private var searchText = ""
    @State private var selectedCategory: SymptomCategory?
    
    init(userId: UUID) {
        _historyManager = StateObject(wrappedValue: SymptomHistoryManager(userId: userId))
    }
    
    var currentTrimester: Trimester {
        userManager.currentUser?.currentTrimester ?? .first
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter
                VStack(spacing: 12) {
                    SearchBar(text: $searchText)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterChip(
                                title: "All",
                                isSelected: selectedCategory == nil,
                                action: { selectedCategory = nil }
                            )
                            
                            ForEach(SymptomCategory.allCases, id: \.self) { category in
                                FilterChip(
                                    title: category.rawValue,
                                    isSelected: selectedCategory == category,
                                    action: { selectedCategory = category }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Quick Assessment Button
                        Button(action: { showingAssessment = true }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("New Symptom Assessment")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text("Get personalized guidance for your symptoms")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                
                                Spacer()
                                
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [.pink, .purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        // Active Symptoms
                        if !historyManager.getActiveSymptoms().isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Active Symptoms")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                ForEach(historyManager.getActiveSymptoms()) { assessment in
                                    ActiveSymptomCard(
                                        assessment: assessment,
                                        onResolve: {
                                            historyManager.markResolved(assessmentId: assessment.id)
                                        }
                                    )
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        // Common Symptoms
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Common in \(currentTrimester.rawValue)")
                                    .font(.headline)
                                
                                Spacer()
                                
                                Image(systemName: "info.circle")
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                            
                            let symptoms = getFilteredSymptoms()
                            
                            if symptoms.isEmpty {
                                Text("No symptoms found")
                                    .foregroundColor(.secondary)
                                    .padding()
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(symptoms) { symptom in
                                        SymptomCard(symptom: symptom) {
                                            selectedSymptom = symptom
                                            showingAssessment = true
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Recent History
                        if !historyManager.getRecentAssessments().isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Recent History")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                ForEach(historyManager.getRecentAssessments().prefix(5)) { assessment in
                                    HistoryCard(assessment: assessment)
                                        .padding(.horizontal)
                                }
                            }
                            .padding(.top)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Symptom Checker")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingAssessment) {
                if let symptom = selectedSymptom {
                    SymptomAssessmentView(
                        symptom: symptom,
                        historyManager: historyManager,
                        currentTrimester: currentTrimester
                    )
                } else {
                    SymptomSelectionView(
                        historyManager: historyManager,
                        currentTrimester: currentTrimester
                    )
                }
            }
        }
    }
    
    private func getFilteredSymptoms() -> [Symptom] {
        var symptoms = SymptomDatabase.getSymptomsByTrimester(currentTrimester)
        
        if let category = selectedCategory {
            symptoms = symptoms.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            symptoms = symptoms.filter { symptom in
                symptom.name.localizedCaseInsensitiveContains(searchText) ||
                symptom.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return symptoms
    }
}

// MARK: - Symptom Card

struct SymptomCard: View {
    let symptom: Symptom
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: iconForCategory(symptom.category))
                        .font(.title3)
                        .foregroundColor(.pink)
                        .frame(width: 30)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(symptom.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(symptom.category.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    SeverityBadge(severity: symptom.severity)
                }
                
                Text(symptom.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    private func iconForCategory(_ category: SymptomCategory) -> String {
        switch category {
        case .pain:
            return "bolt.fill"
        case .digestive:
            return "stomach"
        case .bleeding:
            return "drop.fill"
        case .respiratory:
            return "lungs.fill"
        case .neurological:
            return "brain.head.profile"
        case .skin:
            return "hand.raised.fill"
        case .urinary:
            return "drop.triangle.fill"
        case .emotional:
            return "heart.fill"
        case .movement:
            return "figure.2"
        case .other:
            return "questionmark.circle.fill"
        }
    }
}

struct SeverityBadge: View {
    let severity: SymptomSeverityLevel
    
    var body: some View {
        Text(severity.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(4)
    }
    
    private var backgroundColor: Color {
        switch severity {
        case .mild:
            return .green.opacity(0.2)
        case .moderate:
            return .yellow.opacity(0.2)
        case .severe:
            return .orange.opacity(0.2)
        case .emergency:
            return .red.opacity(0.2)
        }
    }
    
    private var foregroundColor: Color {
        switch severity {
        case .mild:
            return .green
        case .moderate:
            return .yellow
        case .severe:
            return .orange
        case .emergency:
            return .red
        }
    }
}

// MARK: - Active Symptom Card

struct ActiveSymptomCard: View {
    let assessment: SymptomAssessment
    let onResolve: () -> Void
    @State private var showingDetail = false
    
    var daysSince: Int {
        Calendar.current.dateComponents([.day], from: assessment.dateReported, to: Date()).day ?? 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(assessment.symptom.name)
                        .font(.headline)
                    
                    HStack(spacing: 8) {
                        Label("\(daysSince) days ago", systemImage: "clock")
                        
                        if let painScale = assessment.painScale {
                            Label("Pain: \(painScale)/10", systemImage: "gauge")
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: onResolve) {
                    Label("Resolved", systemImage: "checkmark.circle")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            HStack(spacing: 12) {
                ActionBadge(action: assessment.actionTaken)
                
                if assessment.followUpDate != nil {
                    Label("Follow-up scheduled", systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
        .onTapGesture {
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            AssessmentDetailView(assessment: assessment)
        }
    }
}

struct ActionBadge: View {
    let action: AssessmentAction
    
    var body: some View {
        Label(action.rawValue, systemImage: iconForAction(action))
            .font(.caption)
            .foregroundColor(colorForAction(action))
    }
    
    private func iconForAction(_ action: AssessmentAction) -> String {
        switch action {
        case .selfCare:
            return "house"
        case .callProvider:
            return "phone"
        case .visitProvider:
            return "building.2"
        case .emergency:
            return "exclamationmark.triangle"
        case .monitoring:
            return "eye"
        }
    }
    
    private func colorForAction(_ action: AssessmentAction) -> Color {
        switch action {
        case .selfCare:
            return .green
        case .callProvider:
            return .blue
        case .visitProvider:
            return .orange
        case .emergency:
            return .red
        case .monitoring:
            return .purple
        }
    }
}

// MARK: - History Card

struct HistoryCard: View {
    let assessment: SymptomAssessment
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(assessment.symptom.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 8) {
                    Text(assessment.dateReported, style: .date)
                    
                    if assessment.resolved {
                        Label("Resolved", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            ActionBadge(action: assessment.actionTaken)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.pink : Color(.secondarySystemBackground))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

// MARK: - Symptom Selection View

struct SymptomSelectionView: View {
    @ObservedObject var historyManager: SymptomHistoryManager
    let currentTrimester: Trimester
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    @State private var selectedCategory: SymptomCategory?
    @State private var selectedSymptom: Symptom?
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)
                    .padding()
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        ForEach(SymptomCategory.allCases, id: \.self) { category in
                            if !getSymptomsForCategory(category).isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(category.rawValue)
                                        .font(.headline)
                                        .padding(.horizontal)
                                    
                                    ForEach(getSymptomsForCategory(category)) { symptom in
                                        Button(action: {
                                            selectedSymptom = symptom
                                        }) {
                                            HStack {
                                                Text(symptom.name)
                                                    .foregroundColor(.primary)
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                                    .foregroundColor(.secondary)
                                            }
                                            .padding()
                                            .background(Color(.secondarySystemBackground))
                                            .cornerRadius(8)
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Select Symptom")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .sheet(item: $selectedSymptom) { symptom in
                SymptomAssessmentView(
                    symptom: symptom,
                    historyManager: historyManager,
                    currentTrimester: currentTrimester
                )
            }
        }
    }
    
    private func getSymptomsForCategory(_ category: SymptomCategory) -> [Symptom] {
        let symptoms = SymptomDatabase.getSymptomsByCategory(category)
        
        if searchText.isEmpty {
            return symptoms
        } else {
            return symptoms.filter { symptom in
                symptom.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

// MARK: - Symptom Assessment View

struct SymptomAssessmentView: View {
    let symptom: Symptom
    @ObservedObject var historyManager: SymptomHistoryManager
    let currentTrimester: Trimester
    @Environment(\.presentationMode) var presentationMode
    
    @State private var duration: SymptomDuration = .justStarted
    @State private var frequency: SymptomFrequency = .once
    @State private var painScale: Double = 5
    @State private var affectingDailyLife = false
    @State private var triggers: [String] = []
    @State private var newTrigger = ""
    @State private var associatedSymptoms: Set<String> = []
    @State private var notes = ""
    @State private var showingRecommendation = false
    @State private var recommendation: AssessmentRecommendation?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Symptom Details")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(symptom.name)
                            .font(.headline)
                        Text(symptom.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                Section(header: Text("Duration")) {
                    Picker("How long have you had this symptom?", selection: $duration) {
                        ForEach(SymptomDuration.allCases, id: \.self) { duration in
                            Text(duration.rawValue).tag(duration)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Frequency")) {
                    Picker("How often does it occur?", selection: $frequency) {
                        ForEach(SymptomFrequency.allCases, id: \.self) { frequency in
                            Text(frequency.rawValue).tag(frequency)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                if symptom.category == .pain {
                    Section(header: Text("Pain Level")) {
                        VStack {
                            HStack {
                                Text("1")
                                Slider(value: $painScale, in: 1...10, step: 1)
                                Text("10")
                            }
                            Text("Current pain: \(Int(painScale))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("Impact")) {
                    Toggle("Is this affecting your daily activities?", isOn: $affectingDailyLife)
                }
                
                Section(header: Text("Associated Symptoms")) {
                    let relatedSymptoms = symptom.relatedSymptoms + [
                        "Fever", "Nausea", "Vomiting", "Dizziness",
                        "Heavy bleeding", "Severe pain", "Vision changes"
                    ]
                    
                    ForEach(relatedSymptoms, id: \.self) { related in
                        HStack {
                            Text(related)
                            Spacer()
                            if associatedSymptoms.contains(related) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.pink)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if associatedSymptoms.contains(related) {
                                associatedSymptoms.remove(related)
                            } else {
                                associatedSymptoms.insert(related)
                            }
                        }
                    }
                }
                
                Section(header: Text("Triggers (Optional)")) {
                    ForEach(triggers, id: \.self) { trigger in
                        Text(trigger)
                    }
                    
                    HStack {
                        TextField("Add trigger", text: $newTrigger)
                        Button("Add") {
                            if !newTrigger.isEmpty {
                                triggers.append(newTrigger)
                                newTrigger = ""
                            }
                        }
                        .disabled(newTrigger.isEmpty)
                    }
                }
                
                Section(header: Text("Additional Notes (Optional)")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Symptom Assessment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Get Assessment") {
                        performAssessment()
                    }
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showingRecommendation) {
                if let recommendation = recommendation {
                    AssessmentResultView(
                        symptom: symptom,
                        recommendation: recommendation,
                        onSave: {
                            saveAssessment()
                            presentationMode.wrappedValue.dismiss()
                        }
                    )
                }
            }
        }
    }
    
    private func performAssessment() {
        let assessment = SymptomAssessmentEngine.assessSymptom(
            symptom: symptom,
            duration: duration,
            frequency: frequency,
            painScale: symptom.category == .pain ? Int(painScale) : nil,
            affectingDailyLife: affectingDailyLife,
            associatedSymptoms: Array(associatedSymptoms),
            currentTrimester: currentTrimester
        )
        
        self.recommendation = assessment
        self.showingRecommendation = true
    }
    
    private func saveAssessment() {
        guard let recommendation = recommendation else { return }
        
        let assessment = SymptomAssessment(
            userId: historyManager.assessments.first?.userId ?? UUID(),
            symptom: symptom,
            dateReported: Date(),
            duration: duration,
            frequency: frequency,
            triggers: triggers,
            relievingFactors: [],
            associatedSymptoms: Array(associatedSymptoms),
            painScale: symptom.category == .pain ? Int(painScale) : nil,
            affectingDailyLife: affectingDailyLife,
            actionTaken: recommendation.recommendedAction,
            notes: notes.isEmpty ? nil : notes
        )
        
        historyManager.addAssessment(assessment)
    }
}

// MARK: - Assessment Result View

struct AssessmentResultView: View {
    let symptom: Symptom
    let recommendation: AssessmentRecommendation
    let onSave: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Urgency Level
                    UrgencyBanner(
                        urgencyLevel: recommendation.urgencyLevel,
                        recommendedAction: recommendation.recommendedAction
                    )
                    
                    // Recommendations
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recommended Actions")
                            .font(.headline)
                        
                        ForEach(recommendation.recommendations, id: \.self) { rec in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.pink)
                                    .font(.caption)
                                    .padding(.top, 2)
                                
                                Text(rec)
                                    .font(.subheadline)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Emergency Signs
                    if !recommendation.emergencyReasons.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Emergency Warning Signs", systemImage: "exclamationmark.triangle.fill")
                                .font(.headline)
                                .foregroundColor(.red)
                            
                            ForEach(recommendation.emergencyReasons, id: \.self) { reason in
                                Text("• " + reason)
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Must Call Provider
                    if !recommendation.mustCallProviderReasons.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Call Your Provider", systemImage: "phone.fill")
                                .font(.headline)
                                .foregroundColor(.orange)
                            
                            ForEach(recommendation.mustCallProviderReasons, id: \.self) { reason in
                                Text("• " + reason)
                                    .font(.subheadline)
                            }
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Self-Care Instructions
                    if recommendation.recommendedAction == .selfCare && !recommendation.selfCareInstructions.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Self-Care Instructions")
                                .font(.headline)
                            
                            ForEach(recommendation.selfCareInstructions, id: \.self) { instruction in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("•")
                                    Text(instruction)
                                        .font(.subheadline)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    
                    // Warning Signs to Watch
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Monitor for These Warning Signs")
                            .font(.headline)
                        
                        ForEach(recommendation.warningSignsToWatch, id: \.self) { sign in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "eye")
                                    .foregroundColor(.purple)
                                    .font(.caption)
                                    .padding(.top, 2)
                                
                                Text(sign)
                                    .font(.subheadline)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Disclaimer
                    Text("This assessment is for informational purposes only and does not replace professional medical advice. Always consult your healthcare provider for medical concerns.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding()
                        .background(Color(.tertiarySystemBackground))
                        .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("Assessment Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save Assessment") {
                        onSave()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct UrgencyBanner: View {
    let urgencyLevel: UrgencyLevel
    let recommendedAction: AssessmentAction
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: iconForUrgency())
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(urgencyLevel.rawValue + " Urgency")
                        .font(.headline)
                    Text(recommendedAction.rawValue)
                        .font(.subheadline)
                }
                
                Spacer()
            }
            .foregroundColor(.white)
            .padding()
        }
        .background(backgroundColorForUrgency())
        .cornerRadius(12)
    }
    
    private func iconForUrgency() -> String {
        switch urgencyLevel {
        case .low:
            return "checkmark.circle.fill"
        case .moderate:
            return "exclamationmark.circle.fill"
        case .high:
            return "exclamationmark.triangle.fill"
        case .critical:
            return "exclamationmark.octagon.fill"
        }
    }
    
    private func backgroundColorForUrgency() -> Color {
        switch urgencyLevel {
        case .low:
            return .green
        case .moderate:
            return .yellow
        case .high:
            return .orange
        case .critical:
            return .red
        }
    }
}

// MARK: - Assessment Detail View

struct AssessmentDetailView: View {
    let assessment: SymptomAssessment
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Symptom Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text(assessment.symptom.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(assessment.symptom.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Assessment Details
                    VStack(alignment: .leading, spacing: 16) {
                        InfoRow(label: "Date Reported", value: assessment.dateReported.formatted())
                        InfoRow(label: "Duration", value: assessment.duration.rawValue)
                        InfoRow(label: "Frequency", value: assessment.frequency.rawValue)
                        
                        if let painScale = assessment.painScale {
                            InfoRow(label: "Pain Level", value: "\(painScale)/10")
                        }
                        
                        InfoRow(label: "Affects Daily Life", value: assessment.affectingDailyLife ? "Yes" : "No")
                        InfoRow(label: "Action Taken", value: assessment.actionTaken.rawValue)
                        
                        if assessment.resolved {
                            InfoRow(
                                label: "Status",
                                value: "Resolved on \(assessment.resolvedDate?.formatted() ?? "")"
                            )
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Associated Symptoms
                    if !assessment.associatedSymptoms.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Associated Symptoms")
                                .font(.headline)
                            
                            ForEach(assessment.associatedSymptoms, id: \.self) { symptom in
                                HStack {
                                    Image(systemName: "circle.fill")
                                        .font(.caption)
                                        .foregroundColor(.pink)
                                    Text(symptom)
                                        .font(.subheadline)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    
                    // Notes
                    if let notes = assessment.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.headline)
                            Text(notes)
                                .font(.subheadline)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Assessment Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}