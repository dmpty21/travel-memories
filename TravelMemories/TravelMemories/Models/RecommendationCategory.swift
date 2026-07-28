import Foundation

enum RecommendationCategory: String, CaseIterable, Identifiable, Codable {
    case restaurant
    case museum
    case park
    case activity
    case coffeeShop

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .restaurant: "Restaurants"
        case .museum: "Museums"
        case .park: "Parks"
        case .activity: "Activities"
        case .coffeeShop: "Coffee Shops"
        }
    }

    var symbolName: String {
        switch self {
        case .restaurant: "fork.knife"
        case .museum: "building.columns"
        case .park: "leaf"
        case .activity: "figure.hiking"
        case .coffeeShop: "cup.and.saucer"
        }
    }
}
