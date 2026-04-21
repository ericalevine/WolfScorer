import SwiftUI

struct WatchContentView: View {
    @EnvironmentObject var connectivity: WatchConnectivityManager

    var body: some View {
        if let state = connectivity.gameState {
            WatchLeaderboardView(state: state)
        } else {
            VStack(spacing: 8) {
                Image(systemName: "pawprint.fill")
                    .font(.title2)
                    .foregroundStyle(.orange)
                Text("Wolf Scorer")
                    .font(.headline)
                Text("Open app on iPhone to start")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}
