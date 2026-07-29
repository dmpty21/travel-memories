import SwiftUI

struct PlaceRow: View {
    @Bindable var place: Place

    var body: some View {
        HStack(spacing: 12) {
            Group {
                if let urlString = place.photoURL, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        if case .success(let image) = phase {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            Color.secondary.opacity(0.15)
                        }
                    }
                } else {
                    Color.secondary.opacity(0.15)
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundStyle(.secondary)
                                .imageScale(.small)
                        }
                }
            }
            .frame(width: 44, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Text(place.city)
        }
        .task {
            await place.loadPhotoIfNeeded()
        }
    }
}
