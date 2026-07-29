import SwiftUI

struct PlacePhotoHeader: View {
    let place: Place

    var body: some View {
        if let urlString = place.photoURL, let url = URL(string: urlString) {
            VStack(alignment: .trailing, spacing: 4) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Color.clear
                    default:
                        ZStack {
                            Color.secondary.opacity(0.1)
                            ProgressView()
                        }
                    }
                }
                .frame(height: 200)
                .clipped()

                if let photographer = place.photoPhotographer {
                    Text("Photo by \(photographer) on Pexels")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 6)
                }
            }
        }
    }
}
