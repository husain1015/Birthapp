import SwiftUI

struct PrenatalPrepView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var selectedCategory: ExerciseCategory? = nil
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if selectedCategory == nil {
                    CategoryListView(selectedCategory: $selectedCategory)
                } else {
                    ExerciseListView(category: selectedCategory!, selectedCategory: $selectedCategory)
                }
            }
            .navigationTitle("Prenatal Prep")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct CategoryListView: View {
    @Binding var selectedCategory: ExerciseCategory?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                ForEach(ExerciseCategory.allCases, id: \.self) { category in
                    CategoryCard(category: category) {
                        selectedCategory = category
                    }
                }
            }
            .padding()
        }
    }
}

struct CategoryCard: View {
    let category: ExerciseCategory
    let action: () -> Void
    
    var categoryIcon: String {
        switch category {
        case .breathing: return "wind"
        case .pelvicFloor: return "figure.stand"
        case .core: return "figure.core.training"
        case .mobility: return "figure.flexibility"
        case .strength: return "figure.strengthtraining.traditional"
        case .laborPrep: return "heart.circle"
        case .relaxation: return "leaf"
        }
    }
    
    var categoryColor: Color {
        switch category {
        case .breathing: return .blue
        case .pelvicFloor: return .pink
        case .core: return .orange
        case .mobility: return .green
        case .strength: return .red
        case .laborPrep: return .purple
        case .relaxation: return .teal
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: categoryIcon)
                    .font(.largeTitle)
                    .foregroundColor(categoryColor)
                    .frame(width: 60)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(category.rawValue)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(categoryDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    var categoryDescription: String {
        switch category {
        case .breathing:
            return "Connect breath with pelvic floor movement"
        case .pelvicFloor:
            return "Strengthen and relax your pelvic floor muscles"
        case .core:
            return "Safe core exercises for pregnancy"
        case .mobility:
            return "Gentle stretches to ease discomfort"
        case .strength:
            return "Modified strength training for pregnancy"
        case .laborPrep:
            return "Positions and movements for labor"
        case .relaxation:
            return "Reduce stress and promote calm"
        }
    }
}

struct ExerciseListView: View {
    let category: ExerciseCategory
    @Binding var selectedCategory: ExerciseCategory?
    @State private var exercises: [Exercise] = []
    
    var body: some View {
        List {
            ForEach(exercises) { exercise in
                NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                    ExerciseRow(exercise: exercise)
                }
            }
        }
        .navigationBarItems(leading: Button("Back") {
            selectedCategory = nil
        })
        .onAppear {
            loadExercises()
        }
    }
    
    private func loadExercises() {
        let professional = ProfessionalCredential(
            name: "Dr. Sarah Johnson",
            title: "DPT, Pelvic Floor Specialist",
            certification: "APTA Certified",
            bio: "15 years experience in prenatal and postpartum care"
        )
        
        exercises = [
            Exercise(
                name: "Diaphragmatic Breathing",
                category: category,
                benefit: .pelvicFloorRelaxation,
                description: "Connect your breath with pelvic floor movement",
                instructions: [
                    "Lie comfortably with one hand on chest, one on belly",
                    "Inhale slowly through nose, allowing belly to rise",
                    "Exhale gently, feeling pelvic floor naturally lift",
                    "Repeat for 5-10 breaths"
                ],
                duration: 300,
                trimesterSuitability: [.first, .second, .third],
                createdBy: professional
            )
        ]
    }
}

struct ExerciseRow: View {
    let exercise: Exercise
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(exercise.name)
                    .font(.headline)
                
                HStack {
                    Label("\(Int(exercise.duration / 60)) min", systemImage: "clock")
                    
                    Text("•")
                    
                    Text(exercise.benefit.rawValue)
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if !exercise.trimesterSuitability.isEmpty {
                HStack(spacing: 4) {
                    ForEach(exercise.trimesterSuitability.indices, id: \.self) { index in
                        Text("\(index + 1)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                            .background(Color.pink)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct ExerciseDetailView: View {
    let exercise: Exercise
    @State private var isPlaying = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VideoPlaceholder()
                
                VStack(alignment: .leading, spacing: 15) {
                    Text(exercise.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    HStack {
                        Label("\(Int(exercise.duration / 60)) minutes", systemImage: "clock")
                        
                        Spacer()
                        
                        HStack {
                            ForEach(exercise.trimesterSuitability, id: \.self) { trimester in
                                Text(trimester.rawValue.prefix(6))
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.pink.opacity(0.2))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .font(.subheadline)
                    
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
                                    .foregroundColor(.pink)
                                
                                Text(instruction)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Created by")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(exercise.createdBy.name)
                            .font(.headline)
                        
                        Text(exercise.createdBy.title)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct VideoPlaceholder: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .aspectRatio(16/9, contentMode: .fit)
            
            Image(systemName: "play.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.white)
        }
    }
}