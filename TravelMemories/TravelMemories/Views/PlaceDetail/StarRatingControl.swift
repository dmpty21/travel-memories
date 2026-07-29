import SwiftUI

struct StarRatingControl: View {
    @Binding var rating: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .foregroundStyle(star <= rating ? .yellow : .secondary)
                    .onTapGesture {
                        rating = (rating == star) ? 0 : star
                    }
            }
        }
        .imageScale(.large)
    }
}

struct StarRatingView: View {
    var rating: Int

    var body: some View {
        HStack(spacing: 1) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
            }
        }
        .foregroundStyle(.yellow)
        .imageScale(.small)
    }
}

#Preview {
    VStack(spacing: 24) {
        StarRatingControl(rating: .constant(3))
        StarRatingView(rating: 4)
    }
    .padding()
}
