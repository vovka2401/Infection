import SwiftUI

struct CreateGameView: View {
    @EnvironmentObject var menuViewModel: MenuViewModel
    @EnvironmentObject var navigator: Navigator
    @State var settings: GameSettings
    @State var selectedMap: Map
    @State var selectedRoomState = RoomState.mode
    let maps = Map.rectangleMaps + Map.hexagonMaps

    init(isLocalGame: Bool = false) {
        _selectedMap = State(initialValue: maps[0])
        _settings = State(initialValue: GameSettings(isLocalGame: isLocalGame))
    }

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
                        navigator.dismiss()
                    }
                    Picker("View State", selection: $selectedRoomState) {
                        Text(L10n.mode.text).tag(RoomState.mode)
                        Text(L10n.settings.text).tag(RoomState.settings)
                        Text(L10n.map.text).tag(RoomState.map)
                    }
                    .foregroundStyle(Color.white)
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: Screen.width - 40)
                    .padding(.bottom, 10)
                }
                .background(Color(red: 0.863, green: 0.918, blue: 0.992))
                switch selectedRoomState {
                case .mode: modeView
                case .map: mapView
                case .settings: settingsView
                }
                createGameButton
            }
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .onChange(of: settings.maxCountOfPlayers) { newValue in
            let maps = maps.filter({ $0.getCountOfPlayers() == newValue })
            if let firstMap = maps.first {
                selectedMap = firstMap
            }
        }
    }

    var modeView: some View {
        VStack(spacing: 0) {
            ForEach(GameWinMode.allCases, id: \.rawValue) { mode in
                Button {
                    withAnimation(.easeInOut) {
                        settings.gameWinMode = mode
                    }
                } label: {
                    VStack {
                        HStack {
                            Text(mode.title)
                                .font(.title)
                                .bold()
                                .foregroundStyle(Color.black)
                                .shadow(color: Color.gray.opacity(0.1), radius: 1, x: 1, y: 2)
                            Spacer()
                        }
                        .padding(.bottom, 10)
                        HStack {
                            Text(mode.description)
                                .font(.title2)
                                .foregroundStyle(Color.black)
                                .multilineTextAlignment(.leading)
                                .shadow(color: Color.gray.opacity(0.3), radius: 1, x: 1, y: 2)
                            Spacer()
                        }
                    }
                    .frame(width: Screen.width - 60)
                    .padding(20)
                    .background {
                        Color.white.opacity(0.95)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(settings.gameWinMode == mode ? Color.orange : Color.white, lineWidth: 6)
                    }
                }
                .padding(.top, 20)
            }
            Spacer()
        }
    }

    var mapView: some View {
        MapPickerView(
            selectedMap: $selectedMap,
            maps: maps.filter({ $0.getCountOfPlayers() == settings.maxCountOfPlayers }),
            selectedWinMode: settings.gameWinMode
        )
    }

    var settingsView: some View {
        VStack(spacing: 0) {
            VStack(spacing: 10) {
                HStack {
                    if !settings.isLocalGame {
                        settingView(title: L10n.privateGame.text, value: $settings.isGamePrivate, isDisabled: settings.isLocalGame) {
                            Image("lock")
                                .resizable()
                                .scaledToFit()
                                .scaleEffect(x: 1.2, y: 1.2)
                        }
                        settingView(title: L10n.fogOfWar.text, value: $settings.isFogOfWarEnabled, isDisabled: settings.isLocalGame) {
                            Image("cloud1")
                                .resizable()
                                .scaledToFit()
                                .scaleEffect(x: 1.3, y: 1.3)
                        }
                    }
                    settingView(title: L10n.randomSteps.text, value: $settings.areRandomStepsEnabled) {
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
                }
                sliderView(title: L10n.stepsPerTurn.text, range: 1 ... 8, value: $settings.countOfStepsPerTurn, disabled: settings.areRandomStepsEnabled)
                    .animation(.easeInOut, value: settings.areRandomStepsEnabled)
                    .onChange(of: settings.countOfStepsPerTurn) { _ in
                        settings.areRandomStepsEnabled = false
                    }
                sliderView(title: L10n.countOfPlayers.text, range: 2 ... 6, value: $settings.maxCountOfPlayers)
            }
            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.top, 20)
    }

    var createGameButton: some View {
        Button(action: startGame) {
            RoundedRectangle(cornerRadius: 20)
                .fill(.orange)
                .frame(width: 150, height: 60)
                .overlay {
                    Text(L10n.createGame.text)
                        .bold()
                        .foregroundStyle(.white)
                }
                .shadow(color: .orange, radius: 2)
        }
        .frame(width: Screen.width)
        .padding(.vertical, 20)
        .background(Color(red: 0.863, green: 0.918, blue: 0.992))
    }

    @ViewBuilder
    func settingView(title: String, value: Binding<Bool>, isDisabled: Bool = false, image: () -> some View) -> some View {
        Button {
            value.wrappedValue.toggle()
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
    
    func sliderView(title: String, range: ClosedRange<Int>, value: Binding<Int>, disabled: Bool = false) -> some View {
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
        }
        .frame(width: Screen.width - 30)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.95))
                .frame(width: Screen.width - 20)
        }
        .overlay {
            if disabled {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.4))
                    .frame(width: Screen.width - 20)
            }
        }
    }

    private func startGame() {
        settings.maxCountOfPlayers = selectedMap.getCountOfPlayers()
        let game = Game(map: selectedMap, settings: settings)
        menuViewModel.gameCenterManager.isGameCreator = true
        menuViewModel.gameCenterManager.gameViewModel = GameViewModel(game: game)
        if settings.isLocalGame {
            menuViewModel.gameCenterManager.gameViewModel.setup()
            Navigator.shared.pushGameView()
        } else {
            menuViewModel.gameCenterManager.presentMatchmaker()
        }
    }
}

enum RoomState {
    case mode
    case map
    case settings
}
