import SwiftUI

struct WatchContentView: View {
    @EnvironmentObject var connectivity: WatchConnectivityManager
    @StateObject private var detector = ImpactDetector()

    var body: some View {
        Group {
            if let state = connectivity.gameState {
                WatchLeaderboardView(state: state, detectionsThisHole: detector.detectionsThisHole)
            } else {
                idleView
            }
        }
        .onAppear {
            detector.onImpact = { [weak connectivity] in
                connectivity?.sendPlayerHit()
            }
        }
        .onChange(of: connectivity.gameState?.isWolfDecision) { _, isDecision in
            if isDecision == true {
                detector.startListening()
            } else {
                detector.stopListening()
            }
        }
        .onChange(of: connectivity.gameState?.holeNumber) { _, _ in
            detector.resetCount()
        }
    }

    var idleView: some View {
        VStack(spacing: 8) {
            Image(systemName: "pawprint.fill")
                .font(.title2)
                .foregroundStyle(.orange)
            Text("Wolf Scorer")
                .font(.headline)
            Text("Open app on iPhone")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}
