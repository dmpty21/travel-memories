import SwiftUI

struct PhotoCard: View {
    let title: String
    let subtitle: String
    let imageData: Data?

    var body: some View {
        photo
            .frame(height: 160)
            .overlay(alignment: .bottom) {
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0),
                        .init(color: .black.opacity(0), location: 0.45),
                        .init(color: .black.opacity(0.45), location: 0.75),
                        .init(color: .black.opacity(0.75), location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .allowsHitTesting(false)
            }
            .overlay(alignment: .bottomLeading) {
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
                .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 1)
                .padding(14)
                .zIndex(1)
            }
            .clipShape(RoundedRectangle(cornerRadius: AtlasRadius.xl, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AtlasRadius.xl, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
            )
    }

    @ViewBuilder
    private var photo: some View {
        if let imageData, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
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
    PhotoCard(title: "Tokyo", subtitle: "12 places", imageData: nil)
        .padding()
}
