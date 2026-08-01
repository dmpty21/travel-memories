import SwiftUI
import SwiftData

struct AppRootView: View {
    @Query private var profiles: [Profile]

    var body: some View {
        if profiles.isEmpty {
            CreateProfileView()
        } else {
            RootTabView()
        }
    }
}

#Preview {
    AppRootView()
        .modelContainer(for: [Profile.self, Place.self, Recommendation.self, LogisticsNote.self, Trip.self, TripItem.self], inMemory: true)
}
