//import SwiftUI
//import Firebase
//
//class LobbyViewModel: ObservableObject {
//    @Published var menuViewModel: MenuViewModel
//    @Published var lobby: Lobby
//    @Published var gameStarted = false
//    @Published var lobbyObserver: UInt?
//    @Published var gameObserver: UInt?
//    var isHost: Bool { lobby.host == GameManager.shared.localPlayer }
//    
//    init(menuViewModel: MenuViewModel, lobby: Lobby) {
//        self.menuViewModel = menuViewModel
//        self.lobby = lobby
//    }
//
//    func startGame(_ game: Game? = nil) {
//        removeObservers()
//        lobby.settings.maxCountOfPlayers = lobby.map.getCountOfPlayers()
//        let game = game ?? Game(lobby: lobby)
//        menuViewModel.gameViewModel = GameViewModel(game: game)
//        menuViewModel.gameViewModel.setup(isHost: isHost)
//        Navigator.shared.pushGameView()
//    }
//
//    func toggleIsReadyState() {
//        guard let indexOfLocalPlayer = lobby.players.firstIndex(where: { $0 == GameManager.shared.localPlayer }) else { return }
//        var player = lobby.players[indexOfLocalPlayer]
//        player.isReady = true
//        lobby.players[indexOfLocalPlayer] = player
//        print(player.isReady)
//        sendLobbyData()
//    }
//    
//    func quitLobby() {
//        lobby.players.removeAll(where: { $0 == GameManager.shared.localPlayer })
//        removeObservers()
//        sendLobbyData()
//    }
//    
//    func sendLobbyData() {
//        FirebaseManager.shared.sendLobbyData(lobby)
//    }
//
//    func observeLobby() {
//        lobbyObserver = FirebaseManager.shared.ref.child("lobbies").child(lobby.id).child("lobby").observe(.value) { snapshot in
//            if let stringData = snapshot.value as? String {
//                let data = Data(stringData.utf8)
//                do {
//                    self.lobby = try JSONDecoder().decode(Lobby.self, from: data)
//                } catch {
//                    print(error)
//                }
//            }
//        }
//        gameObserver = FirebaseManager.shared.ref.child("lobbies").child(lobby.id).child("game").observe(.value) { snapshot in
//            if !self.gameStarted, let stringData = snapshot.value as? String {
//                let data = Data(stringData.utf8)
//                do {
//                    let game = try JSONDecoder().decode(Game.self, from: data)
//                    self.startGame(game)
//                } catch {
//                    print(error)
//                }
//            }
//        }
//    }
//    
//    func removeObservers() {
//        if let lobbyObserver {
//            FirebaseManager.shared.ref.child("lobbies").child(lobby.id).child("lobby").removeObserver(withHandle: lobbyObserver)
//        }
//        if let gameObserver {
//            FirebaseManager.shared.ref.child("lobbies").child(lobby.id).child("game").removeObserver(withHandle: gameObserver)
//        }
//    }
//}
