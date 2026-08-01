import Foundation

enum TripType: String, CaseIterable, Identifiable, Codable {
    case business
    case leisure

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .business: "Business"
        case .leisure: "Leisure"
        }
    }

    var symbolName: String {
        switch self {
        case .business: "briefcase.fill"
        case .leisure: "sun.max.fill"
        }
    }
}
