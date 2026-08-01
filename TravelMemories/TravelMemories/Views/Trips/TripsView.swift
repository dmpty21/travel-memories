import SwiftUI
import SwiftData

struct TripsView: View {
    @Query(sort: \Trip.startDate) private var trips: [Trip]

    @State private var isPresentingAddTrip = false

    private var upcomingTrips: [Trip] {
        trips.filter(\.isUpcoming).sorted { $0.startDate < $1.startDate }
    }

    private var previousTrips: [Trip] {
        trips.filter { !$0.isUpcoming }.sorted { $0.startDate > $1.startDate }
    }

    var body: some View {
        NavigationStack {
            Group {
                if trips.isEmpty {
                    ContentUnavailableView(
                        "Plan Your Next Trip",
                        systemImage: "airplane.departure",
                        description: Text("Add a trip to start planning \u{2014} or log one you've already taken.")
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.atlasGround)
                } else {
                    List {
                        if !upcomingTrips.isEmpty {
                            Section("Upcoming") {
                                ForEach(upcomingTrips) { trip in
                                    NavigationLink(value: trip) {
                                        TripRow(trip: trip)
                                    }
                                }
                            }
                        }
                        if !previousTrips.isEmpty {
                            Section("Previous") {
                                ForEach(previousTrips) { trip in
                                    NavigationLink(value: trip) {
                                        TripRow(trip: trip)
                                    }
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.atlasGround)
                }
            }
            .navigationTitle("Trips")
            .navigationDestination(for: Trip.self) { trip in
                TripDetailView(trip: trip)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isPresentingAddTrip = true
                    } label: {
                        Label("Add Trip", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingAddTrip) {
                AddEditTripView()
            }
        }
    }
}

private struct TripRow: View {
    let trip: Trip

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: trip.type.symbolName)
                .foregroundStyle(Color.atlasAccent600)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(trip.destination)
                    .font(.body.weight(.medium))
                Text(trip.dateRangeText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(trip.type.displayName)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TripsView()
        .modelContainer(for: [Trip.self, TripItem.self], inMemory: true)
}
