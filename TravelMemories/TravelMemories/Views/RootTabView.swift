import SwiftUI
import SwiftData

struct RootTabView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                DashboardView()
            }
            Tab("Places", systemImage: "map") {
                PlacesListView()
            }
            Tab("Trips", systemImage: "airplane") {
                TripsView()
            }
            Tab("Favorites", systemImage: "star") {
                FavoritesView()
            }
            Tab("Profile", systemImage: "person.crop.circle") {
                ProfileView()
            }
        }
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: [Place.self, Recommendation.self, LogisticsNote.self], inMemory: true)
}
