import Foundation

// MARK: - Workout History Models

struct WorkoutSession: Codable, Identifiable {
    var id: UUID = UUID()
    let userId: UUID
    let exerciseId: UUID
    let exerciseName: String
    let weekNumber: Int
    let dayNumber: Int
    let startTime: Date
    var endTime: Date?
    var duration: TimeInterval // in seconds
    var actualReps: Int?
    var actualSets: Int?
    var intensity: IntensityLevel
    var notes: String?
    var heartRate: Int? // average BPM
    var caloriesBurned: Double?
    var isCompleted: Bool = false
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct DailyWorkoutSummary: Codable, Identifiable {
    var id: UUID = UUID()
    let userId: UUID
    let date: Date
    let weekNumber: Int
    let completedExercises: Int
    let totalExercises: Int
    let totalDuration: TimeInterval // in seconds
    let totalCaloriesBurned: Double
    let exerciseSessions: [WorkoutSession]
    
    var completionPercentage: Double {
        guard totalExercises > 0 else { return 0 }
        return Double(completedExercises) / Double(totalExercises) * 100
    }
}

struct WeeklyWorkoutSummary: Codable, Identifiable {
    var id: UUID = UUID()
    let userId: UUID
    let weekNumber: Int
    let startDate: Date
    let endDate: Date
    let completedDays: Int
    let totalDays: Int = 3 // 3 exercise days per week
    let totalDuration: TimeInterval
    let totalCaloriesBurned: Double
    let dailySummaries: [DailyWorkoutSummary]
    
    var completionPercentage: Double {
        return Double(completedDays) / Double(totalDays) * 100
    }
}

// MARK: - Accomplishments & Streak Models

struct ExerciseStreak: Codable {
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastExerciseDate: Date?
    var totalDaysExercised: Int = 0
    var weeklyGoal: Int = 3
    
    mutating func updateStreak(exerciseDate: Date) {
        let calendar = Calendar.current
        
        if let lastDate = lastExerciseDate {
            let daysBetween = calendar.dateComponents([.day], from: lastDate, to: exerciseDate).day ?? 0
            
            if daysBetween == 1 {
                // Consecutive day
                currentStreak += 1
            } else if daysBetween > 1 {
                // Streak broken
                currentStreak = 1
            }
            // If daysBetween == 0, same day, don't update streak
        } else {
            // First exercise
            currentStreak = 1
        }
        
        longestStreak = max(longestStreak, currentStreak)
        lastExerciseDate = exerciseDate
        totalDaysExercised += 1
    }
}

struct Accomplishment: Codable, Identifiable {
    var id: UUID = UUID()
    let userId: UUID
    let type: AccomplishmentType
    let title: String
    let description: String
    let dateAchieved: Date
    let icon: String
    let value: Int? // For numeric accomplishments
}

enum AccomplishmentType: String, Codable, CaseIterable {
    case streakMilestone = "Streak Milestone"
    case weeklyGoal = "Weekly Goal"
    case trimesterComplete = "Trimester Complete"
    case exerciseMilestone = "Exercise Milestone"
    case consistencyAward = "Consistency Award"
    case personalBest = "Personal Best"
    case specialAchievement = "Special Achievement"
}

struct ExerciseMetrics: Codable {
    let userId: UUID
    var totalWorkouts: Int = 0
    var totalMinutesExercised: Int = 0
    var totalCaloriesBurned: Double = 0
    var favoriteExerciseCategory: WeeklyExerciseCategory?
    var averageWorkoutDuration: Int = 0 // in minutes
    var weeklyConsistencyRate: Double = 0.0 // percentage
    
    // Milestones
    var milestonesReached: [MilestoneType: Bool] = [:]
    
    mutating func updateMetrics(from session: WorkoutSession) {
        totalWorkouts += 1
        totalMinutesExercised += Int(session.duration / 60)
        totalCaloriesBurned += session.caloriesBurned ?? 0
        averageWorkoutDuration = totalMinutesExercised / totalWorkouts
        
        checkMilestones()
    }
    
    private mutating func checkMilestones() {
        // Check various milestones
        if totalWorkouts >= 10 && !(milestonesReached[.tenWorkouts] ?? false) {
            milestonesReached[.tenWorkouts] = true
        }
        
        if totalWorkouts >= 25 && !(milestonesReached[.twentyFiveWorkouts] ?? false) {
            milestonesReached[.twentyFiveWorkouts] = true
        }
        
        if totalWorkouts >= 50 && !(milestonesReached[.fiftyWorkouts] ?? false) {
            milestonesReached[.fiftyWorkouts] = true
        }
        
        if totalMinutesExercised >= 500 && !(milestonesReached[.fiveHundredMinutes] ?? false) {
            milestonesReached[.fiveHundredMinutes] = true
        }
        
        if totalMinutesExercised >= 1000 && !(milestonesReached[.thousandMinutes] ?? false) {
            milestonesReached[.thousandMinutes] = true
        }
    }
}

enum MilestoneType: String, Codable {
    case tenWorkouts = "10 Workouts"
    case twentyFiveWorkouts = "25 Workouts"
    case fiftyWorkouts = "50 Workouts"
    case fiveHundredMinutes = "500 Minutes"
    case thousandMinutes = "1000 Minutes"
    case perfectWeek = "Perfect Week"
    case monthlyConsistency = "Monthly Consistency"
}

// MARK: - Workout History Manager

class WorkoutHistoryManager: ObservableObject {
    @Published var sessions: [WorkoutSession] = []
    @Published var accomplishments: [Accomplishment] = []
    @Published var currentStreak: ExerciseStreak = ExerciseStreak()
    @Published var metrics: ExerciseMetrics
    
    private let userId: UUID
    private let storageKey = "WorkoutHistory"
    private let accomplishmentsKey = "Accomplishments"
    private let streakKey = "ExerciseStreak"
    private let metricsKey = "ExerciseMetrics"
    
    init(userId: UUID) {
        self.userId = userId
        self.metrics = ExerciseMetrics(userId: userId)
        loadData()
    }
    
    func startWorkout(exercise: WeeklyExercise, weekNumber: Int, dayNumber: Int) -> WorkoutSession {
        let session = WorkoutSession(
            userId: userId,
            exerciseId: exercise.id,
            exerciseName: exercise.name,
            weekNumber: weekNumber,
            dayNumber: dayNumber,
            startTime: Date(),
            duration: 0,
            intensity: exercise.intensity
        )
        return session
    }
    
    func completeWorkout(_ session: inout WorkoutSession, actualDuration: TimeInterval? = nil) {
        session.endTime = Date()
        session.duration = actualDuration ?? Date().timeIntervalSince(session.startTime)
        session.isCompleted = true
        
        // Estimate calories (rough estimate: 5 calories per minute for moderate intensity)
        let caloriesPerMinute = session.intensity == .gentle ? 3.0 :
                               session.intensity == .light ? 4.0 :
                               session.intensity == .moderate ? 5.0 : 6.0
        session.caloriesBurned = (session.duration / 60) * caloriesPerMinute
        
        sessions.append(session)
        metrics.updateMetrics(from: session)
        currentStreak.updateStreak(exerciseDate: Date())
        
        checkForAccomplishments(session: session)
        saveData()
    }
    
    func getDailySummary(for date: Date) -> DailyWorkoutSummary? {
        let calendar = Calendar.current
        let daysSessions = sessions.filter { session in
            calendar.isDate(session.startTime, inSameDayAs: date)
        }
        
        guard !daysSessions.isEmpty else { return nil }
        
        let weekNumber = daysSessions.first?.weekNumber ?? 0
        let completedCount = daysSessions.filter { $0.isCompleted }.count
        let totalDuration = daysSessions.reduce(0) { $0 + $1.duration }
        let totalCalories = daysSessions.reduce(0) { $0 + ($1.caloriesBurned ?? 0) }
        
        return DailyWorkoutSummary(
            userId: userId,
            date: date,
            weekNumber: weekNumber,
            completedExercises: completedCount,
            totalExercises: daysSessions.count,
            totalDuration: totalDuration,
            totalCaloriesBurned: totalCalories,
            exerciseSessions: daysSessions
        )
    }
    
    func getWeeklySummary(weekNumber: Int) -> WeeklyWorkoutSummary? {
        let weekSessions = sessions.filter { $0.weekNumber == weekNumber }
        guard !weekSessions.isEmpty else { return nil }
        
        let calendar = Calendar.current
        let uniqueDays = Set(weekSessions.map { calendar.startOfDay(for: $0.startTime) })
        let dailySummaries = uniqueDays.compactMap { getDailySummary(for: $0) }
        
        let totalDuration = weekSessions.reduce(0) { $0 + $1.duration }
        let totalCalories = weekSessions.reduce(0) { $0 + ($1.caloriesBurned ?? 0) }
        
        return WeeklyWorkoutSummary(
            userId: userId,
            weekNumber: weekNumber,
            startDate: weekSessions.min(by: { $0.startTime < $1.startTime })?.startTime ?? Date(),
            endDate: weekSessions.max(by: { $0.startTime < $1.startTime })?.startTime ?? Date(),
            completedDays: uniqueDays.count,
            totalDuration: totalDuration,
            totalCaloriesBurned: totalCalories,
            dailySummaries: dailySummaries
        )
    }
    
    private func checkForAccomplishments(session: WorkoutSession) {
        // Check streak milestones
        if currentStreak.currentStreak == 7 {
            addAccomplishment(
                type: .streakMilestone,
                title: "Week Warrior",
                description: "Completed 7 days in a row!",
                icon: "flame.fill",
                value: 7
            )
        } else if currentStreak.currentStreak == 14 {
            addAccomplishment(
                type: .streakMilestone,
                title: "Two Week Champion",
                description: "Maintained a 14-day streak!",
                icon: "flame.fill",
                value: 14
            )
        } else if currentStreak.currentStreak == 30 {
            addAccomplishment(
                type: .streakMilestone,
                title: "Monthly Master",
                description: "Incredible 30-day streak!",
                icon: "flame.fill",
                value: 30
            )
        }
        
        // Check weekly goal
        let calendar = Calendar.current
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        let weekSessions = sessions.filter { session in
            session.startTime >= weekStart && session.isCompleted
        }
        
        let uniqueDays = Set(weekSessions.map { calendar.startOfDay(for: $0.startTime) })
        if uniqueDays.count >= 3 && !hasAccomplishmentThisWeek(type: .weeklyGoal) {
            addAccomplishment(
                type: .weeklyGoal,
                title: "Weekly Goal Achieved",
                description: "Completed 3 workout days this week!",
                icon: "star.fill",
                value: 3
            )
        }
        
        // Check exercise milestones
        if metrics.totalWorkouts == 10 {
            addAccomplishment(
                type: .exerciseMilestone,
                title: "Getting Started",
                description: "Completed your first 10 workouts!",
                icon: "10.circle.fill",
                value: 10
            )
        } else if metrics.totalWorkouts == 25 {
            addAccomplishment(
                type: .exerciseMilestone,
                title: "Quarter Century",
                description: "Amazing! 25 workouts completed!",
                icon: "25.circle.fill",
                value: 25
            )
        } else if metrics.totalWorkouts == 50 {
            addAccomplishment(
                type: .exerciseMilestone,
                title: "Half Century",
                description: "Incredible dedication - 50 workouts!",
                icon: "50.circle.fill",
                value: 50
            )
        }
    }
    
    private func hasAccomplishmentThisWeek(type: AccomplishmentType) -> Bool {
        let calendar = Calendar.current
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        
        return accomplishments.contains { accomplishment in
            accomplishment.type == type && accomplishment.dateAchieved >= weekStart
        }
    }
    
    private func addAccomplishment(type: AccomplishmentType, title: String, description: String, icon: String, value: Int? = nil) {
        let accomplishment = Accomplishment(
            userId: userId,
            type: type,
            title: title,
            description: description,
            dateAchieved: Date(),
            icon: icon,
            value: value
        )
        accomplishments.append(accomplishment)
        saveData()
    }
    
    // MARK: - Data Persistence
    
    private func loadData() {
        // Load sessions
        if let data = UserDefaults.standard.data(forKey: "\(storageKey)_\(userId)"),
           let decoded = try? JSONDecoder().decode([WorkoutSession].self, from: data) {
            sessions = decoded
        }
        
        // Load accomplishments
        if let data = UserDefaults.standard.data(forKey: "\(accomplishmentsKey)_\(userId)"),
           let decoded = try? JSONDecoder().decode([Accomplishment].self, from: data) {
            accomplishments = decoded
        }
        
        // Load streak
        if let data = UserDefaults.standard.data(forKey: "\(streakKey)_\(userId)"),
           let decoded = try? JSONDecoder().decode(ExerciseStreak.self, from: data) {
            currentStreak = decoded
        }
        
        // Load metrics
        if let data = UserDefaults.standard.data(forKey: "\(metricsKey)_\(userId)"),
           let decoded = try? JSONDecoder().decode(ExerciseMetrics.self, from: data) {
            metrics = decoded
        }
    }
    
    private func saveData() {
        // Save sessions
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: "\(storageKey)_\(userId)")
        }
        
        // Save accomplishments
        if let encoded = try? JSONEncoder().encode(accomplishments) {
            UserDefaults.standard.set(encoded, forKey: "\(accomplishmentsKey)_\(userId)")
        }
        
        // Save streak
        if let encoded = try? JSONEncoder().encode(currentStreak) {
            UserDefaults.standard.set(encoded, forKey: "\(streakKey)_\(userId)")
        }
        
        // Save metrics
        if let encoded = try? JSONEncoder().encode(metrics) {
            UserDefaults.standard.set(encoded, forKey: "\(metricsKey)_\(userId)")
        }
    }
}