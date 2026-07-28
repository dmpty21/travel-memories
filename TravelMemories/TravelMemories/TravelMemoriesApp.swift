import SwiftUI
import SwiftData

@main
struct TravelMemoriesApp: App {
    @State private var isShowingSplash = true

    var body: some Scene {
        WindowGroup {
            if isShowingSplash {
                SplashView {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isShowingSplash = false
                    }
                }
            } else {
                RootTabView()
            }
        }
        .modelContainer(for: [Place.self, Recommendation.self, LogisticsNote.self])
    }
}
