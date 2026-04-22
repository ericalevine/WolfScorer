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
        let vm = GameViewModel(players: players, pointValue: pointValue)
        viewModel = vm
        PhoneConnectivityManager.shared.onPlayerHit = { [weak self, weak vm] in
            guard let vm else { return }
            vm.playerHitDetected()
            if let self, self.viewModel != nil {
                PhoneConnectivityManager.shared.sendGameState(vm)
            }
        }
        PhoneConnectivityManager.shared.sendGameState(vm)
    }

    func resetGame() {
        viewModel = nil
        PhoneConnectivityManager.shared.onPlayerHit = nil
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
