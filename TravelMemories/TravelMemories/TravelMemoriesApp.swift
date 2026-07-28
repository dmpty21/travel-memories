import SwiftUI
import SwiftData

@main
struct TravelMemoriesApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(for: [Place.self, Recommendation.self, LogisticsNote.self])
    }
}
