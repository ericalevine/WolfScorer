import SwiftUI

struct WatchLeaderboardView: View {
    let state: WatchGameState
    let detectionsThisHole: Int

    var body: some View {
        List {
            if state.isWolfDecision {
                listeningSection
            }

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

    var listeningSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(.green)
                        .frame(width: 7, height: 7)
                    Text("Listening")
                        .font(.caption2.bold())
                        .foregroundStyle(.green)
                    Spacer()
                    if detectionsThisHole > 0 {
                        Text("\(detectionsThisHole)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                if let name = state.currentPlayerName {
                    Text("\(name) is up")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
