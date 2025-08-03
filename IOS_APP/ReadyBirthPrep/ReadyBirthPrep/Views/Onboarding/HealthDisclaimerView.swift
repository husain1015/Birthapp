import SwiftUI

struct HealthDisclaimerView: View {
    @State private var hasReadDisclaimer = false
    @State private var acknowledgesRisks = false
    @State private var willConsultProvider = false
    
    var allChecked: Bool {
        hasReadDisclaimer && acknowledgesRisks && willConsultProvider
    }
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 10) {
                Image(systemName: "exclamationmark.shield.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                
                Text("Important Health & Safety Information")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    DisclaimerSection(
                        title: "Medical Disclaimer",
                        content: """
                        ReadyBirth Prep is designed to provide educational content and exercise guidance for pregnancy and postpartum recovery. This app is NOT a substitute for professional medical advice, diagnosis, or treatment.
                        
                        Always seek the advice of your qualified healthcare provider with any questions you may have regarding your medical condition. Never disregard professional medical advice or delay in seeking it because of something you have read or seen in this app.
                        """
                    )
                    
                    DisclaimerSection(
                        title: "Exercise Safety",
                        content: """
                        Before beginning any exercise program during pregnancy or postpartum, you must consult with your healthcare provider or a pelvic floor physical therapist. Every pregnancy is unique, and what is safe for one person may not be safe for another.
                        
                        Stop exercising immediately and contact your healthcare provider if you experience:
                        • Vaginal bleeding
                        • Dizziness or feeling faint
                        • Chest pain or difficulty breathing
                        • Calf pain or swelling
                        • Decreased fetal movement
                        • Fluid leaking from the vagina
                        • Contractions or abdominal pain
                        """
                    )
                    
                    DisclaimerSection(
                        title: "Professional Guidance",
                        content: """
                        All exercise content in this app has been developed and vetted by certified professionals including Pelvic Floor Physical Therapists, Certified Prenatal/Postnatal Fitness Instructors, and Doulas. However, this does not replace individualized assessment and guidance from your own healthcare team.
                        """
                    )
                }
                .padding(.horizontal)
            }
            
            VStack(spacing: 15) {
                CheckboxRow(isChecked: $hasReadDisclaimer, text: "I have read and understood this disclaimer")
                CheckboxRow(isChecked: $acknowledgesRisks, text: "I acknowledge the risks of exercising during pregnancy")
                CheckboxRow(isChecked: $willConsultProvider, text: "I will consult my healthcare provider before starting")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding(.horizontal)
            
            if allChecked {
                Text("Swipe to continue →")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
            }
            
            Spacer()
        }
    }
}

struct DisclaimerSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct CheckboxRow: View {
    @Binding var isChecked: Bool
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Button(action: { isChecked.toggle() }) {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .font(.title2)
                    .foregroundColor(isChecked ? .pink : .gray)
            }
            
            Text(text)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
    }
}