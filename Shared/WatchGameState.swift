import Foundation

struct WatchGameState: Codable {
    struct PlayerSummary: Codable {
        let name: String
        let points: Int
    }
    let holeNumber: Int
    let wolfName: String
    let players: [PlayerSummary]
}
