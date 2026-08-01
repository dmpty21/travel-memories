import SwiftUI

struct PhotoCard: View {
    let title: String
    let subtitle: String
    let photoURL: String?

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            photo

            LinearGradient(
                colors: [.clear, .black.opacity(0.75)],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(1)
            }
            .padding(14)
        }
        .frame(height: 160)
        .clipShape(RoundedRectangle(cornerRadius: AtlasRadius.xl, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AtlasRadius.xl, style: .continuous)
                .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
        )
    }

    @ViewBuilder
    private var photo: some View {
        if let photoURL, let url = URL(string: photoURL) {
            AsyncImage(url: url) { phase in
                if case .success(let image) = phase {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    placeholder
                }
            }
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        LinearGradient(
            colors: [Color.atlasAccent600.opacity(0.7), Color.atlasAccent.opacity(0.35)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            Image(systemName: "photo")
                .font(.title)
                .foregroundStyle(.white.opacity(0.6))
        }
    }
}

#Preview {
    PhotoCard(title: "Tokyo", subtitle: "12 places", photoURL: nil)
        .padding()
}
