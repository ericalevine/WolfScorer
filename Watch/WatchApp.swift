import SwiftUI

@main
struct WolfScorerWatchApp: App {
    @StateObject private var connectivity = WatchConnectivityManager()

    var body: some Scene {
        WindowGroup {
            WatchContentView()
                .environmentObject(connectivity)
        }
    }
}
