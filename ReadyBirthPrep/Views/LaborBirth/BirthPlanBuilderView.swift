import SwiftUI

struct BirthPlanBuilderView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var birthPlan = BirthPlan(userId: UUID())
    @State private var currentSection = 0
    
    var body: some View {
        VStack {
            ProgressView(value: Double(currentSection + 1), total: 5)
                .progressViewStyle(LinearProgressViewStyle(tint: .pink))
                .padding()
            
            TabView(selection: $currentSection) {
                EnvironmentPreferencesView(environment: $birthPlan.environment)
                    .tag(0)
                
                SupportPeopleView(supportPeople: $birthPlan.supportPeople)
                    .tag(1)
                
                PainManagementView(preferences: $birthPlan.painManagement)
                    .tag(2)
                
                LaborPositionsSelectionView(positions: $birthPlan.laboringPositions)
                    .tag(3)
                
                NewbornPreferencesView(preferences: $birthPlan.newbornProcedures)
                    .tag(4)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            HStack {
                if currentSection > 0 {
                    Button("Previous") {
                        withAnimation {
                            currentSection -= 1
                        }
                    }
                }
                
                Spacer()
                
                if currentSection < 4 {
                    Button("Next") {
                        withAnimation {
                            currentSection += 1
                        }
                    }
                } else {
                    Button("Generate Plan") {
                        generateBirthPlan()
                    }
                    .fontWeight(.bold)
                }
            }
            .padding()
        }
        .navigationTitle("Birth Plan Builder")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let userId = userManager.currentUser?.id {
                birthPlan.userId = userId
            }
        }
    }
    
    private func generateBirthPlan() {
        // Generate PDF and save
    }
}

struct EnvironmentPreferencesView: View {
    @Binding var environment: BirthEnvironment
    
    var body: some View {
        Form {
            Section(header: Text("Environment Preferences")) {
                Picker("Lighting", selection: $environment.lighting) {
                    ForEach(LightingPreference.allCases, id: \.self) { preference in
                        Text(preference.rawValue).tag(preference)
                    }
                }
                
                Toggle("Music", isOn: $environment.music)
                
                if environment.music {
                    TextField("Playlist Name", text: Binding(
                        get: { environment.musicPlaylist ?? "" },
                        set: { environment.musicPlaylist = $0.isEmpty ? nil : $0 }
                    ))
                }
                
                Toggle("Aromatherapy", isOn: $environment.aromatherapy)
                
                Picker("Room Temperature", selection: $environment.temperature) {
                    ForEach(TemperaturePreference.allCases, id: \.self) { preference in
                        Text(preference.rawValue).tag(preference)
                    }
                }
                
                Picker("Visitors", selection: $environment.visitors) {
                    ForEach(VisitorPreference.allCases, id: \.self) { preference in
                        Text(preference.rawValue).tag(preference)
                    }
                }
            }
        }
    }
}

struct SupportPeopleView: View {
    @Binding var supportPeople: [SupportPerson]
    @State private var showingAddPerson = false
    
    var body: some View {
        List {
            Section(header: Text("Support Team")) {
                ForEach(supportPeople) { person in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(person.name)
                            .font(.headline)
                        Text("\(person.relationship) - \(person.role)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .onDelete(perform: deletePerson)
                
                Button(action: { showingAddPerson = true }) {
                    Label("Add Support Person", systemImage: "plus.circle")
                }
            }
        }
        .sheet(isPresented: $showingAddPerson) {
            AddSupportPersonView(supportPeople: $supportPeople)
        }
    }
    
    private func deletePerson(at offsets: IndexSet) {
        supportPeople.remove(atOffsets: offsets)
    }
}

struct AddSupportPersonView: View {
    @Binding var supportPeople: [SupportPerson]
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var relationship = ""
    @State private var role = ""
    @State private var contactNumber = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                TextField("Relationship", text: $relationship)
                TextField("Role during birth", text: $role)
                TextField("Contact Number", text: $contactNumber)
                    .keyboardType(.phonePad)
            }
            .navigationTitle("Add Support Person")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Add") {
                    var person = SupportPerson(
                        name: name,
                        relationship: relationship,
                        role: role
                    )
                    person.contactNumber = contactNumber.isEmpty ? nil : contactNumber
                    supportPeople.append(person)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(name.isEmpty || relationship.isEmpty || role.isEmpty)
            )
        }
    }
}

struct PainManagementView: View {
    @Binding var preferences: PainManagementPreferences
    
    var body: some View {
        Form {
            Section(header: Text("Natural Pain Management")) {
                ForEach(NaturalPainManagement.allCases, id: \.self) { method in
                    MultipleSelectionRow(
                        title: method.rawValue,
                        isSelected: preferences.naturalMethods.contains(method)
                    ) {
                        if preferences.naturalMethods.contains(method) {
                            preferences.naturalMethods.removeAll { $0 == method }
                        } else {
                            preferences.naturalMethods.append(method)
                        }
                    }
                }
            }
            
            Section(header: Text("Medical Pain Management")) {
                Picker("Epidural Preference", selection: $preferences.epiduralPreference) {
                    ForEach(EpiduralPreference.allCases, id: \.self) { preference in
                        Text(preference.rawValue).tag(preference)
                    }
                }
            }
            
            Section(header: Text("Additional Notes")) {
                TextEditor(text: Binding(
                    get: { preferences.additionalNotes ?? "" },
                    set: { preferences.additionalNotes = $0.isEmpty ? nil : $0 }
                ))
                .frame(height: 100)
            }
        }
    }
}

struct LaborPositionsSelectionView: View {
    @Binding var positions: [LaborPosition]
    
    var body: some View {
        List {
            Section(header: Text("Preferred Labor Positions")) {
                ForEach(LaborPosition.allCases, id: \.self) { position in
                    MultipleSelectionRow(
                        title: position.rawValue,
                        isSelected: positions.contains(position)
                    ) {
                        if positions.contains(position) {
                            positions.removeAll { $0 == position }
                        } else {
                            positions.append(position)
                        }
                    }
                }
            }
        }
    }
}

struct NewbornPreferencesView: View {
    @Binding var preferences: NewbornPreferences
    
    var body: some View {
        Form {
            Section(header: Text("Immediate After Birth")) {
                Toggle("Immediate skin-to-skin contact", isOn: $preferences.immediateSkintToSkin)
                Toggle("Delayed cord clamping", isOn: $preferences.delayedCordClamping)
            }
            
            Section(header: Text("Newborn Procedures")) {
                Picker("Vitamin K", selection: $preferences.vitaminK) {
                    ForEach(VitaminKPreference.allCases, id: \.self) { preference in
                        Text(preference.rawValue).tag(preference)
                    }
                }
                
                Toggle("Eye ointment", isOn: $preferences.eyeOintment)
                Toggle("Hepatitis B vaccine", isOn: $preferences.hepatitisB)
                
                Picker("Circumcision", selection: $preferences.circumcision) {
                    ForEach(CircumcisionPreference.allCases, id: \.self) { preference in
                        Text(preference.rawValue).tag(preference)
                    }
                }
            }
            
            Section(header: Text("Feeding")) {
                Picker("Feeding preference", selection: $preferences.feeding) {
                    ForEach(FeedingPreference.allCases, id: \.self) { preference in
                        Text(preference.rawValue).tag(preference)
                    }
                }
            }
        }
    }
}