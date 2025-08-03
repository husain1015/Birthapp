import SwiftUI

struct PerinealCareView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab Selection
            Picker("", selection: $selectedTab) {
                Text("During Labor").tag(0)
                Text("Postpartum Care").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            ScrollView {
                VStack(spacing: 20) {
                    if selectedTab == 0 {
                        DuringLaborContent()
                    } else {
                        PostpartumCareContent()
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Perineal Care")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct DuringLaborContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("How to Reduce Perineal Tears")
                .font(.title2)
                .fontWeight(.bold)
            
            InfoCard(
                title: "Keep Moving",
                description: "Stay mobile during labor if not on epidural. If using an epidural, utilize a peanut ball in sideline positions or sit up in bed upright to maintain movement.",
                icon: "figure.walk",
                color: .blue
            )
            
            InfoCard(
                title: "Breathing Techniques",
                description: "Avoid holding your breath during pushing. Remember to breathe out, especially during the pushing phase. It's okay to take breaks and push only when you feel ready.",
                icon: "wind",
                color: .teal
            )
            
            InfoCard(
                title: "Rest Periods",
                description: "Take sufficient rest between active phases of labor to ensure you are well-rested and prepared for the pushing phase.",
                icon: "bed.double",
                color: .purple
            )
            
            InfoCard(
                title: "Optimal Positions",
                description: "Use positions such as upright, quadruped, or sideline, depending on your comfort and epidural status. Utilize tools like bars for support, ensuring they are adjusted appropriately.",
                icon: "figure.stand",
                color: .orange
            )
            
            InfoCard(
                title: "Laboring Down",
                description: "Practice \"laboring down\" during the second stage of labor, allowing the baby's descent through the birth canal to occur naturally with minimal pushing effort. This technique conserves energy and may reduce the risk of perineal trauma.",
                icon: "arrow.down.circle",
                color: .green
            )
            
            InfoCard(
                title: "Laboring in Water",
                description: "If available and safe, consider laboring in a birthing pool or tub, as water immersion may help with pain relief and relaxation, potentially reducing the risk of tearing.",
                icon: "drop.fill",
                color: .blue
            )
            
            InfoCard(
                title: "Communication",
                description: "Maintain open communication with your healthcare team regarding your preferences, concerns, and any discomfort you may experience during labor.",
                icon: "bubble.left.and.bubble.right",
                color: .pink
            )
            
            InfoCard(
                title: "Position Changes",
                description: "Regularly change positions during labor to help encourage optimal fetal positioning and relieve pressure on the perineum.",
                icon: "arrow.triangle.2.circlepath",
                color: .indigo
            )
            
            InfoCard(
                title: "Perineal Support",
                description: "Your healthcare provider may offer perineal support techniques, such as applying counter-pressure or using warm compresses during the pushing phase, to help reduce the risk of tearing.",
                icon: "hand.raised",
                color: .red
            )
            
            InfoCard(
                title: "Gentle Pushing",
                description: "Practice gentle, controlled pushing techniques, focusing on the sensation and guidance from your body rather than forceful pushing.",
                icon: "arrow.right.circle",
                color: .mint
            )
            
            InfoCard(
                title: "Perineal Massage",
                description: "Consider practicing perineal massage during pregnancy to help prepare and potentially reduce the risk of tearing during labor.",
                icon: "hand.point.up.left",
                color: .brown
            )
        }
    }
}

struct PostpartumCareContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Postpartum Perineal Care")
                .font(.title2)
                .fontWeight(.bold)
            
            InfoCard(
                title: "Avoid Constipation",
                description: "Maintain regular bowel movements to avoid constipation, as straining during bowel movements can increase pressure on the perineum and contribute to the risk of tearing.",
                icon: "exclamationmark.triangle",
                color: .orange
            )
            
            InfoCard(
                title: "Use Squatty Potty",
                description: "Consider using a squatty potty or similar device to promote proper alignment and reduce straining during bowel movements, which can help prevent constipation and reduce pressure on the perineum.",
                icon: "chair",
                color: .green
            )
            
            InfoCard(
                title: "Postpartum Care",
                description: "After delivery, continue practicing good perineal hygiene and follow any postpartum care instructions provided by your healthcare provider to promote healing and reduce the risk of infection.",
                icon: "heart.circle",
                color: .pink
            )
            
            InfoCard(
                title: "Perineal Cooling",
                description: "Consider using cold packs or cooling pads on the perineum after delivery to help reduce swelling and discomfort.",
                icon: "snowflake",
                color: .blue
            )
            
            InfoCard(
                title: "Perineal Sprays or Soaks",
                description: "Use perineal sprays or sitz baths with warm water and soothing herbs, such as witch hazel or chamomile, to promote healing and comfort postpartum.",
                icon: "drop.triangle",
                color: .purple
            )
            
            // 4th Trimester Essentials Section
            Text("4th Trimester Essentials")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 30)
            
            EssentialItem(
                title: "Squatty Potty",
                description: "Decreases pressure on your pelvic floor while carrying out bowel movements",
                icon: "chair.lounge"
            )
            
            EssentialItem(
                title: "Sitz Bath",
                description: "Helps soothe and calm tender, aching perineal areas after birth, decreases perineal pain",
                icon: "bathtub"
            )
            
            EssentialItem(
                title: "Perineal Cold Packs",
                description: "Eases pain and swelling after childbirth and pain caused by hemorrhoids post delivery",
                icon: "snowflake"
            )
            
            EssentialItem(
                title: "Peri Wash Bottle",
                description: "Helps your perineum heal faster, feel better, and help prevent infection. Dilutes the stinging effect of urine on your sore or stitched perineum after vaginal birth.",
                icon: "drop"
            )
            
            EssentialItem(
                title: "Witch Hazel Pads",
                description: "Used to relieve itching, burning, and irritation caused post delivery around your perineal/rectal area",
                icon: "leaf"
            )
            
            EssentialItem(
                title: "C-Section Scar Massage",
                description: "Scar massaging cream helps minimize the appearance of scars and nourishes the skin. Please consult your healthcare provider for directions.",
                icon: "hand.raised"
            )
            
            EssentialItem(
                title: "Nipple Cream",
                description: "Eases pain and provides moisture to help heal or prevent dry, cracked, itchy, or bleeding nipples during the first few weeks of breastfeeding",
                icon: "drop.circle"
            )
            
            EssentialItem(
                title: "Foam Roller",
                description: "Can help ease discomfort, tightness and tension in your muscles postpartum by breaking up muscle adhesions and increasing range of motion",
                icon: "cylinder"
            )
            
            EssentialItem(
                title: "Postpartum Belts/Belly Wraps",
                description: "Help relieve postpartum pain, help muscles and incisions heal as well as helps with posture",
                icon: "bandage"
            )
            
            EssentialItem(
                title: "Heating Pad",
                description: "After birth pains are caused by contractions of your uterus as it returns to pre-pregnancy size. Using heating pad helps ease those cramps.",
                icon: "thermometer.sun"
            )
        }
    }
}

struct InfoCard: View {
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
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct EssentialItem: View {
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(AppConstants.primaryColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 5)
    }
}