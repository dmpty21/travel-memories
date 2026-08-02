import SwiftUI
import SwiftData

struct AddEditReservationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var trip: Trip
    var reservation: Reservation?
    var initialType: ReservationType = .hotel

    @State private var type: ReservationType = .hotel
    @State private var hotelName: String = ""
    @State private var address: String = ""
    @State private var airline: String = ""
    @State private var flightNumber: String = ""
    @State private var departureAirport: String = ""
    @State private var arrivalAirport: String = ""
    @State private var startDate: Date = .now
    @State private var endDate: Date = .now
    @State private var confirmationNumber: String = ""
    @State private var notes: String = ""

    private var isEditing: Bool { reservation != nil }

    private var isValid: Bool {
        switch type {
        case .hotel:
            return !hotelName.trimmingCharacters(in: .whitespaces).isEmpty
        case .flight:
            return !flightNumber.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Picker("Type", selection: $type) {
                    ForEach(ReservationType.allCases) { type in
                        Label(type.displayName, systemImage: type.symbolName).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .disabled(isEditing)

                switch type {
                case .hotel:
                    hotelFields
                case .flight:
                    flightFields
                }

                Section("Confirmation") {
                    TextField("Confirmation Number", text: $confirmationNumber)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(isEditing ? "Edit \(type.displayName)" : "Add \(type.displayName)")
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
                if let reservation {
                    type = reservation.type
                    hotelName = reservation.hotelName
                    address = reservation.address ?? ""
                    airline = reservation.airline
                    flightNumber = reservation.flightNumber
                    departureAirport = reservation.departureAirport ?? ""
                    arrivalAirport = reservation.arrivalAirport ?? ""
                    startDate = reservation.startDate ?? .now
                    endDate = reservation.endDate ?? .now
                    confirmationNumber = reservation.confirmationNumber
                    notes = reservation.notes
                } else {
                    type = initialType
                    startDate = trip.startDate
                    endDate = trip.endDate
                }
            }
        }
    }

    private var hotelFields: some View {
        Section("Hotel") {
            TextField("Hotel Name", text: $hotelName)
            TextField("Address", text: $address)
            DatePicker("Check-in", selection: $startDate, displayedComponents: .date)
            DatePicker("Check-out", selection: $endDate, in: startDate..., displayedComponents: .date)
        }
    }

    private var flightFields: some View {
        Section("Flight") {
            TextField("Airline", text: $airline)
            TextField("Flight Number", text: $flightNumber)
                .textInputAutocapitalization(.characters)
            TextField("Departure Airport (e.g. JFK)", text: $departureAirport)
                .textInputAutocapitalization(.characters)
            TextField("Arrival Airport (e.g. NRT)", text: $arrivalAirport)
                .textInputAutocapitalization(.characters)
            DatePicker("Departure", selection: $startDate)
            DatePicker("Arrival", selection: $endDate, in: startDate...)
        }
    }

    private func save() {
        let trimmedConfirmation = confirmationNumber.trimmingCharacters(in: .whitespaces)
        let trimmedNotes = notes.trimmingCharacters(in: .whitespaces)
        let trimmedAddress = address.trimmingCharacters(in: .whitespaces)
        let trimmedDeparture = departureAirport.trimmingCharacters(in: .whitespaces)
        let trimmedArrival = arrivalAirport.trimmingCharacters(in: .whitespaces)

        if let reservation {
            reservation.type = type
            reservation.hotelName = hotelName.trimmingCharacters(in: .whitespaces)
            reservation.address = trimmedAddress.isEmpty ? nil : trimmedAddress
            reservation.airline = airline.trimmingCharacters(in: .whitespaces)
            reservation.flightNumber = flightNumber.trimmingCharacters(in: .whitespaces)
            reservation.departureAirport = trimmedDeparture.isEmpty ? nil : trimmedDeparture
            reservation.arrivalAirport = trimmedArrival.isEmpty ? nil : trimmedArrival
            reservation.startDate = startDate
            reservation.endDate = endDate
            reservation.confirmationNumber = trimmedConfirmation
            reservation.notes = trimmedNotes
        } else {
            let newReservation = Reservation(
                type: type,
                confirmationNumber: trimmedConfirmation,
                notes: trimmedNotes,
                startDate: startDate,
                endDate: endDate,
                hotelName: hotelName.trimmingCharacters(in: .whitespaces),
                address: trimmedAddress.isEmpty ? nil : trimmedAddress,
                airline: airline.trimmingCharacters(in: .whitespaces),
                flightNumber: flightNumber.trimmingCharacters(in: .whitespaces),
                departureAirport: trimmedDeparture.isEmpty ? nil : trimmedDeparture,
                arrivalAirport: trimmedArrival.isEmpty ? nil : trimmedArrival,
                trip: trip
            )
            modelContext.insert(newReservation)
        }
        dismiss()
    }
}

#Preview {
    let trip = Trip(destination: "Kyoto, Japan", startDate: .now, endDate: .now.addingTimeInterval(86400 * 5), type: .leisure)
    return AddEditReservationView(trip: trip)
        .modelContainer(for: [Trip.self, Reservation.self], inMemory: true)
}
