import Foundation
import SwiftData

@Model
final class Reservation {
    var typeRaw: String = ReservationType.hotel.rawValue
    var confirmationNumber: String = ""
    var notes: String = ""
    var startDate: Date?
    var endDate: Date?
    var createdAt: Date = Date.now
    var trip: Trip?

    // Hotel-specific
    var hotelName: String = ""
    var address: String?

    // Flight-specific (kept ready for a future flight-status integration)
    var airline: String = ""
    var flightNumber: String = ""
    var departureAirport: String?
    var arrivalAirport: String?

    var type: ReservationType {
        get { ReservationType(rawValue: typeRaw) ?? .hotel }
        set { typeRaw = newValue.rawValue }
    }

    var title: String {
        switch type {
        case .hotel:
            return hotelName
        case .flight:
            let code = [airline, flightNumber].filter { !$0.isEmpty }.joined(separator: " ")
            return code.isEmpty ? "Flight" : code
        }
    }

    var subtitle: String {
        switch type {
        case .hotel:
            return address ?? ""
        case .flight:
            let route = [departureAirport, arrivalAirport].compactMap { $0 }.filter { !$0.isEmpty }
            return route.joined(separator: " → ")
        }
    }

    init(
        type: ReservationType,
        confirmationNumber: String = "",
        notes: String = "",
        startDate: Date? = nil,
        endDate: Date? = nil,
        hotelName: String = "",
        address: String? = nil,
        airline: String = "",
        flightNumber: String = "",
        departureAirport: String? = nil,
        arrivalAirport: String? = nil,
        trip: Trip? = nil
    ) {
        self.typeRaw = type.rawValue
        self.confirmationNumber = confirmationNumber
        self.notes = notes
        self.startDate = startDate
        self.endDate = endDate
        self.hotelName = hotelName
        self.address = address
        self.airline = airline
        self.flightNumber = flightNumber
        self.departureAirport = departureAirport
        self.arrivalAirport = arrivalAirport
        self.createdAt = .now
        self.trip = trip
    }
}
