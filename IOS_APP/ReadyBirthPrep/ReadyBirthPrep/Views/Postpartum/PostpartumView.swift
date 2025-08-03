import SwiftUI

struct PostpartumView: View {
    @State private var currentPhase: RecoveryPhase = .phase1
    @State private var hasMedicalClearance = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    PhaseSelector(currentPhase: $currentPhase, hasMedicalClearance: hasMedicalClearance)
                    
                    PhaseInfoCard(phase: currentPhase)
                    
                    if currentPhase == .phase3 && !hasMedicalClearance {
                        MedicalClearanceCard(hasClearance: $hasMedicalClearance)
                    } else {
                        PhaseContentView(phase: currentPhase)
                    }
                }
                .padding()
            }
            .navigationTitle("Postpartum Recovery")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct PhaseSelector: View {
    @Binding var currentPhase: RecoveryPhase
    let hasMedicalClearance: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Recovery Phase")
                .font(.headline)
            
            Picker("Phase", selection: $currentPhase) {
                ForEach(RecoveryPhase.allCases, id: \.self) { phase in
                    Text(phase.rawValue).tag(phase)
                        .disabled(phase == .phase3 && !hasMedicalClearance)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
}

struct PhaseInfoCard: View {
    let phase: RecoveryPhase
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: phaseIcon)
                    .font(.title2)
                    .foregroundColor(.pink)
                
                Text(phase.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            if phase == .phase1 {
                WarningCard(
                    title: "Important",
                    message: "Focus on rest and recovery. No strenuous exercise.",
                    icon: "exclamationmark.triangle.fill",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var phaseIcon: String {
        switch phase {
        case .phase1: return "bed.double.fill"
        case .phase2: return "figure.walk"
        case .phase3: return "figure.strengthtraining.functional"
        }
    }
}

struct MedicalClearanceCard: View {
    @Binding var hasClearance: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "stethoscope")
                .font(.largeTitle)
                .foregroundColor(.blue)
            
            Text("Medical Clearance Required")
                .font(.headline)
            
            Text("Phase 3 exercises require clearance from your healthcare provider (typically at 6-week postpartum visit).")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: { hasClearance = true }) {
                Text("I have medical clearance")
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct PhaseContentView: View {
    let phase: RecoveryPhase
    
    var body: some View {
        VStack(spacing: 15) {
            switch phase {
            case .phase1:
                Phase1Content()
            case .phase2:
                Phase2Content()
            case .phase3:
                Phase3Content()
            }
        }
    }
}

struct Phase1Content: View {
    var body: some View {
        VStack(spacing: 15) {
            ExerciseCard(
                title: "360° Breathing",
                description: "Gentle breathing to reconnect with your core",
                duration: "5 minutes",
                difficulty: .beginner
            )
            
            ExerciseCard(
                title: "Pelvic Floor Awareness",
                description: "Gentle activation and release",
                duration: "5 minutes",
                difficulty: .beginner
            )
            
            ExerciseCard(
                title: "Ankle Pumps",
                description: "Improve circulation while resting",
                duration: "2 minutes",
                difficulty: .beginner
            )
            
            SymptomCheckerCard()
        }
    }
}

struct Phase2Content: View {
    var body: some View {
        VStack(spacing: 15) {
            ExerciseCard(
                title: "Transverse Abdominis Activation",
                description: "Gentle core reconnection",
                duration: "10 minutes",
                difficulty: .beginner
            )
            
            ExerciseCard(
                title: "Pelvic Tilts",
                description: "Mobilize spine and pelvis",
                duration: "5 minutes",
                difficulty: .beginner
            )
            
            ExerciseCard(
                title: "Walking Program",
                description: "Start with 5-10 minute walks",
                duration: "10 minutes",
                difficulty: .beginner
            )
            
            ExerciseCard(
                title: "Posture Awareness",
                description: "Carrying and feeding positions",
                duration: "Throughout day",
                difficulty: .beginner
            )
        }
    }
}

struct Phase3Content: View {
    var body: some View {
        VStack(spacing: 15) {
            ExerciseCard(
                title: "Progressive Core Program",
                description: "Rebuild core strength safely",
                duration: "20 minutes",
                difficulty: .intermediate
            )
            
            ExerciseCard(
                title: "Functional Movements",
                description: "Squats, lunges with proper form",
                duration: "15 minutes",
                difficulty: .intermediate
            )
            
            ExerciseCard(
                title: "Diastasis Recti Safe Exercises",
                description: "Modified planks and core work",
                duration: "15 minutes",
                difficulty: .intermediate
            )
            
            ExerciseCard(
                title: "Cardio Progression",
                description: "Low-impact cardio options",
                duration: "20-30 minutes",
                difficulty: .intermediate
            )
        }
    }
}

struct ExerciseCard: View {
    let title: String
    let description: String
    let duration: String
    let difficulty: RoutineDifficulty
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: { showingDetail = true }) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Label(duration, systemImage: "clock")
                        
                        Text("•")
                        
                        Text(difficulty.rawValue)
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 2)
        }
        .sheet(isPresented: $showingDetail) {
            PostpartumExerciseDetailView(
                title: title,
                description: description,
                duration: duration,
                difficulty: difficulty
            )
        }
    }
}

struct SymptomCheckerCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "exclamationmark.shield.fill")
                    .foregroundColor(.red)
                
                Text("When to Contact Your Doctor")
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                SymptomRow(symptom: "Heavy bleeding (soaking pad in 1 hour)")
                SymptomRow(symptom: "Fever over 100.4°F (38°C)")
                SymptomRow(symptom: "Foul-smelling discharge")
                SymptomRow(symptom: "Severe abdominal pain")
                SymptomRow(symptom: "Signs of infection at incision site")
                SymptomRow(symptom: "Difficulty breathing or chest pain")
            }
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
    }
}

struct SymptomRow: View {
    let symptom: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Color.red)
                .frame(width: 6, height: 6)
                .offset(y: 6)
            
            Text(symptom)
                .font(.subheadline)
        }
    }
}

struct WarningCard: View {
    let title: String
    let message: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                
                Text(message)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(10)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct PostpartumExerciseDetailView: View {
    let title: String
    let description: String
    let duration: String
    let difficulty: RoutineDifficulty
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        HStack {
                            Label(duration, systemImage: "clock")
                            
                            Text("•")
                            
                            Text(difficulty.rawValue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(difficultyColor.opacity(0.2))
                                .foregroundColor(difficultyColor)
                                .cornerRadius(8)
                        }
                        .font(.subheadline)
                        
                        Text(description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Instructions")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(getInstructions(), id: \.self) { instruction in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.pink)
                                    .font(.caption)
                                
                                Text(instruction)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Important Notes")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        WarningCard(
                            title: "Listen to Your Body",
                            message: "Stop if you experience pain, bleeding, or discomfort",
                            icon: "exclamationmark.triangle.fill",
                            color: .orange
                        )
                        .padding(.horizontal)
                        
                        if difficulty == .intermediate {
                            WarningCard(
                                title: "Medical Clearance",
                                message: "Ensure you have medical clearance before starting Phase 3 exercises",
                                icon: "stethoscope",
                                color: .blue
                            )
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
            }
            .navigationBarTitle("Exercise Details", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private var difficultyColor: Color {
        switch difficulty {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
    
    private func getInstructions() -> [String] {
        switch title {
        case "360° Breathing":
            return [
                "Find a comfortable position lying on your side or sitting",
                "Place one hand on your chest and one on your belly",
                "Breathe in slowly through your nose for 4 counts",
                "Feel your ribs expand in all directions",
                "Exhale slowly through your mouth for 6 counts",
                "Repeat for 5 minutes"
            ]
        case "Pelvic Floor Awareness":
            return [
                "Lie on your side with a pillow between your knees",
                "Breathe normally and relax your body",
                "On exhale, gently lift your pelvic floor muscles",
                "Imagine lifting a marble with your vagina",
                "Hold for 3 seconds, then slowly release",
                "Rest for 6 seconds between repetitions"
            ]
        case "Transverse Abdominis Activation":
            return [
                "Lie on your back with knees bent",
                "Place hands on lower belly",
                "Inhale to prepare",
                "Exhale and gently draw belly button toward spine",
                "Maintain normal breathing while holding",
                "Release slowly and repeat"
            ]
        case "Progressive Core Program":
            return [
                "Start with basic breathing exercises",
                "Progress to gentle core activation",
                "Add movement patterns as strength improves",
                "Focus on quality over quantity",
                "Stop if doming occurs in abdomen",
                "Build up gradually over weeks"
            ]
        default:
            return [
                "Follow the guidance of your healthcare provider",
                "Start slowly and progress gradually",
                "Focus on proper form and breathing",
                "Stop if you experience any pain or discomfort",
                "Stay hydrated throughout exercise",
                "Rest as needed between repetitions"
            ]
        }
    }
}