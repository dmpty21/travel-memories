import Foundation
import SwiftData

@Model
final class TripItem {
    var name: String = ""
    var note: String = ""
    var categoryRaw: String = RecommendationCategory.activity.rawValue
    var isCompleted: Bool = false
    var createdAt: Date = Date.now
    var trip: Trip?

    var category: RecommendationCategory {
        get { RecommendationCategory(rawValue: categoryRaw) ?? .activity }
        set { categoryRaw = newValue.rawValue }
    }

    init(
        name: String,
        note: String,
        category: RecommendationCategory,
        isCompleted: Bool,
        trip: Trip? = nil
    ) {
        self.name = name
        self.note = note
        self.categoryRaw = category.rawValue
        self.isCompleted = isCompleted
        self.createdAt = .now
        self.trip = trip
    }
}
