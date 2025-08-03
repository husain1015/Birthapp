import SwiftUI

struct HospitalBagChecklistView: View {
    @State private var selectedCategory: HospitalBagCategory = .labor
    @State private var items: [HospitalBagItem] = []
    @State private var showingAddItem = false
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category Picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(HospitalBagCategory.allCases, id: \.self) { category in
                            CategoryTab(
                                category: category,
                                isSelected: selectedCategory == category,
                                action: { selectedCategory = category }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                
                // Progress Bar
                ProgressBarView(items: filteredItems)
                    .padding()
                
                // Checklist
                List {
                    ForEach(filteredItems) { item in
                        if let index = items.firstIndex(where: { $0.id == item.id }) {
                            HospitalBagItemRow(item: $items[index])
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("Hospital Bag Checklist")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddItem = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .environment(\.editMode, $editMode)
            .sheet(isPresented: $showingAddItem) {
                AddItemView(items: $items, category: selectedCategory)
            }
            .onAppear {
                loadDefaultItems()
            }
        }
    }
    
    private var filteredItems: [HospitalBagItem] {
        items.filter { $0.category == selectedCategory }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        let itemsToDelete = offsets.map { filteredItems[$0] }
        items.removeAll { item in
            itemsToDelete.contains { $0.id == item.id }
        }
    }
    
    private func loadDefaultItems() {
        items = [
            // Labor Items
            HospitalBagItem(name: "Comfortable clothing - easy to remove", category: .labor, description: nil),
            HospitalBagItem(name: "Labor playlist (if desired)", category: .labor, description: nil),
            HospitalBagItem(name: "Headphones", category: .labor, description: nil),
            HospitalBagItem(name: "Pillow (pregnancy pillow or regular)", category: .labor, description: nil),
            HospitalBagItem(name: "Pictures (if desired)", category: .labor, description: nil),
            HospitalBagItem(name: "Favorite snacks", category: .labor, description: nil),
            HospitalBagItem(name: "Hydrating beverages", category: .labor, description: nil),
            HospitalBagItem(name: "Socks/slippers/flip flops", category: .labor, description: nil),
            HospitalBagItem(name: "Warm blanket", category: .labor, description: nil),
            HospitalBagItem(name: "Camera (batteries/charger)", category: .labor, description: nil),
            HospitalBagItem(name: "Phone chargers", category: .labor, description: nil),
            HospitalBagItem(name: "Wallet & insurance cards", category: .labor, description: nil),
            HospitalBagItem(name: "Birth plan (if applicable)", category: .labor, description: nil),
            HospitalBagItem(name: "LED candles/soft lights", category: .labor, description: "Set the mood"),
            HospitalBagItem(name: "TENS machine", category: .labor, description: nil),
            HospitalBagItem(name: "Combs", category: .labor, description: "Pain management"),
            HospitalBagItem(name: "Baby wrap/rebozo", category: .labor, description: "Shaking apple tree"),
            HospitalBagItem(name: "Birthing ball/peanut ball", category: .labor, description: "Hospitals may provide"),
            
            // Postpartum Items
            HospitalBagItem(name: "Toothbrush & toothpaste", category: .postpartum, description: nil),
            HospitalBagItem(name: "Lip balm", category: .postpartum, description: nil),
            HospitalBagItem(name: "Travel sized shampoo/conditioner", category: .postpartum, description: nil),
            HospitalBagItem(name: "Deodorant", category: .postpartum, description: nil),
            HospitalBagItem(name: "Loofah/shower sponge", category: .postpartum, description: nil),
            HospitalBagItem(name: "Flip flops", category: .postpartum, description: nil),
            HospitalBagItem(name: "Hairbrush", category: .postpartum, description: nil),
            HospitalBagItem(name: "Hair ties/clips", category: .postpartum, description: nil),
            HospitalBagItem(name: "Gowns or pajamas", category: .postpartum, description: nil),
            HospitalBagItem(name: "Nursing bra and/or gowns to access nursing", category: .postpartum, description: nil),
            HospitalBagItem(name: "Socks/slippers", category: .postpartum, description: nil),
            HospitalBagItem(name: "Blanket & pillow", category: .postpartum, description: nil),
            HospitalBagItem(name: "Favorite snacks and beverages", category: .postpartum, description: nil),
            HospitalBagItem(name: "Underwear", category: .postpartum, description: "Depends or Frida Mom"),
            HospitalBagItem(name: "Ice packs", category: .postpartum, description: "Frida Mom recovery pack"),
            HospitalBagItem(name: "Peri bottle", category: .postpartum, description: nil),
            HospitalBagItem(name: "Witch hazel pads", category: .postpartum, description: nil),
            HospitalBagItem(name: "Nipple cream", category: .postpartum, description: nil),
            
            // Support Person Items
            HospitalBagItem(name: "Toiletries or grooming supplies", category: .supportPerson, description: nil),
            HospitalBagItem(name: "Underwear", category: .supportPerson, description: nil),
            HospitalBagItem(name: "Sweatshirt", category: .supportPerson, description: nil),
            HospitalBagItem(name: "Socks/slippers", category: .supportPerson, description: nil),
            HospitalBagItem(name: "Sandals/flip flops", category: .supportPerson, description: nil),
            HospitalBagItem(name: "Swimsuit", category: .supportPerson, description: "If wanting to accompany in shower or tub"),
            HospitalBagItem(name: "Comfortable clothing", category: .supportPerson, description: nil),
            HospitalBagItem(name: "PJ's", category: .supportPerson, description: nil),
            HospitalBagItem(name: "Wallet & insurance cards", category: .supportPerson, description: nil),
            HospitalBagItem(name: "Pillow & blanket", category: .supportPerson, description: nil),
            HospitalBagItem(name: "Copy of birth plan", category: .supportPerson, description: nil),
            HospitalBagItem(name: "Toothbrush & toothpaste", category: .supportPerson, description: nil),
            HospitalBagItem(name: "Favorite snacks and beverages", category: .supportPerson, description: nil),
            HospitalBagItem(name: "Personal bath towels", category: .supportPerson, description: nil),
            HospitalBagItem(name: "Phone numbers of people to call", category: .supportPerson, description: nil),
            
            // Baby Items
            HospitalBagItem(name: "2-3 onesies size 0-3 months", category: .baby, description: nil),
            HospitalBagItem(name: "Going home outfit", category: .baby, description: nil),
            HospitalBagItem(name: "1-2 pacifiers (if wanted)", category: .baby, description: nil),
            HospitalBagItem(name: "Car seat (installed!)", category: .baby, description: nil),
            HospitalBagItem(name: "Vaseline or organic coconut oil", category: .baby, description: "For helping meconium poops cleanup"),
            HospitalBagItem(name: "1-2 hats", category: .baby, description: nil),
            HospitalBagItem(name: "1-2 blankets and/or swaddles", category: .baby, description: nil),
            HospitalBagItem(name: "1 small pack of diapers - size 1", category: .baby, description: nil),
            HospitalBagItem(name: "1 pack of wipes", category: .baby, description: nil),
            HospitalBagItem(name: "Breast pump & bottles", category: .baby, description: "If exclusively pumping"),
            HospitalBagItem(name: "Hand expressed colostrum", category: .baby, description: "If applicable"),
        ]
    }
}

struct CategoryTab: View {
    let category: HospitalBagCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: category.icon)
                    .font(.title2)
                Text(category.rawValue)
                    .font(.caption)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? AppConstants.primaryColor : Color(.systemGray5))
            )
        }
    }
}

struct ProgressBarView: View {
    let items: [HospitalBagItem]
    
    private var progress: Double {
        guard !items.isEmpty else { return 0 }
        let packedCount = Double(items.filter { $0.isPacked }.count)
        return packedCount / Double(items.count)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(Int(progress * 100))% Complete")
                    .font(.headline)
                Spacer()
                Text("\(items.filter { $0.isPacked }.count) of \(items.count) items")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color(.systemGray5))
                        .frame(height: 10)
                    
                    RoundedRectangle(cornerRadius: 5)
                        .fill(AppConstants.primaryColor)
                        .frame(width: geometry.size.width * progress, height: 10)
                        .animation(.easeInOut, value: progress)
                }
            }
            .frame(height: 10)
        }
    }
}

struct HospitalBagItemRow: View {
    @Binding var item: HospitalBagItem
    
    var body: some View {
        HStack {
            Button(action: { item.isPacked.toggle() }) {
                Image(systemName: item.isPacked ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isPacked ? AppConstants.primaryColor : .gray)
                    .font(.title2)
            }
            .buttonStyle(BorderlessButtonStyle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.body)
                    .strikethrough(item.isPacked)
                    .foregroundColor(item.isPacked ? .secondary : .primary)
                
                if let description = item.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct AddItemView: View {
    @Binding var items: [HospitalBagItem]
    let category: HospitalBagCategory
    @State private var itemName = ""
    @State private var itemDescription = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Item name", text: $itemName)
                    TextField("Description (optional)", text: $itemDescription)
                }
                
                Section(header: Text("Category")) {
                    Text(category.rawValue)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Add Item")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Add") {
                    addItem()
                }
                .disabled(itemName.isEmpty)
            )
        }
    }
    
    private func addItem() {
        let newItem = HospitalBagItem(
            name: itemName,
            category: category,
            description: itemDescription.isEmpty ? nil : itemDescription
        )
        items.append(newItem)
        presentationMode.wrappedValue.dismiss()
    }
}