import SwiftUI

struct TripsView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Plan Your Next Trip",
                systemImage: "airplane.departure",
                description: Text("Trip planning is coming soon.")
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.atlasGround)
            .navigationTitle("Trips")
        }
    }
}

#Preview {
    TripsView()
}
