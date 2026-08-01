import SwiftUI

struct SplashView: View {
    var onFinished: () -> Void

    @State private var isIconVisible = false
    @State private var isTextVisible = false
    @State private var isGlowing = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.atlasPineLight, .atlasAccent800, .atlasPineDark],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 26) {
                PeaksMarkIcon(size: 88, color: .atlasGround)
                    .opacity(isIconVisible ? 1 : 0)
                    .scaleEffect(isIconVisible ? 1 : 0.8)
                    .shadow(color: .atlasGround.opacity(isGlowing ? 0.45 : 0), radius: isGlowing ? 14 : 0)

                Text("ATLAS")
                    .font(.system(size: 22, weight: .medium, design: .serif))
                    .tracking(9)
                    .foregroundStyle(Color.atlasGround)
                    .opacity(isTextVisible ? 1 : 0)
                    .offset(y: isTextVisible ? 0 : 12)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.9)) {
                isIconVisible = true
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.6)) {
                isTextVisible = true
            }
            withAnimation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true).delay(1.0)) {
                isGlowing = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                onFinished()
            }
        }
    }
}

#Preview {
    SplashView(onFinished: {})
}
