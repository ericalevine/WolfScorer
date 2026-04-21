import SwiftUI

struct WatchLeaderboardView: View {
    let state: WatchGameState

    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: "pawprint.fill")
                        .foregroundStyle(.orange)
                        .font(.caption)
                    Text(state.wolfName)
                        .font(.caption)
                    Spacer()
                    Text("H\(state.holeNumber)")
                        .foregroundStyle(.secondary)
                        .font(.caption2)
                }
            }

            Section("Standings") {
                ForEach(Array(state.players.enumerated()), id: \.offset) { rank, player in
                    HStack {
                        Text("\(rank + 1).")
                            .foregroundStyle(.secondary)
                            .font(.caption2)
                            .frame(width: 16)
                        Text(player.name)
                            .font(.caption)
                            .lineLimit(1)
                        Spacer()
                        Text("\(player.points)")
                            .font(.caption.bold())
                    }
                }
            }
        }
        .navigationTitle("Wolf")
    }
}
