import SwiftUI
import SwiftData
import MapKit

struct AddEditPlaceView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var place: Place?

    @State private var country: String = ""
    @State private var city: String = ""
    @StateObject private var searchCompleter = CitySearchCompleter()
    @FocusState private var isCityFieldFocused: Bool

    private var isEditing: Bool { place != nil }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Country", text: $country)

                TextField("City", text: $city)
                    .focused($isCityFieldFocused)
                    .onChange(of: city) { _, newValue in
                        searchCompleter.updateQuery(newValue)
                    }

                if isCityFieldFocused && !searchCompleter.suggestions.isEmpty {
                    ForEach(searchCompleter.suggestions, id: \.self) { suggestion in
                        Button {
                            select(suggestion)
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(suggestion.title)
                                    .foregroundStyle(.primary)
                                if !suggestion.subtitle.isEmpty {
                                    Text(suggestion.subtitle)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Place" : "Add Place")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(country.trimmingCharacters(in: .whitespaces).isEmpty
                                  || city.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let place {
                    country = place.country
                    city = place.city
                }
            }
        }
    }

    private func select(_ suggestion: MKLocalSearchCompletion) {
        isCityFieldFocused = false
        searchCompleter.clear()

        let request = MKLocalSearch.Request(completion: suggestion)
        let search = MKLocalSearch(request: request)

        Task {
            guard let response = try? await search.start(),
                  let placemark = response.mapItems.first?.placemark else { return }
            await MainActor.run {
                city = placemark.locality ?? suggestion.title
                if let resolvedCountry = placemark.country {
                    country = resolvedCountry
                }
            }
        }
    }

    private func save() {
        let trimmedCountry = country.trimmingCharacters(in: .whitespaces)
        let trimmedCity = city.trimmingCharacters(in: .whitespaces)

        if let place {
            place.country = trimmedCountry
            place.city = trimmedCity
        } else {
            let newPlace = Place(country: trimmedCountry, city: trimmedCity)
            modelContext.insert(newPlace)
        }
        dismiss()
    }
}

#Preview {
    AddEditPlaceView()
        .modelContainer(for: [Place.self, Recommendation.self, LogisticsNote.self], inMemory: true)
}
