import SwiftUI

@main
struct WolfScorerApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            if let vm = appState.viewModel {
                RootView()
                    .environmentObject(vm)
                    .environmentObject(appState)
            } else {
                SetupView()
                    .environmentObject(appState)
            }
        }
    }
}

@MainActor
class AppState: ObservableObject {
    @Published var viewModel: GameViewModel?

    func startGame(players: [Player], pointValue: Double) {
        viewModel = GameViewModel(players: players, pointValue: pointValue)
    }

    func resetGame() {
        viewModel = nil
    }
}

struct RootView: View {
    @EnvironmentObject var vm: GameViewModel
    @EnvironmentObject var appState: AppState

    var body: some View {
        switch vm.phase {
        case .wolfDecision:
            WolfDecisionView()
        case .scoreEntry:
            ScoreEntryView()
        case .holeResult:
            HoleResultView()
        case .complete:
            SummaryView()
        }
    }
}
