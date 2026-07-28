import SwiftUI
import SwiftData

struct AddEditLogisticsNoteView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var place: Place
    var logisticsNote: LogisticsNote?

    @State private var text: String = ""

    private var isEditing: Bool { logisticsNote != nil }

    var body: some View {
        NavigationStack {
            Form {
                TextField("e.g. Fly into Haneda, not Narita", text: $text, axis: .vertical)
                    .lineLimit(3...6)
            }
            .navigationTitle(isEditing ? "Edit Note" : "Add Logistics Note")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                if let logisticsNote {
                    text = logisticsNote.text
                }
            }
        }
    }

    private func save() {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        if let logisticsNote {
            logisticsNote.text = trimmedText
        } else {
            let newNote = LogisticsNote(text: trimmedText, place: place)
            modelContext.insert(newNote)
        }
        dismiss()
    }
}

#Preview {
    let place = Place(country: "Japan", city: "Tokyo")
    return AddEditLogisticsNoteView(place: place)
        .modelContainer(for: [Place.self, Recommendation.self, LogisticsNote.self], inMemory: true)
}
