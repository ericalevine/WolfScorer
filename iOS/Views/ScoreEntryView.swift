import SwiftUI

struct ScoreEntryView: View {
    @EnvironmentObject var vm: GameViewModel
    @State private var showLeaderboard = false
    @State private var scores: [UUID: Int] = [:]

    private var wolfTeam: Set<UUID> {
        var team: Set<UUID> = [vm.currentHole.wolfPlayerID]
        if let p = vm.currentHole.partnerPlayerID { team.insert(p) }
        return team
    }

    private var isLone: Bool {
        vm.currentHole.isLoneWolf || vm.currentHole.isBlindWolf
    }

    private var modeLabel: String {
        if vm.currentHole.isBlindWolf { return "Blind Wolf" }
        if vm.currentHole.isLoneWolf { return "Lone Wolf" }
        return "2v2"
    }

    private var modeLabelColor: Color {
        if vm.currentHole.isBlindWolf { return .purple }
        if vm.currentHole.isLoneWolf { return .orange }
        return .blue
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text(modeLabel)
                            .font(.headline)
                            .foregroundStyle(modeLabelColor)
                        Spacer()
                        if !isLone, let pid = vm.currentHole.partnerPlayerID,
                           let partner = vm.game.players.first(where: { $0.id == pid }) {
                            Text("\(vm.wolf.name) + \(partner.name) vs field")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("\(vm.wolf.name) vs field")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if !isLone {
                    Section("Wolf's Team") {
                        ForEach(vm.game.players.filter { wolfTeam.contains($0.id) }) { player in
                            ScoreRow(player: player, score: scoreBinding(for: player.id))
                        }
                    }
                    Section("Opponents") {
                        ForEach(vm.game.players.filter { !wolfTeam.contains($0.id) }) { player in
                            ScoreRow(player: player, score: scoreBinding(for: player.id))
                        }
                    }
                } else {
                    Section("Wolf") {
                        ForEach(vm.game.players.filter { $0.id == vm.currentHole.wolfPlayerID }) { player in
                            ScoreRow(player: player, score: scoreBinding(for: player.id))
                        }
                    }
                    Section("Field") {
                        ForEach(vm.game.players.filter { $0.id != vm.currentHole.wolfPlayerID }) { player in
                            ScoreRow(player: player, score: scoreBinding(for: player.id))
                        }
                    }
                }

                Section {
                    Button("Submit Scores") {
                        for (id, score) in scores {
                            vm.enterScore(for: id, score: score)
                        }
                        vm.submitScores()
                        PhoneConnectivityManager.shared.sendGameState(vm)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Hole \(vm.currentHole.number) Scores")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showLeaderboard = true } label: {
                        Image(systemName: "list.number")
                    }
                }
            }
            .sheet(isPresented: $showLeaderboard) {
                LeaderboardView()
            }
            .onAppear {
                for player in vm.game.players {
                    scores[player.id] = 4
                }
            }
        }
    }

    private func scoreBinding(for id: UUID) -> Binding<Int> {
        Binding(
            get: { scores[id, default: 4] },
            set: { scores[id] = $0 }
        )
    }
}

struct ScoreRow: View {
    let player: Player
    @Binding var score: Int

    var body: some View {
        HStack {
            Text(player.name)
            Spacer()
            Stepper("\(score)", value: $score, in: 1...15)
                .fixedSize()
        }
    }
}
