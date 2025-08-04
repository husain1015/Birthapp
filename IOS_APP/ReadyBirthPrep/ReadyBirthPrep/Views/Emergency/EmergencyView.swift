import SwiftUI
import MapKit

struct EmergencyView: View {
    @StateObject private var emergencyManager: EmergencyManager
    @State private var showingSettings = false
    @State private var showingContractionTimer = false
    @State private var showingLaborSigns = false
    @State private var showingWarningSignsGuide = false
    @State private var refreshID = UUID()
    
    init(userId: UUID) {
        _emergencyManager = StateObject(wrappedValue: EmergencyManager(userId: userId))
    }
    
    var activeQuickAccessItems: [QuickAccessItem] {
        emergencyManager.emergencyInfo.quickAccessItems.filter { $0.isEnabled }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Emergency Banner
                    if emergencyManager.quickContractionTimer.pattern == .timeToGo {
                        EmergencyBanner(
                            title: "Time to Call Your Provider",
                            message: "Contractions meet the 5-1-1 rule",
                            action: {
                                let phone = emergencyManager.emergencyInfo.medicalInfo.obProviderPhone
                                if !phone.isEmpty,
                                   let url = URL(string: "tel://\(phone.replacingOccurrences(of: " ", with: ""))") {
                                    UIApplication.shared.open(url)
                                }
                            }
                        )
                        .padding(.horizontal)
                    }
                    
                    // Quick Actions Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(activeQuickAccessItems) { item in
                            QuickAccessButton(
                                item: item,
                                emergencyManager: emergencyManager,
                                onTap: {
                                    handleQuickAccess(item)
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Contraction Summary
                    if !emergencyManager.quickContractionTimer.contractions.isEmpty {
                        ContractionSummaryCard(timer: emergencyManager.quickContractionTimer)
                            .padding(.horizontal)
                            .onTapGesture {
                                showingContractionTimer = true
                            }
                    }
                    
                    // Active Labor Signs
                    let activeSigns = emergencyManager.getActiveLaborSigns()
                    if !activeSigns.isEmpty {
                        ActiveLaborSignsCard(signs: activeSigns)
                            .padding(.horizontal)
                    }
                    
                    // Hospital Info Card
                    if let hospital = emergencyManager.emergencyInfo.hospitalInfo {
                        HospitalInfoCard(
                            hospital: hospital,
                            onCall: emergencyManager.callHospital,
                            onDirections: emergencyManager.getDirectionsToHospital
                        )
                        .padding(.horizontal)
                    } else {
                        Button(action: { showingSettings = true }) {
                            HStack {
                                Image(systemName: "building.2")
                                    .font(.title2)
                                VStack(alignment: .leading) {
                                    Text("Add Hospital Information")
                                        .font(.headline)
                                    Text("Quick access to directions and contact")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                        }
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    }
                    
                    // Emergency Contacts
                    if !emergencyManager.emergencyInfo.emergencyContacts.isEmpty {
                        EmergencyContactsCard(contacts: emergencyManager.emergencyInfo.emergencyContacts)
                            .padding(.horizontal)
                    }
                    
                    // Warning Signs Reference
                    Button(action: { showingWarningSignsGuide = true }) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.title2)
                                .foregroundColor(.red)
                            VStack(alignment: .leading) {
                                Text("Emergency Warning Signs")
                                    .font(.headline)
                                Text("Know when to seek immediate help")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Emergency Hub")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                EmergencySettingsView(emergencyManager: emergencyManager)
            }
            .sheet(isPresented: $showingContractionTimer) {
                ContractionTimerFullView(timer: emergencyManager.quickContractionTimer)
            }
            .sheet(isPresented: $showingLaborSigns) {
                LaborSignsChecklistView(emergencyManager: emergencyManager)
            }
            .sheet(isPresented: $showingWarningSignsGuide) {
                WarningSignsGuideView()
            }
        }
        .id(refreshID)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            refreshID = UUID()
        }
    }
    
    private func handleQuickAccess(_ item: QuickAccessItem) {
        switch item.type {
        case .contractionTimer:
            showingContractionTimer = true
        case .callHospital:
            emergencyManager.callHospital()
        case .callProvider:
            let phone = emergencyManager.emergencyInfo.medicalInfo.obProviderPhone
            if !phone.isEmpty,
               let url = URL(string: "tel://\(phone.replacingOccurrences(of: " ", with: ""))") {
                UIApplication.shared.open(url)
            }
        case .hospitalDirections:
            emergencyManager.getDirectionsToHospital()
        case .laborSigns:
            showingLaborSigns = true
        case .emergencyContacts:
            // Show contacts
            break
        case .hospitalBag:
            // Navigate to hospital bag checklist
            break
        case .birthPlan:
            // Show birth plan
            break
        case .insurance:
            // Show insurance info
            break
        case .custom:
            // Handle custom action
            break
        }
    }
}

// MARK: - Emergency Banner

struct EmergencyBanner: View {
    let title: String
    let message: String
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    Text(message)
                        .font(.subheadline)
                }
                Spacer()
            }
            .foregroundColor(.white)
            
            Button(action: action) {
                Text("Call Now")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.red)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.red)
        .cornerRadius(12)
    }
}

// MARK: - Quick Access Button

struct QuickAccessButton: View {
    let item: QuickAccessItem
    let emergencyManager: EmergencyManager
    let onTap: () -> Void
    
    var isActive: Bool {
        switch item.type {
        case .contractionTimer:
            return emergencyManager.quickContractionTimer.isTimingContraction
        default:
            return false
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color(item.type.defaultColor).opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: item.type.icon)
                        .font(.title2)
                        .foregroundColor(Color(item.type.defaultColor))
                    
                    if isActive {
                        Circle()
                            .stroke(Color(item.type.defaultColor), lineWidth: 3)
                            .frame(width: 60, height: 60)
                            .scaleEffect(1.1)
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isActive)
                    }
                }
                
                Text(item.customLabel ?? item.type.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .foregroundColor(.primary)
    }
}

// MARK: - Contraction Summary Card

struct ContractionSummaryCard: View {
    @ObservedObject var timer: QuickContractionTimer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Contraction Pattern", systemImage: "waveform.path.ecg")
                    .font(.headline)
                
                Spacer()
                
                Text(timer.pattern.description)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color(timer.pattern.color).opacity(0.2))
                    .foregroundColor(Color(timer.pattern.color))
                    .cornerRadius(20)
            }
            
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Count")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(timer.contractions.count)")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                VStack(alignment: .leading) {
                    Text("Avg Duration")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Int(timer.averageDuration))s")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                VStack(alignment: .leading) {
                    Text("Avg Interval")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Int(timer.averageInterval / 60))m")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Active Labor Signs Card

struct ActiveLaborSignsCard: View {
    let signs: [LaborSign]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Active Labor Signs", systemImage: "checkmark.circle.fill")
                .font(.headline)
                .foregroundColor(.green)
            
            ForEach(signs, id: \.name) { sign in
                HStack {
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                        .frame(width: 20)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(sign.name)
                            .font(.subheadline)
                        
                        if let startTime = sign.startTime {
                            Text("Started \(startTime, style: .relative) ago")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Hospital Info Card

struct HospitalInfoCard: View {
    let hospital: HospitalInfo
    let onCall: () -> Void
    let onDirections: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "building.2")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(hospital.name)
                        .font(.headline)
                    Text(hospital.address)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                Button(action: onCall) {
                    Label("Call", systemImage: "phone.fill")
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: onDirections) {
                    Label("Directions", systemImage: "map.fill")
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            
            if let parking = hospital.parkingInfo {
                HStack {
                    Image(systemName: "car.fill")
                        .foregroundColor(.secondary)
                        .frame(width: 20)
                    Text(parking)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Emergency Contacts Card

struct EmergencyContactsCard: View {
    let contacts: [EmergencyContact]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Emergency Contacts", systemImage: "person.2.fill")
                .font(.headline)
            
            ForEach(contacts.prefix(2)) { contact in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(contact.name)
                            .font(.subheadline)
                        Text(contact.relationship)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if let url = URL(string: "tel://\(contact.phoneNumber.replacingOccurrences(of: " ", with: ""))") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Contraction Timer Full View

struct ContractionTimerFullView: View {
    @ObservedObject var timer: QuickContractionTimer
    @Environment(\.presentationMode) var presentationMode
    @State private var showingHistory = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Timer Display
                VStack(spacing: 20) {
                    if timer.isTimingContraction {
                        // Active Timer
                        VStack(spacing: 16) {
                            Text("Timing Contraction")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text(formatDuration(timer.currentContraction?.duration ?? 0))
                                .font(.system(size: 60, weight: .thin, design: .monospaced))
                            
                            Button(action: timer.stopContraction) {
                                ZStack {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 100, height: 100)
                                    
                                    Image(systemName: "stop.fill")
                                        .font(.title)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding()
                    } else {
                        // Ready to Start
                        VStack(spacing: 16) {
                            Text("Ready to Time")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            if let lastContraction = timer.contractions.last {
                                VStack(spacing: 8) {
                                    Text("Last contraction")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    HStack(spacing: 20) {
                                        VStack {
                                            Text(formatDuration(lastContraction.duration))
                                                .font(.title3)
                                                .fontWeight(.semibold)
                                            Text("Duration")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        if let interval = lastContraction.intervalFromPrevious {
                                            VStack {
                                                Text(formatDuration(interval))
                                                    .font(.title3)
                                                    .fontWeight(.semibold)
                                                Text("Interval")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)
                            }
                            
                            Button(action: timer.startContraction) {
                                ZStack {
                                    Circle()
                                        .fill(Color.purple)
                                        .frame(width: 100, height: 100)
                                    
                                    Image(systemName: "play.fill")
                                        .font(.title)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding()
                    }
                }
                .frame(maxHeight: .infinity)
                
                // Pattern Analysis
                if !timer.contractions.isEmpty {
                    VStack(spacing: 16) {
                        Divider()
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Pattern")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(timer.pattern.description)
                                    .font(.headline)
                                    .foregroundColor(Color(timer.pattern.color))
                            }
                            
                            Spacer()
                            
                            Button("History") {
                                showingHistory = true
                            }
                        }
                        
                        HStack(spacing: 20) {
                            StatBox(
                                label: "Count",
                                value: "\(timer.contractions.count)",
                                color: .blue
                            )
                            
                            StatBox(
                                label: "Avg Duration",
                                value: formatDuration(timer.averageDuration),
                                color: .purple
                            )
                            
                            StatBox(
                                label: "Avg Interval",
                                value: formatDuration(timer.averageInterval),
                                color: .green
                            )
                        }
                        
                        if timer.pattern == .timeToGo {
                            Button(action: {
                                // Call provider
                            }) {
                                Label("Call Provider - 5-1-1 Rule Met", systemImage: "phone.fill")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                }
            }
            .navigationTitle("Contraction Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: timer.reset) {
                            Label("Reset Timer", systemImage: "arrow.clockwise")
                        }
                        
                        Button(action: shareContractionData) {
                            Label("Share Data", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingHistory) {
                ContractionHistoryView(contractions: timer.contractions)
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func shareContractionData() {
        let summary = """
        Contraction Summary
        
        Total Contractions: \(timer.contractions.count)
        Average Duration: \(formatDuration(timer.averageDuration))
        Average Interval: \(formatDuration(timer.averageInterval))
        Pattern: \(timer.pattern.description)
        
        Started: \(timer.contractions.first?.startTime ?? Date())
        """
        
        let av = UIActivityViewController(activityItems: [summary], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            rootViewController.present(av, animated: true)
        }
    }
}

struct StatBox: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Labor Signs Checklist View

struct LaborSignsChecklistView: View {
    @ObservedObject var emergencyManager: EmergencyManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                ForEach(emergencyManager.emergencyInfo.laborSignsChecklist.allSigns, id: \.name) { sign in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(sign.name)
                                .font(.headline)
                            
                            Spacer()
                            
                            Toggle("", isOn: Binding(
                                get: { sign.isPresent },
                                set: { emergencyManager.updateLaborSign(sign.name, isPresent: $0) }
                            ))
                        }
                        
                        Text(sign.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let emergencyIf = sign.emergencyIf {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text("Emergency if: \(emergencyIf)")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        if sign.isPresent, let startTime = sign.startTime {
                            Text("Started \(startTime, style: .relative) ago")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Labor Signs Checklist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Warning Signs Guide View

struct WarningSignsGuideView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Picker("Type", selection: $selectedTab) {
                    Text("Pregnancy").tag(0)
                    Text("Labor").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                ScrollView {
                    VStack(spacing: 16) {
                        let signs = selectedTab == 0 ?
                            EmergencyWarningDatabase.warningSignsPregnancy :
                            EmergencyWarningDatabase.warningSignsLabor
                        
                        ForEach(signs) { sign in
                            WarningSignCard(sign: sign)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Emergency Warning Signs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct WarningSignCard: View {
    let sign: EmergencyWarningSign
    
    var backgroundColor: Color {
        switch sign.severity {
        case .immediate: return .red
        case .urgent: return .orange
        case .soon: return .yellow
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.white)
                Text(sign.title)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(sign.symptoms, id: \.self) { symptom in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .foregroundColor(.white)
                        Text(symptom)
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                }
            }
            
            Text(sign.action)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.white.opacity(0.2))
                .cornerRadius(8)
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(12)
    }
}

// MARK: - Contraction History View

struct ContractionHistoryView: View {
    let contractions: [QuickContraction]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                ForEach(contractions.reversed()) { contraction in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(contraction.startTime, style: .time)
                                .font(.headline)
                            Text("Duration: \(formatDuration(contraction.duration))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if let interval = contraction.intervalFromPrevious {
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Interval")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(formatDuration(interval))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Contraction History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Emergency Settings View

struct EmergencySettingsView: View {
    @ObservedObject var emergencyManager: EmergencyManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Hospital Information")) {
                    // Hospital settings fields
                    Text("Hospital settings would go here")
                }
                
                Section(header: Text("Medical Information")) {
                    // Medical info fields
                    Text("Medical information fields would go here")
                }
                
                Section(header: Text("Quick Access Items")) {
                    // Quick access customization
                    Text("Quick access customization would go here")
                }
            }
            .navigationTitle("Emergency Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}