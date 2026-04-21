import SwiftUI

struct SummaryView: View {
    @EnvironmentObject var vm: GameViewModel
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            List {
                if let winner = vm.leaderboard.first {
                    Section {
                        VStack(spacing: 8) {
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(.yellow)
                            Text("\(winner.name) Wins!")
                                .font(.title.bold())
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                }

                Section("Final Standings") {
                    ForEach(Array(vm.leaderboard.enumerated()), id: \.element.id) { rank, player in
                        HStack {
                            Text("\(rank + 1).")
                                .foregroundStyle(.secondary)
                                .frame(width: 24)
                            Text(player.name)
                                .fontWeight(rank == 0 ? .bold : .regular)
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("\(player.points) pts")
                                    .fontWeight(.semibold)
                                let money = vm.moneySettlement[player.id] ?? 0
                                let moneyStr = String(format: "%.2f", abs(money))
                                Text(money >= 0 ? "Wins $\(moneyStr)" : "Owes $\(moneyStr)")
                                    .font(.caption)
                                    .foregroundStyle(money >= 0 ? .green : .red)
                            }
                        }
                    }
                }

                Section("Hole-by-Hole Breakdown") {
                    ForEach(vm.game.holes) { hole in
                        DisclosureGroup {
                            ForEach(vm.game.players) { player in
                                HStack {
                                    Text(player.name)
                                        .font(.subheadline)
                                    Spacer()
                                    if let score = hole.scores[player.id] {
                                        Text("\(score)")
                                            .foregroundStyle(.secondary)
                                    }
                                    let pts = hole.pointsAwarded[player.id] ?? 0
                                    if pts > 0 {
                                        Text("+\(pts)")
                                            .foregroundStyle(.green)
                                            .fontWeight(.semibold)
                                            .frame(width: 32, alignment: .trailing)
                                    } else {
                                        Text("—")
                                            .foregroundStyle(.tertiary)
                                            .frame(width: 32, alignment: .trailing)
                                    }
                                }
                            }
                        } label: {
                            HoleHistoryRow(hole: hole, players: vm.game.players)
                        }
                    }
                }

                Section {
                    Button("New Game") {
                        appState.resetGame()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.red)
                }
            }
            .navigationTitle("Game Summary")
        }
    }
}
