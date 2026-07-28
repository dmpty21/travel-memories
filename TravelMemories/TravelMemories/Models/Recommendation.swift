import Foundation
import SwiftData

@Model
final class Recommendation {
    var name: String
    var note: String
    var categoryRaw: String
    var isFavorite: Bool
    var createdAt: Date
    var place: Place?

    var address: String?
    var latitude: Double?
    var longitude: Double?

    var category: RecommendationCategory {
        get { RecommendationCategory(rawValue: categoryRaw) ?? .restaurant }
        set { categoryRaw = newValue.rawValue }
    }

    init(
        name: String,
        note: String,
        category: RecommendationCategory,
        isFavorite: Bool = false,
        place: Place? = nil,
        address: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil
    ) {
        self.name = name
        self.note = note
        self.categoryRaw = category.rawValue
        self.isFavorite = isFavorite
        self.createdAt = .now
        self.place = place
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
    }
}
