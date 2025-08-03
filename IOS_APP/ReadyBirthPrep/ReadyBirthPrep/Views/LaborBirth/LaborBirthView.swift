import SwiftUI

struct LaborBirthView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: BirthPlanBuilderView()) {
                    ModuleCard(
                        title: "Birth Plan Builder",
                        description: "Create your personalized birth preferences",
                        icon: "doc.text",
                        color: .green
                    )
                }
                
                NavigationLink(destination: ContractionTimerView()) {
                    ModuleCard(
                        title: "Contraction Timer",
                        description: "Track contraction frequency and duration",
                        icon: "waveform.path.ecg",
                        color: .orange
                    )
                }
                
                NavigationLink(destination: LaborPositionsView()) {
                    ModuleCard(
                        title: "Labor Positions",
                        description: "Visual guide for comfort during labor",
                        icon: "figure.walk",
                        color: .blue
                    )
                }
                
                NavigationLink(destination: ComfortMeasuresView()) {
                    ModuleCard(
                        title: "Comfort Measures",
                        description: "Breathing techniques and partner support",
                        icon: "heart.circle",
                        color: .pink
                    )
                }
                
                NavigationLink(destination: HospitalBagChecklistView()) {
                    ModuleCard(
                        title: "Hospital Bag Checklist",
                        description: "Everything you need for labor and recovery",
                        icon: "bag.fill",
                        color: .purple
                    )
                }
                
                NavigationLink(destination: PerinealCareView()) {
                    ModuleCard(
                        title: "Perineal Care",
                        description: "Tips to reduce tears and postpartum care",
                        icon: "heart.text.square",
                        color: .red
                    )
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Labor & Birth")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct ModuleCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}