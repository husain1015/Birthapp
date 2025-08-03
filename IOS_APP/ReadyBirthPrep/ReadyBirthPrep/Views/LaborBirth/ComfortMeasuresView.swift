import SwiftUI

struct ComfortMeasuresView: View {
    var body: some View {
        List {
            Section(header: Text("Breathing Techniques")) {
                NavigationLink(destination: BreathingTechniquesView()) {
                    ModuleCard(
                        title: "Labor Breathing",
                        description: "Breathing patterns for contractions",
                        icon: "wind",
                        color: .blue
                    )
                }
            }
            
            Section(header: Text("Partner Support")) {
                NavigationLink(destination: PartnerSupportView()) {
                    ModuleCard(
                        title: "Massage Techniques",
                        description: "Comfort touch and counter-pressure",
                        icon: "hands.sparkles",
                        color: .purple
                    )
                }
            }
            
            Section(header: Text("Affirmations")) {
                NavigationLink(destination: AffirmationsView()) {
                    ModuleCard(
                        title: "Birth Affirmations",
                        description: "Positive mantras for labor",
                        icon: "quote.bubble",
                        color: .pink
                    )
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Comfort Measures")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BreathingTechniquesView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                BreathingCard(
                    title: "Slow Breathing",
                    pattern: "In for 4, Out for 6",
                    description: "Use during early labor and between contractions",
                    instructions: [
                        "Inhale slowly through your nose for 4 counts",
                        "Exhale gently through your mouth for 6 counts",
                        "Focus on relaxing your jaw and shoulders",
                        "Continue throughout the contraction"
                    ]
                )
                
                BreathingCard(
                    title: "Light Breathing",
                    pattern: "Quick in, Quick out",
                    description: "For active labor when slow breathing no longer helps",
                    instructions: [
                        "Take quick, light breaths",
                        "Keep breathing shallow and rhythmic",
                        "Like blowing out birthday candles",
                        "Return to slow breathing between contractions"
                    ]
                )
                
                BreathingCard(
                    title: "Transition Breathing",
                    pattern: "Pant-Pant-Blow",
                    description: "For transition phase or urge to push too early",
                    instructions: [
                        "Take two short pants",
                        "Follow with a longer blow",
                        "Repeat: pant-pant-blow",
                        "Helps resist the urge to push"
                    ]
                )
            }
            .padding()
        }
        .navigationTitle("Breathing Techniques")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BreathingCard: View {
    let title: String
    let pattern: String
    let description: String
    let instructions: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                
                Text(pattern)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.pink)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Instructions:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                ForEach(Array(instructions.enumerated()), id: \.offset) { index, instruction in
                    HStack(alignment: .top, spacing: 10) {
                        Text("\(index + 1).")
                            .fontWeight(.bold)
                            .foregroundColor(.pink)
                        
                        Text(instruction)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct PartnerSupportView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Partner support can make a significant difference during labor. Here are techniques your partner can use to help you.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                TechniqueCard(
                    title: "Lower Back Counter-Pressure",
                    description: "Relieves back labor pain",
                    steps: [
                        "Partner places palms on your lower back",
                        "Apply firm, steady pressure during contractions",
                        "Release pressure between contractions",
                        "Adjust position based on your feedback"
                    ]
                )
                
                TechniqueCard(
                    title: "Hip Squeeze",
                    description: "Opens pelvis and relieves pressure",
                    steps: [
                        "You lean forward (on ball or bed)",
                        "Partner places hands on hip bones",
                        "Squeeze hips together and slightly up",
                        "Hold during contraction, release after"
                    ]
                )
                
                TechniqueCard(
                    title: "Light Touch Massage",
                    description: "Promotes relaxation between contractions",
                    steps: [
                        "Use fingertips for light strokes",
                        "Focus on arms, shoulders, and scalp",
                        "Keep movements slow and rhythmic",
                        "Stop during contractions if preferred"
                    ]
                )
            }
            .padding()
        }
        .navigationTitle("Partner Support")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TechniqueCard: View {
    let title: String
    let description: String
    let steps: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(Color.purple)
                            .frame(width: 6, height: 6)
                            .offset(y: 6)
                        
                        Text(step)
                            .font(.subheadline)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct AffirmationsView: View {
    let affirmations = [
        "My body knows how to birth my baby",
        "Each contraction brings me closer to meeting my baby",
        "I am strong and capable",
        "I trust my body and my baby",
        "I can do hard things",
        "My body is perfectly designed for this",
        "I am surrounded by love and support",
        "I breathe in peace, I breathe out tension",
        "My baby and I are working together",
        "This is temporary, my baby is forever"
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                Text("Positive affirmations can help maintain focus and confidence during labor. Choose ones that resonate with you.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                ForEach(affirmations, id: \.self) { affirmation in
                    AffirmationCard(text: affirmation)
                }
            }
            .padding()
        }
        .navigationTitle("Birth Affirmations")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AffirmationCard: View {
    let text: String
    @State private var isFavorite = false
    
    var body: some View {
        HStack {
            Text(text)
                .font(.body)
                .fontWeight(.medium)
                .multilineTextAlignment(.leading)
                .padding(.trailing, 10)
            
            Spacer()
            
            Button(action: { isFavorite.toggle() }) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(isFavorite ? .pink : .gray)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}