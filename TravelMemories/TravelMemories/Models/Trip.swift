import Foundation
import SwiftData

@Model
final class Trip {
    var destination: String
    var startDate: Date
    var endDate: Date
    var typeRaw: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \TripItem.trip)
    var items: [TripItem] = []

    var type: TripType {
        get { TripType(rawValue: typeRaw) ?? .leisure }
        set { typeRaw = newValue.rawValue }
    }

    var isUpcoming: Bool {
        endDate >= Calendar.current.startOfDay(for: .now)
    }

    var dateRangeText: String {
        let calendar = Calendar.current
        let sameYear = calendar.component(.year, from: startDate) == calendar.component(.year, from: endDate)
        let sameMonth = sameYear && calendar.component(.month, from: startDate) == calendar.component(.month, from: endDate)

        if sameMonth {
            return "\(startDate.formatted(.dateTime.month(.abbreviated).day()))–\(endDate.formatted(.dateTime.day()))"
        } else if sameYear {
            return "\(startDate.formatted(.dateTime.month(.abbreviated).day())) – \(endDate.formatted(.dateTime.month(.abbreviated).day()))"
        } else {
            return "\(startDate.formatted(.dateTime.month(.abbreviated).day().year())) – \(endDate.formatted(.dateTime.month(.abbreviated).day().year()))"
        }
    }

    init(destination: String, startDate: Date, endDate: Date, type: TripType) {
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
        self.typeRaw = type.rawValue
        self.createdAt = .now
    }
}
