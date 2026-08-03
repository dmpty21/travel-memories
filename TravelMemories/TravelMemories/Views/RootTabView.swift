import SwiftUI
import SwiftData

struct RootTabView: View {
    @State private var selection = 0

    var body: some View {
        TabView(selection: $selection) {
            Tab("Home", systemImage: "house.fill", value: 0) {
                DashboardView()
            }
            Tab("Places", systemImage: "map", value: 1) {
                PlacesListView()
            }
            Tab("Trips", systemImage: "airplane", value: 2) {
                TripsView()
            }
            Tab("Favorites", systemImage: "star", value: 3) {
                FavoritesView()
            }
            Tab("Profile", systemImage: "person.crop.circle", value: 4) {
                ProfileView()
            }
        }
        #if DEBUG
        .onAppear {
            if let flagIndex = ProcessInfo.processInfo.arguments.firstIndex(of: "-ScreenshotTab"),
               ProcessInfo.processInfo.arguments.indices.contains(flagIndex + 1) {
                let names = ["home", "places", "trips", "favorites", "profile"]
                if let tabIndex = names.firstIndex(of: ProcessInfo.processInfo.arguments[flagIndex + 1].lowercased()) {
                    selection = tabIndex
                }
            }
        }
        #endif
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: [Place.self, Recommendation.self, LogisticsNote.self], inMemory: true)
}
