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

    private func count(for category: RecommendationCategory) -> Int {
        recommendations.filter { $0.category == category }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header

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
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Dashboard")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Welcome back")
                .font(.largeTitle.bold())
            Text("Your travel footprint so far.")
                .foregroundStyle(.secondary)
        }
    }

    private var categoryBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("By Category")
                .font(.headline)

            VStack(spacing: 0) {
                ForEach(RecommendationCategory.allCases) { category in
                    HStack {
                        Label(category.displayName, systemImage: category.symbolName)
                        Spacer()
                        Text("\(count(for: category))")
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 10)

                    if category != RecommendationCategory.allCases.last {
                        Divider()
                    }
                }
            }
            .padding(.horizontal)
            .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
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
                .foregroundStyle(Color.accentColor)
            Text("\(value)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [Place.self, Recommendation.self, LogisticsNote.self], inMemory: true)
}
