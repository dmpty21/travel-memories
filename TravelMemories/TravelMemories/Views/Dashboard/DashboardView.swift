import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query private var places: [Place]
    @Query private var recommendations: [Recommendation]

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

    private var recentRecommendations: [Recommendation] {
        recommendations
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(4)
            .map { $0 }
    }

    private func count(for category: RecommendationCategory) -> Int {
        recommendations.filter { $0.category == category }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    header

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        StatCard(title: "Countries", value: countryCount, systemImage: "globe.americas.fill")
                        StatCard(title: "Cities", value: cityCount, systemImage: "building.2.fill")
                        StatCard(title: "Restaurants Added", value: restaurantRecommendations.count, systemImage: "fork.knife")
                        StatCard(title: "Restaurants Visited", value: visitedRestaurantCount, systemImage: "checkmark.seal.fill")
                    }

                    if !recentRecommendations.isEmpty {
                        recentSection
                    }

                    categoryBreakdown
                }
                .padding()
            }
            .background(Color.atlasGround)
            .navigationTitle("Home")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Welcome back")
                .font(.system(size: 30, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.atlasText)
            Text("Your travel footprint so far.")
                .foregroundStyle(Color.atlasNeutral500)
        }
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Recommendations")
                .font(.headline)
                .foregroundStyle(Color.atlasText)

            VStack(spacing: 10) {
                ForEach(recentRecommendations) { recommendation in
                    RecentRecommendationRow(recommendation: recommendation)
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

private struct RecentRecommendationRow: View {
    let recommendation: Recommendation

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                if let place = recommendation.place {
                    Text(place.city.uppercased())
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Color.atlasAccent600)
                        .kerning(0.5)
                }
                Text(recommendation.name)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.atlasText)
                    .lineLimit(1)
            }
            Spacer()
            Image(systemName: recommendation.category.symbolName)
                .foregroundStyle(Color.atlasNeutral500)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.atlasSurface, in: RoundedRectangle(cornerRadius: AtlasRadius.lg, style: .continuous))
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [Place.self, Recommendation.self, LogisticsNote.self], inMemory: true)
}
