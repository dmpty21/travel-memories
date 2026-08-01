import Foundation
import SwiftData

@Model
final class Profile {
    var name: String = ""
    var createdAt: Date = Date.now

    init(name: String) {
        self.name = name
        self.createdAt = .now
    }
}
