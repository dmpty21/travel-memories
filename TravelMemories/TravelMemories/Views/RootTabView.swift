import SwiftUI
import SwiftData

struct RootTabView: View {
    var body: some View {
        TabView {
            Tab("Places", systemImage: "map") {
                PlacesListView()
            }
            Tab("Favorites", systemImage: "star") {
                FavoritesView()
            }
        }
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: [Place.self, Recommendation.self, LogisticsNote.self], inMemory: true)
}
