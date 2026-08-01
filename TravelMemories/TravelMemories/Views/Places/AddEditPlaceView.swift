import SwiftUI
import SwiftData
import MapKit
import PhotosUI

struct AddEditPlaceView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var place: Place?

    @State private var country: String = ""
    @State private var city: String = ""
    @State private var photoData: Data?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @StateObject private var searchCompleter = CitySearchCompleter()
    @FocusState private var isCityFieldFocused: Bool

    private var isEditing: Bool { place != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    photoPicker
                    if photoData != nil {
                        Button("Remove Photo", role: .destructive) {
                            photoData = nil
                            selectedPhotoItem = nil
                        }
                    }
                }

                TextField("Country", text: $country)

                TextField("City", text: $city)
                    .focused($isCityFieldFocused)
                    .onChange(of: city) { _, newValue in
                        searchCompleter.updateQuery(newValue)
                    }

                if isCityFieldFocused && !searchCompleter.suggestions.isEmpty {
                    ForEach(searchCompleter.suggestions, id: \.self) { suggestion in
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
            .navigationTitle(isEditing ? "Edit Place" : "Add Place")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(country.trimmingCharacters(in: .whitespaces).isEmpty
                                  || city.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let place {
                    country = place.country
                    city = place.city
                    photoData = place.photoData
                }
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                guard let newItem else { return }
                Task {
                    guard let data = try? await newItem.loadTransferable(type: Data.self) else { return }
                    let processed = Self.compressedImageData(from: data) ?? data
                    await MainActor.run {
                        photoData = processed
                    }
                }
            }
        }
    }

    private var photoPicker: some View {
        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
            if let photoData, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, minHeight: 160, maxHeight: 160)
                    .clipShape(RoundedRectangle(cornerRadius: AtlasRadius.lg, style: .continuous))
            } else {
                Label("Add Photo", systemImage: "photo.badge.plus")
            }
        }
        .buttonStyle(.plain)
    }

    private func select(_ suggestion: MKLocalSearchCompletion) {
        isCityFieldFocused = false
        searchCompleter.clear()

        let request = MKLocalSearch.Request(completion: suggestion)
        let search = MKLocalSearch(request: request)

        Task {
            guard let response = try? await search.start(),
                  let placemark = response.mapItems.first?.placemark else { return }
            await MainActor.run {
                city = placemark.locality ?? suggestion.title
                if let resolvedCountry = placemark.country {
                    country = resolvedCountry
                }
            }
        }
    }

    private func save() {
        let trimmedCountry = country.trimmingCharacters(in: .whitespaces)
        let trimmedCity = city.trimmingCharacters(in: .whitespaces)

        if let place {
            place.country = trimmedCountry
            place.city = trimmedCity
            place.photoData = photoData
        } else {
            let newPlace = Place(country: trimmedCountry, city: trimmedCity)
            newPlace.photoData = photoData
            modelContext.insert(newPlace)
        }
        dismiss()
    }

    private static func compressedImageData(from data: Data, maxDimension: CGFloat = 1600, quality: CGFloat = 0.8) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        let size = image.size
        let scale = min(1, maxDimension / max(size.width, size.height))
        let targetSize = CGSize(width: size.width * scale, height: size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        return resized.jpegData(compressionQuality: quality)
    }
}

#Preview {
    AddEditPlaceView()
        .modelContainer(for: [Place.self, Recommendation.self, LogisticsNote.self], inMemory: true)
}
