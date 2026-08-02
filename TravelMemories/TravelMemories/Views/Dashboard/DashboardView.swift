import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query private var places: [Place]
    @Query private var recommendations: [Recommendation]
    @Query private var profiles: [Profile]
    @Query(sort: \Trip.startDate) private var trips: [Trip]

    private var greeting: String {
        guard let name = profiles.first?.name.trimmingCharacters(in: .whitespaces), !name.isEmpty else {
            return "Welcome back"
        }
        return "Hi, \(name)"
    }

    private var countryCount: Int {
        Set(places.map(\.country)).count
    }

    private var cityCount: Int {
        places.count
    }

    private var restaurantRecommendations: [Recommendation] {
        recommendations.filter { $0.category == .restaurant }
    }

    private var visitedRestaurantCount: Int {
        restaurantRecommendations.filter(\.isVisited).count
    }

    private var upcomingTrips: [Trip] {
        trips.filter(\.isUpcoming).sorted { $0.startDate < $1.startDate }
    }

    private func count(for category: RecommendationCategory) -> Int {
        recommendations.filter { $0.category == category }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    header

                    if !upcomingTrips.isEmpty {
                        upcomingTripsSection
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        StatCard(title: "Countries", value: countryCount, systemImage: "globe.americas.fill")
                        StatCard(title: "Cities", value: cityCount, systemImage: "building.2.fill")
                        StatCard(title: "Restaurants Added", value: restaurantRecommendations.count, systemImage: "fork.knife")
                        StatCard(title: "Restaurants Visited", value: visitedRestaurantCount, systemImage: "checkmark.seal.fill")
                    }

                    categoryBreakdown
                }
                .padding()
            }
            .background(Color.atlasGround)
            .navigationTitle("Home")
            .navigationDestination(for: Trip.self) { trip in
                TripDetailView(trip: trip)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(greeting)
                .font(.system(size: 30, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.atlasText)
            Text("Your travel footprint so far.")
                .foregroundStyle(Color.atlasNeutral500)
        }
    }

    private var upcomingTripsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upcoming Trips")
                .font(.headline)
                .foregroundStyle(Color.atlasText)

            VStack(spacing: 10) {
                ForEach(upcomingTrips) { trip in
                    NavigationLink(value: trip) {
                        UpcomingTripRow(trip: trip)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var categoryBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("By Category")
                .font(.headline)
                .foregroundStyle(Color.atlasText)

            VStack(spacing: 0) {
                ForEach(RecommendationCategory.allCases) { category in
                    HStack {
                        Label(category.displayName, systemImage: category.symbolName)
                            .foregroundStyle(Color.atlasText)
                        Spacer()
                        Text("\(count(for: category))")
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.atlasNeutral500)
                    }
                    .padding(.vertical, 10)

                    if category != RecommendationCategory.allCases.last {
                        Divider()
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
            .background(Color.atlasSurface, in: RoundedRectangle(cornerRadius: AtlasRadius.xl, style: .continuous))
        }
    }
}

private struct StatCard: View {
    let title: String
    let value: Int
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(Color.atlasAccent800)
            Text("\(value)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(Color.atlasText)
            Text(title)
                .font(.caption)
                .foregroundStyle(Color.atlasNeutral500)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.atlasSurface, in: RoundedRectangle(cornerRadius: AtlasRadius.xl, style: .continuous))
    }
}

private struct UpcomingTripRow: View {
    let trip: Trip

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: trip.type.symbolName)
                .foregroundStyle(Color.atlasAccent600)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(trip.destination)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.atlasText)
                    .lineLimit(1)
                Text(trip.dateRangeText)
                    .font(.caption)
                    .foregroundStyle(Color.atlasNeutral500)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.atlasNeutral500)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.atlasSurface, in: RoundedRectangle(cornerRadius: AtlasRadius.lg, style: .continuous))
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [Place.self, Recommendation.self, LogisticsNote.self, Trip.self, TripItem.self, Profile.self], inMemory: true)
}
