import SwiftUI
import SwiftData
import MapKit
import Contacts

struct AddEditRecommendationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    var place: Place
    var recommendation: Recommendation?

    @State private var name: String = ""
    @State private var note: String = ""
    @State private var category: RecommendationCategory = .restaurant
    @State private var isFavorite: Bool = false
    @State private var rating: Int = 0
    @State private var address: String = ""
    @State private var latitude: Double?
    @State private var longitude: Double?
    @State private var isPresentingLookup = false

    private var isEditing: Bool { recommendation != nil }

    private var mapsURL: URL? {
        guard let latitude, let longitude else { return nil }
        var components = URLComponents(string: "http://maps.apple.com/")
        components?.queryItems = [
            URLQueryItem(name: "ll", value: "\(latitude),\(longitude)"),
            URLQueryItem(name: "q", value: name)
        ]
        return components?.url
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)

                Picker("Category", selection: $category) {
                    ForEach(RecommendationCategory.allCases) { category in
                        Label(category.displayName, systemImage: category.symbolName)
                            .tag(category)
                    }
                }

                TextField("Note", text: $note, axis: .vertical)
                    .lineLimit(3...6)

                Toggle("Favorite", isOn: $isFavorite)

                HStack {
                    Text("My Rating")
                    Spacer()
                    StarRatingControl(rating: $rating)
                }

                Section {
                    Button {
                        isPresentingLookup = true
                    } label: {
                        Label("Look Up Place on Maps", systemImage: "map")
                    }

                    TextField("Address", text: $address, axis: .vertical)
                        .lineLimit(2...4)

                    if let mapsURL {
                        Button {
                            openURL(mapsURL)
                        } label: {
                            Label("Open in Maps", systemImage: "arrow.up.right.square")
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Recommendation" : "Add Recommendation")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let recommendation {
                    name = recommendation.name
                    note = recommendation.note
                    category = recommendation.category
                    isFavorite = recommendation.isFavorite
                    rating = recommendation.rating ?? 0
                    address = recommendation.address ?? ""
                    latitude = recommendation.latitude
                    longitude = recommendation.longitude
                }
            }
            .sheet(isPresented: $isPresentingLookup) {
                PlaceLookupSheet(cityName: place.city, country: place.country) { mapItem in
                    applyLookup(mapItem)
                }
            }
        }
    }

    private func applyLookup(_ mapItem: MKMapItem) {
        if let mapItemName = mapItem.name, !mapItemName.isEmpty {
            name = mapItemName
        }
        address = formattedAddress(from: mapItem.placemark)
        latitude = mapItem.placemark.coordinate.latitude
        longitude = mapItem.placemark.coordinate.longitude
    }

    private func formattedAddress(from placemark: MKPlacemark) -> String {
        if let postalAddress = placemark.postalAddress {
            return CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress)
                .replacingOccurrences(of: "\n", with: ", ")
        }
        return placemark.title ?? ""
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedAddress = address.trimmingCharacters(in: .whitespacesAndNewlines)

        if let recommendation {
            recommendation.name = trimmedName
            recommendation.note = note
            recommendation.category = category
            recommendation.isFavorite = isFavorite
            recommendation.rating = rating == 0 ? nil : rating
            recommendation.address = trimmedAddress.isEmpty ? nil : trimmedAddress
            recommendation.latitude = latitude
            recommendation.longitude = longitude
        } else {
            let newRecommendation = Recommendation(
                name: trimmedName,
                note: note,
                category: category,
                isFavorite: isFavorite,
                place: place,
                address: trimmedAddress.isEmpty ? nil : trimmedAddress,
                latitude: latitude,
                longitude: longitude,
                rating: rating == 0 ? nil : rating
            )
            modelContext.insert(newRecommendation)
        }
        dismiss()
    }
}

#Preview {
    let place = Place(country: "Japan", city: "Tokyo")
    return AddEditRecommendationView(place: place)
        .modelContainer(for: [Place.self, Recommendation.self, LogisticsNote.self], inMemory: true)
}
