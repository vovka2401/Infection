import SwiftUI

struct ContentView: View {
    @StateObject var menuViewModel = MenuViewModel()
    @StateObject var navigator = Navigator.shared

    var body: some View {
        NavigationStack(path: $navigator.path) {
            MenuView()
                .environmentObject(menuViewModel)
                .environmentObject(navigator)
                .navigationDestination(for: NavigationDestination.self) { value in
                    switch value {
                    case .createGameView(isLocalGame: let isLocalGame):
                        CreateGameView(isLocalGame: isLocalGame)
                            .environmentObject(menuViewModel)
                            .environmentObject(navigator)
                    case .gameView:
                        GameView(gameViewModel: menuViewModel.gameCenterManager.gameViewModel)
                    case .joinGameView:
                        JoinGameView()
                            .environmentObject(menuViewModel)
                            .environmentObject(navigator)
                    }
                }
                .overlay {
//                    if !menuViewModel.wasTutorialShown {
//                        TutorialView()
//                            .environmentObject(menuViewModel)
//                            .transition(.opacity)
//                            .animation(.easeInOut, value: menuViewModel.wasTutorialShown)
//                    }
                }
        }
        .onAppear {
            menuViewModel.gameCenterManager.authenticatePlayer()
        }
    }
}

#Preview {
    ContentView()
}
