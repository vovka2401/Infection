import SwiftUI

struct ContentView: View {
    @StateObject var menuViewModel = MenuViewModel()
    @StateObject var navigator = Navigator.shared
    @StateObject var authViewModel = AuthViewModel()

    var body: some View {
        NavigationStack(path: $navigator.path) {
            if authViewModel.state == .signedOut && !UserDefaults.standard.isLoggedIn {
                LoginView()
                    .transition(.opacity)
                    .environmentObject(authViewModel)
            } else {
                MenuView()
                    .transition(.opacity)
                    .environmentObject(menuViewModel)
                    .environmentObject(navigator)
                    .environmentObject(authViewModel)
                    .navigationDestination(for: NavigationDestination.self) { value in
                        switch value {
                        case .createLobbyView(isLocalGame: let isLocalGame):
                            CreateLobbyView(isLocalGame: isLocalGame)
                                .environmentObject(menuViewModel)
                                .environmentObject(navigator)
                        case .gameView:
                            GameView(gameViewModel: menuViewModel.gameViewModel)
                        case .lobbiesView:
                            LobbiesView()
                                .environmentObject(menuViewModel)
                                .environmentObject(navigator)
                        case .lobbyView(let lobby):
                            LobbyView(lobby: lobby)
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
                    .onAppear {
                        GameManager.shared.authentificatePlayer()
                    }
            }
        }
        .animation(.easeInOut, value: authViewModel.state)
    }
}

#Preview {
    ContentView()
}
