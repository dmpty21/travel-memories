import SwiftUI

struct RecommendationRow: View {
    let recommendation: Recommendation

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(recommendation.name)
                    .font(.body)
                if !recommendation.note.trimmingCharacters(in: .whitespaces).isEmpty {
                    Text(recommendation.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            if recommendation.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                    .imageScale(.small)
            }
        }
        .contentShape(Rectangle())
    }
}
