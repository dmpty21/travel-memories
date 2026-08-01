import SwiftUI
import SwiftData

struct AddEditTripItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var trip: Trip
    var item: TripItem?

    @State private var name: String = ""
    @State private var note: String = ""
    @State private var category: RecommendationCategory = .restaurant
    @State private var isCompleted: Bool = false

    private var isEditing: Bool { item != nil }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)

                Picker("Category", selection: $category) {
                    ForEach(RecommendationCategory.allCases) { category in
                        Label(category.displayName, systemImage: category.symbolName)
                            .tag(category)
                    }
                }

                TextField("Note", text: $note, axis: .vertical)
                    .lineLimit(3...6)

                Toggle("Completed", isOn: $isCompleted)
            }
            .navigationTitle(isEditing ? "Edit Item" : "Add Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let item {
                    name = item.name
                    note = item.note
                    category = item.category
                    isCompleted = item.isCompleted
                } else {
                    isCompleted = !trip.isUpcoming
                }
            }
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)

        if let item {
            item.name = trimmedName
            item.note = note
            item.category = category
            item.isCompleted = isCompleted
        } else {
            let newItem = TripItem(name: trimmedName, note: note, category: category, isCompleted: isCompleted, trip: trip)
            modelContext.insert(newItem)
        }
        dismiss()
    }
}

#Preview {
    let trip = Trip(destination: "Kyoto, Japan", startDate: .now, endDate: .now.addingTimeInterval(86400 * 5), type: .leisure)
    return AddEditTripItemView(trip: trip)
        .modelContainer(for: [Trip.self, TripItem.self], inMemory: true)
}
