import SwiftUI
import SwiftData

struct PlacesListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Place.country), SortDescriptor(\Place.city)]) private var places: [Place]

    @State private var isPresentingAddPlace = false

    private var groupedPlaces: [(country: String, places: [Place])] {
        let groups = Dictionary(grouping: places, by: \.country)
        return groups.keys.sorted().map { country in
            (country, groups[country]!.sorted { $0.city < $1.city })
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if places.isEmpty {
                    ContentUnavailableView(
                        "No Places Yet",
                        systemImage: "map",
                        description: Text("Add a country and city you've visited to start building recommendations.")
                    )
                } else {
                    List {
                        ForEach(groupedPlaces, id: \.country) { group in
                            Section(group.country) {
                                ForEach(group.places) { place in
                                    NavigationLink(value: place) {
                                        Text(place.city)
                                    }
                                }
                                .onDelete { offsets in
                                    delete(placesInGroup: group.places, at: offsets)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Places")
            .navigationDestination(for: Place.self) { place in
                PlaceDetailView(place: place)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isPresentingAddPlace = true
                    } label: {
                        Label("Add Place", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingAddPlace) {
                AddEditPlaceView()
            }
        }
    }

    private func delete(placesInGroup: [Place], at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(placesInGroup[index])
        }
    }
}

#Preview {
    PlacesListView()
        .modelContainer(for: [Place.self, Recommendation.self, LogisticsNote.self], inMemory: true)
}
