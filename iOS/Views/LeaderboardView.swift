import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject var vm: GameViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Standings — After Hole \(vm.game.holes.count)") {
                    ForEach(Array(vm.leaderboard.enumerated()), id: \.element.id) { rank, player in
                        HStack {
                            Text("\(rank + 1)")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                                .frame(width: 24)
                            Text(player.name)
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("\(player.points) pts")
                                    .fontWeight(.semibold)
                                let money = vm.moneySettlement[player.id] ?? 0
                                let moneyStr = String(format: "%.2f", abs(money))
                                Text(money >= 0 ? "+$\(moneyStr)" : "-$\(moneyStr)")
                                    .font(.caption)
                                    .foregroundStyle(money >= 0 ? .green : .red)
                            }
                        }
                    }
                }

                if !vm.game.holes.isEmpty {
                    Section("Hole History") {
                        ForEach(vm.game.holes) { hole in
                            HoleHistoryRow(hole: hole, players: vm.game.players)
                        }
                    }
                }
            }
            .navigationTitle("Leaderboard")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct HoleHistoryRow: View {
    let hole: HoleRecord
    let players: [Player]

    private var wolfName: String {
        players.first { $0.id == hole.wolfPlayerID }?.name ?? "?"
    }

    private var modeLabel: String {
        if hole.isBlindWolf { return "Blind Wolf" }
        if hole.isLoneWolf { return "Lone Wolf" }
        if let pid = hole.partnerPlayerID, let p = players.first(where: { $0.id == pid }) {
            return "w/ \(p.name)"
        }
        return "Lone Wolf"
    }

    private var resultLabel: String {
        switch hole.result {
        case "wolfWins": return "W"
        case "wolfLoses": return "L"
        default: return "T"
        }
    }

    private var resultColor: Color {
        switch hole.result {
        case "wolfWins": return .green
        case "wolfLoses": return .red
        default: return .secondary
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Text("H\(hole.number)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 28, alignment: .leading)
            VStack(alignment: .leading, spacing: 2) {
                Text(wolfName)
                    .font(.subheadline)
                Text(modeLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(resultLabel)
                .font(.headline)
                .foregroundStyle(resultColor)
        }
    }
}
