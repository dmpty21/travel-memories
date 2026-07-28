import Foundation
import MapKit
import Combine

final class PlaceLookupCompleter: NSObject, ObservableObject {
    @Published var suggestions: [MKLocalSearchCompletion] = []

    private let completer: MKLocalSearchCompleter

    override init() {
        completer = MKLocalSearchCompleter()
        super.init()
        completer.resultTypes = .pointOfInterest
        completer.delegate = self
    }

    func biasSearch(near cityName: String, country: String) {
        Task {
            let geocoder = CLGeocoder()
            guard let placemark = try? await geocoder.geocodeAddressString("\(cityName), \(country)").first,
                  let coordinate = placemark.location?.coordinate else { return }
            await MainActor.run {
                completer.region = MKCoordinateRegion(
                    center: coordinate,
                    latitudinalMeters: 50_000,
                    longitudinalMeters: 50_000
                )
            }
        }
    }

    func updateQuery(_ query: String) {
        completer.queryFragment = query
    }

    func clear() {
        completer.queryFragment = ""
        suggestions = []
    }
}

extension PlaceLookupCompleter: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        suggestions = completer.results
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        suggestions = []
    }
}
