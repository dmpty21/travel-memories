import SwiftUI
import SwiftData

struct FavoritesView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "No Favorites Yet",
                systemImage: "star",
                description: Text("Star your favorite recommendations and they'll show up here.")
            )
            .navigationTitle("Favorites")
        }
    }
}

#Preview {
    FavoritesView()
        .modelContainer(for: [Place.self, Recommendation.self, LogisticsNote.self], inMemory: true)
}
