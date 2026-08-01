import Foundation

extension Place {
    var shareText: String {
        var lines: [String] = ["\(city), \(country)"]

        let sortedNotes = (logisticsNotes ?? []).sorted { $0.createdAt < $1.createdAt }
        if !sortedNotes.isEmpty {
            lines.append("")
            lines.append("Logistics")
            for note in sortedNotes {
                lines.append("• \(note.text)")
            }
        }

        let groupedRecommendations = Dictionary(grouping: recommendations ?? [], by: \.category)
        for category in RecommendationCategory.allCases {
            guard let items = groupedRecommendations[category]?.sorted(by: { $0.name < $1.name }),
                  !items.isEmpty else { continue }

            lines.append("")
            lines.append(category.displayName)
            for item in items {
                let bullet = item.isFavorite ? "★" : "•"
                let note = item.note.trimmingCharacters(in: .whitespacesAndNewlines)
                let ratingSuffix = (item.rating.map { " (\(String(repeating: "★", count: $0))\(String(repeating: "☆", count: 5 - $0)))" }) ?? ""
                if note.isEmpty {
                    lines.append("\(bullet) \(item.name)\(ratingSuffix)")
                } else {
                    lines.append("\(bullet) \(item.name)\(ratingSuffix) — \(note)")
                }
                if let address = item.address, !address.isEmpty {
                    lines.append("   \(address)")
                }
            }
        }

        return lines.joined(separator: "\n")
    }
}
