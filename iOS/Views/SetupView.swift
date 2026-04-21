import SwiftUI

struct SetupView: View {
    @EnvironmentObject var appState: AppState

    @State private var playerNames: [String] = ["", "", "", ""]
    @State private var playerCount: Int = 4
    @State private var pointValueText: String = "1"

    private var validNames: [String] {
        playerNames.prefix(playerCount)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    private var canStart: Bool { validNames.count == playerCount }

    var body: some View {
        NavigationStack {
            Form {
                Section("Players") {
                    Picker("", selection: $playerCount) {
                        Text("3 Players").tag(3)
                        Text("4 Players").tag(4)
                    }
                    .pickerStyle(.segmented)

                    ForEach(0..<playerCount, id: \.self) { i in
                        HStack {
                            Text("\(i + 1).")
                                .foregroundStyle(.secondary)
                                .frame(width: 24)
                            TextField("Player \(i + 1)", text: $playerNames[i])
                        }
                    }
                }

                Section("Stakes") {
                    HStack {
                        Text("$ per point")
                        Spacer()
                        TextField("1", text: $pointValueText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 70)
                    }
                }

                Section {
                    Button("Start Game") {
                        let players = validNames.map { Player(name: $0) }
                        appState.startGame(
                            players: players,
                            pointValue: Double(pointValueText) ?? 1.0
                        )
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(!canStart)
                }
            }
            .navigationTitle("Wolf Scorer")
        }
    }
}
