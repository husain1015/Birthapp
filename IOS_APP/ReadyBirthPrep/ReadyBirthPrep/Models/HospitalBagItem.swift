import Foundation

enum HospitalBagCategory: String, CaseIterable, Codable {
    case labor = "Labor"
    case postpartum = "Postpartum"
    case supportPerson = "Support Person"
    case baby = "Baby"
    
    var icon: String {
        switch self {
        case .labor: return "figure.walk"
        case .postpartum: return "heart.circle"
        case .supportPerson: return "person.2"
        case .baby: return "figure.and.child.holdinghands"
        }
    }
    
    var color: String {
        switch self {
        case .labor: return "pink"
        case .postpartum: return "purple"
        case .supportPerson: return "blue"
        case .baby: return "green"
        }
    }
}

struct HospitalBagItem: Identifiable, Codable {
    let id = UUID()
    let name: String
    let category: HospitalBagCategory
    let description: String?
    var isPacked: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case name, category, description, isPacked
    }
}