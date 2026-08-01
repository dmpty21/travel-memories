import SwiftUI
import SwiftData
import MapKit

struct AddEditTripView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var trip: Trip?

    @Query(sort: [SortDescriptor(\Place.country), SortDescriptor(\Place.city)]) private var places: [Place]

    @State private var destination: String = ""
    @State private var startDate: Date = .now
    @State private var endDate: Date = .now
    @State private var type: TripType = .leisure
    @State private var selectedPlace: Place?
    @StateObject private var searchCompleter = CitySearchCompleter()
    @FocusState private var isDestinationFieldFocused: Bool

    private var isEditing: Bool { trip != nil }

    private var isValid: Bool {
        let hasDestination = !destination.trimmingCharacters(in: .whitespaces).isEmpty || selectedPlace != nil
        return hasDestination && endDate >= startDate
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Destination", text: $destination)
                    .focused($isDestinationFieldFocused)
                    .onChange(of: destination) { _, newValue in
                        searchCompleter.updateQuery(newValue)
                    }

                if isDestinationFieldFocused && !searchCompleter.suggestions.isEmpty {
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

                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: .date)

                Picker("Type", selection: $type) {
                    ForEach(TripType.allCases) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(.segmented)

                Picker("Linked Place", selection: $selectedPlace) {
                    Text("None").tag(Place?.none)
                    ForEach(places) { place in
                        Text("\(place.city), \(place.country)").tag(Place?.some(place))
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Trip" : "Add Trip")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!isValid)
                }
            }
            .onAppear {
                if let trip {
                    destination = trip.destination
                    startDate = trip.startDate
                    endDate = trip.endDate
                    type = trip.type
                    selectedPlace = trip.place
                }
            }
            .onChange(of: startDate) { _, newValue in
                if endDate < newValue {
                    endDate = newValue
                }
            }
        }
    }

    private func select(_ suggestion: MKLocalSearchCompletion) {
        isDestinationFieldFocused = false
        searchCompleter.clear()
        destination = suggestion.subtitle.isEmpty ? suggestion.title : "\(suggestion.title), \(suggestion.subtitle)"
    }

    private func save() {
        var trimmedDestination = destination.trimmingCharacters(in: .whitespaces)
        if trimmedDestination.isEmpty, let selectedPlace {
            trimmedDestination = "\(selectedPlace.city), \(selectedPlace.country)"
        }

        if let trip {
            trip.destination = trimmedDestination
            trip.startDate = startDate
            trip.endDate = endDate
            trip.type = type
            trip.place = selectedPlace
        } else {
            let newTrip = Trip(destination: trimmedDestination, startDate: startDate, endDate: endDate, type: type)
            newTrip.place = selectedPlace
            modelContext.insert(newTrip)
        }
        dismiss()
    }
}

#Preview {
    AddEditTripView()
        .modelContainer(for: [Place.self, Trip.self, TripItem.self], inMemory: true)
}
