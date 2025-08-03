import SwiftUI

struct AccomplishmentsView: View {
    @EnvironmentObject var userManager: UserManager
    @StateObject private var workoutHistory: WorkoutHistoryManager
    @State private var selectedTab = 0
    
    init(userId: UUID) {
        _workoutHistory = StateObject(wrappedValue: WorkoutHistoryManager(userId: userId))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Streak and metrics header
                StreakHeaderView(
                    currentStreak: workoutHistory.currentStreak,
                    metrics: workoutHistory.metrics
                )
                
                // Tab selector
                Picker("View", selection: $selectedTab) {
                    Text("Achievements").tag(0)
                    Text("History").tag(1)
                    Text("Stats").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content based on selected tab
                if selectedTab == 0 {
                    AchievementsListView(accomplishments: workoutHistory.accomplishments)
                } else if selectedTab == 1 {
                    WorkoutHistoryListView(sessions: workoutHistory.sessions)
                } else {
                    ExerciseStatsView(metrics: workoutHistory.metrics, history: workoutHistory)
                }
            }
            .navigationTitle("Your Progress")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Streak Header
struct StreakHeaderView: View {
    let currentStreak: ExerciseStreak
    let metrics: ExerciseMetrics
    
    var body: some View {
        VStack(spacing: 20) {
            // Current streak
            VStack(spacing: 10) {
                HStack(spacing: 5) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    
                    Text("\(currentStreak.currentStreak)")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.orange)
                }
                
                Text("Day Streak")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 30) {
                    VStack {
                        Text("\(currentStreak.longestStreak)")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Best Streak")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack {
                        Text("\(currentStreak.totalDaysExercised)")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Total Days")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack {
                        Text("\(metrics.totalWorkouts)")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Workouts")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.orange.opacity(0.1), Color.pink.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(20)
            .padding()
        }
    }
}

// MARK: - Achievements List
struct AchievementsListView: View {
    let accomplishments: [Accomplishment]
    
    var groupedAccomplishments: [AccomplishmentType: [Accomplishment]] {
        Dictionary(grouping: accomplishments.sorted { $0.dateAchieved > $1.dateAchieved }, by: { $0.type })
    }
    
    var body: some View {
        ScrollView {
            if accomplishments.isEmpty {
                EmptyAchievementsView()
            } else {
                VStack(spacing: 20) {
                    ForEach(AccomplishmentType.allCases, id: \.self) { type in
                        if let typeAccomplishments = groupedAccomplishments[type], !typeAccomplishments.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(type.rawValue)
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                ForEach(typeAccomplishments) { accomplishment in
                                    AccomplishmentCard(accomplishment: accomplishment)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
        }
    }
}

struct AccomplishmentCard: View {
    let accomplishment: Accomplishment
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 15) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.purple, Color.pink]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: accomplishment.icon)
                    .font(.title)
                    .foregroundColor(.white)
            }
            .scaleEffect(isAnimating ? 1.1 : 1.0)
            .animation(
                Animation.easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true),
                value: isAnimating
            )
            
            VStack(alignment: .leading, spacing: 5) {
                Text(accomplishment.title)
                    .font(.headline)
                
                Text(accomplishment.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(accomplishment.dateAchieved, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if let value = accomplishment.value {
                Text("\(value)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
        .padding(.horizontal)
        .onAppear {
            withAnimation {
                isAnimating = true
            }
        }
    }
}

struct EmptyAchievementsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "trophy")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Achievements Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Complete your workouts to earn achievements and build your streak!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.top, 100)
    }
}

// MARK: - Workout History List
struct WorkoutHistoryListView: View {
    let sessions: [WorkoutSession]
    
    var groupedSessions: [(key: Date, value: [WorkoutSession])] {
        let grouped = Dictionary(grouping: sessions.sorted { $0.startTime > $1.startTime }) { session in
            Calendar.current.startOfDay(for: session.startTime)
        }
        return grouped.sorted { $0.key > $1.key }
    }
    
    var body: some View {
        ScrollView {
            if sessions.isEmpty {
                EmptyHistoryView()
            } else {
                VStack(spacing: 20) {
                    ForEach(groupedSessions, id: \.key) { date, daySessions in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(date, style: .date)
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(daySessions) { session in
                                WorkoutSessionCard(session: session)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
        }
    }
}

struct WorkoutSessionCard: View {
    let session: WorkoutSession
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(session.exerciseName)
                    .font(.headline)
                
                HStack {
                    Label(session.formattedDuration, systemImage: "clock")
                    
                    if let calories = session.caloriesBurned {
                        Label("\(Int(calories)) cal", systemImage: "flame")
                    }
                    
                    Label(session.intensity.rawValue, systemImage: "speedometer")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                Text("Week \(session.weekNumber) • Day \(session.dayNumber)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if session.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Workout History")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Your completed workouts will appear here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 100)
    }
}

// MARK: - Exercise Stats View
struct ExerciseStatsView: View {
    let metrics: ExerciseMetrics
    let history: WorkoutHistoryManager
    
    var averageWorkoutsPerWeek: Double {
        guard !history.sessions.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let weeks = Set(history.sessions.map { calendar.component(.weekOfYear, from: $0.startTime) })
        return Double(history.sessions.count) / Double(weeks.count)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Overall Stats
                VStack(spacing: 15) {
                    Text("Overall Statistics")
                        .font(.headline)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        ExerciseStatCard(
                            title: "Total Minutes",
                            value: "\(metrics.totalMinutesExercised)",
                            icon: "clock.fill",
                            color: .blue
                        )
                        
                        ExerciseStatCard(
                            title: "Calories Burned",
                            value: "\(Int(metrics.totalCaloriesBurned))",
                            icon: "flame.fill",
                            color: .orange
                        )
                        
                        ExerciseStatCard(
                            title: "Avg Duration",
                            value: "\(metrics.averageWorkoutDuration) min",
                            icon: "timer",
                            color: .green
                        )
                        
                        ExerciseStatCard(
                            title: "Weekly Average",
                            value: String(format: "%.1f", averageWorkoutsPerWeek),
                            icon: "calendar",
                            color: .purple
                        )
                    }
                }
                .padding()
                
                // Weekly Progress Chart
                WeeklyProgressChart(history: history)
                    .padding()
                
                // Milestones
                MilestonesView(milestones: metrics.milestonesReached)
                    .padding()
            }
        }
    }
}

struct ExerciseStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(15)
    }
}

struct WeeklyProgressChart: View {
    let history: WorkoutHistoryManager
    
    var lastFourWeeks: [(week: Int, count: Int)] {
        let calendar = Calendar.current
        let currentWeek = calendar.component(.weekOfYear, from: Date())
        
        var weekData: [(week: Int, count: Int)] = []
        
        for i in 0..<4 {
            let week = currentWeek - (3 - i)
            let sessionsInWeek = history.sessions.filter { session in
                calendar.component(.weekOfYear, from: session.startTime) == week
            }.count
            
            weekData.append((week: week, count: sessionsInWeek))
        }
        
        return weekData
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Weekly Progress")
                .font(.headline)
            
            HStack(alignment: .bottom, spacing: 20) {
                ForEach(lastFourWeeks, id: \.week) { weekData in
                    VStack {
                        Text("\(weekData.count)")
                            .font(.caption)
                            .fontWeight(.semibold)
                        
                        Rectangle()
                            .fill(weekData.count >= 3 ? Color.green : Color.orange)
                            .frame(width: 40, height: CGFloat(weekData.count) * 30 + 10)
                            .cornerRadius(5)
                        
                        Text("W\(weekData.week)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(15)
        }
    }
}

struct MilestonesView: View {
    let milestones: [MilestoneType: Bool]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Milestones")
                .font(.headline)
            
            ForEach(MilestoneType.allCases, id: \.self) { milestone in
                HStack {
                    Image(systemName: milestones[milestone] ?? false ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(milestones[milestone] ?? false ? .green : .gray)
                    
                    Text(milestone.rawValue)
                        .foregroundColor(milestones[milestone] ?? false ? .primary : .secondary)
                    
                    Spacer()
                    
                    if milestones[milestone] ?? false {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

// Make MilestoneType CaseIterable
extension MilestoneType: CaseIterable {
    static var allCases: [MilestoneType] {
        return [.tenWorkouts, .twentyFiveWorkouts, .fiftyWorkouts, .fiveHundredMinutes, .thousandMinutes, .perfectWeek, .monthlyConsistency]
    }
}