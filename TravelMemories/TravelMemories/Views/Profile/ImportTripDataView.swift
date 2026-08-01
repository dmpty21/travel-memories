import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ImportTripDataView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var isPresentingFileImporter = false
    @State private var validRows: [TripImportRow] = []
    @State private var errors: [String] = []
    @State private var hasParsed = false
    @State private var importSummary: String?
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if let importSummary {
                    successView(importSummary)
                } else if hasParsed {
                    previewView
                } else {
                    pickerView
                }
            }
            .navigationTitle("Import Trip Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .fileImporter(isPresented: $isPresentingFileImporter, allowedContentTypes: [.commaSeparatedText]) { result in
                handlePickedFile(result)
            }
        }
    }

    private var pickerView: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.and.arrow.down.on.square")
                .font(.system(size: 48))
                .foregroundStyle(Color.atlasAccent600)
            Text("Import a CSV exported from the trip data template to bulk-add places, trips, and recommendations.")
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.atlasNeutral500)
                .padding(.horizontal, 32)
            Button {
                isPresentingFileImporter = true
            } label: {
                Label("Choose CSV File", systemImage: "doc.text")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.atlasAccent, in: RoundedRectangle(cornerRadius: AtlasRadius.pill, style: .continuous))
            }
            .padding(.horizontal, 32)

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal, 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.atlasGround)
    }

    private var previewView: some View {
        List {
            Section {
                Text("Will create \(uniquePlaceCount) place\(uniquePlaceCount == 1 ? "" : "s"), \(uniqueTripCount) trip\(uniqueTripCount == 1 ? "" : "s"), and \(validRows.count) entr\(validRows.count == 1 ? "y" : "ies").")
                    .font(.body)
            }

            if !errors.isEmpty {
                Section("Skipped Rows (\(errors.count))") {
                    ForEach(errors, id: \.self) { error in
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section {
                Button {
                    commitImport()
                } label: {
                    Text("Import \(validRows.count) Valid Row\(validRows.count == 1 ? "" : "s")")
                        .frame(maxWidth: .infinity)
                }
                .disabled(validRows.isEmpty)

                Button("Choose a Different File") {
                    resetToPicker()
                }
            }
        }
    }

    private func successView(_ summary: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color.atlasAccent600)
            Text(summary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button("Done") { dismiss() }
                .buttonStyle(.borderedProminent)
                .tint(Color.atlasAccent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.atlasGround)
    }

    private var uniquePlaceCount: Int {
        Set(validRows.map { "\($0.country.lowercased())|\($0.city.lowercased())" }).count
    }

    private var uniqueTripCount: Int {
        Set(validRows.map { "\($0.country.lowercased())|\($0.city.lowercased())|\($0.startDate)|\($0.endDate)" }).count
    }

    private func handlePickedFile(_ result: Result<URL, Error>) {
        switch result {
        case .failure(let error):
            errorMessage = error.localizedDescription
        case .success(let url):
            parseFile(at: url)
        }
    }

    private func parseFile(at url: URL) {
        errorMessage = nil
        let didAccess = url.startAccessingSecurityScopedResource()
        defer { if didAccess { url.stopAccessingSecurityScopedResource() } }

        guard let data = try? Data(contentsOf: url), let text = String(data: data, encoding: .utf8) else {
            errorMessage = "Couldn't read that file. Make sure it's a CSV export."
            return
        }

        let allRows = CSVParser.parse(text)
        guard !allRows.isEmpty else {
            errorMessage = "The file appears to be empty."
            return
        }
        let dataRows = allRows.dropFirst()

        var parsedRows: [TripImportRow] = []
        var parseErrors: [String] = []
        for (offset, fields) in dataRows.enumerated() {
            let rowNumber = offset + 2 // +1 for header, +1 for 1-based row numbering
            switch TripImportRow.parse(fields: fields, rowNumber: rowNumber) {
            case .success(let row):
                parsedRows.append(row)
            case .failure(let error):
                parseErrors.append(error.message)
            }
        }

        validRows = parsedRows
        errors = parseErrors
        hasParsed = true
    }

    private func resetToPicker() {
        hasParsed = false
        validRows = []
        errors = []
    }

    private func commitImport() {
        var placesByKey: [String: Place] = [:]
        var tripsByKey: [String: Trip] = [:]

        for row in validRows {
            let placeKey = "\(row.country.lowercased())|\(row.city.lowercased())"
            let place: Place
            if let existing = placesByKey[placeKey] ?? findExistingPlace(country: row.country, city: row.city) {
                place = existing
            } else {
                place = Place(country: row.country, city: row.city)
                modelContext.insert(place)
            }
            placesByKey[placeKey] = place

            let tripKey = "\(placeKey)|\(row.startDate.timeIntervalSince1970)|\(row.endDate.timeIntervalSince1970)"
            let trip: Trip
            if let existing = tripsByKey[tripKey] ?? findExistingTrip(place: place, startDate: row.startDate, endDate: row.endDate) {
                trip = existing
            } else {
                trip = Trip(destination: "\(row.city), \(row.country)", startDate: row.startDate, endDate: row.endDate, type: row.tripType)
                trip.place = place
                modelContext.insert(trip)
            }
            tripsByKey[tripKey] = trip

            let recommendation = Recommendation(
                name: row.name,
                note: row.note,
                category: row.category,
                isFavorite: row.isFavorite,
                isVisited: row.isCompleted,
                place: place,
                rating: row.rating
            )
            modelContext.insert(recommendation)

            let tripItem = TripItem(name: row.name, note: row.note, category: row.category, isCompleted: row.isCompleted, trip: trip)
            modelContext.insert(tripItem)
        }

        importSummary = "Imported \(validRows.count) entr\(validRows.count == 1 ? "y" : "ies") across \(tripsByKey.count) trip\(tripsByKey.count == 1 ? "" : "s")."
    }

    private func findExistingPlace(country: String, city: String) -> Place? {
        let descriptor = FetchDescriptor<Place>()
        guard let places = try? modelContext.fetch(descriptor) else { return nil }
        return places.first { $0.country.caseInsensitiveCompare(country) == .orderedSame && $0.city.caseInsensitiveCompare(city) == .orderedSame }
    }

    private func findExistingTrip(place: Place, startDate: Date, endDate: Date) -> Trip? {
        (place.trips ?? []).first {
            Calendar.current.isDate($0.startDate, inSameDayAs: startDate) && Calendar.current.isDate($0.endDate, inSameDayAs: endDate)
        }
    }
}

#Preview {
    ImportTripDataView()
        .modelContainer(for: [Place.self, Recommendation.self, Trip.self, TripItem.self], inMemory: true)
}
