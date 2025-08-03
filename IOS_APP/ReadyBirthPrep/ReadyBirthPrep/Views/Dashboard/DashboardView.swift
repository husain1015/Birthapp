import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var userManager: UserManager
    @StateObject private var recommendationService = ExerciseRecommendationService()
    @State private var todaysFocus: DailyFocus?
    @State private var todaysExerciseDay: ExerciseDay?
    @State private var navigateToExercises = false
    @State private var navigateToBirthPlan = false
    @State private var navigateToContractions = false
    @State private var navigateToWeeklyPlan = false
    @State private var navigateToWeeklyPlanWithDay = false
    @State private var showingExerciseDetail = false
    @State private var selectedExercise: Exercise?
    @State private var currentWeekPlan: WeeklyPlan?
    @State private var navigateToAccomplishments = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let user = userManager.currentUser {
                        PregnancyProgressCard(user: user, navigateToWeeklyPlan: $navigateToWeeklyPlan)
                        
                        // Workout streak card
                        WorkoutStreakCard(userId: user.id, navigateToAccomplishments: $navigateToAccomplishments)
                        
                        if recommendationService.isLoading {
                            AIRecommendationLoadingCard()
                        } else if let recommendation = recommendationService.todaysRecommendation {
                            AIRecommendationCard(
                                recommendation: recommendation,
                                onExerciseTap: { exercise in
                                    selectedExercise = exercise
                                    showingExerciseDetail = true
                                }
                            )
                        } else if let exerciseDay = todaysExerciseDay {
                            TodaysExerciseCard(exerciseDay: exerciseDay, navigateToWeeklyPlan: $navigateToWeeklyPlanWithDay)
                        } else {
                            TodaysFocusCard(focus: todaysFocus, navigateToExercises: $navigateToExercises)
                        }
                        
                        QuickLinksSection(
                            navigateToExercises: $navigateToExercises,
                            navigateToBirthPlan: $navigateToBirthPlan,
                            navigateToContractions: $navigateToContractions,
                            navigateToWeeklyPlan: $navigateToWeeklyPlan
                        )
                        
                        WeeklyTipsCard(weekOfPregnancy: user.currentWeekOfPregnancy)
                    }
                }
                .padding()
            }
            .navigationTitle("Welcome, \(userManager.currentUser?.name ?? "")")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadTodaysExercises()
                if let user = userManager.currentUser {
                    Task {
                        await recommendationService.generateDailyRecommendations(for: user)
                    }
                }
            }
            .sheet(isPresented: $showingExerciseDetail) {
                if let exercise = selectedExercise {
                    ExerciseDetailSheet(exercise: exercise, recommendationService: recommendationService, userId: userManager.currentUser?.id ?? UUID())
                }
            }
            .background(
                NavigationLink(destination: PrenatalPrepView(), isActive: $navigateToExercises) {
                    EmptyView()
                }
            )
            .background(
                NavigationLink(destination: BirthPlanBuilderView(), isActive: $navigateToBirthPlan) {
                    EmptyView()
                }
            )
            .background(
                NavigationLink(destination: ContractionTimerView(), isActive: $navigateToContractions) {
                    EmptyView()
                }
            )
            .background(
                NavigationLink(destination: WeeklyPlanView(), isActive: $navigateToWeeklyPlan) {
                    EmptyView()
                }
            )
            .background(
                NavigationLink(destination: WeeklyPlanView(selectedDayIndex: getCurrentDayIndex()), isActive: $navigateToWeeklyPlanWithDay) {
                    EmptyView()
                }
            )
            .background(
                NavigationLink(destination: AccomplishmentsView(userId: userManager.currentUser?.id ?? UUID()), isActive: $navigateToAccomplishments) {
                    EmptyView()
                }
            )
        }
    }
    
    private func loadTodaysExercises() {
        guard let user = userManager.currentUser else { return }
        
        // Create weekly plan for current week
        let weekNumber = user.currentWeekOfPregnancy
        currentWeekPlan = WeeklyPlan(userId: user.id, weekNumber: weekNumber)
        
        // Get current day of week (1 = Monday, 2 = Wednesday, 3 = Friday)
        let dayIndex = getCurrentDayIndex()
        
        if let plan = currentWeekPlan, dayIndex < plan.exerciseDays.count {
            todaysExerciseDay = plan.exerciseDays[dayIndex]
        } else {
            // Fallback to default focus
            loadTodaysFocus()
        }
    }
    
    private func loadTodaysFocus() {
        todaysFocus = DailyFocus(
            title: "Pelvic Floor Breathing",
            description: "Today's focus is on connecting breath with your pelvic floor",
            duration: "15 minutes",
            category: .breathing
        )
    }
    
    private func getCurrentDayIndex() -> Int {
        // Check if there's a current day being worked on or show the next incomplete day
        if let plan = currentWeekPlan {
            // Find the first incomplete day
            for (index, day) in plan.exerciseDays.enumerated() {
                if !day.isCompleted {
                    return index
                }
            }
            // All days completed, show the first day
            return 0
        }
        return 0
    }
}

struct PregnancyProgressCard: View {
    let user: User
    @Binding var navigateToWeeklyPlan: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Week \(user.currentWeekOfPregnancy)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(user.currentTrimester.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 5) {
                    Text("\(user.daysUntilDueDate)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.pink)
                    
                    Text("days to go")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            ProgressView(value: Double(user.currentWeekOfPregnancy), total: 40)
                .progressViewStyle(LinearProgressViewStyle(tint: .pink))
                .scaleEffect(x: 1, y: 2, anchor: .center)
            
            HStack {
                Label("Due: \(user.dueDate, formatter: dateFormatter)", systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: { navigateToWeeklyPlan = true }) {
                    HStack(spacing: 4) {
                        Text("Weekly Plan")
                            .font(.caption)
                            .fontWeight(.medium)
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.caption)
                    }
                    .foregroundColor(AppConstants.primaryColor)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}

struct TodaysFocusCard: View {
    let focus: DailyFocus?
    @Binding var navigateToExercises: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today's Focus")
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
            }
            
            if let focus = focus {
                VStack(alignment: .leading, spacing: 8) {
                    Text(focus.title)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text(focus.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Label(focus.duration, systemImage: "clock")
                        
                        Spacer()
                        
                        Button(action: { navigateToExercises = true }) {
                            Text("Start")
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(Color.pink)
                                .cornerRadius(20)
                        }
                    }
                    .font(.caption)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct QuickLinksSection: View {
    @EnvironmentObject var userManager: UserManager
    @Binding var navigateToExercises: Bool
    @Binding var navigateToBirthPlan: Bool
    @Binding var navigateToContractions: Bool
    @Binding var navigateToWeeklyPlan: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick Access")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                QuickLinkButton(
                    title: "Exercises",
                    icon: "figure.strengthtraining.traditional",
                    color: .blue,
                    action: { navigateToExercises = true }
                )
                
                QuickLinkButton(
                    title: "Birth Plan",
                    icon: "doc.text",
                    color: .green,
                    action: { navigateToBirthPlan = true }
                )
                
                QuickLinkButton(
                    title: "Contractions",
                    icon: "waveform.path.ecg",
                    color: .orange,
                    action: { navigateToContractions = true }
                )
                
                QuickLinkButton(
                    title: "Weekly Plan",
                    icon: "calendar.badge.clock",
                    color: .purple,
                    action: { navigateToWeeklyPlan = true }
                )
            }
        }
    }
}

struct QuickLinkButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

struct WeeklyTipsCard: View {
    let weekOfPregnancy: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Week \(weekOfPregnancy) Tips")
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                TipRow(tip: "Focus on deep breathing exercises daily")
                TipRow(tip: "Stay hydrated - aim for 8-10 glasses of water")
                TipRow(tip: "Practice pelvic tilts to ease back discomfort")
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

struct TipRow: View {
    let tip: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Color.pink)
                .frame(width: 6, height: 6)
                .offset(y: 6)
            
            Text(tip)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct DailyFocus {
    let title: String
    let description: String
    let duration: String
    let category: ExerciseCategory
}

struct TodaysExerciseCard: View {
    let exerciseDay: ExerciseDay
    @Binding var navigateToWeeklyPlan: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Workout")
                        .font(.headline)
                    Text(exerciseDay.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "figure.walk.motion")
                    .foregroundColor(.pink)
                    .font(.title2)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Label("\(exerciseDay.totalDuration) minutes", systemImage: "clock")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Label("\(exerciseDay.exercises.count) exercises", systemImage: "list.bullet")
                        .font(.subheadline)
                }
                .foregroundColor(.secondary)
                
                // Show first 2 exercises as preview
                ForEach(exerciseDay.exercises.prefix(2)) { exercise in
                    HStack {
                        Circle()
                            .fill(Color.pink.opacity(0.2))
                            .frame(width: 6, height: 6)
                        Text(exercise.name)
                            .font(.caption)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                    }
                }
                
                if exerciseDay.exercises.count > 2 {
                    HStack {
                        Circle()
                            .fill(Color.pink.opacity(0.2))
                            .frame(width: 6, height: 6)
                        Text("and \(exerciseDay.exercises.count - 2) more...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    if exerciseDay.isCompleted {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Completed")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                        }
                    } else {
                        Text("\(exerciseDay.exercises.filter { $0.isCompleted }.count) of \(exerciseDay.exercises.count) done")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: { navigateToWeeklyPlan = true }) {
                        Text(exerciseDay.isCompleted ? "View" : "Start")
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(exerciseDay.isCompleted ? Color.gray : Color.pink)
                            .cornerRadius(20)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct AIRecommendationLoadingCard: View {
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("AI Exercise Recommendations")
                    .font(.headline)
                
                Spacer()
                
                ProgressView()
                    .scaleEffect(0.8)
            }
            
            Text("Analyzing your pregnancy journey and exercise history...")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

struct AIRecommendationCard: View {
    let recommendation: DailyExerciseRecommendation
    let onExerciseTap: (Exercise) -> Void
    @State private var expandedExerciseId: UUID?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Today's AI Recommendations")
                        .font(.headline)
                    
                    Text("Week \(recommendation.weekOfPregnancy) • Personalized for you")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "sparkles")
                    .foregroundColor(.purple)
                    .font(.title2)
            }
            
            if !recommendation.reasoning.isEmpty {
                Text(recommendation.reasoning)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            VStack(spacing: 10) {
                ForEach(recommendation.recommendedExercises.prefix(3)) { exercise in
                    RecommendedExerciseRow(
                        exercise: exercise,
                        isExpanded: expandedExerciseId == exercise.id,
                        onTap: {
                            withAnimation {
                                if expandedExerciseId == exercise.id {
                                    expandedExerciseId = nil
                                } else {
                                    expandedExerciseId = exercise.id
                                }
                            }
                        },
                        onStart: {
                            onExerciseTap(exercise)
                        }
                    )
                }
            }
            
            if !recommendation.focusAreas.isEmpty {
                HStack {
                    Text("Focus:")
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    ForEach(recommendation.focusAreas.prefix(2), id: \.self) { area in
                        Text(area)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.purple.opacity(0.1))
                            .foregroundColor(.purple)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct RecommendedExerciseRow: View {
    let exercise: Exercise
    let isExpanded: Bool
    let onTap: () -> Void
    let onStart: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: onTap) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(exercise.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        HStack {
                            Label("\(Int(exercise.duration / 60)) min", systemImage: "clock")
                                .font(.caption)
                            
                            Text("•")
                            
                            Text(exercise.category.rawValue)
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    Text(exercise.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button(action: onStart) {
                        Text("Start Exercise")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.purple)
                            .cornerRadius(15)
                    }
                }
                .padding(.top, 5)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct ExerciseDetailSheet: View {
    let exercise: Exercise
    let recommendationService: ExerciseRecommendationService
    let userId: UUID
    @Environment(\.presentationMode) var presentationMode
    @State private var exerciseCompleted = false
    @State private var actualDuration: TimeInterval = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let thumbnailURL = exercise.thumbnailURL, let url = URL(string: thumbnailURL) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 200)
                                .clipped()
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 200)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text(exercise.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(exercise.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Instructions")
                                .font(.headline)
                            
                            ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { index, instruction in
                                HStack(alignment: .top, spacing: 10) {
                                    Text("\(index + 1).")
                                        .fontWeight(.bold)
                                        .foregroundColor(.purple)
                                    
                                    Text(instruction)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        
                        if !exerciseCompleted {
                            Button(action: completeExercise) {
                                Text("Mark as Complete")
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .cornerRadius(10)
                            }
                            .padding(.top)
                        } else {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Exercise Completed!")
                                    .fontWeight(.medium)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitle("Exercise Details", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func completeExercise() {
        actualDuration = exercise.duration
        recommendationService.saveExerciseCompletion(exercise, userId: userId, duration: actualDuration)
        withAnimation {
            exerciseCompleted = true
        }
    }
}

struct WorkoutStreakCard: View {
    let userId: UUID
    @Binding var navigateToAccomplishments: Bool
    @StateObject private var workoutHistory: WorkoutHistoryManager
    
    init(userId: UUID, navigateToAccomplishments: Binding<Bool>) {
        self.userId = userId
        self._navigateToAccomplishments = navigateToAccomplishments
        self._workoutHistory = StateObject(wrappedValue: WorkoutHistoryManager(userId: userId))
    }
    
    var body: some View {
        Button(action: { navigateToAccomplishments = true }) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Exercise Streak")
                        .font(.headline)
                    
                    HStack(spacing: 20) {
                        HStack(spacing: 5) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                            Text("\(workoutHistory.currentStreak.currentStreak)")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("days")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                            .frame(height: 30)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Best: \(workoutHistory.currentStreak.longestStreak)")
                                .font(.caption)
                            Text("Total: \(workoutHistory.currentStreak.totalDaysExercised)")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack {
                    Image(systemName: "trophy.fill")
                        .font(.title)
                        .foregroundColor(.yellow)
                    Text("\(workoutHistory.accomplishments.count)")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.orange.opacity(0.1), Color.pink.opacity(0.1)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(15)
        }
        .buttonStyle(PlainButtonStyle())
    }
}