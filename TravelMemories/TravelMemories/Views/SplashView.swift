import SwiftUI

struct SplashView: View {
    var onFinished: () -> Void

    @State private var isPulsing = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            StackedMemoriesIcon(size: 120)
                .opacity(isPulsing ? 0.55 : 1.0)
                .animation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true), value: isPulsing)
        }
        .onAppear {
            isPulsing = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                onFinished()
            }
        }
    }
}

#Preview {
    SplashView(onFinished: {})
}
