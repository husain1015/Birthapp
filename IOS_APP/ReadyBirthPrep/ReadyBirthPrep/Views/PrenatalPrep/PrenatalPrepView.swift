import SwiftUI
import WebKit

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
            name: "Dr. Jennifer Vohra",
            title: "DPT, Pelvic Floor Specialist",
            certification: "APTA Certified",
            bio: "Bloom Pelvic Health & Wellness - Expert in prenatal and postpartum care"
        )
        
        let professional2 = ProfessionalCredential(
            name: "Dr. Jennifer Vohra",
            title: "DPT, Prenatal Fitness Specialist",
            certification: "Bloom Pelvic Health & Wellness",
            bio: "Expert in prenatal fitness and pelvic health"
        )
        
        switch category {
        case .breathing:
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
                    createdBy: professional,
                    videoURL: "https://www.youtube.com/embed/vF6oQugtJcQ",
                    thumbnailURL: "https://images.unsplash.com/photo-1518611012118-696072aa579a?w=400"
                ),
                Exercise(
                    name: "360° Breathing",
                    category: category,
                    benefit: .coreStability,
                    description: "Expand breath in all directions for core support",
                    instructions: [
                        "Sit or lie comfortably with hands on lower ribs",
                        "Inhale, feeling ribs expand outward and back",
                        "Exhale slowly, allowing ribs to gently close",
                        "Focus on expansion in all directions",
                        "Practice for 5-10 breaths"
                    ],
                    duration: 300,
                    trimesterSuitability: [.first, .second, .third],
                    createdBy: professional,
                    videoURL: "https://www.youtube.com/embed/Db_xATnfO0M",
                    thumbnailURL: "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400"
                )
            ]
        case .pelvicFloor:
            exercises = [
                Exercise(
                    name: "Pelvic Floor Activation",
                    category: category,
                    benefit: .pelvicFloorStrength,
                    description: "Gentle activation and release of pelvic floor muscles",
                    instructions: [
                        "Sit comfortably or lie on your side",
                        "Inhale to relax pelvic floor completely",
                        "Exhale and gently lift pelvic floor muscles",
                        "Think of picking up a blueberry with your vagina",
                        "Release completely on next inhale",
                        "Repeat 10 times"
                    ],
                    duration: 600,
                    trimesterSuitability: [.first, .second, .third],
                    createdBy: professional,
                    videoURL: "https://www.youtube.com/embed/n0wqH-NJXhY",
                    thumbnailURL: "https://images.unsplash.com/photo-1588286840104-8957b019727f?w=400"
                ),
                Exercise(
                    name: "Transverse Abdominis Connection",
                    category: category,
                    benefit: .coreStability,
                    description: "Connect deep core with pelvic floor",
                    instructions: [
                        "Lie on side with knees bent",
                        "Place hand on lower belly",
                        "Inhale to prepare",
                        "Exhale and gently draw belly button toward spine",
                        "Feel gentle tension under your hand",
                        "Hold for 3-5 seconds, then release"
                    ],
                    duration: 480,
                    trimesterSuitability: [.first, .second, .third],
                    createdBy: professional
                )
            ]
        case .core:
            exercises = [
                Exercise(
                    name: "Modified Bird Dog",
                    category: category,
                    benefit: .coreStability,
                    description: "Safe core strengthening for pregnancy",
                    instructions: [
                        "Start on hands and knees, wrists under shoulders",
                        "Keep spine neutral",
                        "Extend right arm forward",
                        "Hold for 5 seconds",
                        "Return to start and switch sides",
                        "Progress to opposite arm and leg when ready"
                    ],
                    duration: 600,
                    trimesterSuitability: [.first, .second],
                    createdBy: professional2,
                    videoURL: "https://www.youtube.com/embed/wiFNA3sqjCA",
                    thumbnailURL: "https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=400"
                ),
                Exercise(
                    name: "Side-Lying Leg Lifts",
                    category: category,
                    benefit: .hipStability,
                    description: "Strengthen core and hips safely",
                    instructions: [
                        "Lie on left side with head supported",
                        "Bend bottom knee for stability",
                        "Keep top leg straight",
                        "Slowly lift top leg up",
                        "Lower with control",
                        "Perform 10-15 reps each side"
                    ],
                    duration: 600,
                    trimesterSuitability: [.first, .second, .third],
                    createdBy: professional2
                )
            ]
        case .mobility:
            exercises = [
                Exercise(
                    name: "Cat-Cow Stretch",
                    category: category,
                    benefit: .painRelief,
                    description: "Gentle spinal mobility for comfort",
                    instructions: [
                        "Start on hands and knees",
                        "Inhale, arch back gently (cow)",
                        "Exhale, round spine up (cat)",
                        "Move slowly and smoothly",
                        "Repeat 8-10 times"
                    ],
                    duration: 300,
                    trimesterSuitability: [.first, .second, .third],
                    createdBy: professional2,
                    videoURL: "https://www.youtube.com/embed/KpNznspZZEY",
                    thumbnailURL: "https://images.unsplash.com/photo-1599901860904-17e6ed7083a0?w=400"
                ),
                Exercise(
                    name: "Hip Circles",
                    category: category,
                    benefit: .hipMobility,
                    description: "Release tension and prepare hips for birth",
                    instructions: [
                        "Stand with feet hip-width apart",
                        "Place hands on hips",
                        "Circle hips clockwise 10 times",
                        "Circle counterclockwise 10 times",
                        "Keep movements smooth and controlled"
                    ],
                    duration: 300,
                    trimesterSuitability: [.first, .second, .third],
                    createdBy: professional
                )
            ]
        case .strength:
            exercises = [
                Exercise(
                    name: "Wall Squats",
                    category: category,
                    benefit: .functionalStrength,
                    description: "Build leg strength for labor",
                    instructions: [
                        "Stand with back against wall",
                        "Walk feet out about 2 feet",
                        "Slide down wall into squat",
                        "Hold for 5-10 seconds",
                        "Slide back up",
                        "Repeat 10-15 times"
                    ],
                    duration: 600,
                    trimesterSuitability: [.first, .second],
                    createdBy: professional2
                ),
                Exercise(
                    name: "Modified Plank",
                    category: category,
                    benefit: .coreStability,
                    description: "Safe plank variation for pregnancy",
                    instructions: [
                        "Start on hands and knees",
                        "Walk hands forward slightly",
                        "Keep hips in line with shoulders",
                        "Hold for 15-30 seconds",
                        "Rest and repeat 3 times"
                    ],
                    duration: 480,
                    trimesterSuitability: [.first, .second],
                    createdBy: professional2
                )
            ]
        case .laborPrep:
            exercises = [
                Exercise(
                    name: "Birth Ball Hip Circles",
                    category: category,
                    benefit: .laborPreparation,
                    description: "Practice movements for active labor",
                    instructions: [
                        "Sit on birth ball with feet flat on floor",
                        "Circle hips clockwise 10 times",
                        "Circle counterclockwise 10 times",
                        "Try figure-8 movements",
                        "Practice daily in third trimester"
                    ],
                    duration: 600,
                    trimesterSuitability: [.second, .third],
                    createdBy: professional
                ),
                Exercise(
                    name: "Supported Squat Practice",
                    category: category,
                    benefit: .laborPreparation,
                    description: "Build endurance for birthing positions",
                    instructions: [
                        "Stand facing partner or wall",
                        "Hold hands or place hands on wall",
                        "Lower into comfortable squat",
                        "Hold for 30-60 seconds",
                        "Stand and rest",
                        "Repeat 5 times"
                    ],
                    duration: 600,
                    trimesterSuitability: [.second, .third],
                    createdBy: professional
                )
            ]
        case .relaxation:
            exercises = [
                Exercise(
                    name: "Progressive Muscle Relaxation",
                    category: category,
                    benefit: .stressReduction,
                    description: "Release tension throughout the body",
                    instructions: [
                        "Lie comfortably on left side",
                        "Tense feet for 5 seconds, then release",
                        "Move up through calves, thighs, glutes",
                        "Continue through arms and shoulders",
                        "End with facial muscles",
                        "Rest in complete relaxation"
                    ],
                    duration: 900,
                    trimesterSuitability: [.first, .second, .third],
                    createdBy: professional
                ),
                Exercise(
                    name: "Visualization for Birth",
                    category: category,
                    benefit: .mentalPreparation,
                    description: "Mental preparation for labor",
                    instructions: [
                        "Find comfortable position",
                        "Close eyes and breathe deeply",
                        "Visualize your ideal birth environment",
                        "Imagine waves of contractions as ocean waves",
                        "Picture meeting your baby",
                        "Practice daily in third trimester"
                    ],
                    duration: 600,
                    trimesterSuitability: [.second, .third],
                    createdBy: professional
                )
            ]
        }
    }
}

struct ExerciseRow: View {
    let exercise: Exercise
    
    var body: some View {
        HStack(spacing: 12) {
            if let thumbnailURL = exercise.thumbnailURL, let url = URL(string: thumbnailURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                }
            }
            
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
                VideoPlaceholder(videoURL: exercise.videoURL, thumbnailURL: exercise.thumbnailURL)
                
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
    let videoURL: String?
    let thumbnailURL: String?
    @State private var showingVideo = false
    
    var body: some View {
        ZStack {
            if let thumbnailURL = thumbnailURL, let url = URL(string: thumbnailURL) {
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
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
            }
            
            Button(action: {
                if videoURL != nil {
                    showingVideo = true
                }
            }) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
            }
        }
        .aspectRatio(16/9, contentMode: .fit)
        .cornerRadius(12)
        .sheet(isPresented: $showingVideo) {
            if let videoURL = videoURL {
                VideoPlayerView(videoURL: videoURL)
            }
        }
    }
}

struct VideoPlayerView: View {
    let videoURL: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                if let url = URL(string: videoURL) {
                    WebView(url: url)
                } else {
                    Text("Unable to load video")
                        .foregroundColor(.secondary)
                }
            }
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}