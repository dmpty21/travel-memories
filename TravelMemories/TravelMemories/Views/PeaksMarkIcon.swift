import SwiftUI

/// The "Peaks Mark" — Atlas's logo: a simple mountain-range line, drawn from
/// the same path data as the brand's design source (100x100 unit space).
struct PeaksMarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        let points: [CGPoint] = [
            CGPoint(x: 14, y: 64),
            CGPoint(x: 34, y: 34),
            CGPoint(x: 50, y: 54),
            CGPoint(x: 66, y: 28),
            CGPoint(x: 88, y: 60),
        ]
        let scaleX = rect.width / 100
        let scaleY = rect.height / 100

        var path = Path()
        for (index, point) in points.enumerated() {
            let scaled = CGPoint(x: rect.minX + point.x * scaleX, y: rect.minY + point.y * scaleY)
            if index == 0 {
                path.move(to: scaled)
            } else {
                path.addLine(to: scaled)
            }
        }
        return path
    }
}

struct PeaksMarkIcon: View {
    var size: CGFloat = 120
    var color: Color = .atlasAccent800

    private var strokeWidth: CGFloat { size * 0.042 }

    var body: some View {
        PeaksMarkShape()
            .stroke(color, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round, lineJoin: .round))
            .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 40) {
        PeaksMarkIcon(size: 120)
        PeaksMarkIcon(size: 88, color: .atlasGround)
            .padding(40)
            .background(Color.atlasAccent800)
    }
    .padding()
}
