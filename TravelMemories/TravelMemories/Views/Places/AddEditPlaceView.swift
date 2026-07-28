import SwiftUI
import SwiftData

struct AddEditPlaceView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var place: Place?

    @State private var country: String = ""
    @State private var city: String = ""

    private var isEditing: Bool { place != nil }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Country", text: $country)
                TextField("City", text: $city)
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
