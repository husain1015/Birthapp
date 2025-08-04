import SwiftUI
import PhotosUI

struct DigitalWalletView: View {
    @StateObject private var walletManager: DigitalWalletManager
    @State private var selectedTab = 0
    @State private var showingAddSheet = false
    @State private var searchText = ""
    
    init(userId: UUID) {
        _walletManager = StateObject(wrappedValue: DigitalWalletManager(userId: userId))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                
                // Tab Selection
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        TabButton(title: "Medical Records", icon: "doc.text.fill", isSelected: selectedTab == 0) {
                            selectedTab = 0
                        }
                        TabButton(title: "Ultrasounds", icon: "waveform", isSelected: selectedTab == 1) {
                            selectedTab = 1
                        }
                        TabButton(title: "Test Results", icon: "chart.line.uptrend.xyaxis", isSelected: selectedTab == 2) {
                            selectedTab = 2
                        }
                        TabButton(title: "Insurance", icon: "creditcard.fill", isSelected: selectedTab == 3) {
                            selectedTab = 3
                        }
                        TabButton(title: "Emergency", icon: "phone.fill", isSelected: selectedTab == 4) {
                            selectedTab = 4
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 8)
                
                // Content
                TabView(selection: $selectedTab) {
                    MedicalRecordsView(walletManager: walletManager, searchText: searchText)
                        .tag(0)
                    
                    UltrasoundsView(walletManager: walletManager)
                        .tag(1)
                    
                    TestResultsView(walletManager: walletManager, searchText: searchText)
                        .tag(2)
                    
                    InsuranceView(walletManager: walletManager)
                        .tag(3)
                    
                    EmergencyContactsView(walletManager: walletManager)
                        .tag(4)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Digital Wallet")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.pink)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddItemSheet(walletManager: walletManager, selectedTab: selectedTab)
            }
        }
    }
}

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(isSelected ? .pink : .gray)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(isSelected ? Color.pink.opacity(0.1) : Color.clear)
            .cornerRadius(8)
        }
    }
}

// MARK: - Medical Records View

struct MedicalRecordsView: View {
    @ObservedObject var walletManager: DigitalWalletManager
    let searchText: String
    
    var filteredRecords: [MedicalRecord] {
        if searchText.isEmpty {
            return walletManager.wallet.medicalRecords.sorted { $0.date > $1.date }
        } else {
            return walletManager.wallet.medicalRecords.filter { record in
                record.title.localizedCaseInsensitiveContains(searchText) ||
                record.notes?.localizedCaseInsensitiveContains(searchText) ?? false
            }.sorted { $0.date > $1.date }
        }
    }
    
    var body: some View {
        ScrollView {
            if filteredRecords.isEmpty {
                DigitalWalletEmptyStateView(
                    icon: "doc.text",
                    title: searchText.isEmpty ? "No Medical Records" : "No Results",
                    message: searchText.isEmpty ? "Add your medical records to keep them organized and accessible" : "Try a different search term"
                )
                .padding(.top, 50)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(filteredRecords) { record in
                        MedicalRecordCard(record: record) {
                            walletManager.deleteMedicalRecord(record)
                        }
                    }
                }
                .padding()
            }
        }
    }
}

struct MedicalRecordCard: View {
    let record: MedicalRecord
    let onDelete: () -> Void
    @State private var showingDetail = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(record.title)
                        .font(.headline)
                    Text(record.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(record.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if record.fileData != nil {
                        Image(systemName: "paperclip")
                            .foregroundColor(.pink)
                    }
                }
            }
            
            if let provider = record.provider {
                Label(provider, systemImage: "person.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let notes = record.notes {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            if !record.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(record.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.pink.opacity(0.1))
                                .foregroundColor(.pink)
                                .cornerRadius(4)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .onTapGesture {
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            MedicalRecordDetailView(record: record, onDelete: onDelete)
        }
    }
}

// MARK: - Ultrasounds View

struct UltrasoundsView: View {
    @ObservedObject var walletManager: DigitalWalletManager
    
    var favoriteUltrasounds: [UltrasoundRecord] {
        walletManager.wallet.ultrasounds.filter { $0.isFavorite }.sorted { $0.date > $1.date }
    }
    
    var allUltrasounds: [UltrasoundRecord] {
        walletManager.wallet.ultrasounds.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        ScrollView {
            if allUltrasounds.isEmpty {
                DigitalWalletEmptyStateView(
                    icon: "waveform",
                    title: "No Ultrasounds",
                    message: "Add your ultrasound images to track your baby's growth"
                )
                .padding(.top, 50)
            } else {
                VStack(alignment: .leading, spacing: 20) {
                    if !favoriteUltrasounds.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Favorites")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(favoriteUltrasounds) { ultrasound in
                                        UltrasoundThumbnail(ultrasound: ultrasound) {
                                            walletManager.toggleUltrasoundFavorite(ultrasound.id)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("All Ultrasounds")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LazyVStack(spacing: 12) {
                            ForEach(allUltrasounds) { ultrasound in
                                UltrasoundCard(ultrasound: ultrasound) {
                                    walletManager.toggleUltrasoundFavorite(ultrasound.id)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
    }
}

struct UltrasoundThumbnail: View {
    let ultrasound: UltrasoundRecord
    let onToggleFavorite: () -> Void
    @State private var showingDetail = false
    
    var body: some View {
        VStack(spacing: 8) {
            if let imageData = ultrasound.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipped()
                    .cornerRadius(12)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .overlay(
                        Image(systemName: "waveform")
                            .foregroundColor(.gray)
                            .font(.largeTitle)
                    )
            }
            
            VStack(spacing: 2) {
                Text(ultrasound.gestationalAge)
                    .font(.caption)
                    .fontWeight(.medium)
                Text(ultrasound.date, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .onTapGesture {
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            UltrasoundDetailView(ultrasound: ultrasound, onToggleFavorite: onToggleFavorite)
        }
    }
}

struct UltrasoundCard: View {
    let ultrasound: UltrasoundRecord
    let onToggleFavorite: () -> Void
    @State private var showingDetail = false
    
    var body: some View {
        HStack(spacing: 12) {
            if let imageData = ultrasound.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipped()
                    .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "waveform")
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(ultrasound.type.rawValue)
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(action: onToggleFavorite) {
                        Image(systemName: ultrasound.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(.pink)
                    }
                }
                
                Text(ultrasound.gestationalAge)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(ultrasound.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let facility = ultrasound.facility {
                    Label(facility, systemImage: "building.2")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .onTapGesture {
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            UltrasoundDetailView(ultrasound: ultrasound, onToggleFavorite: onToggleFavorite)
        }
    }
}

// MARK: - Test Results View

struct TestResultsView: View {
    @ObservedObject var walletManager: DigitalWalletManager
    let searchText: String
    
    var abnormalResults: [TestResult] {
        walletManager.getAbnormalResults()
    }
    
    var filteredResults: [TestResult] {
        let results = walletManager.wallet.testResults
        if searchText.isEmpty {
            return results.sorted { $0.date > $1.date }
        } else {
            return results.filter { result in
                result.testName.localizedCaseInsensitiveContains(searchText) ||
                result.notes?.localizedCaseInsensitiveContains(searchText) ?? false
            }.sorted { $0.date > $1.date }
        }
    }
    
    var body: some View {
        ScrollView {
            if filteredResults.isEmpty {
                DigitalWalletEmptyStateView(
                    icon: "chart.line.uptrend.xyaxis",
                    title: searchText.isEmpty ? "No Test Results" : "No Results",
                    message: searchText.isEmpty ? "Add your test results to track your health progress" : "Try a different search term"
                )
                .padding(.top, 50)
            } else {
                VStack(alignment: .leading, spacing: 20) {
                    if !abnormalResults.isEmpty && searchText.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Label("Abnormal Results", systemImage: "exclamationmark.triangle.fill")
                                    .font(.headline)
                                    .foregroundColor(.orange)
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            ForEach(abnormalResults) { result in
                                TestResultCard(result: result)
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        if searchText.isEmpty {
                            Text("All Results")
                                .font(.headline)
                                .padding(.horizontal)
                        }
                        
                        LazyVStack(spacing: 12) {
                            ForEach(filteredResults) { result in
                                TestResultCard(result: result)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
    }
}

struct TestResultCard: View {
    let result: TestResult
    @State private var showingDetail = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.testName)
                        .font(.headline)
                    Text(result.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if result.isAbnormal {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.orange)
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Result: \(result.result)")
                        .font(.subheadline)
                        .foregroundColor(result.isAbnormal ? .orange : .primary)
                    
                    if let normalRange = result.normalRange {
                        Text("Normal: \(normalRange)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Text(result.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if result.followUpRequired {
                Label("Follow-up Required", systemImage: "clock.fill")
                    .font(.caption)
                    .foregroundColor(.pink)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .onTapGesture {
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            TestResultDetailView(result: result)
        }
    }
}

// MARK: - Insurance View

struct InsuranceView: View {
    @ObservedObject var walletManager: DigitalWalletManager
    
    var body: some View {
        ScrollView {
            if walletManager.wallet.insuranceCards.isEmpty {
                DigitalWalletEmptyStateView(
                    icon: "creditcard",
                    title: "No Insurance Cards",
                    message: "Add your insurance information for quick access during appointments"
                )
                .padding(.top, 50)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(walletManager.wallet.insuranceCards) { card in
                        InsuranceCardView(card: card)
                    }
                }
                .padding()
            }
        }
    }
}

struct InsuranceCardView: View {
    let card: InsuranceCard
    @State private var showingDetail = false
    @State private var showingFront = true
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(card.insurerName)
                        .font(.headline)
                    if card.isPrimary {
                        Label("Primary Insurance", systemImage: "star.fill")
                            .font(.caption)
                            .foregroundColor(.pink)
                    }
                }
                
                Spacer()
                
                Image(systemName: "creditcard.fill")
                    .foregroundColor(.pink)
                    .font(.title2)
            }
            
            if let frontData = card.cardFrontImage,
               let frontImage = UIImage(data: frontData),
               let backData = card.cardBackImage,
               let backImage = UIImage(data: backData) {
                ZStack {
                    Image(uiImage: showingFront ? frontImage : backImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .shadow(radius: 5)
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: { showingFront.toggle() }) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .padding(8)
                                    .background(Color.black.opacity(0.6))
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                            }
                            .padding()
                        }
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    DigitalWalletInfoRow(label: "Policy #", value: card.policyNumber)
                    DigitalWalletInfoRow(label: "Member ID", value: card.memberId)
                    if let groupNumber = card.groupNumber {
                        DigitalWalletInfoRow(label: "Group #", value: groupNumber)
                    }
                    DigitalWalletInfoRow(label: "Coverage", value: card.coverageType)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            HStack(spacing: 16) {
                if let phone = card.phoneNumber {
                    Button(action: {
                        if let url = URL(string: "tel://\(phone.replacingOccurrences(of: " ", with: ""))") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Label("Call", systemImage: "phone.fill")
                            .font(.caption)
                            .foregroundColor(.pink)
                    }
                }
                
                if let website = card.website {
                    Button(action: {
                        if let url = URL(string: website) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Label("Website", systemImage: "globe")
                            .font(.caption)
                            .foregroundColor(.pink)
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .onTapGesture {
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            InsuranceDetailView(card: card)
        }
    }
}

// MARK: - Emergency Contacts View

struct EmergencyContactsView: View {
    @ObservedObject var walletManager: DigitalWalletManager
    
    var primaryContact: EmergencyContact? {
        walletManager.getPrimaryEmergencyContact()
    }
    
    var otherContacts: [EmergencyContact] {
        walletManager.wallet.emergencyContacts.filter { !$0.isPrimary }
    }
    
    var body: some View {
        ScrollView {
            if walletManager.wallet.emergencyContacts.isEmpty {
                DigitalWalletEmptyStateView(
                    icon: "phone",
                    title: "No Emergency Contacts",
                    message: "Add emergency contacts for quick access in urgent situations"
                )
                .padding(.top, 50)
            } else {
                VStack(alignment: .leading, spacing: 20) {
                    if let primary = primaryContact {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Primary Contact")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            EmergencyContactCard(contact: primary, isPrimary: true)
                                .padding(.horizontal)
                        }
                    }
                    
                    if !otherContacts.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Other Contacts")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(otherContacts) { contact in
                                EmergencyContactCard(contact: contact, isPrimary: false)
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

struct EmergencyContactCard: View {
    let contact: EmergencyContact
    let isPrimary: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(contact.name)
                        .font(.headline)
                    Text(contact.relationship)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isPrimary {
                    Image(systemName: "star.fill")
                        .foregroundColor(.pink)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Button(action: {
                    if let url = URL(string: "tel://\(contact.phoneNumber.replacingOccurrences(of: " ", with: ""))") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Label(contact.phoneNumber, systemImage: "phone.fill")
                        .font(.subheadline)
                        .foregroundColor(.pink)
                }
                
                if let alternatePhone = contact.alternatePhone {
                    Button(action: {
                        if let url = URL(string: "tel://\(alternatePhone.replacingOccurrences(of: " ", with: ""))") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Label(alternatePhone, systemImage: "phone")
                            .font(.caption)
                            .foregroundColor(.pink)
                    }
                }
                
                if let email = contact.email {
                    Button(action: {
                        if let url = URL(string: "mailto:\(email)") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Label(email, systemImage: "envelope.fill")
                            .font(.caption)
                            .foregroundColor(.pink)
                    }
                }
            }
            
            if contact.hasHealthcarePOA {
                Label("Has Healthcare Power of Attorney", systemImage: "doc.text.fill")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(isPrimary ? Color.pink.opacity(0.1) : Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Supporting Views

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search records...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct DigitalWalletEmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

struct DigitalWalletInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Detail Views (Placeholder)

struct MedicalRecordDetailView: View {
    let record: MedicalRecord
    let onDelete: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Medical Record Details")
                        .font(.largeTitle)
                    // Add detailed view implementation
                }
                .padding()
            }
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

struct UltrasoundDetailView: View {
    let ultrasound: UltrasoundRecord
    let onToggleFavorite: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Ultrasound Details")
                        .font(.largeTitle)
                    // Add detailed view implementation
                }
                .padding()
            }
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

struct TestResultDetailView: View {
    let result: TestResult
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Test Result Details")
                        .font(.largeTitle)
                    // Add detailed view implementation
                }
                .padding()
            }
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

struct InsuranceDetailView: View {
    let card: InsuranceCard
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Insurance Details")
                        .font(.largeTitle)
                    // Add detailed view implementation
                }
                .padding()
            }
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

// MARK: - Add Item Sheet

struct AddItemSheet: View {
    @ObservedObject var walletManager: DigitalWalletManager
    let selectedTab: Int
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Add New Item")
                    .font(.largeTitle)
                    .padding()
                
                // Add forms based on selected tab
                // Implementation would go here
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}