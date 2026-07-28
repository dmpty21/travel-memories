import Foundation
import SwiftData

@Model
final class Place {
    var country: String
    var city: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Recommendation.place)
    var recommendations: [Recommendation] = []

    @Relationship(deleteRule: .cascade, inverse: \LogisticsNote.place)
    var logisticsNotes: [LogisticsNote] = []

    init(country: String, city: String) {
        self.country = country
        self.city = city
        self.createdAt = .now
    }
}
