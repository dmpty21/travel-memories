import SwiftUI
import MapKit
import SwiftData

struct PlaceMapView: View {
    var place: Place

    @Environment(\.dismiss) private var dismiss
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selectedRecommendationID: PersistentIdentifier?

    private var pinned: [Recommendation] {
        (place.recommendations ?? []).filter { $0.latitude != nil && $0.longitude != nil }
    }

    private var selectedRecommendation: Recommendation? {
        guard let selectedRecommendationID else { return nil }
        return pinned.first { $0.id == selectedRecommendationID }
    }

    var body: some View {
        NavigationStack {
            Group {
                if pinned.isEmpty {
                    ContentUnavailableView(
                        "No Locations Yet",
                        systemImage: "map",
                        description: Text("Use \"Look Up Place on Maps\" when adding a recommendation to plot it here.")
                    )
                } else {
                    ZStack(alignment: .bottom) {
                        Map(position: $cameraPosition, selection: $selectedRecommendationID) {
                            ForEach(pinned) { recommendation in
                                Marker(
                                    recommendation.name,
                                    systemImage: recommendation.category.symbolName,
                                    coordinate: CLLocationCoordinate2D(
                                        latitude: recommendation.latitude!,
                                        longitude: recommendation.longitude!
                                    )
                                )
                                .tint(recommendation.isVisited ? .green : .teal)
                                .tag(recommendation.id)
                            }
                        }
                        .mapControls {
                            MapCompass()
                            MapPitchToggle()
                        }

                        VStack {
                            MapLegend()
                                .padding(.top, 8)
                            Spacer()
                        }

                        if let selectedRecommendation {
                            MapSelectionCard(recommendation: selectedRecommendation)
                                .padding()
                        }
                    }
                }
            }
            .navigationTitle("\(place.city) Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                cameraPosition = .region(regionFitting(pinned.map {
                    CLLocationCoordinate2D(latitude: $0.latitude!, longitude: $0.longitude!)
                }))
            }
        }
    }

    private func regionFitting(_ coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        guard !coordinates.isEmpty else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                span: MKCoordinateSpan(latitudeDelta: 60, longitudeDelta: 60)
            )
        }
        let lats = coordinates.map(\.latitude)
        let lons = coordinates.map(\.longitude)
        let minLat = lats.min()!, maxLat = lats.max()!
        let minLon = lons.min()!, maxLon = lons.max()!
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
        let span = MKCoordinateSpan(
            latitudeDelta: max((maxLat - minLat) * 1.6, 0.02),
            longitudeDelta: max((maxLon - minLon) * 1.6, 0.02)
        )
        return MKCoordinateRegion(center: center, span: span)
    }
}

private struct MapLegend: View {
    var body: some View {
        HStack(spacing: 16) {
            legendItem(color: .teal, label: "On the List")
            legendItem(color: .green, label: "Visited")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(.regularMaterial, in: Capsule())
        .shadow(radius: 4)
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .font(.caption.weight(.medium))
        }
    }
}

private struct MapSelectionCard: View {
    let recommendation: Recommendation

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: recommendation.category.symbolName)
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(Color.accentColor, in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(recommendation.name)
                    .font(.headline)
                if let address = recommendation.address, !address.isEmpty {
                    Text(address)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                if let rating = recommendation.rating, rating > 0 {
                    StarRatingView(rating: rating)
                }
            }

            Spacer(minLength: 8)

            if recommendation.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(radius: 8)
    }
}

#Preview {
    let place = Place(country: "Japan", city: "Tokyo")
    let rec = Recommendation(
        name: "Sukiyabashi Jiro",
        note: "World-famous sushi",
        category: .restaurant,
        isFavorite: true,
        place: place,
        address: "Tokyo, Japan",
        latitude: 35.6712,
        longitude: 139.7625
    )
    place.recommendations = [rec]
    return PlaceMapView(place: place)
}
