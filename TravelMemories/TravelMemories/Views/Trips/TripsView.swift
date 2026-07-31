import SwiftUI

struct TripsView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Plan Your Next Trip",
                systemImage: "airplane.departure",
                description: Text("Trip planning is coming soon.")
            )
            .navigationTitle("Trips")
        }
    }
}

#Preview {
    TripsView()
}
