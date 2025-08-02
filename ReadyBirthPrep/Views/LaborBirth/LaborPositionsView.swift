import SwiftUI

struct LaborPositionsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(LaborPosition.allCases, id: \.self) { position in
                    PositionCard(position: position)
                }
            }
            .padding()
        }
        .navigationTitle("Labor Positions")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PositionCard: View {
    let position: LaborPosition
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: positionIcon)
                    .font(.title2)
                    .foregroundColor(.pink)
                
                Text(position.rawValue)
                    .font(.headline)
                
                Spacer()
            }
            
            Text(positionDescription)
                .font(.body)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Benefits:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                ForEach(positionBenefits, id: \.self) { benefit in
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(Color.pink)
                            .frame(width: 6, height: 6)
                            .offset(y: 6)
                        
                        Text(benefit)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var positionIcon: String {
        switch position {
        case .standing: return "figure.walk"
        case .handsKnees: return "figure.stand.line.dotted.figure.stand"
        case .birtingBall: return "circle"
        case .squatting: return "figure.stand"
        case .sideLying: return "person.fill.turn.right"
        case .semiReclined: return "person.fill.turn.down"
        case .waterBirth: return "drop.circle"
        }
    }
    
    private var positionDescription: String {
        switch position {
        case .standing:
            return "Walking and standing help use gravity to encourage baby's descent."
        case .handsKnees:
            return "This position can help relieve back pain and encourage baby to rotate."
        case .birtingBall:
            return "Sitting or leaning on a birthing ball promotes pelvic mobility."
        case .squatting:
            return "Squatting opens the pelvis and uses gravity effectively."
        case .sideLying:
            return "Side-lying can provide rest while maintaining progress."
        case .semiReclined:
            return "Semi-reclined position allows for rest with some gravity assistance."
        case .waterBirth:
            return "Water immersion can provide pain relief and relaxation."
        }
    }
    
    private var positionBenefits: [String] {
        switch position {
        case .standing:
            return ["Uses gravity", "Encourages descent", "Can shorten labor"]
        case .handsKnees:
            return ["Relieves back pressure", "Helps baby rotate", "Opens pelvis"]
        case .birtingBall:
            return ["Promotes movement", "Comfortable support", "Encourages opening"]
        case .squatting:
            return ["Opens pelvis 30% more", "Uses gravity", "May speed delivery"]
        case .sideLying:
            return ["Allows rest", "Good for epidural", "Reduces tearing risk"]
        case .semiReclined:
            return ["Comfortable", "Good visibility", "Easy monitoring"]
        case .waterBirth:
            return ["Natural pain relief", "Promotes relaxation", "Gentle for baby"]
        }
    }
}