import SwiftUI
import SwiftData

struct TripDetailView: View {
    @Bindable var trip: Trip
    @Environment(\.modelContext) private var modelContext

    @State private var isPresentingEditTrip = false
    @State private var isPresentingAddItem = false
    @State private var itemToEdit: TripItem?

    private var groupedItems: [(category: RecommendationCategory, items: [TripItem])] {
        let groups = Dictionary(grouping: trip.items, by: \.category)
        return RecommendationCategory.allCases.compactMap { category in
            guard let items = groups[category], !items.isEmpty else { return nil }
            return (category, items.sorted { $0.name < $1.name })
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

            if trip.items.isEmpty {
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
                Button {
                    isPresentingAddItem = true
                } label: {
                    Label("Add Item", systemImage: "plus")
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
    }

    private func delete(itemsInGroup: [TripItem], at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(itemsInGroup[index])
        }
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
    .modelContainer(for: [Trip.self, TripItem.self], inMemory: true)
}
