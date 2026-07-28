import SwiftUI
import SwiftData

struct AddEditRecommendationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var place: Place
    var recommendation: Recommendation?

    @State private var name: String = ""
    @State private var note: String = ""
    @State private var category: RecommendationCategory = .restaurant
    @State private var isFavorite: Bool = false

    private var isEditing: Bool { recommendation != nil }

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

                Toggle("Favorite", isOn: $isFavorite)
            }
            .navigationTitle(isEditing ? "Edit Recommendation" : "Add Recommendation")
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
                if let recommendation {
                    name = recommendation.name
                    note = recommendation.note
                    category = recommendation.category
                    isFavorite = recommendation.isFavorite
                }
            }
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)

        if let recommendation {
            recommendation.name = trimmedName
            recommendation.note = note
            recommendation.category = category
            recommendation.isFavorite = isFavorite
        } else {
            let newRecommendation = Recommendation(
                name: trimmedName,
                note: note,
                category: category,
                isFavorite: isFavorite,
                place: place
            )
            modelContext.insert(newRecommendation)
        }
        dismiss()
    }
}

#Preview {
    let place = Place(country: "Japan", city: "Tokyo")
    return AddEditRecommendationView(place: place)
        .modelContainer(for: [Place.self, Recommendation.self, LogisticsNote.self], inMemory: true)
}
