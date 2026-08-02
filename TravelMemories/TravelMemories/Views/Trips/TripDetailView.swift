import SwiftUI
import SwiftData

struct TripDetailView: View {
    @Bindable var trip: Trip
    @Environment(\.modelContext) private var modelContext

    @State private var isPresentingEditTrip = false
    @State private var isPresentingAddItem = false
    @State private var itemToEdit: TripItem?
    @State private var addReservationType: ReservationType?
    @State private var reservationToEdit: Reservation?

    private var groupedItems: [(category: RecommendationCategory, items: [TripItem])] {
        let groups = Dictionary(grouping: trip.items ?? [], by: \.category)
        return RecommendationCategory.allCases.compactMap { category in
            guard let items = groups[category], !items.isEmpty else { return nil }
            return (category, items.sorted { $0.name < $1.name })
        }
    }

    private var sortedReservations: [Reservation] {
        (trip.reservations ?? []).sorted {
            ($0.startDate ?? .distantFuture) < ($1.startDate ?? .distantFuture)
        }
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Label(trip.dateRangeText, systemImage: "calendar")
                    Label(trip.type.displayName, systemImage: trip.type.symbolName)
                }
                .foregroundStyle(.secondary)
                .font(.subheadline)
            }

            if !sortedReservations.isEmpty {
                Section {
                    ForEach(sortedReservations) { reservation in
                        ReservationRow(reservation: reservation)
                            .onTapGesture { reservationToEdit = reservation }
                    }
                    .onDelete { offsets in
                        delete(reservationsAt: offsets)
                    }
                } header: {
                    Label("Reservations", systemImage: "doc.text")
                }
            }

            if (trip.items ?? []).isEmpty {
                Section {
                    Text("No items yet")
                        .foregroundStyle(.secondary)
                } header: {
                    Label("Itinerary", systemImage: "list.bullet")
                }
            } else {
                ForEach(groupedItems, id: \.category) { group in
                    Section {
                        ForEach(group.items) { item in
                            TripItemRow(item: item)
                                .onTapGesture { itemToEdit = item }
                        }
                        .onDelete { offsets in
                            delete(itemsInGroup: group.items, at: offsets)
                        }
                    } header: {
                        Label(group.category.displayName, systemImage: group.category.symbolName)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.atlasGround)
        .navigationTitle(trip.destination)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Menu {
                    Button {
                        isPresentingAddItem = true
                    } label: {
                        Label("Itinerary Item", systemImage: "checklist")
                    }
                    Button {
                        addReservationType = .hotel
                    } label: {
                        Label("Hotel Reservation", systemImage: ReservationType.hotel.symbolName)
                    }
                    Button {
                        addReservationType = .flight
                    } label: {
                        Label("Flight Reservation", systemImage: ReservationType.flight.symbolName)
                    }
                } label: {
                    Label("Add", systemImage: "plus")
                }

                Menu {
                    Button {
                        isPresentingEditTrip = true
                    } label: {
                        Label("Edit Trip", systemImage: "pencil")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $isPresentingEditTrip) {
            AddEditTripView(trip: trip)
        }
        .sheet(isPresented: $isPresentingAddItem) {
            AddEditTripItemView(trip: trip)
        }
        .sheet(item: $itemToEdit) { item in
            AddEditTripItemView(trip: trip, item: item)
        }
        .sheet(item: $addReservationType) { type in
            AddEditReservationView(trip: trip, initialType: type)
        }
        .sheet(item: $reservationToEdit) { reservation in
            AddEditReservationView(trip: trip, reservation: reservation)
        }
    }

    private func delete(itemsInGroup: [TripItem], at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(itemsInGroup[index])
        }
    }

    private func delete(reservationsAt offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(sortedReservations[index])
        }
    }
}

private struct ReservationRow: View {
    let reservation: Reservation

    private var dateText: String? {
        guard let startDate = reservation.startDate else { return nil }
        switch reservation.type {
        case .hotel:
            guard let endDate = reservation.endDate else {
                return startDate.formatted(.dateTime.month(.abbreviated).day())
            }
            return "\(startDate.formatted(.dateTime.month(.abbreviated).day())) – \(endDate.formatted(.dateTime.month(.abbreviated).day()))"
        case .flight:
            return startDate.formatted(.dateTime.month(.abbreviated).day().hour().minute())
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: reservation.type.symbolName)
                .foregroundStyle(Color.atlasAccent600)
                .imageScale(.large)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(reservation.title.isEmpty ? reservation.type.displayName : reservation.title)
                    .font(.body)
                if !reservation.subtitle.isEmpty {
                    Text(reservation.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let dateText {
                    Text(dateText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if !reservation.confirmationNumber.isEmpty {
                    Text("Confirmation: \(reservation.confirmationNumber)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .contentShape(Rectangle())
    }
}

private struct TripItemRow: View {
    @Bindable var item: TripItem

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(item.isCompleted ? Color.atlasAccent600 : Color.atlasNeutral500)
                .imageScale(.large)
                .onTapGesture {
                    item.isCompleted.toggle()
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.body)
                    .strikethrough(item.isCompleted)
                if !item.note.trimmingCharacters(in: .whitespaces).isEmpty {
                    Text(item.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    let trip = Trip(destination: "Kyoto, Japan", startDate: .now, endDate: .now.addingTimeInterval(86400 * 5), type: .leisure)
    return NavigationStack {
        TripDetailView(trip: trip)
    }
    .modelContainer(for: [Trip.self, TripItem.self, Reservation.self], inMemory: true)
}
