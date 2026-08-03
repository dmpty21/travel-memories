#if DEBUG
import Foundation
import SwiftData

/// Populates the store with realistic sample data for App Store screenshots.
/// Only runs in Debug builds, and only when launched with `-SeedSampleData`.
enum SampleDataSeeder {
    static func seedIfNeeded(context: ModelContext) {
        guard ProcessInfo.processInfo.arguments.contains("-SeedSampleData") else { return }
        guard (try? context.fetch(FetchDescriptor<Trip>()))?.isEmpty ?? true else { return }

        let rows = CSVParser.parse(sampleCSV).dropFirst()
        var placesByKey: [String: Place] = [:]
        var tripsByKey: [String: Trip] = [:]

        for (offset, fields) in rows.enumerated() {
            guard case .success(let row) = TripImportRow.parse(fields: fields, rowNumber: offset + 2) else { continue }

            let placeKey = "\(row.country.lowercased())|\(row.city.lowercased())"
            let place = placesByKey[placeKey] ?? {
                let new = Place(country: row.country, city: row.city)
                context.insert(new)
                return new
            }()
            placesByKey[placeKey] = place

            let tripKey = "\(placeKey)|\(row.startDate.timeIntervalSince1970)|\(row.endDate.timeIntervalSince1970)"
            let trip = tripsByKey[tripKey] ?? {
                let new = Trip(destination: "\(row.city), \(row.country)", startDate: row.startDate, endDate: row.endDate, type: row.tripType)
                new.place = place
                context.insert(new)
                return new
            }()
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
            context.insert(recommendation)

            let tripItem = TripItem(name: row.name, note: row.note, category: row.category, isCompleted: row.isCompleted, trip: trip)
            context.insert(tripItem)
        }

        try? context.save()
    }

    private static let sampleCSV = """
    Country,City,Trip Start Date,Trip End Date,Trip Type,Category,Name,Note,Completed,Favorite,Rating
    France,Paris,2025-05-10,2025-05-17,Leisure,Restaurant,Le Petit Vendome,Tiny bistro near the Louvre with incredible steak frites,Yes,Yes,5
    France,Paris,2025-05-10,2025-05-17,Leisure,Museum,Musee d'Orsay,Impressionist collection in an old train station,Yes,Yes,5
    France,Paris,2025-05-10,2025-05-17,Leisure,Coffee Shop,Cafe de Flore,Classic Left Bank cafe for people watching,Yes,No,4
    France,Paris,2025-05-10,2025-05-17,Leisure,Park,Jardin du Luxembourg,Perfect for a morning walk,Yes,No,4
    France,Paris,2025-05-10,2025-05-17,Leisure,Activity,Seine River Cruise,Great at sunset,No,Yes,
    Japan,Tokyo,2025-10-02,2025-10-12,Leisure,Restaurant,Sushi Saito,Once in a lifetime omakase,Yes,Yes,5
    Japan,Tokyo,2025-10-02,2025-10-12,Leisure,Museum,teamLab Planets,Immersive digital art museum,Yes,Yes,5
    Japan,Tokyo,2025-10-02,2025-10-12,Leisure,Park,Shinjuku Gyoen,Beautiful in autumn,Yes,No,4
    Japan,Tokyo,2025-10-02,2025-10-12,Leisure,Coffee Shop,Blue Bottle Coffee Shibuya,Good spot to recharge,Yes,No,3
    Japan,Tokyo,2025-10-02,2025-10-12,Leisure,Activity,Tsukiji Outer Market Food Tour,So much fresh seafood,No,Yes,
    Italy,Rome,2024-09-14,2024-09-21,Leisure,Restaurant,Roscioli,Best carbonara in Rome,Yes,Yes,5
    Italy,Rome,2024-09-14,2024-09-21,Leisure,Museum,Vatican Museums,Sistine Chapel is unreal in person,Yes,Yes,5
    Italy,Rome,2024-09-14,2024-09-21,Leisure,Activity,Colosseum Underground Tour,Book ahead worth it,Yes,No,4
    Italy,Rome,2024-09-14,2024-09-21,Leisure,Coffee Shop,Sant'Eustachio Il Caffe,Best espresso near the Pantheon,Yes,No,5
    United States,New York,2026-03-05,2026-03-09,Business,Restaurant,Katz's Delicatessen,Pastrami sandwich is worth the trip,No,No,
    United States,New York,2026-03-05,2026-03-09,Business,Coffee Shop,Blue Bottle Chelsea,Quick coffee between meetings,No,No,
    Mexico,Mexico City,2025-01-15,2025-01-20,Leisure,Restaurant,Pujol,Tasting menu was unforgettable,Yes,Yes,5
    Mexico,Mexico City,2025-01-15,2025-01-20,Leisure,Museum,Frida Kahlo Museum,Casa Azul is a must,Yes,Yes,5
    Mexico,Mexico City,2025-01-15,2025-01-20,Leisure,Park,Chapultepec Park,Huge green space with castle views,Yes,No,4
    """
}
#endif
