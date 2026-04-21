import Foundation

struct WolfScoringEngine {

    static func calculatePoints(hole: HoleRecord, players: [Player]) -> [UUID: Int] {
        guard hole.scores.count == players.count else { return [:] }

        var points: [UUID: Int] = [:]
        players.forEach { points[$0.id] = 0 }

        let multiplier = hole.isBlindWolf ? 2 : 1
        let wolfID = hole.wolfPlayerID
        let isLone = hole.isLoneWolf || hole.isBlindWolf || hole.partnerPlayerID == nil

        if isLone {
            let wolfScore = hole.scores[wolfID] ?? 99
            let bestOther = players
                .filter { $0.id != wolfID }
                .compactMap { hole.scores[$0.id] }
                .min() ?? 99

            if wolfScore < bestOther {
                points[wolfID] = 2 * multiplier
            } else if wolfScore > bestOther {
                players.filter { $0.id != wolfID }.forEach {
                    points[$0.id] = 1 * multiplier
                }
            }
        } else {
            guard let partnerID = hole.partnerPlayerID else { return points }
            let wolfTeam: Set<UUID> = [wolfID, partnerID]

            let wolfBest = players.filter { wolfTeam.contains($0.id) }
                .compactMap { hole.scores[$0.id] }.min() ?? 99
            let otherBest = players.filter { !wolfTeam.contains($0.id) }
                .compactMap { hole.scores[$0.id] }.min() ?? 99

            if wolfBest < otherBest {
                players.filter { wolfTeam.contains($0.id) }.forEach {
                    points[$0.id] = 1 * multiplier
                }
            } else if wolfBest > otherBest {
                players.filter { !wolfTeam.contains($0.id) }.forEach {
                    points[$0.id] = 1 * multiplier
                }
            }
        }

        return points
    }

    static func applyPoints(awarded: [UUID: Int], to players: inout [Player]) {
        for i in players.indices {
            players[i].points += awarded[players[i].id] ?? 0
        }
    }

    static func moneySettlement(players: [Player], pointValue: Double) -> [UUID: Double] {
        let avg = Double(players.reduce(0) { $0 + $1.points }) / Double(players.count)
        return Dictionary(uniqueKeysWithValues: players.map {
            ($0.id, (Double($0.points) - avg) * pointValue)
        })
    }
}
