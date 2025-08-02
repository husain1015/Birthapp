import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var todaysFocus: DailyFocus?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let user = userManager.currentUser {
                        PregnancyProgressCard(user: user)
                        
                        TodaysFocusCard(focus: todaysFocus)
                        
                        QuickLinksSection()
                        
                        WeeklyTipsCard(weekOfPregnancy: user.currentWeekOfPregnancy)
                    }
                }
                .padding()
            }
            .navigationTitle("Welcome, \(userManager.currentUser?.name ?? "")")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadTodaysFocus()
            }
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
}

struct PregnancyProgressCard: View {
    let user: User
    
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
                        
                        Button(action: {}) {
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
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick Access")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                QuickLinkButton(
                    title: "Exercises",
                    icon: "figure.strengthtraining.traditional",
                    color: .blue
                )
                
                QuickLinkButton(
                    title: "Birth Plan",
                    icon: "doc.text",
                    color: .green
                )
                
                QuickLinkButton(
                    title: "Contractions",
                    icon: "waveform.path.ecg",
                    color: .orange
                )
                
                QuickLinkButton(
                    title: "Resources",
                    icon: "book.fill",
                    color: .purple
                )
            }
        }
    }
}

struct QuickLinkButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
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