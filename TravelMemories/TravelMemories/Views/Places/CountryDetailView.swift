import SwiftUI
import SwiftData

struct CountryDetailView: View {
    let countryName: String

    @Environment(\.modelContext) private var modelContext
    @Query private var places: [Place]

    @State private var placeToDelete: Place?

    private let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]

    init(countryName: String) {
        self.countryName = countryName
        let name = countryName
        _places = Query(
            filter: #Predicate<Place> { $0.country == name },
            sort: [SortDescriptor(\Place.city)]
        )
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(places) { place in
                    NavigationLink(value: place) {
                        PhotoCard(
                            title: place.city,
                            subtitle: placeSubtitle(place),
                            photoURL: place.photoURL
                        )
                    }
                    .buttonStyle(.plain)
                    .task {
                        await place.loadPhotoIfNeeded()
                    }
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
        .navigationTitle(countryName)
        .navigationBarTitleDisplayMode(.large)
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

    private func placeSubtitle(_ place: Place) -> String {
        let count = place.recommendations.count
        return "\(count) \(count == 1 ? "place" : "places")"
    }
}
