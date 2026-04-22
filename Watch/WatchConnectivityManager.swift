import Foundation
import WatchConnectivity

@MainActor
class WatchConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    @Published var gameState: WatchGameState?

    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func sendPlayerHit() {
        guard WCSession.default.isReachable else { return }
        WCSession.default.sendMessage(["playerHit": true], replyHandler: nil)
    }

    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        guard let data = message["gameState"] as? Data,
              let state = try? JSONDecoder().decode(WatchGameState.self, from: data) else { return }
        Task { @MainActor in self.gameState = state }
    }

    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        guard let data = applicationContext["gameState"] as? Data,
              let state = try? JSONDecoder().decode(WatchGameState.self, from: data) else { return }
        Task { @MainActor in self.gameState = state }
    }
}
