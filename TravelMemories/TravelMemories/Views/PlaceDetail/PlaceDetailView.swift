import SwiftUI
import SwiftData

struct PlaceDetailView: View {
    @Bindable var place: Place

    @State private var isPresentingEdit = false

    var body: some View {
        List {
            Section("Recommendations") {
                Text("Coming soon")
                    .foregroundStyle(.secondary)
            }
            Section("Logistics Notes") {
                Text("Coming soon")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(place.city)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { isPresentingEdit = true }
            }
        }
        .sheet(isPresented: $isPresentingEdit) {
            AddEditPlaceView(place: place)
        }
    }
}

#Preview {
    let place = Place(country: "Japan", city: "Tokyo")
    return NavigationStack {
        PlaceDetailView(place: place)
    }
    .modelContainer(for: [Place.self, Recommendation.self, LogisticsNote.self], inMemory: true)
}
