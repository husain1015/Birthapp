import SwiftUI

struct MedicationTrackerView: View {
    @StateObject private var medicationManager: MedicationManager
    @State private var showingAddMedication = false
    @State private var selectedTab = 0
    
    init(userId: UUID) {
        _medicationManager = StateObject(wrappedValue: MedicationManager(userId: userId))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selection
                Picker("View", selection: $selectedTab) {
                    Text("Today").tag(0)
                    Text("Medications").tag(1)
                    Text("History").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content
                TabView(selection: $selectedTab) {
                    TodaysMedicationsView(medicationManager: medicationManager)
                        .tag(0)
                    
                    AllMedicationsView(medicationManager: medicationManager)
                        .tag(1)
                    
                    MedicationHistoryView(medicationManager: medicationManager)
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Medication Tracker")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddMedication = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.pink)
                    }
                }
            }
            .sheet(isPresented: $showingAddMedication) {
                AddMedicationView(medicationManager: medicationManager)
            }
        }
    }
}

// MARK: - Today's Medications View

struct TodaysMedicationsView: View {
    @ObservedObject var medicationManager: MedicationManager
    @State private var showingLogSheet = false
    @State private var selectedScheduleItem: MedicationScheduleItem?
    
    var upcomingMedications: [MedicationScheduleItem] {
        medicationManager.todaysMedications.filter { $0.isUpcoming }
    }
    
    var pastDueMedications: [MedicationScheduleItem] {
        medicationManager.todaysMedications.filter { $0.isPastDue }
    }
    
    var completedMedications: [MedicationScheduleItem] {
        medicationManager.todaysMedications.filter { $0.isLogged }
    }
    
    var adherenceRate: Double {
        let total = medicationManager.todaysMedications.count
        let taken = completedMedications.filter { $0.logStatus == .taken }.count
        guard total > 0 else { return 100 }
        return Double(taken) / Double(total) * 100
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Daily Progress
                DailyProgressCard(
                    taken: completedMedications.filter { $0.logStatus == .taken }.count,
                    total: medicationManager.todaysMedications.count,
                    adherenceRate: adherenceRate
                )
                .padding(.horizontal)
                
                // Refill Reminders
                let refillNeeded = medicationManager.getMedicationsNeedingRefill()
                if !refillNeeded.isEmpty {
                    RefillRemindersSection(medications: refillNeeded)
                        .padding(.horizontal)
                }
                
                // Past Due
                if !pastDueMedications.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Past Due", systemImage: "exclamationmark.circle.fill")
                            .font(.headline)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                        
                        ForEach(pastDueMedications) { item in
                            MedicationScheduleCard(
                                item: item,
                                onTap: {
                                    selectedScheduleItem = item
                                    showingLogSheet = true
                                }
                            )
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Upcoming
                if !upcomingMedications.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Upcoming", systemImage: "clock")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(upcomingMedications) { item in
                            MedicationScheduleCard(
                                item: item,
                                onTap: {
                                    selectedScheduleItem = item
                                    showingLogSheet = true
                                }
                            )
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Completed
                if !completedMedications.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Completed", systemImage: "checkmark.circle.fill")
                            .font(.headline)
                            .foregroundColor(.green)
                            .padding(.horizontal)
                        
                        ForEach(completedMedications) { item in
                            MedicationScheduleCard(
                                item: item,
                                onTap: {
                                    selectedScheduleItem = item
                                    showingLogSheet = true
                                }
                            )
                            .padding(.horizontal)
                        }
                    }
                }
                
                if medicationManager.todaysMedications.isEmpty {
                    MedicationEmptyStateView(
                        icon: "pills",
                        title: "No Medications Today",
                        message: "Add medications to track your daily intake"
                    )
                    .padding(.top, 50)
                }
            }
            .padding(.vertical)
        }
        .sheet(isPresented: $showingLogSheet) {
            if let item = selectedScheduleItem {
                LogMedicationSheet(
                    medicationManager: medicationManager,
                    scheduleItem: item
                )
            }
        }
    }
}

// MARK: - Daily Progress Card

struct DailyProgressCard: View {
    let taken: Int
    let total: Int
    let adherenceRate: Double
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Progress")
                        .font(.headline)
                    Text("\(taken) of \(total) taken")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                CircularProgressView(
                    progress: total > 0 ? Double(taken) / Double(total) : 0,
                    lineWidth: 8,
                    size: 60
                )
                .overlay(
                    Text("\(Int(adherenceRate))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                )
            }
            
            if total > taken {
                Text("\(total - taken) medications remaining today")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.pink.opacity(0.1), .purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
    }
}

struct CircularProgressView: View {
    let progress: Double
    let lineWidth: CGFloat
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [.pink, .purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(Angle(degrees: -90))
                .animation(.easeInOut(duration: 0.3), value: progress)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Refill Reminders Section

struct RefillRemindersSection: View {
    let medications: [Medication]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Refill Needed Soon", systemImage: "exclamationmark.triangle.fill")
                .font(.headline)
                .foregroundColor(.orange)
            
            ForEach(medications) { medication in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(medication.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        if let refillDate = medication.refillDate {
                            Text("Refill by \(refillDate, style: .date)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    if let pharmacy = medication.pharmacyInfo {
                        Button(action: {
                            if let phone = pharmacy.phone,
                               let url = URL(string: "tel://\(phone.replacingOccurrences(of: " ", with: ""))") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Image(systemName: "phone.fill")
                                .foregroundColor(.orange)
                        }
                    }
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
}

// MARK: - Medication Schedule Card

struct MedicationScheduleCard: View {
    let item: MedicationScheduleItem
    let onTap: () -> Void
    
    var statusColor: Color {
        if item.isLogged {
            return item.logStatus == .taken ? .green : .gray
        } else if item.isPastDue {
            return .red
        } else {
            return .blue
        }
    }
    
    var statusIcon: String {
        if item.isLogged {
            return item.logStatus == .taken ? "checkmark.circle.fill" : "xmark.circle.fill"
        } else if item.isPastDue {
            return "exclamationmark.circle.fill"
        } else {
            return "clock"
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Time
                VStack {
                    Text(item.scheduledTime, style: .time)
                        .font(.headline)
                    Text(item.timeSlot.label)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(width: 80)
                
                // Medication Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.medication.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(item.medication.dosage) \(item.medication.unit.rawValue)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let instructions = item.medication.instructions {
                        Text(instructions)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Status
                Image(systemName: statusIcon)
                    .font(.title2)
                    .foregroundColor(statusColor)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

// MARK: - All Medications View

struct AllMedicationsView: View {
    @ObservedObject var medicationManager: MedicationManager
    @State private var showingInactive = false
    @State private var selectedMedication: Medication?
    
    var activeMedications: [Medication] {
        medicationManager.medications.filter { $0.isActive }
    }
    
    var inactiveMedications: [Medication] {
        medicationManager.medications.filter { !$0.isActive }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Active Medications
                if !activeMedications.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Active Medications")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(activeMedications) { medication in
                            MedicationCard(
                                medication: medication,
                                adherenceRate: medicationManager.getAdherenceRate(for: medication.id),
                                onTap: {
                                    selectedMedication = medication
                                }
                            )
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Inactive Medications
                if !inactiveMedications.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Inactive Medications")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button(action: { showingInactive.toggle() }) {
                                Image(systemName: showingInactive ? "chevron.up" : "chevron.down")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal)
                        
                        if showingInactive {
                            ForEach(inactiveMedications) { medication in
                                MedicationCard(
                                    medication: medication,
                                    adherenceRate: medicationManager.getAdherenceRate(for: medication.id),
                                    onTap: {
                                        selectedMedication = medication
                                    }
                                )
                                .padding(.horizontal)
                                .opacity(0.6)
                            }
                        }
                    }
                }
                
                if medicationManager.medications.isEmpty {
                    MedicationEmptyStateView(
                        icon: "pills",
                        title: "No Medications",
                        message: "Add medications and supplements to track your daily intake"
                    )
                    .padding(.top, 50)
                }
            }
            .padding(.vertical)
        }
        .sheet(item: $selectedMedication) { medication in
            MedicationDetailView(
                medication: medication,
                medicationManager: medicationManager
            )
        }
    }
}

// MARK: - Medication Card

struct MedicationCard: View {
    let medication: Medication
    let adherenceRate: Double
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(medication.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 8) {
                            MedicationTypeBadge(type: medication.type)
                            
                            if let category = medication.pregnancyCategory {
                                PregnancyCategoryBadge(category: category)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(Int(adherenceRate))%")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(adherenceRate >= 80 ? .green : .orange)
                        
                        Text("Adherence")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Label("\(medication.dosage) \(medication.unit.rawValue)", systemImage: "pills")
                    
                    Spacer()
                    
                    Label(medication.frequency.rawValue, systemImage: "clock")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                if !medication.interactions.isEmpty {
                    Label("Has interactions", systemImage: "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

struct MedicationTypeBadge: View {
    let type: MedicationType
    
    var body: some View {
        Text(type.rawValue)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(Color.blue.opacity(0.2))
            .foregroundColor(.blue)
            .cornerRadius(4)
    }
}

struct PregnancyCategoryBadge: View {
    let category: PregnancyCategory
    
    var backgroundColor: Color {
        switch category {
        case .categoryA, .categoryB:
            return .green.opacity(0.2)
        case .categoryC:
            return .yellow.opacity(0.2)
        case .categoryD:
            return .orange.opacity(0.2)
        case .categoryX:
            return .red.opacity(0.2)
        case .notRated:
            return .gray.opacity(0.2)
        }
    }
    
    var foregroundColor: Color {
        switch category {
        case .categoryA, .categoryB:
            return .green
        case .categoryC:
            return .yellow
        case .categoryD:
            return .orange
        case .categoryX:
            return .red
        case .notRated:
            return .gray
        }
    }
    
    var body: some View {
        Text(String(category.rawValue.prefix(10)))
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(4)
    }
}

// MARK: - Medication History View

struct MedicationHistoryView: View {
    @ObservedObject var medicationManager: MedicationManager
    @State private var selectedDays = 7
    
    var groupedLogs: [(Date, [MedicationLog])] {
        let calendar = Calendar.current
        let cutoffDate = calendar.date(byAdding: .day, value: -selectedDays, to: Date()) ?? Date()
        
        let logs = medicationManager.medicationLogs
            .filter { $0.scheduledTime > cutoffDate }
            .sorted { $0.scheduledTime > $1.scheduledTime }
        
        let grouped = Dictionary(grouping: logs) { log in
            calendar.startOfDay(for: log.scheduledTime)
        }
        
        return grouped.sorted { $0.key > $1.key }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Days Filter
            Picker("Time Period", selection: $selectedDays) {
                Text("7 Days").tag(7)
                Text("14 Days").tag(14)
                Text("30 Days").tag(30)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            ScrollView {
                if groupedLogs.isEmpty {
                    MedicationEmptyStateView(
                        icon: "clock.arrow.circlepath",
                        title: "No History",
                        message: "Your medication history will appear here"
                    )
                    .padding(.top, 50)
                } else {
                    LazyVStack(spacing: 20) {
                        ForEach(groupedLogs, id: \.0) { date, logs in
                            VStack(alignment: .leading, spacing: 12) {
                                Text(date, style: .date)
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                ForEach(logs) { log in
                                    MedicationLogCard(log: log)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
    }
}

struct MedicationLogCard: View {
    let log: MedicationLog
    
    var statusColor: Color {
        switch log.status {
        case .taken:
            return .green
        case .skipped:
            return .orange
        case .missed:
            return .red
        case .pending:
            return .gray
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(log.medicationName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 8) {
                    Label {
                        Text(log.scheduledTime, style: .time)
                    } icon: {
                        Image(systemName: "clock")
                    }
                    
                    if let actualTime = log.actualTime {
                        Label {
                            Text(actualTime, style: .time)
                        } icon: {
                            Image(systemName: "checkmark.circle")
                        }
                        .foregroundColor(.green)
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(log.status.rawValue)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.2))
                .foregroundColor(statusColor)
                .cornerRadius(4)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}

// MARK: - Log Medication Sheet

struct LogMedicationSheet: View {
    @ObservedObject var medicationManager: MedicationManager
    let scheduleItem: MedicationScheduleItem
    @Environment(\.presentationMode) var presentationMode
    
    @State private var taken = true
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(scheduleItem.medication.name)
                            .font(.headline)
                        
                        HStack {
                            Text("\(scheduleItem.medication.dosage) \(scheduleItem.medication.unit.rawValue)")
                            Text("•")
                            Text(scheduleItem.scheduledTime, style: .time)
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                Section {
                    Toggle("Taken", isOn: $taken)
                }
                
                Section(header: Text("Notes (Optional)")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                
                if !taken {
                    Section(header: Text("Reason for Skipping")) {
                        ForEach(["Forgot", "Side effects", "Not needed", "Out of medication"], id: \.self) { reason in
                            Button(action: { notes = reason }) {
                                HStack {
                                    Text(reason)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if notes == reason {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.pink)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Log Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        medicationManager.logMedication(
                            medicationId: scheduleItem.medication.id,
                            timeSlot: scheduleItem.timeSlot,
                            taken: taken,
                            notes: notes.isEmpty ? nil : notes
                        )
                        presentationMode.wrappedValue.dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Add Medication View

struct AddMedicationView: View {
    @ObservedObject var medicationManager: MedicationManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var type: MedicationType = .prescription
    @State private var dosage = ""
    @State private var unit: DosageUnit = .mg
    @State private var frequency: MedicationFrequency = .onceDaily
    @State private var reasonForTaking = ""
    @State private var prescribedBy = ""
    @State private var instructions = ""
    @State private var startDate = Date()
    @State private var hasEndDate = false
    @State private var endDate = Date()
    @State private var remindersEnabled = true
    @State private var timeSlots: [Date] = [Date()]
    @State private var showingSafetyAlert = false
    @State private var safetyCategory: PregnancyCategory?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Medication Information")) {
                    TextField("Medication Name", text: $name)
                    
                    Picker("Type", selection: $type) {
                        ForEach(MedicationType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    HStack {
                        TextField("Dosage", text: $dosage)
                            .keyboardType(.decimalPad)
                        
                        Picker("Unit", selection: $unit) {
                            ForEach(DosageUnit.allCases, id: \.self) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                Section(header: Text("Schedule")) {
                    Picker("Frequency", selection: $frequency) {
                        ForEach(MedicationFrequency.allCases, id: \.self) { freq in
                            Text(freq.rawValue).tag(freq)
                        }
                    }
                    
                    ForEach(0..<numberOfTimeSlots(), id: \.self) { index in
                        DatePicker(
                            "Time \(index + 1)",
                            selection: Binding(
                                get: { 
                                    index < timeSlots.count ? timeSlots[index] : Date()
                                },
                                set: { newValue in
                                    if index < timeSlots.count {
                                        timeSlots[index] = newValue
                                    }
                                }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                    }
                    
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    
                    Toggle("Set End Date", isOn: $hasEndDate)
                    
                    if hasEndDate {
                        DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                    }
                }
                
                Section(header: Text("Additional Information")) {
                    TextField("Reason for Taking", text: $reasonForTaking)
                    TextField("Prescribed By", text: $prescribedBy)
                    TextField("Instructions", text: $instructions)
                }
                
                Section {
                    Toggle("Enable Reminders", isOn: $remindersEnabled)
                }
            }
            .navigationTitle("Add Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        checkSafetyAndSave()
                    }
                    .fontWeight(.semibold)
                    .disabled(name.isEmpty || dosage.isEmpty)
                }
            }
            .alert(isPresented: $showingSafetyAlert) {
                Alert(
                    title: Text("Pregnancy Safety Check"),
                    message: Text(safetyAlertMessage()),
                    primaryButton: .default(Text("Continue")) {
                        saveMedication()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    private func numberOfTimeSlots() -> Int {
        switch frequency {
        case .onceDaily, .everyOtherDay, .weekly:
            return 1
        case .twiceDaily:
            return 2
        case .threeTimesDaily:
            return 3
        case .fourTimesDaily:
            return 4
        case .asNeeded, .custom:
            return 1
        }
    }
    
    private func checkSafetyAndSave() {
        safetyCategory = MedicationSafetyDatabase.checkSafety(medicationName: name)
        
        if safetyCategory == .categoryD || safetyCategory == .categoryX {
            showingSafetyAlert = true
        } else {
            saveMedication()
        }
    }
    
    private func safetyAlertMessage() -> String {
        guard let category = safetyCategory else {
            return "This medication has not been evaluated for pregnancy safety. Please consult your healthcare provider."
        }
        
        switch category {
        case .categoryD:
            return "This medication is Category D - there is evidence of risk to the fetus. Please confirm with your healthcare provider before taking."
        case .categoryX:
            return "This medication is Category X - contraindicated in pregnancy. Please consult your healthcare provider immediately."
        default:
            return "Please confirm with your healthcare provider before taking any medication during pregnancy."
        }
    }
    
    private func saveMedication() {
        // Update timeSlots array based on frequency
        while timeSlots.count < numberOfTimeSlots() {
            timeSlots.append(Date())
        }
        while timeSlots.count > numberOfTimeSlots() {
            timeSlots.removeLast()
        }
        
        let timeSlotModels = timeSlots.enumerated().map { index, time in
            MedicationTimeSlot(
                time: time,
                label: getTimeSlotLabel(for: index)
            )
        }
        
        let medication = Medication(
            name: name,
            type: type,
            dosage: dosage,
            unit: unit,
            frequency: frequency,
            timeSlots: timeSlotModels,
            startDate: startDate,
            endDate: hasEndDate ? endDate : nil,
            prescribedBy: prescribedBy.isEmpty ? nil : prescribedBy,
            reasonForTaking: reasonForTaking,
            instructions: instructions.isEmpty ? nil : instructions,
            remindersEnabled: remindersEnabled
        )
        
        medicationManager.addMedication(medication)
        presentationMode.wrappedValue.dismiss()
    }
    
    private func getTimeSlotLabel(for index: Int) -> String {
        switch frequency {
        case .onceDaily:
            return "Daily"
        case .twiceDaily:
            return index == 0 ? "Morning" : "Evening"
        case .threeTimesDaily:
            return index == 0 ? "Morning" : index == 1 ? "Afternoon" : "Evening"
        case .fourTimesDaily:
            return index == 0 ? "Morning" : index == 1 ? "Noon" : index == 2 ? "Evening" : "Bedtime"
        default:
            return "Dose \(index + 1)"
        }
    }
}

// MARK: - Medication Detail View

struct MedicationDetailView: View {
    let medication: Medication
    @ObservedObject var medicationManager: MedicationManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showingEditView = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(medication.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 12) {
                            MedicationTypeBadge(type: medication.type)
                            
                            if let category = medication.pregnancyCategory {
                                PregnancyCategoryBadge(category: category)
                            }
                            
                            if medication.isActive {
                                Label("Active", systemImage: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    
                    // Dosage & Schedule
                    VStack(alignment: .leading, spacing: 16) {
                        InfoRow(label: "Dosage", value: "\(medication.dosage) \(medication.unit.rawValue)")
                        InfoRow(label: "Frequency", value: medication.frequency.rawValue)
                        InfoRow(label: "Reason", value: medication.reasonForTaking)
                        
                        if let prescribedBy = medication.prescribedBy {
                            InfoRow(label: "Prescribed By", value: prescribedBy)
                        }
                        
                        if let instructions = medication.instructions {
                            InfoRow(label: "Instructions", value: instructions)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Schedule Times
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Daily Schedule")
                            .font(.headline)
                        
                        ForEach(medication.timeSlots) { slot in
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.pink)
                                Text(slot.time, style: .time)
                                Text("•")
                                Text(slot.label)
                            }
                            .font(.subheadline)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Safety Information
                    if !medication.interactions.isEmpty || medication.pregnancyCategory != nil {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Safety Information", systemImage: "exclamationmark.triangle")
                                .font(.headline)
                                .foregroundColor(.orange)
                            
                            if let category = medication.pregnancyCategory {
                                Text(category.rawValue)
                                    .font(.subheadline)
                            }
                            
                            ForEach(medication.interactions, id: \.self) { interaction in
                                Text("• \(interaction)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Adherence
                    let adherenceRate = medicationManager.getAdherenceRate(for: medication.id)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("30-Day Adherence")
                            .font(.headline)
                        
                        HStack {
                            Text("\(Int(adherenceRate))%")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(adherenceRate >= 80 ? .green : .orange)
                            
                            Spacer()
                            
                            CircularProgressView(
                                progress: adherenceRate / 100,
                                lineWidth: 8,
                                size: 60
                            )
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Actions
                    VStack(spacing: 12) {
                        Button(action: {
                            medicationManager.toggleMedicationActive(medication.id)
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Label(
                                medication.isActive ? "Mark as Inactive" : "Mark as Active",
                                systemImage: medication.isActive ? "pause.circle" : "play.circle"
                            )
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        
                        Button(action: { showingDeleteAlert = true }) {
                            Label("Delete Medication", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .foregroundColor(.red)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Medication Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showingEditView = true
                    }
                }
            }
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("Delete Medication"),
                    message: Text("Are you sure you want to delete \(medication.name)? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        medicationManager.deleteMedication(medication)
                        presentationMode.wrappedValue.dismiss()
                    },
                    secondaryButton: .cancel()
                )
            }
            .sheet(isPresented: $showingEditView) {
                // Edit medication view would go here
                Text("Edit Medication View")
            }
        }
    }
}

// MARK: - Empty State View

struct MedicationEmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(40)
    }
}