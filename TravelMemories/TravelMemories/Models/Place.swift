import Foundation
import SwiftData

@Model
final class Place {
    var country: String
    var city: String
    var createdAt: Date

    @Attribute(.externalStorage) var photoData: Data?

    @Relationship(deleteRule: .cascade, inverse: \Recommendation.place)
    var recommendations: [Recommendation] = []

    @Relationship(deleteRule: .cascade, inverse: \LogisticsNote.place)
    var logisticsNotes: [LogisticsNote] = []

    @Relationship(deleteRule: .nullify, inverse: \Trip.place)
    var trips: [Trip] = []

    init(country: String, city: String) {
        self.country = country
        self.city = city
        self.createdAt = .now
    }
}
