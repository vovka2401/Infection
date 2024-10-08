import Firebase
import SwiftUI

struct LobbyView: View {
    @EnvironmentObject var menuViewModel: MenuViewModel
    @EnvironmentObject var navigator: Navigator
    @State var lobby: Lobby
    @State var selectedRoomState = RoomState.players
    @State var gameStarted = false
    @State var lobbyObserver: UInt?
    @State var gameObserver: UInt?
    var isHost: Bool { lobby.host == GameManager.shared.localPlayer }
    
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
                VStack(spacing: 0) {
                    NavigationBar {
                        quitLobby()
                    }
                    Picker("View State", selection: $selectedRoomState) {
                        Text(L10n.settings.text).tag(RoomState.settings)
                        Text(L10n.players.text).tag(RoomState.players)
                    }
                    .foregroundStyle(Color.white)
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: Screen.width - 40)
                    .padding(.bottom, 10)
                }
                .background(Color(red: 0.863, green: 0.918, blue: 0.992))
                switch selectedRoomState {
                case .settings: settingsView
                case .players: playersView
                default: EmptyView()
                }
                if isHost {
                    Rectangle()
                        .fill(Color(red: 0.863, green: 0.918, blue: 0.992))
                        .frame(width: Screen.width, height: 100)
                        .overlay {
                            startGameButton
                        }
                }
            }
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .onAppear {
            observeLobby()
        }
        .onDisappear {
            removeObservers()
        }
        .onChange(of: lobby.players) { players in
            if let localPlayer = GameManager.shared.localPlayer, !players.contains(localPlayer) {
                navigator.dismiss()
            }
        }
    }

    var settingsView: some View {
        VStack(spacing: 0) {
            VStack(spacing: 10) {
                HStack {
                    settingView(title: L10n.privateGame.text, value: $lobby.settings.isGamePrivate, isDisabled: !isHost) {
                        Image("lock")
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(x: 1.2, y: 1.2)
                    }
                    settingView(title: L10n.randomSteps.text, value: $lobby.settings.areRandomStepsEnabled, isDisabled: !isHost) {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.yellow)
                            .frame(size: CGSize(width: Screen.width / 14, height: Screen.width / 28))
                            .overlay {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(lineWidth: 2)
                                    .fill(Color.black)
                                    .frame(size: CGSize(width: Screen.width / 14, height: Screen.width / 28))
                            }
                            .scaleEffect(x: 1.2, y: 1.2)
                    }
                    if !lobby.settings.isLocalGame {
                        settingView(title: L10n.fogOfWar.text, value: $lobby.settings.isFogOfWarEnabled, isDisabled: lobby.settings.isLocalGame || !isHost) {
                            Image("cloud1")
                                .resizable()
                                .scaledToFit()
                                .scaleEffect(x: 1.3, y: 1.3)
                        }
                    }
                }
                sliderView(title: L10n.stepsPerTurn.text, range: 1 ... 8, value: $lobby.settings.countOfStepsPerTurn, isDisabled: lobby.settings.areRandomStepsEnabled || !isHost)
                    .animation(.easeInOut, value: lobby.settings.areRandomStepsEnabled)
                    .onChange(of: lobby.settings.countOfStepsPerTurn) { _ in
                        lobby.settings.areRandomStepsEnabled = false
                    }
                sliderView(title: L10n.countOfPlayers.text, range: 2 ... 6, value: $lobby.settings.maxCountOfPlayers, isDisabled: true)
            }
            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.top, 20)
    }

    var playersView: some View {
        VStack(spacing: 10) {
            ForEach(lobby.players, id: \.name) { player in
                playerView(player: player)
            }
            ForEach(lobby.players.count ..< lobby.settings.maxCountOfPlayers, id: \.self) { _ in
                playerView(player: nil)
            }
            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.top, 20)
    }

    var startGameButton: some View {
        let canStartGame = lobby.players.count == lobby.settings.maxCountOfPlayers
        return Button {
            startGame()
        } label: {
            RoundedRectangle(cornerRadius: 20)
                .fill(.orange)
                .frame(width: 150, height: 60)
                .overlay {
                    Text(L10n.startGame.text)
                        .bold()
                        .foregroundStyle(.white)
                }
                .overlay {
                    if !canStartGame {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.black.opacity(0.2))
                            .frame(width: 150, height: 60)
                    }
                }
                .shadow(color: .orange, radius: canStartGame ? 2 : 0)
        }
        .disabled(!canStartGame)
        .animation(.easeInOut, value: canStartGame)
    }

    var isReadyButton: some View {
        Button {
            toggleIsReadyState()
        } label: {
            RoundedRectangle(cornerRadius: 20)
                .fill(lobby.players.first(where: { $0 == GameManager.shared.localPlayer })?.isReady == true ? .green : .red)
                .frame(width: 60, height: 60)
                .overlay {
                    Text(L10n.ready.text)
                        .bold()
                        .foregroundStyle(.white)
                }
        }
    }

    @ViewBuilder
    func settingView(title: String, value: Binding<Bool>, isDisabled: Bool = false, image: () -> some View) -> some View {
        Button {
            value.wrappedValue.toggle()
            sendLobbyData()
        } label: {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.white.opacity(0.95))
                .frame(width: Screen.width / 5, height: Screen.width / 4)
                .overlay {
                    VStack {
                        image()
                            .frame(side: Screen.width / 15)
                        Spacer()
                        Text(title)
                            .font(.system(size: 15))
                            .foregroundStyle(Color.black)
                            .frame(height: 40)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 3)
                }
                .overlay {
                    if !value.wrappedValue {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.black.opacity(0.4))
                    }
                }
        }
        .disabled(isDisabled)
        .animation(.easeInOut, value: value.wrappedValue)
    }

    @ViewBuilder
    func playerView(player: Player?) -> some View {
        if let player {
            RoundedRectangle(cornerRadius: 7)
                .fill(.white)
                .frame(width: Screen.width - 30, height: 50)
                .overlay {
                    HStack {
                        Text(player.name)
                        Spacer()
                        if isHost, player != GameManager.shared.localPlayer {
                            Button {
                                kickPlayer(player)
                            } label: {
                                Text(L10n.kick.text)
                                    .foregroundStyle(Color.black)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 12)
                                    .background {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(white: 0.9))
                                    }
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                }
        } else {
            RoundedRectangle(cornerRadius: 7)
                .fill(Color(white: 0.85, opacity: 0.85))
                .frame(width: Screen.width - 30, height: 50)
        }
    }
    
    func sliderView(title: String, range: ClosedRange<Int>, value: Binding<Int>, isDisabled: Bool = false) -> some View {
        VStack {
            Text("\(title): \(value.wrappedValue)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.black)
            ScaleView(
                selectedStepsCount: value,
                range: range,
                color: Color.yellow,
                strokeColor: Color.black
            )
            .onChange(of: value.wrappedValue) { newValue in
                guard isHost else { return }
                sendLobbyData()
            }
        }
        .frame(width: Screen.width - 30)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.95))
                .frame(width: Screen.width - 20)
        }
        .disabled(isDisabled)
    }
    
    private func kickPlayer(_ player: Player) {
        lobby.players.removeAll(where: { $0 == player })
        sendLobbyData()
    }

    private func startGame(_ game: Game? = nil) {
        removeObservers()
        lobby.settings.maxCountOfPlayers = lobby.map.getCountOfPlayers()
        let game = game ?? Game(lobby: lobby)
        menuViewModel.gameViewModel = GameViewModel(game: game)
        menuViewModel.gameViewModel.setup(isHost: isHost)
        navigator.pushGameView()
    }

    private func toggleIsReadyState() {
        guard let indexOfLocalPlayer = lobby.players.firstIndex(where: { $0 == GameManager.shared.localPlayer }) else { return }
        var player = lobby.players[indexOfLocalPlayer]
        player.isReady = true
        lobby.players[indexOfLocalPlayer] = player
        print(player.isReady)
        sendLobbyData()
    }
    
    private func quitLobby() {
        lobby.players.removeAll(where: { $0 == GameManager.shared.localPlayer })
        removeObservers()
        sendLobbyData()
    }
    
    private func sendLobbyData() {
        FirebaseManager.shared.sendLobbyData(lobby)
    }

    private func observeLobby() {
        lobbyObserver = FirebaseManager.shared.ref.child("lobbies").child(lobby.id).child("lobby").observe(.value) { snapshot in
            if let stringData = snapshot.value as? String {
                let data = Data(stringData.utf8)
                do {
                    lobby = try JSONDecoder().decode(Lobby.self, from: data)
                } catch {
                    print(error)
                }
            }
        }
        gameObserver = FirebaseManager.shared.ref.child("lobbies").child(lobby.id).child("game").observe(.value) { snapshot in
            if !gameStarted, let stringData = snapshot.value as? String {
                let data = Data(stringData.utf8)
                do {
                    let game = try JSONDecoder().decode(Game.self, from: data)
                    startGame(game)
                } catch {
                    print(error)
                }
            }
        }
    }
    
    private func removeObservers() {
        if let lobbyObserver {
            FirebaseManager.shared.ref.child("lobbies").child(lobby.id).child("lobby").removeObserver(withHandle: lobbyObserver)
        }
        if let gameObserver {
            FirebaseManager.shared.ref.child("lobbies").child(lobby.id).child("game").removeObserver(withHandle: gameObserver)
        }
    }
}
