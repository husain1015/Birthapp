import SwiftUI

struct LaborPositionsGuideView: View {
    @State private var selectedCategory = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Category Picker
                Picker("Position Category", selection: $selectedCategory) {
                    Text("Labor Positions").tag(0)
                    Text("With Peanut Ball").tag(1)
                    Text("Birth Prep Exercises").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                switch selectedCategory {
                case 0:
                    LaborPositionsContent()
                case 1:
                    PeanutBallPositionsContent()
                case 2:
                    BirthPrepExercisesContent()
                default:
                    EmptyView()
                }
            }
        }
        .navigationTitle("Labor Positions Guide")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct LaborPositionsContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Positions to Facilitate Labor")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            PositionCard(
                title: "Walking",
                benefits: [
                    "Uses gravity to encourage descent",
                    "Helps encourage baby into a good position",
                    "Provides distraction",
                    "Helps increase comfort"
                ],
                icon: "figure.walk",
                color: .blue
            )
            
            PositionCard(
                title: "Squatting",
                benefits: [
                    "Uses gravity to encourage descent",
                    "May help rotate baby into delivery position",
                    "May help dilation",
                    "Allows freedom to shift weight for comfort"
                ],
                icon: "figure.stand",
                color: .green
            )
            
            PositionCard(
                title: "Lunging",
                benefits: [
                    "Helps open mid-pelvis",
                    "May help rotate baby into delivery position",
                    "Helps relieve back pressure",
                    "Can help if labor stalls"
                ],
                icon: "figure.walk.motion",
                color: .orange
            )
            
            PositionCard(
                title: "Swaying & Slow Dancing",
                benefits: [
                    "Moving your hips can help with comfort and allowing baby to descend",
                    "Provides distraction",
                    "Allows your partner to provide support"
                ],
                icon: "figure.2",
                color: .pink
            )
            
            PositionCard(
                title: "Kneeling on Hands & Knees",
                benefits: [
                    "May relieve pressure on your back",
                    "May help rotate baby into delivery position",
                    "Allows rocking hip motion",
                    "Allows support to provide massage, counterpressure, & heat or cold compress"
                ],
                icon: "figure.stand.line.dotted.figure",
                color: .purple
            )
            
            PositionCard(
                title: "Sitting",
                benefits: [
                    "Uses gravity to encourage descent",
                    "Good for resting",
                    "Allows support to provide massage or counterpressure",
                    "Sitting on a toilet can help relieve perineum muscles",
                    "Can encourage rhythmic movement"
                ],
                icon: "chair",
                color: .teal
            )
        }
        .padding(.bottom)
    }
}

struct PeanutBallPositionsContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Labor Positions With Peanut Ball")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            Text("The peanut ball can help open the pelvis and provide comfort during labor, especially with an epidural.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            PeanutBallPosition(
                title: "Side-Lying with Peanut Ball",
                description: "Place the peanut ball between your knees while lying on your side. This helps open the pelvis and can help baby descend.",
                icon: "bed.double"
            )
            
            PeanutBallPosition(
                title: "Semi-Reclined with Peanut Ball",
                description: "Sit up in bed with the peanut ball between your legs. This position uses gravity while maintaining comfort.",
                icon: "figure.seated.side"
            )
            
            PeanutBallPosition(
                title: "Asymmetric Position",
                description: "Place one leg over the peanut ball while keeping the other straight. This can help baby rotate and descend.",
                icon: "figure.stand.line.dotted.figure"
            )
            
            InfoBox(
                title: "Tip",
                message: "Change positions every 30-60 minutes to help labor progress and maintain comfort.",
                icon: "lightbulb",
                color: .yellow
            )
        }
        .padding(.bottom)
    }
}

struct BirthPrepExercisesContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Birth Prep Exercises")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            Text("These positions enable the lower part of your pelvis to open wider & help baby have room to move to the perineum & birth canal")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            BirthPrepExerciseCard(
                title: "Sitting On Birthing Ball",
                description: "Sit on the ball with feet flat on floor, hip-width apart. Rock gently or make figure-8 movements.",
                icon: "circle",
                color: .blue
            )
            
            BirthPrepExerciseCard(
                title: "Deep Squats with Partner Support",
                description: "Hold partner's hands for support. Lower into a deep squat, keeping back straight. Hold for 30-60 seconds.",
                icon: "figure.2",
                color: .green
            )
            
            BirthPrepExerciseCard(
                title: "Cat Cow, Child Pose",
                description: "Move between cat and cow poses to mobilize spine. Rest in child's pose between contractions.",
                icon: "figure.yoga",
                color: .purple
            )
            
            BirthPrepExerciseCard(
                title: "Butterfly Stretches",
                description: "Sit with soles of feet together, knees out. Gently press knees down to open hips.",
                icon: "figure.flexibility",
                color: .orange
            )
            
            BirthPrepExerciseCard(
                title: "Walking",
                description: "Regular walking helps baby engage in the pelvis and can help labor progress.",
                icon: "figure.walk",
                color: .pink
            )
        }
        .padding(.bottom)
    }
}

struct PositionCard: View {
    let title: String
    let benefits: [String]
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.1))
                    .cornerRadius(10)
                
                Text(title)
                    .font(.headline)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 5) {
                ForEach(benefits, id: \.self) { benefit in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .foregroundColor(color)
                        Text(benefit)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct PeanutBallPosition: View {
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(AppConstants.primaryColor)
                .frame(width: 40, height: 40)
                .background(AppConstants.primaryColor.opacity(0.1))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct BirthPrepExerciseCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct InfoBox: View {
    let title: String
    let message: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}