import Foundation
import Combine

@MainActor
class GameViewModel: ObservableObject {
    @Published var game: Game
    @Published var currentHole: HoleRecord
    @Published var phase: GamePhase = .wolfDecision
    @Published var currentPlayerIndex: Int = 0
    @Published var currentPlayerHasHit: Bool = false

    enum GamePhase: Equatable {
        case wolfDecision
        case scoreEntry
        case holeResult
        case complete
    }

    init(players: [Player], pointValue: Double = 1.0) {
        let g = Game(players: players, pointValueDollars: pointValue)
        self.game = g
        self.currentHole = HoleRecord(
            number: 1,
            wolfPlayerID: g.wolfPlayer(forHole: 1).id
        )
    }

    var wolf: Player {
        game.players.first { $0.id == currentHole.wolfPlayerID }!
    }

    var teeOrder: [Player] {
        game.teeOrder(forHole: currentHole.number)
    }

    var nonWolfPlayers: [Player] {
        Array(teeOrder.dropLast())
    }

    var currentDecisionPlayer: Player? {
        guard currentPlayerIndex < nonWolfPlayers.count else { return nil }
        return nonWolfPlayers[currentPlayerIndex]
    }

    // MARK: - Wolf Decision

    func markCurrentPlayerHit() {
        currentPlayerHasHit = true
    }

    func selectPartner(_ player: Player) {
        currentHole.partnerPlayerID = player.id
        currentHole.isLoneWolf = false
        currentHole.isBlindWolf = false
        phase = .scoreEntry
    }

    func passCurrentPlayer() {
        currentPlayerIndex += 1
        currentPlayerHasHit = false
        if currentPlayerIndex >= nonWolfPlayers.count {
            goLoneWolf()
        }
    }

    func goLoneWolf() {
        currentHole.isLoneWolf = true
        currentHole.partnerPlayerID = nil
        currentHole.isBlindWolf = false
        phase = .scoreEntry
    }

    func goBlindWolf() {
        currentHole.isBlindWolf = true
        currentHole.isLoneWolf = true
        currentHole.partnerPlayerID = nil
        phase = .scoreEntry
    }

    // MARK: - Score Entry

    func enterScore(for playerID: UUID, score: Int) {
        currentHole.scores[playerID] = score
    }

    var allScoresEntered: Bool {
        currentHole.scores.count == game.players.count
    }

    func submitScores() {
        guard allScoresEntered else { return }
        let awarded = WolfScoringEngine.calculatePoints(hole: currentHole, players: game.players)
        currentHole.pointsAwarded = awarded
        WolfScoringEngine.applyPoints(awarded: awarded, to: &game.players)
        currentHole.result = {
            let wolfPts = awarded[currentHole.wolfPlayerID] ?? 0
            if wolfPts > 0 { return "wolfWins" }
            return awarded.values.contains { $0 > 0 } ? "wolfLoses" : "tied"
        }()
        game.holes.append(currentHole)
        phase = .holeResult
    }

    // MARK: - Advance

    func nextHole() {
        let next = currentHole.number + 1
        if next > 18 {
            game.isComplete = true
            phase = .complete
        } else {
            game.currentHoleNumber = next
            currentHole = HoleRecord(
                number: next,
                wolfPlayerID: game.wolfPlayer(forHole: next).id
            )
            currentPlayerIndex = 0
            currentPlayerHasHit = false
            phase = .wolfDecision
        }
    }

    // MARK: - Results

    var leaderboard: [Player] {
        game.players.sorted { $0.points > $1.points }
    }

    var moneySettlement: [UUID: Double] {
        WolfScoringEngine.moneySettlement(players: game.players, pointValue: game.pointValueDollars)
    }
}
