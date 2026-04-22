import Foundation
import WatchConnectivity

class PhoneConnectivityManager: NSObject, WCSessionDelegate {
    static let shared = PhoneConnectivityManager()

    var onPlayerHit: (() -> Void)?

    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func sendGameState(_ vm: GameViewModel) {
        guard WCSession.default.activationState == .activated else { return }
        let snapshot = WatchGameState(
            holeNumber: vm.currentHole.number,
            wolfName: vm.wolf.name,
            players: vm.leaderboard.map { WatchGameState.PlayerSummary(name: $0.name, points: $0.points) },
            isWolfDecision: vm.phase == .wolfDecision,
            currentPlayerName: vm.currentDecisionPlayer?.name
        )
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["gameState": data], replyHandler: nil)
        } else {
            try? WCSession.default.updateApplicationContext(["gameState": data])
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) { WCSession.default.activate() }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if message["playerHit"] != nil {
            Task { @MainActor in self.onPlayerHit?() }
            return
        }
    }
}
