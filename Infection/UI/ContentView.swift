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
                    if value == .createGameView(isLocalGame: false) {
                        CreateGameView(isLocalGame: false)
                            .environmentObject(menuViewModel)
                            .environmentObject(navigator)
                    } else if value == .createGameView(isLocalGame: true) {
                        CreateGameView(isLocalGame: true)
                            .environmentObject(menuViewModel)
                            .environmentObject(navigator)
                    } else if value == .gameView {
                        GameView(gameViewModel: menuViewModel.gameCenterManager.gameViewModel)
                            .environmentObject(menuViewModel)
                            .environmentObject(navigator)
                    } else if value == .joinGameView {
                        JoinGameView()
                            .environmentObject(menuViewModel)
                            .environmentObject(navigator)
                    }
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
