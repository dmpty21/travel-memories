import SwiftUI

struct PlacePhotoHeader: View {
    let place: Place

    var body: some View {
        if let photoData = place.photoData, let uiImage = UIImage(data: photoData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200)
                .clipped()
        }
    }
}
