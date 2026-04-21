import Foundation

struct Game: Identifiable, Codable {
    let id: UUID
    var players: [Player]
    var holes: [HoleRecord] = []
    var pointValueDollars: Double = 1.0
    var currentHoleNumber: Int = 1
    var isComplete: Bool = false

    init(players: [Player], pointValueDollars: Double = 1.0) {
        self.id = UUID()
        self.players = players
        self.pointValueDollars = pointValueDollars
    }

    func wolfIndex(forHole hole: Int) -> Int {
        let n = players.count
        return (hole - 1 + n - 1) % n
    }

    func wolfPlayer(forHole hole: Int) -> Player {
        players[wolfIndex(forHole: hole)]
    }

    // All non-wolf players in order, then wolf last
    func teeOrder(forHole hole: Int) -> [Player] {
        var order = players
        let wolfIdx = wolfIndex(forHole: hole)
        let wolf = order.remove(at: wolfIdx)
        order.append(wolf)
        return order
    }
}
