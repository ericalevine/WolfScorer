import Foundation

struct WatchGameState: Codable {
    struct PlayerSummary: Codable {
        let name: String
        let points: Int
    }
    let holeNumber: Int
    let wolfName: String
    let players: [PlayerSummary]
    var isWolfDecision: Bool = false
    var currentPlayerName: String?  // whose tee shot is next
}
