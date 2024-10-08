import Firebase
import SwiftUI
import Combine

struct LobbiesView: View {
    @EnvironmentObject var navigator: Navigator
    @State var lobbies: [Lobby] = []
    
    var body: some View {
        ZStack {
            Image("background2")
                .resizable()
                .frame(size: Screen.size)
                .overlay {
                    Color.white.opacity(0.25)
                        .frame(size: Screen.size)
                }
            VStack(spacing: 0) {
                NavigationBar {
                    navigator.dismiss()
                }
                .padding(.bottom, 5)
                .background(Color(red: 0.863, green: 0.918, blue: 0.992))
                Rectangle()
                    .fill(Color(red: 0.863, green: 0.918, blue: 0.992))
                    .frame(width: Screen.width, height: 30)
                    .overlay {
                        HStack {
                            Text(L10n.mode.text)
                            Spacer()
                            Spacer()
                            Text(L10n.id.text)
                            Spacer()
                            Text(L10n.players.text)
                        }
                        .padding(.horizontal, 25)
                    }
                    .padding(.bottom, 10)
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(lobbies) { lobby in
                            Button {
                                joinLobby(lobby)
                            } label: {
                                RoundedRectangle(cornerRadius: 7)
                                    .fill(.white)
                                    .frame(width: Screen.width - 30, height: 50)
                                    .overlay {
                                        HStack {
                                            Text(lobby.settings.gameWinMode.title)
                                            Spacer()
                                            Text(lobby.id)
                                            Spacer()
                                            Text("\(lobby.players.count) \\ \(lobby.settings.maxCountOfPlayers)")
                                        }
                                        .foregroundStyle(Color.black)
                                        .padding(.horizontal, 10)
                                    }
                            }
                        }
                    }
                }
            }
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .onAppear {
            observeLobbies()
        }
    }
    
    private func joinLobby(_ lobby: Lobby) {
        guard lobby.players.count < lobby.settings.maxCountOfPlayers,
              let player = GameManager.shared.localPlayer else { return }
        removeLobbiesObserver()
        var lobby = lobby
        if !lobby.players.contains(player) {
            lobby.players.append(player)
            FirebaseManager.shared.sendLobbyData(lobby)
        }
        navigator.pushLobbyView(lobby: lobby)
    }

    private func observeLobbies() {
        FirebaseManager.shared.ref.child("lobbies").observe(.value) { snapshot in
            var lobbies: [Lobby] = []
            guard let oSnapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
            for oSnap in oSnapshot {
                guard let nodes = oSnap.children.allObjects as? [DataSnapshot] else { return }
                for node in nodes {
                    if let stringData = node.value as? String {
                        let data = Data(stringData.utf8)
                        do {
                            let lobby = try JSONDecoder().decode(Lobby.self, from: data)
                            if !lobby.players.isEmpty, lobby.players.count != lobby.settings.maxCountOfPlayers, !lobby.settings.isGamePrivate {
                                lobbies.append(lobby)
                            }
                        } catch {
                            print(error)
                        }
                    }
                }
            }
            lobbies.sort(by: { $0.creationDate > $1.creationDate })
            self.lobbies = lobbies
        }
    }
    
    private func removeLobbiesObserver() {
        FirebaseManager.shared.ref.child("lobbies").removeAllObservers()
    }
}
