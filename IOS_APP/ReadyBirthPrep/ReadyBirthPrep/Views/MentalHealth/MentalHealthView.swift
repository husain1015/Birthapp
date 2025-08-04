import SwiftUI
import Charts

struct MentalHealthView: View {
    @StateObject private var mentalHealthManager: MentalHealthManager
    @State private var selectedTab = 0
    @State private var showingMoodEntry = false
    @State private var showingScreening = false
    
    init(userId: UUID) {
        _mentalHealthManager = StateObject(wrappedValue: MentalHealthManager(userId: userId))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selection
                Picker("View", selection: $selectedTab) {
                    Text("Dashboard").tag(0)
                    Text("History").tag(1)
                    Text("Resources").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                TabView(selection: $selectedTab) {
                    MentalHealthDashboard(
                        mentalHealthManager: mentalHealthManager,
                        showingMoodEntry: $showingMoodEntry,
                        showingScreening: $showingScreening
                    )
                    .tag(0)
                    
                    MoodHistoryView(mentalHealthManager: mentalHealthManager)
                        .tag(1)
                    
                    SupportResourcesView(resources: mentalHealthManager.supportResources)
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Mental Wellness")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingMoodEntry) {
                MoodEntryView(mentalHealthManager: mentalHealthManager)
            }
            .sheet(isPresented: $showingScreening) {
                EPDSScreeningView(mentalHealthManager: mentalHealthManager)
            }
        }
    }
}

// MARK: - Dashboard View

struct MentalHealthDashboard: View {
    @ObservedObject var mentalHealthManager: MentalHealthManager
    @Binding var showingMoodEntry: Bool
    @Binding var showingScreening: Bool
    
    var todaysMood: MoodEntry? {
        mentalHealthManager.getTodaysMoodEntry()
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Daily Check-in Card
                DailyCheckInCard(
                    todaysMood: todaysMood,
                    streak: mentalHealthManager.currentStreak,
                    onCheckIn: { showingMoodEntry = true }
                )
                .padding(.horizontal)
                
                // Mood Trend Chart
                if !mentalHealthManager.moodEntries.isEmpty {
                    MoodTrendChart(entries: mentalHealthManager.getMoodTrend(days: 7))
                        .padding(.horizontal)
                }
                
                // Insights
                let insights = mentalHealthManager.generateInsights()
                if !insights.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Insights")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(insights, id: \.title) { insight in
                            MentalHealthInsightCard(insight: insight)
                                .padding(.horizontal)
                        }
                    }
                }
                
                // Screening Reminder
                if let latestScreening = mentalHealthManager.getLatestScreening() {
                    ScreeningReminderCard(
                        latestScreening: latestScreening,
                        onTakeScreening: { showingScreening = true }
                    )
                    .padding(.horizontal)
                } else {
                    Button(action: { showingScreening = true }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Mental Health Screening")
                                    .font(.headline)
                                Text("Take a brief assessment to check your wellbeing")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "clipboard.fill")
                                .font(.title2)
                                .foregroundColor(.purple)
                        }
                        .padding()
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                
                // Quick Actions
                QuickActionsSection()
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}

// MARK: - Daily Check-in Card

struct DailyCheckInCard: View {
    let todaysMood: MoodEntry?
    let streak: Int
    let onCheckIn: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Check-in")
                        .font(.headline)
                    
                    if let mood = todaysMood {
                        HStack(spacing: 4) {
                            Text("Today's mood:")
                            Text(mood.overallMood.emoji)
                                .font(.title2)
                            Text(mood.overallMood.description)
                                .fontWeight(.medium)
                        }
                        .font(.subheadline)
                    } else {
                        Text("How are you feeling today?")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if streak > 0 {
                    VStack(alignment: .trailing, spacing: 2) {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                            Text("\(streak)")
                                .fontWeight(.bold)
                        }
                        Text("day streak")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Button(action: onCheckIn) {
                Text(todaysMood == nil ? "Log Today's Mood" : "Update Today's Mood")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.pink, .purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Mood Trend Chart

struct MoodTrendChart: View {
    let entries: [MoodEntry]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("7-Day Mood Trend")
                .font(.headline)
            
            Chart(entries) { entry in
                    LineMark(
                        x: .value("Date", entry.date),
                        y: .value("Mood", entry.overallMood.rawValue)
                    )
                    .foregroundStyle(Color.purple)
                    .interpolationMethod(.catmullRom)
                    
                    PointMark(
                        x: .value("Date", entry.date),
                        y: .value("Mood", entry.overallMood.rawValue)
                    )
                    .foregroundStyle(Color.purple)
                }
                .frame(height: 200)
                .chartYScale(domain: 1...5)
                .chartYAxis {
                    AxisMarks(values: [1, 2, 3, 4, 5]) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let intValue = value.as(Int.self) {
                                Text(MentalHealthMoodLevel(rawValue: intValue)?.emoji ?? "")
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { _ in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                    }
                }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Insight Card

struct MentalHealthInsightCard: View {
    let insight: MentalHealthInsight
    
    var backgroundColor: Color {
        switch insight.type {
        case .positive:
            return .green.opacity(0.1)
        case .neutral:
            return .blue.opacity(0.1)
        case .concern:
            return .orange.opacity(0.1)
        }
    }
    
    var iconColor: Color {
        switch insight.type {
        case .positive:
            return .green
        case .neutral:
            return .blue
        case .concern:
            return .orange
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: insight.icon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.headline)
                Text(insight.message)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(12)
    }
}

// MARK: - Screening Reminder Card

struct ScreeningReminderCard: View {
    let latestScreening: EPDSScreening
    let onTakeScreening: () -> Void
    
    var daysSinceLastScreening: Int {
        Calendar.current.dateComponents([.day], from: latestScreening.date, to: Date()).day ?? 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Latest Screening")
                        .font(.headline)
                    Text("\(daysSinceLastScreening) days ago")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(latestScreening.riskLevel.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color(latestScreening.riskLevel.color).opacity(0.2))
                    .foregroundColor(Color(latestScreening.riskLevel.color))
                    .cornerRadius(20)
            }
            
            if daysSinceLastScreening >= 30 {
                Button(action: onTakeScreening) {
                    Label("Retake Screening", systemImage: "arrow.clockwise")
                        .font(.caption)
                        .foregroundColor(.purple)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Quick Actions Section

struct QuickActionsSection: View {
    @State private var selectedAction: QuickAction?
    
    enum QuickAction: String, CaseIterable, Identifiable {
        case breathing = "Breathing Exercise"
        case grounding = "5-4-3-2-1 Grounding"
        case affirmations = "Positive Affirmations"
        case bodyCheck = "Body Check-in"
        
        var id: String { self.rawValue }
        
        var icon: String {
            switch self {
            case .breathing: return "wind"
            case .grounding: return "leaf.fill"
            case .affirmations: return "heart.text.square"
            case .bodyCheck: return "figure.stand"
            }
        }
        
        var description: String {
            switch self {
            case .breathing: return "3-minute calming breath work"
            case .grounding: return "Grounding technique for anxiety"
            case .affirmations: return "Positive self-statements"
            case .bodyCheck: return "Quick body awareness scan"
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Exercises")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(QuickAction.allCases, id: \.self) { action in
                    Button(action: { selectedAction = action }) {
                        VStack(spacing: 8) {
                            Image(systemName: action.icon)
                                .font(.title2)
                                .foregroundColor(.purple)
                            
                            Text(action.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 80)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        .sheet(item: $selectedAction) { action in
            QuickExerciseView(action: action)
        }
    }
}

// MARK: - Mood Entry View

struct MoodEntryView: View {
    @ObservedObject var mentalHealthManager: MentalHealthManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var overallMood: MentalHealthMoodLevel = .neutral
    @State private var selectedEmotions: Set<Emotion> = []
    @State private var selectedPhysicalSymptoms: Set<PhysicalSymptom> = []
    @State private var sleepQuality: SleepQuality = .fair
    @State private var sleepHours: Double = 7
    @State private var appetiteLevel: AppetiteLevel = .normal
    @State private var energyLevel: EnergyLevel = .moderate
    @State private var anxietyLevel: Double = 5
    @State private var stressLevel: Double = 5
    @State private var babyBondingLevel: Double = 7
    @State private var supportLevel: Double = 7
    @State private var copingStrategiesUsed: Set<CopingStrategy> = []
    @State private var notes = ""
    @State private var currentStep = 0
    
    let steps = ["Mood", "Emotions", "Physical", "Lifestyle", "Coping", "Notes"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress Bar
                ProgressBar(currentStep: currentStep, totalSteps: steps.count)
                    .padding()
                
                // Step Title
                Text(steps[currentStep])
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom)
                
                // Content
                TabView(selection: $currentStep) {
                    // Step 1: Overall Mood
                    VStack(spacing: 20) {
                        Text("How is your overall mood today?")
                            .font(.headline)
                        
                        HStack(spacing: 20) {
                            ForEach(MentalHealthMoodLevel.allCases, id: \.self) { mood in
                                VStack(spacing: 8) {
                                    Text(mood.emoji)
                                        .font(.system(size: 50))
                                        .scaleEffect(overallMood == mood ? 1.2 : 1.0)
                                        .animation(.spring(), value: overallMood)
                                    
                                    Text(mood.description)
                                        .font(.caption)
                                        .fontWeight(overallMood == mood ? .bold : .regular)
                                }
                                .onTapGesture {
                                    overallMood = mood
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    .tag(0)
                    .padding()
                    
                    // Step 2: Emotions
                    VStack(spacing: 20) {
                        Text("What emotions are you experiencing?")
                            .font(.headline)
                        
                        Text("Select all that apply")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(Emotion.allCases, id: \.self) { emotion in
                                    EmotionChip(
                                        emotion: emotion,
                                        isSelected: selectedEmotions.contains(emotion),
                                        onTap: {
                                            if selectedEmotions.contains(emotion) {
                                                selectedEmotions.remove(emotion)
                                            } else {
                                                selectedEmotions.insert(emotion)
                                            }
                                        }
                                    )
                                }
                            }
                        }
                    }
                    .tag(1)
                    .padding()
                    
                    // Step 3: Physical Symptoms
                    VStack(spacing: 20) {
                        Text("Any physical symptoms?")
                            .font(.headline)
                        
                        Text("Select all that apply")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(PhysicalSymptom.allCases, id: \.self) { symptom in
                                    Button(action: {
                                        if selectedPhysicalSymptoms.contains(symptom) {
                                            selectedPhysicalSymptoms.remove(symptom)
                                        } else {
                                            selectedPhysicalSymptoms.insert(symptom)
                                        }
                                    }) {
                                        Text(symptom.rawValue)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(selectedPhysicalSymptoms.contains(symptom) ? Color.pink : Color(.secondarySystemBackground))
                                            .foregroundColor(selectedPhysicalSymptoms.contains(symptom) ? .white : .primary)
                                            .cornerRadius(20)
                                    }
                                }
                            }
                        }
                    }
                    .tag(2)
                    .padding()
                    
                    // Step 4: Lifestyle Factors
                    ScrollView {
                        VStack(spacing: 24) {
                            // Sleep
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Sleep")
                                    .font(.headline)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Quality: \(sleepQuality.rawValue)")
                                        .font(.subheadline)
                                    
                                    Picker("Sleep Quality", selection: $sleepQuality) {
                                        ForEach(SleepQuality.allCases, id: \.self) { quality in
                                            Text(quality.rawValue).tag(quality)
                                        }
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Hours: \(String(format: "%.1f", sleepHours))")
                                        .font(.subheadline)
                                    
                                    Slider(value: $sleepHours, in: 0...12, step: 0.5)
                                }
                            }
                            
                            Divider()
                            
                            // Appetite
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Appetite")
                                    .font(.headline)
                                
                                Picker("Appetite Level", selection: $appetiteLevel) {
                                    ForEach(AppetiteLevel.allCases, id: \.self) { level in
                                        Text(level.rawValue).tag(level)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                            
                            Divider()
                            
                            // Energy
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Energy Level")
                                    .font(.headline)
                                
                                Picker("Energy Level", selection: $energyLevel) {
                                    ForEach(EnergyLevel.allCases, id: \.self) { level in
                                        Text(level.rawValue).tag(level)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            
                            Divider()
                            
                            // Levels
                            VStack(alignment: .leading, spacing: 16) {
                                SliderRow(label: "Anxiety Level", value: $anxietyLevel)
                                SliderRow(label: "Stress Level", value: $stressLevel)
                                SliderRow(label: "Baby Bonding", value: $babyBondingLevel)
                                SliderRow(label: "Support Level", value: $supportLevel)
                            }
                        }
                        .padding()
                    }
                    .tag(3)
                    
                    // Step 5: Coping Strategies
                    VStack(spacing: 20) {
                        Text("What helped you cope today?")
                            .font(.headline)
                        
                        Text("Select all that apply")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(CopingStrategy.allCases, id: \.self) { strategy in
                                    Button(action: {
                                        if copingStrategiesUsed.contains(strategy) {
                                            copingStrategiesUsed.remove(strategy)
                                        } else {
                                            copingStrategiesUsed.insert(strategy)
                                        }
                                    }) {
                                        Text(strategy.rawValue)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(copingStrategiesUsed.contains(strategy) ? Color.green : Color(.secondarySystemBackground))
                                            .foregroundColor(copingStrategiesUsed.contains(strategy) ? .white : .primary)
                                            .cornerRadius(20)
                                    }
                                }
                            }
                        }
                    }
                    .tag(4)
                    .padding()
                    
                    // Step 6: Notes
                    VStack(spacing: 20) {
                        Text("Any additional notes?")
                            .font(.headline)
                        
                        Text("Optional - add any thoughts or context")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $notes)
                            .padding(8)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                            .frame(minHeight: 150)
                        
                        Spacer()
                    }
                    .tag(5)
                    .padding()
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Navigation Buttons
                HStack {
                    if currentStep > 0 {
                        Button("Previous") {
                            withAnimation {
                                currentStep -= 1
                            }
                        }
                    }
                    
                    Spacer()
                    
                    if currentStep < steps.count - 1 {
                        Button("Next") {
                            withAnimation {
                                currentStep += 1
                            }
                        }
                        .fontWeight(.semibold)
                    } else {
                        Button("Save Entry") {
                            saveEntry()
                        }
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.pink)
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
            .navigationTitle("Mood Check-in")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func saveEntry() {
        let entry = MoodEntry(
            userId: mentalHealthManager.moodEntries.first?.userId ?? UUID(),
            date: Date(),
            overallMood: overallMood,
            emotions: Array(selectedEmotions),
            physicalSymptoms: Array(selectedPhysicalSymptoms),
            sleepQuality: sleepQuality,
            sleepHours: sleepHours,
            appetiteLevel: appetiteLevel,
            energyLevel: energyLevel,
            anxietyLevel: Int(anxietyLevel),
            stressLevel: Int(stressLevel),
            babyBondingLevel: Int(babyBondingLevel),
            supportLevel: Int(supportLevel),
            triggers: [],
            copingStrategiesUsed: Array(copingStrategiesUsed),
            notes: notes.isEmpty ? nil : notes
        )
        
        mentalHealthManager.addMoodEntry(entry)
        presentationMode.wrappedValue.dismiss()
    }
}

struct ProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    
    var progress: Double {
        Double(currentStep + 1) / Double(totalSteps)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 8)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.pink, .purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * CGFloat(progress), height: 8)
                    .animation(.easeInOut, value: progress)
            }
        }
        .frame(height: 8)
    }
}

struct EmotionChip: View {
    let emotion: Emotion
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(emotion.rawValue)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? (emotion.isPositive ? Color.green : Color.orange) : Color(.secondarySystemBackground))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct SliderRow: View {
    let label: String
    @Binding var value: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.subheadline)
                Spacer()
                Text("\(Int(value))/10")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Slider(value: $value, in: 0...10, step: 1)
                .accentColor(.purple)
        }
    }
}

// MARK: - Mood History View

struct MoodHistoryView: View {
    @ObservedObject var mentalHealthManager: MentalHealthManager
    @State private var selectedEntry: MoodEntry?
    
    var groupedEntries: [(Date, [MoodEntry])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: mentalHealthManager.moodEntries) { entry in
            calendar.startOfDay(for: entry.date)
        }
        return grouped.sorted { $0.key > $1.key }
    }
    
    var body: some View {
        ScrollView {
            if mentalHealthManager.moodEntries.isEmpty {
                MentalHealthEmptyStateView(
                    icon: "heart.text.square",
                    title: "No Entries Yet",
                    message: "Start tracking your mood to see your history"
                )
                .padding(.top, 50)
            } else {
                LazyVStack(spacing: 20) {
                    ForEach(groupedEntries, id: \.0) { date, entries in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(date, style: .date)
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(entries) { entry in
                                MoodHistoryCard(entry: entry)
                                    .padding(.horizontal)
                                    .onTapGesture {
                                        selectedEntry = entry
                                    }
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .sheet(item: $selectedEntry) { entry in
            MoodDetailView(entry: entry)
        }
    }
}

struct MoodHistoryCard: View {
    let entry: MoodEntry
    
    var positiveEmotions: [Emotion] {
        entry.emotions.filter { $0.isPositive }
    }
    
    var negativeEmotions: [Emotion] {
        entry.emotions.filter { !$0.isPositive }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(entry.overallMood.emoji)
                    .font(.title)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.overallMood.description)
                        .font(.headline)
                    Text(entry.date, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if entry.needsSupport {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                }
            }
            
            if !entry.emotions.isEmpty {
                HStack {
                    if !positiveEmotions.isEmpty {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text(positiveEmotions.prefix(3).map { $0.rawValue }.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if !negativeEmotions.isEmpty {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text(negativeEmotions.prefix(3).map { $0.rawValue }.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Support Resources View

struct SupportResourcesView: View {
    let resources: [SupportResource]
    @State private var selectedType: ResourceType?
    
    var filteredResources: [SupportResource] {
        if let type = selectedType {
            return resources.filter { $0.type == type }
        }
        return resources
    }
    
    var crisisResources: [SupportResource] {
        resources.filter { $0.isCrisis }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Crisis Resources
                if !crisisResources.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Crisis Support", systemImage: "phone.fill")
                            .font(.headline)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                        
                        ForEach(crisisResources) { resource in
                            ResourceCard(resource: resource, isCrisis: true)
                                .padding(.horizontal)
                        }
                    }
                }
                
                // Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterChip(
                            title: "All",
                            isSelected: selectedType == nil,
                            action: { selectedType = nil }
                        )
                        
                        ForEach(ResourceType.allCases, id: \.self) { type in
                            FilterChip(
                                title: type.rawValue,
                                isSelected: selectedType == type,
                                action: { selectedType = type }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Resources
                VStack(alignment: .leading, spacing: 12) {
                    Text("Support Resources")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(filteredResources.filter { !$0.isCrisis }) { resource in
                        ResourceCard(resource: resource, isCrisis: false)
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
    }
}

struct ResourceCard: View {
    let resource: SupportResource
    let isCrisis: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(resource.name)
                        .font(.headline)
                    Text(resource.type.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let cost = resource.cost {
                    Text(cost)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(cost == "Free" ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                        .foregroundColor(cost == "Free" ? .green : .orange)
                        .cornerRadius(4)
                }
            }
            
            Text(resource.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 16) {
                if let phone = resource.phoneNumber {
                    Button(action: {
                        if let url = URL(string: "tel://\(phone.replacingOccurrences(of: " ", with: ""))") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Label(phone, systemImage: "phone.fill")
                            .font(.caption)
                            .foregroundColor(isCrisis ? .white : .pink)
                    }
                }
                
                if let website = resource.website {
                    Button(action: {
                        if let url = URL(string: website) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Label("Website", systemImage: "globe")
                            .font(.caption)
                            .foregroundColor(isCrisis ? .white : .pink)
                    }
                }
                
                Spacer()
                
                if let hours = resource.hours {
                    Text(hours)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(isCrisis ? Color.red : Color(.secondarySystemBackground))
        .foregroundColor(isCrisis ? .white : .primary)
        .cornerRadius(12)
    }
}

// MARK: - Supporting Views

struct EPDSScreeningView: View {
    @ObservedObject var mentalHealthManager: MentalHealthManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Text("EPDS Screening View")
                .navigationTitle("Mental Health Screening")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
        }
    }
}

struct QuickExerciseView: View {
    let action: QuickActionsSection.QuickAction
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: action.icon)
                    .font(.system(size: 60))
                    .foregroundColor(.purple)
                
                Text(action.rawValue)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(action.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Exercise content would go here
                
                Spacer()
            }
            .padding()
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

struct MoodDetailView: View {
    let entry: MoodEntry
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Mood Overview
                    HStack {
                        Text(entry.overallMood.emoji)
                            .font(.system(size: 60))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.overallMood.description)
                                .font(.title2)
                                .fontWeight(.bold)
                            Text(entry.date, style: .date)
                            Text(entry.date, style: .time)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    // Emotions
                    if !entry.emotions.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Emotions")
                                .font(.headline)
                            
                            FlowLayout(spacing: 8) {
                                ForEach(entry.emotions, id: \.self) { emotion in
                                    Text(emotion.rawValue)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(emotion.isPositive ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                                        .foregroundColor(emotion.isPositive ? .green : .orange)
                                        .cornerRadius(20)
                                }
                            }
                        }
                    }
                    
                    // Levels
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Levels")
                            .font(.headline)
                        
                        if let anxiety = entry.anxietyLevel {
                            LevelBar(label: "Anxiety", level: anxiety, maxLevel: 10, color: .orange)
                        }
                        if let stress = entry.stressLevel {
                            LevelBar(label: "Stress", level: stress, maxLevel: 10, color: .red)
                        }
                        if let bonding = entry.babyBondingLevel {
                            LevelBar(label: "Baby Bonding", level: bonding, maxLevel: 10, color: .pink)
                        }
                        if let support = entry.supportLevel {
                            LevelBar(label: "Support", level: support, maxLevel: 10, color: .purple)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Sleep & Lifestyle
                    if entry.sleepQuality != nil || entry.sleepHours != nil {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Sleep & Lifestyle")
                                .font(.headline)
                            
                            HStack(spacing: 20) {
                                if let quality = entry.sleepQuality {
                                    VStack {
                                        Image(systemName: "moon.zzz.fill")
                                            .font(.title2)
                                            .foregroundColor(.purple)
                                        Text(quality.rawValue)
                                            .font(.caption)
                                    }
                                }
                                
                                if let hours = entry.sleepHours {
                                    VStack {
                                        Text("\(String(format: "%.1f", hours))h")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                        Text("Sleep")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                if let appetite = entry.appetiteLevel {
                                    VStack {
                                        Image(systemName: "fork.knife")
                                            .font(.title2)
                                            .foregroundColor(.orange)
                                        Text(appetite.rawValue)
                                            .font(.caption)
                                    }
                                }
                                
                                if let energy = entry.energyLevel {
                                    VStack {
                                        Image(systemName: "bolt.fill")
                                            .font(.title2)
                                            .foregroundColor(.yellow)
                                        Text(energy.rawValue)
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    
                    // Coping Strategies
                    if !entry.copingStrategiesUsed.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Coping Strategies Used")
                                .font(.headline)
                            
                            FlowLayout(spacing: 8) {
                                ForEach(entry.copingStrategiesUsed, id: \.self) { strategy in
                                    Text(strategy.rawValue)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.green.opacity(0.2))
                                        .foregroundColor(.green)
                                        .cornerRadius(20)
                                }
                            }
                        }
                    }
                    
                    // Notes
                    if let notes = entry.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Notes")
                                .font(.headline)
                            
                            Text(notes)
                                .font(.subheadline)
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Mood Details")
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

struct LevelBar: View {
    let label: String
    let level: Int
    let maxLevel: Int
    let color: Color
    
    var progress: Double {
        Double(level) / Double(maxLevel)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.caption)
                Spacer()
                Text("\(level)/\(maxLevel)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(progress))
                }
            }
            .frame(height: 8)
        }
    }
}

// Flow Layout for chips
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return CGSize(width: proposal.replacingUnspecifiedDimensions().width, height: result.height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for row in result.rows {
            for item in row.items {
                let frame = CGRect(
                    x: bounds.minX + item.x,
                    y: bounds.minY + row.y,
                    width: item.width,
                    height: row.height
                )
                subviews[item.index].place(at: frame.origin, proposal: ProposedViewSize(frame.size))
            }
        }
    }
    
    struct FlowResult {
        var rows: [Row] = []
        var height: CGFloat = 0
        
        struct Row {
            var items: [Item] = []
            var y: CGFloat = 0
            var height: CGFloat = 0
        }
        
        struct Item {
            var index: Int
            var x: CGFloat
            var width: CGFloat
        }
        
        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentRow = Row()
            var x: CGFloat = 0
            var y: CGFloat = 0
            
            for (index, subview) in subviews.enumerated() {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > width && !currentRow.items.isEmpty {
                    currentRow.y = y
                    rows.append(currentRow)
                    y += currentRow.height + spacing
                    currentRow = Row()
                    x = 0
                }
                currentRow.items.append(Item(index: index, x: x, width: size.width))
                currentRow.height = max(currentRow.height, size.height)
                x += size.width + spacing
            }
            if !currentRow.items.isEmpty {
                currentRow.y = y
                rows.append(currentRow)
                y += currentRow.height
            }
            height = y
        }
    }
}

// MARK: - Empty State View

struct MentalHealthEmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}