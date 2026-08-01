import Foundation

struct RowParseError: Error {
    let message: String
}

struct TripImportRow {
    let country: String
    let city: String
    let startDate: Date
    let endDate: Date
    let tripType: TripType
    let category: RecommendationCategory
    let name: String
    let note: String
    let isCompleted: Bool
    let isFavorite: Bool
    let rating: Int?

    static func parse(fields: [String], rowNumber: Int) -> Result<TripImportRow, RowParseError> {
        func field(_ index: Int) -> String {
            guard index < fields.count else { return "" }
            return fields[index].trimmingCharacters(in: .whitespacesAndNewlines)
        }

        let country = field(0)
        let city = field(1)
        let startDateText = field(2)
        let endDateText = field(3)
        let typeText = field(4)
        let categoryText = field(5)
        let name = field(6)
        let note = field(7)
        let completedText = field(8)
        let favoriteText = field(9)
        let ratingText = field(10)

        guard !country.isEmpty else {
            return .failure(RowParseError(message: "row \(rowNumber): Country is required"))
        }
        guard !city.isEmpty else {
            return .failure(RowParseError(message: "row \(rowNumber): City is required"))
        }
        guard let startDate = dateFormatter.date(from: startDateText) else {
            return .failure(RowParseError(message: "row \(rowNumber): Trip Start Date \"\(startDateText)\" isn't a valid date (expected YYYY-MM-DD)"))
        }
        guard let endDate = dateFormatter.date(from: endDateText) else {
            return .failure(RowParseError(message: "row \(rowNumber): Trip End Date \"\(endDateText)\" isn't a valid date (expected YYYY-MM-DD)"))
        }
        guard endDate >= startDate else {
            return .failure(RowParseError(message: "row \(rowNumber): Trip End Date is before Trip Start Date"))
        }
        guard let tripType = parseTripType(typeText) else {
            return .failure(RowParseError(message: "row \(rowNumber): Trip Type \"\(typeText)\" must be Business or Leisure"))
        }
        guard !name.isEmpty else {
            return .failure(RowParseError(message: "row \(rowNumber): Name is required"))
        }
        guard let category = parseCategory(categoryText) else {
            return .failure(RowParseError(message: "row \(rowNumber): Category \"\(categoryText)\" doesn't match Restaurant, Museum, Park, Activity, or Coffee Shop"))
        }

        let isCompleted = parseYesNo(completedText) ?? true
        let isFavorite = parseYesNo(favoriteText) ?? false
        let rating = Int(ratingText).flatMap { (1...5).contains($0) ? $0 : nil }

        let row = TripImportRow(
            country: country,
            city: city,
            startDate: startDate,
            endDate: endDate,
            tripType: tripType,
            category: category,
            name: name,
            note: note,
            isCompleted: isCompleted,
            isFavorite: isFavorite,
            rating: rating
        )
        return .success(row)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()

    private static func parseTripType(_ text: String) -> TripType? {
        TripType.allCases.first { $0.displayName.caseInsensitiveCompare(text) == .orderedSame }
    }

    private static func parseCategory(_ text: String) -> RecommendationCategory? {
        let normalized = text.trimmingCharacters(in: .whitespaces).lowercased()
        return RecommendationCategory.allCases.first { category in
            singularDisplayName(category) == normalized || category.displayName.lowercased() == normalized
        }
    }

    private static func singularDisplayName(_ category: RecommendationCategory) -> String {
        switch category {
        case .restaurant: "restaurant"
        case .museum: "museum"
        case .park: "park"
        case .activity: "activity"
        case .coffeeShop: "coffee shop"
        }
    }

    private static func parseYesNo(_ text: String) -> Bool? {
        guard !text.isEmpty else { return nil }
        switch text.lowercased() {
        case "yes", "y", "true", "1": return true
        case "no", "n", "false", "0": return false
        default: return nil
        }
    }
}
