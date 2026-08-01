import SwiftUI
import SwiftData

struct PlacesListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Place.country), SortDescriptor(\Place.city)]) private var places: [Place]

    @State private var isPresentingAddPlace = false
    @State private var searchText = ""
    @State private var placeToDelete: Place?

    private let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]

    private var groupedByCountry: [(country: String, places: [Place])] {
        let groups = Dictionary(grouping: places, by: \.country)
        return groups.keys.sorted().map { country in
            (country, groups[country]!.sorted { $0.city < $1.city })
        }
    }

    private var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var searchResults: [Place] {
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        guard !query.isEmpty else { return [] }
        return places
            .filter { $0.city.lowercased().contains(query) || $0.country.lowercased().contains(query) }
            .sorted { $0.city < $1.city }
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.atlasGround)
                } else if isSearching {
                    if searchResults.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(searchResults) { place in
                                    NavigationLink(value: place) {
                                        PhotoCard(title: place.city, subtitle: place.country, imageData: place.photoData)
                                    }
                                    .buttonStyle(.plain)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            placeToDelete = place
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
                        .background(Color.atlasGround)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(groupedByCountry, id: \.country) { group in
                                NavigationLink(value: group.country) {
                                    PhotoCard(
                                        title: group.country,
                                        subtitle: countrySubtitle(group.places),
                                        imageData: group.places.first(where: { $0.photoData != nil })?.photoData
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                    .background(Color.atlasGround)
                }
            }
            .navigationTitle("Places")
            .searchable(text: $searchText, prompt: "Search countries or cities")
            .navigationDestination(for: Place.self) { place in
                PlaceDetailView(place: place)
            }
            .navigationDestination(for: String.self) { countryName in
                CountryDetailView(countryName: countryName)
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
            .confirmationDialog(
                "Delete \(placeToDelete?.city ?? "")?",
                isPresented: Binding(get: { placeToDelete != nil }, set: { if !$0 { placeToDelete = nil } }),
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    if let placeToDelete {
                        modelContext.delete(placeToDelete)
                    }
                    placeToDelete = nil
                }
                Button("Cancel", role: .cancel) {
                    placeToDelete = nil
                }
            } message: {
                if let placeToDelete {
                    Text("This will also delete its \(placeToDelete.recommendations.count) recommendations and \(placeToDelete.logisticsNotes.count) logistics notes.")
                }
            }
        }
    }

    private func countrySubtitle(_ places: [Place]) -> String {
        let cityCount = places.count
        let placeCount = places.reduce(0) { $0 + $1.recommendations.count }
        let cityWord = cityCount == 1 ? "city" : "cities"
        let placeWord = placeCount == 1 ? "place" : "places"
        return "\(cityCount) \(cityWord) · \(placeCount) \(placeWord)"
    }
}

#Preview {
    PlacesListView()
        .modelContainer(for: [Place.self, Recommendation.self, LogisticsNote.self], inMemory: true)
}
