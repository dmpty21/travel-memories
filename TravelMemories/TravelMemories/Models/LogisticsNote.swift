import Foundation
import SwiftData

@Model
final class LogisticsNote {
    var text: String
    var createdAt: Date
    var place: Place?

    init(text: String, place: Place? = nil) {
        self.text = text
        self.createdAt = .now
        self.place = place
    }
}
