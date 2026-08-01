import SwiftUI

enum AtlasRadius {
    static let sm: CGFloat = 4
    static let md: CGFloat = 8
    static let lg: CGFloat = 14
    static let xl: CGFloat = 24
    static let pill: CGFloat = 999
}

extension Color {
    static let atlasGround = Color(red: 0xf7 / 255, green: 0xf7 / 255, blue: 0xf4 / 255)
    static let atlasSurface = Color(red: 0xff / 255, green: 0xff / 255, blue: 0xff / 255)
    static let atlasAccent = Color(red: 0x2f / 255, green: 0x9e / 255, blue: 0x91 / 255)
    static let atlasAccent600 = Color(red: 0x22 / 255, green: 0x7e / 255, blue: 0x74 / 255)
    static let atlasAccent800 = Color(red: 0x17 / 255, green: 0x4a / 255, blue: 0x45 / 255)
    /// Splash/app-icon gradient stops flanking `atlasAccent800`.
    static let atlasPineLight = Color(red: 0x1c / 255, green: 0x5a / 255, blue: 0x54 / 255)
    static let atlasPineDark = Color(red: 0x12 / 255, green: 0x3b / 255, blue: 0x37 / 255)
    static let atlasNeutral500 = Color(red: 0xa9 / 255, green: 0xa5 / 255, blue: 0x9c / 255)
    static let atlasNeutral800 = Color(red: 0x3a / 255, green: 0x37 / 255, blue: 0x2f / 255)
    static let atlasText = Color(red: 0x21 / 255, green: 0x20 / 255, blue: 0x1b / 255)
}

/// A soft, glassy surface used for stat cards, sheets, and hero panels across the app.
struct AtlasCardBackground: ViewModifier {
    var radius: CGFloat = AtlasRadius.xl

    func body(content: Content) -> some View {
        content
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.5), lineWidth: 1)
            )
    }
}

extension View {
    func atlasCard(radius: CGFloat = AtlasRadius.xl) -> some View {
        modifier(AtlasCardBackground(radius: radius))
    }
}
