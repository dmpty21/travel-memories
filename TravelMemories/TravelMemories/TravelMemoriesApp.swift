import SwiftUI
import SwiftData

@main
struct TravelMemoriesApp: App {
    @State private var isShowingSplash = true

    static let modelContainer: ModelContainer = makeModelContainer()

    var body: some Scene {
        WindowGroup {
            if isShowingSplash {
                SplashView {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isShowingSplash = false
                    }
                }
            } else {
                AppRootView()
            }
        }
        .modelContainer(Self.modelContainer)
    }

    private static func makeModelContainer() -> ModelContainer {
        let schema = Schema([Place.self, Recommendation.self, LogisticsNote.self, Trip.self, TripItem.self, Profile.self])

        let cloudConfiguration = ModelConfiguration(schema: schema, cloudKitDatabase: .automatic)
        if let container = try? ModelContainer(for: schema, configurations: [cloudConfiguration]) {
            return container
        }

        // CloudKit isn't set up yet (Xcode iCloud capability missing, or sync unavailable) —
        // fall back to a local-only store so the app still runs.
        let localConfiguration = ModelConfiguration(schema: schema, cloudKitDatabase: .none)
        if let container = try? ModelContainer(for: schema, configurations: [localConfiguration]) {
            return container
        }

        fatalError("Failed to create ModelContainer with both CloudKit and local-only configurations")
    }
}
