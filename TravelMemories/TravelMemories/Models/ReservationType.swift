import Foundation

enum ReservationType: String, CaseIterable, Identifiable, Codable {
    case hotel
    case flight

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .hotel: "Hotel"
        case .flight: "Flight"
        }
    }

    var symbolName: String {
        switch self {
        case .hotel: "bed.double.fill"
        case .flight: "airplane"
        }
    }
}
