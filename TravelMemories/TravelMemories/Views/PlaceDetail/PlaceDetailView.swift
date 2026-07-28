import SwiftUI
import SwiftData

struct PlaceDetailView: View {
    @Bindable var place: Place
    @Environment(\.modelContext) private var modelContext

    @State private var isPresentingEditPlace = false
    @State private var isPresentingAddRecommendation = false
    @State private var recommendationToEdit: Recommendation?
    @State private var isPresentingAddNote = false
    @State private var noteToEdit: LogisticsNote?

    private var groupedRecommendations: [(category: RecommendationCategory, items: [Recommendation])] {
        let groups = Dictionary(grouping: place.recommendations, by: \.category)
        return RecommendationCategory.allCases.compactMap { category in
            guard let items = groups[category], !items.isEmpty else { return nil }
            return (category, items.sorted { $0.name < $1.name })
        }
    }

    private var sortedLogisticsNotes: [LogisticsNote] {
        place.logisticsNotes.sorted { $0.createdAt < $1.createdAt }
    }

    var body: some View {
        List {
            if place.recommendations.isEmpty {
                Section {
                    Text("No recommendations yet")
                        .foregroundStyle(.secondary)
                } header: {
                    Label("Recommendations", systemImage: "list.bullet")
                }
            } else {
                ForEach(groupedRecommendations, id: \.category) { group in
                    Section {
                        ForEach(group.items) { recommendation in
                            RecommendationRow(recommendation: recommendation)
                                .onTapGesture { recommendationToEdit = recommendation }
                        }
                        .onDelete { offsets in
                            delete(recommendationsInGroup: group.items, at: offsets)
                        }
                    } header: {
                        Label(group.category.displayName, systemImage: group.category.symbolName)
                    }
                }
            }

            Section {
                if sortedLogisticsNotes.isEmpty {
                    Text("No logistics notes yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(sortedLogisticsNotes) { note in
                        Text(note.text)
                            .onTapGesture { noteToEdit = note }
                    }
                    .onDelete { offsets in
                        delete(notes: sortedLogisticsNotes, at: offsets)
                    }
                }

                Button {
                    isPresentingAddNote = true
                } label: {
                    Label("Add Logistics Note", systemImage: "plus")
                }
            } header: {
                Label("Logistics Notes", systemImage: "airplane")
            }
        }
        .navigationTitle(place.city)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                ShareLink(item: place.shareText) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }

                Button {
                    isPresentingAddRecommendation = true
                } label: {
                    Label("Add Recommendation", systemImage: "plus")
                }

                Menu {
                    Button {
                        isPresentingEditPlace = true
                    } label: {
                        Label("Edit Place", systemImage: "pencil")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $isPresentingEditPlace) {
            AddEditPlaceView(place: place)
        }
        .sheet(isPresented: $isPresentingAddRecommendation) {
            AddEditRecommendationView(place: place)
        }
        .sheet(item: $recommendationToEdit) { recommendation in
            AddEditRecommendationView(place: place, recommendation: recommendation)
        }
        .sheet(isPresented: $isPresentingAddNote) {
            AddEditLogisticsNoteView(place: place)
        }
        .sheet(item: $noteToEdit) { note in
            AddEditLogisticsNoteView(place: place, logisticsNote: note)
        }
    }

    private func delete(recommendationsInGroup: [Recommendation], at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(recommendationsInGroup[index])
        }
    }

    private func delete(notes: [LogisticsNote], at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(notes[index])
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
