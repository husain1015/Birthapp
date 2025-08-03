import SwiftUI

struct WeeklyPlanView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var currentWeek: Int = 1
    @State private var weeklyPlan: WeeklyPlan?
    @State private var selectedTab = 0
    @State private var showingPlanDetails = false
    @State private var expandedDayIndex: Int?
    
    var selectedDayIndex: Int? = nil
    
    var trimester: Int {
        WeeklyPlan.getTrimester(from: currentWeek)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Week selector header
                weekSelectorHeader
                
                // Progress overview
                if let plan = weeklyPlan {
                    ProgressOverviewCard(plan: plan)
                        .padding()
                }
                
                // Tab view for different sections
                TabView(selection: $selectedTab) {
                    ExercisePlanTab(weeklyPlan: $weeklyPlan, expandedDayIndex: $expandedDayIndex)
                        .tag(0)
                    
                    NutritionTab(weeklyPlan: $weeklyPlan)
                        .tag(1)
                    
                    EducationTab(weeklyPlan: $weeklyPlan)
                        .tag(2)
                    
                    TasksTab(weeklyPlan: $weeklyPlan)
                        .tag(3)
                    
                    SymptomsTab(weeklyPlan: $weeklyPlan)
                        .tag(4)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Custom tab bar
                customTabBar
            }
            .navigationTitle("Your Weekly Plan")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingPlanDetails = true }) {
                        Image(systemName: "info.circle")
                    }
                }
            }
            .onAppear {
                loadCurrentWeekPlan()
                // If a specific day was selected, expand it and switch to exercise tab
                if let dayIndex = selectedDayIndex {
                    expandedDayIndex = dayIndex
                    selectedTab = 0 // Exercise tab
                }
            }
            .sheet(isPresented: $showingPlanDetails) {
                PlanDetailsView(weeklyPlan: weeklyPlan)
            }
        }
    }
    
    private var weekSelectorHeader: some View {
        VStack(spacing: 10) {
            HStack {
                Button(action: previousWeek) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }
                .disabled(currentWeek <= 1)
                
                Spacer()
                
                VStack {
                    Text("Week \(currentWeek)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Trimester \(trimester)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: nextWeek) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                }
                .disabled(currentWeek >= 40)
            }
            .padding()
            
            // Baby size indicator
            if let plan = weeklyPlan {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.pink)
                    Text(getBabySizeDescription(for: currentWeek))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
            }
        }
        .background(Color(.systemGray6))
    }
    
    private var customTabBar: some View {
        HStack(spacing: 0) {
            TabBarButton(title: "Exercise", icon: "figure.walk", tag: 0, selection: $selectedTab)
            TabBarButton(title: "Nutrition", icon: "leaf", tag: 1, selection: $selectedTab)
            TabBarButton(title: "Learn", icon: "book", tag: 2, selection: $selectedTab)
            TabBarButton(title: "Tasks", icon: "checklist", tag: 3, selection: $selectedTab)
            TabBarButton(title: "Symptoms", icon: "heart.text.square", tag: 4, selection: $selectedTab)
        }
        .background(Color(.systemGray6))
    }
    
    private func loadCurrentWeekPlan() {
        // Calculate current week based on due date
        if let user = userManager.currentUser,
           let assessment = userManager.getUserAssessment(for: user),
           let dueDate = assessment.basicInfo.dueDate {
            let weeksUntilDue = Calendar.current.dateComponents([.weekOfYear], from: Date(), to: dueDate).weekOfYear ?? 40
            currentWeek = max(1, 40 - weeksUntilDue)
        }
        
        // Load or create weekly plan
        if let userId = userManager.currentUser?.id {
            weeklyPlan = WeeklyPlan(userId: userId, weekNumber: currentWeek)
        }
    }
    
    private func previousWeek() {
        currentWeek = max(1, currentWeek - 1)
        loadCurrentWeekPlan()
    }
    
    private func nextWeek() {
        currentWeek = min(40, currentWeek + 1)
        loadCurrentWeekPlan()
    }
    
    private func getBabySizeDescription(for week: Int) -> String {
        switch week {
        case 4: return "Your baby is the size of a poppy seed"
        case 5: return "Your baby is the size of an apple seed"
        case 6: return "Your baby is the size of a sweet pea"
        case 7: return "Your baby is the size of a blueberry"
        case 8: return "Your baby is the size of a raspberry"
        case 9: return "Your baby is the size of a cherry"
        case 10: return "Your baby is the size of a kumquat"
        case 11: return "Your baby is the size of a fig"
        case 12: return "Your baby is the size of a lime"
        case 13: return "Your baby is the size of a peach"
        case 14: return "Your baby is the size of a lemon"
        case 15: return "Your baby is the size of an apple"
        case 16: return "Your baby is the size of an avocado"
        case 17: return "Your baby is the size of a turnip"
        case 18: return "Your baby is the size of a bell pepper"
        case 19: return "Your baby is the size of a mango"
        case 20: return "Your baby is the size of a banana"
        case 21: return "Your baby is the size of a carrot"
        case 22: return "Your baby is the size of a papaya"
        case 23: return "Your baby is the size of a grapefruit"
        case 24: return "Your baby is the size of an ear of corn"
        case 25: return "Your baby is the size of a rutabaga"
        case 26: return "Your baby is the size of a scallion"
        case 27: return "Your baby is the size of a cauliflower"
        case 28: return "Your baby is the size of an eggplant"
        case 29: return "Your baby is the size of a butternut squash"
        case 30: return "Your baby is the size of a cabbage"
        case 31: return "Your baby is the size of a coconut"
        case 32: return "Your baby is the size of a jicama"
        case 33: return "Your baby is the size of a pineapple"
        case 34: return "Your baby is the size of a cantaloupe"
        case 35: return "Your baby is the size of a honeydew"
        case 36: return "Your baby is the size of a romaine lettuce"
        case 37: return "Your baby is the size of a swiss chard"
        case 38: return "Your baby is the size of a leek"
        case 39: return "Your baby is the size of a watermelon"
        case 40: return "Your baby is the size of a pumpkin"
        default: return "Your baby is growing!"
        }
    }
}

// MARK: - Progress Overview Card
struct ProgressOverviewCard: View {
    let plan: WeeklyPlan
    
    var completionPercentage: Int {
        let totalExercises = plan.exerciseDays.flatMap { $0.exercises }.count
        let completedExercises = plan.exerciseDays.flatMap { $0.exercises }.filter { $0.isCompleted }.count
        let totalTasks = totalExercises + plan.nutritionGoals.count + plan.educationTopics.count + plan.preparationTasks.count
        let completedTasks = completedExercises +
                           plan.nutritionGoals.filter { $0.isAchieved }.count +
                           plan.educationTopics.filter { $0.isCompleted }.count +
                           plan.preparationTasks.filter { $0.isCompleted }.count
        
        guard totalTasks > 0 else { return 0 }
        return Int((Double(completedTasks) / Double(totalTasks)) * 100)
    }
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("This Week's Progress")
                    .font(.headline)
                Spacer()
                Text("\(completionPercentage)%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppConstants.primaryColor)
            }
            
            ProgressView(value: Double(completionPercentage), total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: AppConstants.primaryColor))
            
            HStack {
                ProgressStat(icon: "figure.walk", count: plan.exerciseDays.filter { $0.isCompleted }.count, total: plan.exerciseDays.count, color: .blue)
                Spacer()
                ProgressStat(icon: "leaf", count: plan.nutritionGoals.filter { $0.isAchieved }.count, total: plan.nutritionGoals.count, color: .green)
                Spacer()
                ProgressStat(icon: "book", count: plan.educationTopics.filter { $0.isCompleted }.count, total: plan.educationTopics.count, color: .orange)
                Spacer()
                ProgressStat(icon: "checklist", count: plan.preparationTasks.filter { $0.isCompleted }.count, total: plan.preparationTasks.count, color: .purple)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ProgressStat: View {
    let icon: String
    let count: Int
    let total: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text("\(count)/\(total)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Tab Views
struct ExercisePlanTab: View {
    @Binding var weeklyPlan: WeeklyPlan?
    @Binding var expandedDayIndex: Int?
    
    var body: some View {
        ScrollView {
            if let plan = weeklyPlan {
                VStack(spacing: 20) {
                    // Exercise days overview
                    HStack {
                        Text("Your 3-Day Exercise Plan")
                            .font(.headline)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    ForEach(Array(plan.exerciseDays.enumerated()), id: \.element.id) { index, day in
                        ExerciseDayCard(
                            exerciseDay: day,
                            weeklyPlan: $weeklyPlan,
                            isExpanded: expandedDayIndex == index,
                            onToggle: {
                                withAnimation {
                                    if expandedDayIndex == index {
                                        expandedDayIndex = nil
                                    } else {
                                        expandedDayIndex = index
                                    }
                                }
                            }
                        )
                    }
                }
                .padding(.vertical)
            } else {
                Text("Loading exercises...")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
    }
}

struct ExerciseDayCard: View {
    let exerciseDay: ExerciseDay
    @Binding var weeklyPlan: WeeklyPlan?
    var isExpanded: Bool = false
    var onToggle: () -> Void = {}
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Day header
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(exerciseDay.displayName)
                        .font(.headline)
                    Text("\(exerciseDay.totalDuration) minutes total • \(exerciseDay.exercises.count) exercises")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if exerciseDay.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                } else {
                    Text("\(exerciseDay.exercises.filter { $0.isCompleted }.count)/\(exerciseDay.exercises.count)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }
                
                Button(action: onToggle) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            
            if isExpanded {
                VStack(spacing: 10) {
                    ForEach(exerciseDay.exercises) { exercise in
                        WeeklyExerciseRow(exercise: exercise, exerciseDay: exerciseDay, weeklyPlan: $weeklyPlan)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
            }
        }
        .cornerRadius(12)
        .padding(.horizontal)
        .onAppear {
            checkDayCompletion()
        }
    }
    
    private func checkDayCompletion() {
        let allCompleted = exerciseDay.exercises.allSatisfy { $0.isCompleted }
        if allCompleted != exerciseDay.isCompleted {
            if let dayIndex = weeklyPlan?.exerciseDays.firstIndex(where: { $0.id == exerciseDay.id }) {
                weeklyPlan?.exerciseDays[dayIndex].isCompleted = allCompleted
                if allCompleted {
                    weeklyPlan?.exerciseDays[dayIndex].completedDate = Date()
                }
            }
        }
    }
}

struct WeeklyExerciseRow: View {
    let exercise: WeeklyExercise
    let exerciseDay: ExerciseDay
    @Binding var weeklyPlan: WeeklyPlan?
    @State private var showingDetail = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack(spacing: 10) {
                        if let reps = exercise.reps {
                            Label(reps, systemImage: "arrow.clockwise")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Label("\(exercise.duration) min", systemImage: "clock")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if exercise.sets > 1 {
                            Label("\(exercise.sets) sets", systemImage: "square.stack.3d.up")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Label(exercise.intensity.rawValue, systemImage: "flame")
                            .font(.caption)
                            .foregroundColor(intensityColor(for: exercise.intensity))
                    }
                }
                
                Spacer()
                
                Button(action: toggleCompletion) {
                    Image(systemName: exercise.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundColor(exercise.isCompleted ? .green : .gray)
                }
            }
            
            Button(action: { showingDetail = true }) {
                Text("View Details")
                    .font(.caption)
                    .foregroundColor(AppConstants.primaryColor)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .sheet(isPresented: $showingDetail) {
            WeeklyExerciseDetailView(exercise: exercise)
        }
    }
    
    private func toggleCompletion() {
        if let dayIndex = weeklyPlan?.exerciseDays.firstIndex(where: { $0.id == exerciseDay.id }),
           let exerciseIndex = weeklyPlan?.exerciseDays[dayIndex].exercises.firstIndex(where: { $0.id == exercise.id }) {
            weeklyPlan?.exerciseDays[dayIndex].exercises[exerciseIndex].isCompleted.toggle()
            
            // Check if all exercises in the day are completed
            let allCompleted = weeklyPlan?.exerciseDays[dayIndex].exercises.allSatisfy { $0.isCompleted } ?? false
            weeklyPlan?.exerciseDays[dayIndex].isCompleted = allCompleted
            if allCompleted {
                weeklyPlan?.exerciseDays[dayIndex].completedDate = Date()
            }
        }
    }
    
    private func intensityColor(for intensity: IntensityLevel) -> Color {
        switch intensity {
        case .gentle: return .green
        case .light: return .blue
        case .moderate: return .orange
        case .vigorous: return .red
        }
    }
}

struct NutritionTab: View {
    @Binding var weeklyPlan: WeeklyPlan?
    
    var body: some View {
        ScrollView {
            if let plan = weeklyPlan {
                VStack(spacing: 15) {
                    ForEach(plan.nutritionGoals) { goal in
                        NutritionGoalCard(goal: goal, weeklyPlan: $weeklyPlan)
                    }
                }
                .padding()
            }
        }
    }
}

struct NutritionGoalCard: View {
    let goal: NutritionGoal
    @Binding var weeklyPlan: WeeklyPlan?
    @State private var showingFoods = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading) {
                    Text(goal.goal)
                        .font(.headline)
                    if let target = goal.targetAmount {
                        Text(target)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button(action: toggleAchieved) {
                    Image(systemName: goal.isAchieved ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(goal.isAchieved ? .green : .gray)
                }
            }
            
            Label(goal.category.rawValue, systemImage: categoryIcon(for: goal.category))
                .font(.caption)
                .foregroundColor(.secondary)
            
            if showingFoods {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Recommended Foods:")
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    ForEach(goal.foods, id: \.self) { food in
                        HStack {
                            Image(systemName: "leaf.fill")
                                .font(.caption2)
                                .foregroundColor(.green)
                            Text(food)
                                .font(.caption)
                        }
                    }
                    
                    if !goal.tips.isEmpty {
                        Text("Tips:")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.top, 5)
                        
                        ForEach(goal.tips, id: \.self) { tip in
                            HStack(alignment: .top) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.caption2)
                                    .foregroundColor(.yellow)
                                Text(tip)
                                    .font(.caption)
                            }
                        }
                    }
                }
                .padding(.top, 5)
            }
            
            Button(action: { showingFoods.toggle() }) {
                Text(showingFoods ? "Hide Details" : "Show Foods & Tips")
                    .font(.caption)
                    .foregroundColor(AppConstants.primaryColor)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func toggleAchieved() {
        if let index = weeklyPlan?.nutritionGoals.firstIndex(where: { $0.id == goal.id }) {
            weeklyPlan?.nutritionGoals[index].isAchieved.toggle()
        }
    }
    
    private func categoryIcon(for category: NutritionCategory) -> String {
        switch category {
        case .calories: return "flame"
        case .protein: return "fish"
        case .iron: return "drop.fill"
        case .calcium: return "cube"
        case .folicAcid: return "leaf"
        case .omega3: return "capsule"
        case .hydration: return "drop"
        case .fiber: return "leaf.arrow.circlepath"
        case .vitamins: return "pills"
        }
    }
}

struct EducationTab: View {
    @Binding var weeklyPlan: WeeklyPlan?
    
    var body: some View {
        ScrollView {
            if let plan = weeklyPlan {
                VStack(spacing: 15) {
                    ForEach(plan.educationTopics) { topic in
                        EducationTopicCard(topic: topic, weeklyPlan: $weeklyPlan)
                    }
                }
                .padding()
            }
        }
    }
}

struct EducationTopicCard: View {
    let topic: EducationTopic
    @Binding var weeklyPlan: WeeklyPlan?
    @State private var showingDetail = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading) {
                    Text(topic.title)
                        .font(.headline)
                    Label("\(topic.estimatedReadTime) min read", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if topic.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                }
            }
            
            Text(topic.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            Label(topic.category.rawValue, systemImage: categoryIcon(for: topic.category))
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button(action: { showingDetail = true }) {
                Text("Read More")
                    .font(.caption)
                    .foregroundColor(AppConstants.primaryColor)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .sheet(isPresented: $showingDetail) {
            EducationDetailView(topic: topic, weeklyPlan: $weeklyPlan)
        }
    }
    
    private func categoryIcon(for category: EducationCategory) -> String {
        switch category {
        case .fetalDevelopment: return "heart.text.square"
        case .bodyChanges: return "figure.stand"
        case .laborPreparation: return "clock.arrow.circlepath"
        case .newbornCare: return "figure.and.child.holdinghands"
        case .breastfeeding: return "drop.circle"
        case .postpartumRecovery: return "bandage"
        case .safety: return "exclamationmark.shield"
        case .emotionalWellbeing: return "brain.head.profile"
        }
    }
}

struct TasksTab: View {
    @Binding var weeklyPlan: WeeklyPlan?
    
    var body: some View {
        ScrollView {
            if let plan = weeklyPlan {
                VStack(spacing: 20) {
                    // Preparation Tasks
                    if !plan.preparationTasks.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Preparation Tasks")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(plan.preparationTasks) { task in
                                PreparationTaskCard(task: task, weeklyPlan: $weeklyPlan)
                            }
                        }
                    }
                    
                    // Provider Reminders
                    if !plan.providerReminders.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Medical Reminders")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(plan.providerReminders) { reminder in
                                ProviderReminderCard(reminder: reminder, weeklyPlan: $weeklyPlan)
                            }
                        }
                    }
                    
                    // Self-care activities
                    if !plan.selfCareActivities.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Self-Care Activities")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(plan.selfCareActivities) { activity in
                                SelfCareCard(activity: activity, weeklyPlan: $weeklyPlan)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
        }
    }
}

struct SymptomsTab: View {
    @Binding var weeklyPlan: WeeklyPlan?
    
    var body: some View {
        ScrollView {
            if let plan = weeklyPlan {
                VStack(spacing: 15) {
                    ForEach(plan.symptoms) { symptom in
                        SymptomManagementCard(symptom: symptom)
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Supporting Views
struct TabBarButton: View {
    let title: String
    let icon: String
    let tag: Int
    @Binding var selection: Int
    
    var body: some View {
        Button(action: { selection = tag }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(.caption2)
            }
            .foregroundColor(selection == tag ? AppConstants.primaryColor : .gray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}

struct WeeklyExerciseDetailView: View {
    let exercise: WeeklyExercise
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 10) {
                        Text(exercise.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        HStack {
                            Label(exercise.category.rawValue, systemImage: "tag")
                            Spacer()
                            Label(exercise.intensity.rawValue, systemImage: "flame")
                                .foregroundColor(intensityColor(for: exercise.intensity))
                        }
                        
                        HStack {
                            Label("\(exercise.duration) minutes", systemImage: "clock")
                            if exercise.sets > 1 {
                                Label("\(exercise.sets) sets", systemImage: "square.stack.3d.up")
                            }
                            if let reps = exercise.reps {
                                Label(reps, systemImage: "arrow.clockwise")
                            }
                        }
                        .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    // Instructions
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Instructions")
                            .font(.headline)
                        Text(exercise.instructions)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    
                    // Modifications
                    if !exercise.modifications.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Modifications")
                                .font(.headline)
                            ForEach(exercise.modifications, id: \.self) { modification in
                                HStack(alignment: .top) {
                                    Image(systemName: "checkmark.circle")
                                        .foregroundColor(.green)
                                    Text(modification)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        .padding()
                    }
                    
                    // Contraindications
                    if !exercise.contraindications.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("Safety Considerations")
                                    .font(.headline)
                            }
                            
                            ForEach(exercise.contraindications, id: \.self) { contraindication in
                                HStack(alignment: .top) {
                                    Image(systemName: "xmark.circle")
                                        .foregroundColor(.red)
                                    Text(contraindication)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(10)
                        .padding()
                    }
                }
            }
            .navigationBarTitle("Exercise Details", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func intensityColor(for intensity: IntensityLevel) -> Color {
        switch intensity {
        case .gentle: return .green
        case .light: return .blue
        case .moderate: return .orange
        case .vigorous: return .red
        }
    }
}

struct EducationDetailView: View {
    let topic: EducationTopic
    @Binding var weeklyPlan: WeeklyPlan?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 10) {
                        Text(topic.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Label(topic.category.rawValue, systemImage: "tag")
                            .foregroundColor(.secondary)
                        
                        Label("\(topic.estimatedReadTime) minute read", systemImage: "clock")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    // Description
                    Text(topic.description)
                        .padding()
                    
                    // Key Points
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Key Points")
                            .font(.headline)
                        
                        ForEach(topic.keyPoints, id: \.self) { point in
                            HStack(alignment: .top) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text(point)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding()
                    
                    // Resources
                    if !topic.resources.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Additional Resources")
                                .font(.headline)
                            
                            ForEach(topic.resources, id: \.self) { resource in
                                HStack {
                                    Image(systemName: "link")
                                        .foregroundColor(.blue)
                                    Text(resource)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .padding()
                    }
                    
                    // Mark as complete button
                    if !topic.isCompleted {
                        Button(action: markAsComplete) {
                            Label("Mark as Read", systemImage: "checkmark.circle")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppConstants.primaryColor)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding()
                    }
                }
            }
            .navigationBarTitle("Education", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func markAsComplete() {
        if let index = weeklyPlan?.educationTopics.firstIndex(where: { $0.id == topic.id }) {
            weeklyPlan?.educationTopics[index].isCompleted = true
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct PreparationTaskCard: View {
    let task: PreparationTask
    @Binding var weeklyPlan: WeeklyPlan?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading) {
                    Text(task.title)
                        .font(.headline)
                    HStack {
                        Label(task.category.rawValue, systemImage: "folder")
                            .font(.caption)
                        
                        if let dueWeek = task.dueByWeek {
                            Label("Due by week \(dueWeek)", systemImage: "calendar")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                Spacer()
                
                Button(action: toggleCompletion) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(task.isCompleted ? .green : priorityColor(for: task.priority))
                }
            }
            
            Text(task.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func toggleCompletion() {
        if let index = weeklyPlan?.preparationTasks.firstIndex(where: { $0.id == task.id }) {
            weeklyPlan?.preparationTasks[index].isCompleted.toggle()
        }
    }
    
    private func priorityColor(for priority: TaskPriority) -> Color {
        switch priority {
        case .low: return .gray
        case .medium: return .blue
        case .high: return .orange
        case .urgent: return .red
        }
    }
}

struct ProviderReminderCard: View {
    let reminder: ProviderReminder
    @Binding var weeklyPlan: WeeklyPlan?
    
    var body: some View {
        HStack {
            Image(systemName: reminderIcon(for: reminder.reminderType))
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(reminder.title)
                    .font(.headline)
                Text(reminder.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if reminder.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func reminderIcon(for type: ReminderType) -> String {
        switch type {
        case .appointment: return "person.2"
        case .test: return "testtube.2"
        case .ultrasound: return "waveform"
        case .vaccination: return "syringe"
        case .screening: return "doc.text.magnifyingglass"
        case .other: return "bell"
        }
    }
}

struct SelfCareCard: View {
    let activity: SelfCareActivity
    @Binding var weeklyPlan: WeeklyPlan?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading) {
                    Text(activity.name)
                        .font(.headline)
                    HStack {
                        Label("\(activity.duration) min", systemImage: "clock")
                        Label(activity.frequency, systemImage: "repeat")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: toggleCompletion) {
                    Image(systemName: activity.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(activity.isCompleted ? .green : .gray)
                }
            }
            
            Text(activity.instructions)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func toggleCompletion() {
        if let index = weeklyPlan?.selfCareActivities.firstIndex(where: { $0.id == activity.id }) {
            weeklyPlan?.selfCareActivities[index].isCompleted.toggle()
        }
    }
}

struct SymptomManagementCard: View {
    let symptom: SymptomManagement
    @State private var expanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(symptom.symptom)
                    .font(.headline)
                
                Spacer()
                
                if symptom.commonInWeek {
                    Label("Common", systemImage: "info.circle")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Button(action: { expanded.toggle() }) {
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
            }
            
            if expanded {
                VStack(alignment: .leading, spacing: 15) {
                    // Management Tips
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Management Tips")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        ForEach(symptom.managementTips, id: \.self) { tip in
                            HStack(alignment: .top) {
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(.green)
                                    .font(.caption)
                                Text(tip)
                                    .font(.caption)
                            }
                        }
                    }
                    
                    // Warning Signs
                    if !symptom.warningSignsToWatch.isEmpty {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Warning Signs")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                            
                            ForEach(symptom.warningSignsToWatch, id: \.self) { sign in
                                HStack(alignment: .top) {
                                    Image(systemName: "exclamationmark.triangle")
                                        .foregroundColor(.orange)
                                        .font(.caption)
                                    Text(sign)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    
                    // When to Call Provider
                    if let whenToCall = symptom.whenToCallProvider {
                        HStack(alignment: .top) {
                            Image(systemName: "phone.fill")
                                .foregroundColor(.red)
                            Text(whenToCall)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct PlanDetailsView: View {
    let weeklyPlan: WeeklyPlan?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Group {
                if let plan = weeklyPlan {
                    List {
                    Section(header: Text("Week Overview")) {
                        HStack {
                            Text("Week")
                            Spacer()
                            Text("\(plan.weekNumber)")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Trimester")
                            Spacer()
                            Text("\(plan.trimester)")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Completion")
                            Spacer()
                            Text("\(Int(plan.completionRate * 100))%")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Section(header: Text("Plan Contents")) {
                        HStack {
                            Label("Exercise Days", systemImage: "figure.walk")
                            Spacer()
                            Text("\(plan.exerciseDays.count) days")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Label("Nutrition Goals", systemImage: "leaf")
                            Spacer()
                            Text("\(plan.nutritionGoals.count)")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Label("Education Topics", systemImage: "book")
                            Spacer()
                            Text("\(plan.educationTopics.count)")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Label("Tasks", systemImage: "checklist")
                            Spacer()
                            Text("\(plan.preparationTasks.count)")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Section(header: Text("About Your Plan")) {
                        Text("This personalized weekly plan is tailored to your pregnancy journey based on your assessment responses. Each week brings new exercises, nutrition goals, and educational content appropriate for your stage of pregnancy.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("Plan Details")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}