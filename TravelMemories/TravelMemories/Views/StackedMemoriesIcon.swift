import SwiftUI

struct StackedMemoriesIcon: View {
    var size: CGFloat = 120
    var color: Color = .atlasAccent

    private var cornerRadius: CGFloat { size * (14.0 / 104.0) }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(color)
                .opacity(0.55)
                .rotationEffect(.degrees(-12))
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(color)
                .opacity(0.8)
                .rotationEffect(.degrees(8))
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(color)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    StackedMemoriesIcon()
        .padding(60)
        .background(Color.black)
}
