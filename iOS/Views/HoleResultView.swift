import SwiftUI

struct HoleResultView: View {
    @EnvironmentObject var vm: GameViewModel

    private var lastHole: HoleRecord? { vm.game.holes.last }

    private var resultTitle: String {
        guard let hole = lastHole else { return "" }
        switch hole.result {
        case "wolfWins":
            if hole.isBlindWolf { return "Blind Wolf Wins!" }
            if hole.isLoneWolf { return "Lone Wolf Wins!" }
            return "Wolf Team Wins!"
        case "wolfLoses":
            if hole.isBlindWolf { return "Blind Wolf Falls" }
            if hole.isLoneWolf { return "Lone Wolf Falls" }
            return "Field Wins"
        default:
            return "Tied — No Points"
        }
    }

    private var resultColor: Color {
        switch lastHole?.result {
        case "wolfWins": return .green
        case "wolfLoses": return .red
        default: return .secondary
        }
    }

    private var resultIcon: String {
        switch lastHole?.result {
        case "wolfWins": return "star.fill"
        case "wolfLoses": return "xmark.circle.fill"
        default: return "equal.circle.fill"
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Image(systemName: resultIcon)
                            .font(.system(size: 52))
                            .foregroundStyle(resultColor)
                        Text(resultTitle)
                            .font(.title.bold())
                            .foregroundStyle(resultColor)
                    }
                    .padding(.top)

                    if let hole = lastHole {
                        GroupBox("Points This Hole") {
                            VStack(spacing: 10) {
                                ForEach(vm.game.players) { player in
                                    let pts = hole.pointsAwarded[player.id] ?? 0
                                    HStack {
                                        Text(player.name)
                                        Spacer()
                                        Text(pts > 0 ? "+\(pts)" : "0")
                                            .fontWeight(pts > 0 ? .bold : .regular)
                                            .foregroundStyle(pts > 0 ? .green : .secondary)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .padding(.horizontal)
                    }

                    GroupBox("Standings") {
                        VStack(spacing: 10) {
                            ForEach(Array(vm.leaderboard.enumerated()), id: \.element.id) { rank, player in
                                HStack {
                                    Text("\(rank + 1).")
                                        .foregroundStyle(.secondary)
                                        .frame(width: 20)
                                    Text(player.name)
                                    Spacer()
                                    Text("\(player.points) pts")
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .padding(.horizontal)

                    Button(vm.currentHole.number >= 18 ? "See Final Results" : "Next Hole →") {
                        vm.nextHole()
                        PhoneConnectivityManager.shared.sendGameState(vm)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .padding(.bottom)
                }
            }
            .navigationTitle("Hole \(lastHole?.number ?? vm.currentHole.number) Result")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
