import SwiftUI

struct WolfDecisionView: View {
    @EnvironmentObject var vm: GameViewModel
    @State private var showLeaderboard = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                holeHeader
                    .padding()
                    .background(Color(.systemGroupedBackground))

                List {
                    if vm.currentPlayerIndex == 0 && !vm.currentPlayerHasHit {
                        Section {
                            Button {
                                vm.goBlindWolf()
                            } label: {
                                Label("Declare Blind Wolf", systemImage: "eye.slash.fill")
                                    .frame(maxWidth: .infinity)
                                    .foregroundStyle(.purple)
                            }
                        } footer: {
                            Text("Before any tee shots — doubles all points")
                        }
                    }

                    Section("Tee Order") {
                        ForEach(Array(vm.nonWolfPlayers.enumerated()), id: \.element.id) { idx, player in
                            PlayerTeeRow(player: player, index: idx)
                        }

                        HStack {
                            Image(systemName: "pawprint.fill")
                                .foregroundStyle(.orange)
                            Text(vm.wolf.name)
                                .fontWeight(.semibold)
                            Spacer()
                            Text("Wolf — hits last")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                    }

                    if vm.currentPlayerHasHit, let player = vm.currentDecisionPlayer {
                        Section("Wolf's Decision") {
                            Button {
                                vm.selectPartner(player)
                            } label: {
                                Label("Pick \(player.name) as Partner", systemImage: "person.2.fill")
                                    .frame(maxWidth: .infinity)
                                    .foregroundStyle(.green)
                            }

                            Button {
                                vm.passCurrentPlayer()
                            } label: {
                                Label(
                                    vm.currentPlayerIndex >= vm.nonWolfPlayers.count - 1
                                        ? "Pass — Go Lone Wolf"
                                        : "Pass — See Next Shot",
                                    systemImage: "forward.fill"
                                )
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Button("Go Lone Wolf") {
                    vm.goLoneWolf()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemBackground))
            }
            .navigationTitle("Hole \(vm.currentHole.number)")
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
        }
    }

    var holeHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Wolf")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(spacing: 6) {
                    Image(systemName: "pawprint.fill")
                        .foregroundStyle(.orange)
                    Text(vm.wolf.name)
                        .font(.title2.bold())
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("Hole \(vm.currentHole.number) of 18")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(vm.wolf.points) pts")
                    .font(.title2.bold())
                    .foregroundStyle(.orange)
            }
        }
    }
}

struct PlayerTeeRow: View {
    @EnvironmentObject var vm: GameViewModel
    let player: Player
    let index: Int

    private var isPassed: Bool { index < vm.currentPlayerIndex }
    private var isCurrent: Bool { index == vm.currentPlayerIndex }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(player.name)
                    .foregroundStyle(isPassed ? .secondary : .primary)
                if isPassed {
                    Text("Passed")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            if isPassed {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            } else if isCurrent && !vm.currentPlayerHasHit {
                Button("They Hit →") {
                    vm.markCurrentPlayerHit()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            } else if isCurrent && vm.currentPlayerHasHit {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            } else {
                Text("Up next")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}
