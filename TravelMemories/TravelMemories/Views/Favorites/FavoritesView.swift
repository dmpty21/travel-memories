import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Query(
        filter: #Predicate<Recommendation> { $0.isFavorite },
        sort: \Recommendation.name
    ) private var favorites: [Recommendation]

    var body: some View {
        NavigationStack {
            Group {
                if favorites.isEmpty {
                    ContentUnavailableView(
                        "No Favorites Yet",
                        systemImage: "star",
                        description: Text("Star your favorite recommendations and they'll show up here.")
                    )
                } else {
                    List(favorites) { recommendation in
                        if let place = recommendation.place {
                            NavigationLink(value: place) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(recommendation.name)
                                        .font(.body)
                                    Text("\(place.city), \(place.country)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Favorites")
            .navigationDestination(for: Place.self) { place in
                PlaceDetailView(place: place)
            }
        }
    }
}

#Preview {
    FavoritesView()
        .modelContainer(for: [Place.self, Recommendation.self, LogisticsNote.self], inMemory: true)
}
