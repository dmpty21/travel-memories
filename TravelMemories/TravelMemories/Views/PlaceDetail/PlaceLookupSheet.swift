import SwiftUI
import MapKit

struct PlaceLookupSheet: View {
    @Environment(\.dismiss) private var dismiss

    var cityName: String
    var country: String
    var onSelect: (MKMapItem) -> Void

    @State private var query = ""
    @StateObject private var completer = PlaceLookupCompleter()
    @State private var isResolving = false

    var body: some View {
        NavigationStack {
            List {
                if isResolving {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else {
                    ForEach(completer.suggestions, id: \.self) { suggestion in
                        Button {
                            select(suggestion)
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(suggestion.title)
                                    .foregroundStyle(.primary)
                                if !suggestion.subtitle.isEmpty {
                                    Text(suggestion.subtitle)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Look Up Place")
            .searchable(text: $query, prompt: "Search near \(cityName)")
            .onChange(of: query) { _, newValue in
                completer.updateQuery(newValue)
            }
            .onAppear {
                completer.biasSearch(near: cityName, country: country)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func select(_ suggestion: MKLocalSearchCompletion) {
        isResolving = true
        let request = MKLocalSearch.Request(completion: suggestion)
        let search = MKLocalSearch(request: request)

        Task {
            let response = try? await search.start()
            await MainActor.run {
                isResolving = false
                if let mapItem = response?.mapItems.first {
                    onSelect(mapItem)
                }
                dismiss()
            }
        }
    }
}
