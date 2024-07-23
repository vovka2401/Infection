import SwiftUI

struct CreateGameView: View {
    @EnvironmentObject var menuViewModel: MenuViewModel
    @EnvironmentObject var navigator: Navigator
    @State var settings: GameSettings
    @State var selectedMap: Map
    @State var selectedRoomState = RoomState.settings
    let maps = Map.rectangleMaps + Map.hexagonMaps

    init(isLocalGame: Bool = false) {
        _selectedMap = State(initialValue: maps[0])
        _settings = State(initialValue: GameSettings(isLocalGame: isLocalGame))
    }

    var body: some View {
        ZStack {
            Color.orange
                .frame(size: Screen.size)
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.white.opacity(0.7))
                    .frame(width: Screen.width, height: SafeAreaInsets.top + 70)
                    .overlay {
                        HStack {
                            Button {
                                navigator.dismiss()
                            } label: {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(.white)
                                    .frame(width: 30, height: 30)
                                    .overlay {
                                        Image(systemName: "chevron.backward")
                                            .resizable()
                                            .scaledToFit()
                                            .scaleEffect(x: 0.6, y: 0.6)
                                    }
                            }
                            .padding(.leading, 20)
                            Spacer()
                        }
                        .padding(.top, SafeAreaInsets.hasTop ? 0 : 15)
                        .padding(.bottom, 10)
                        VStack(spacing: 0) {
                            Picker("View State", selection: $selectedRoomState) {
                                Text("Mode").tag(RoomState.mode)
                                Text("Map").tag(RoomState.map)
                                Text("Settings").tag(RoomState.settings)
                            }
                            .foregroundStyle(Color.white)
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(width: Screen.width - 40)
                            .padding(.top, SafeAreaInsets.top + 20)
                        }
                    }
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
    }

    var modeView: some View {
//        ScrollView(.vertical, showsIndicators: false) {
        VStack(spacing: 20) {
            Spacer()
//                ForEach(CellForm.allCases, id: \.rawValue) { form in
//                    Button {
//                        selectedCellForm = form
//                        switch form {
//                        case .triangle: break
//                        case .rectangle:
//                            maps = Map.rectangleMaps
//                        case .hexagon:
//                            maps = Map.hexagonMaps
//                        }
//                        selectedMap = maps[0]
//                    } label: {
//                        CellShape(form: form)
//                            .fill(Color.yellow)
//                            .frame(width: Screen.width * 0.6, height: Screen.width * 0.6)
//                    }
//                }
        }
//            .padding(.vertical, 20)
//        }
//        .frame(width: Screen.width)
    }

    var mapView: some View {
        MapPickerView(selectedMap: $selectedMap, maps: maps)
    }

    var settingsView: some View {
        VStack(spacing: 0) {
            VStack {
                if !settings.isLocalGame {
                    HStack {
                        settingView(title: "Private game", value: $settings.isGamePrivate)
                        settingView(title: "Fog of war", value: $settings.isFogOfWarEnabled)
                    }
                    .padding(.top, 10)
                }
                VStack {
                    Text("Steps per turn: \(settings.countOfStepsPerTurn)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.black)
                        .frame(width: Screen.width, alignment: .leading)
                        .padding(.leading, 20)
                    Slider(
                        value: Binding<Double>(
                            get: { Double(settings.countOfStepsPerTurn) },
                            set: { settings.countOfStepsPerTurn = Int($0) }
                        ),
                        in: 1 ... 8,
                        step: 1
                    )
                }
                .frame(width: Screen.width - 30)
                .padding(.vertical, 10)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.7))
                        .frame(width: Screen.width - 10)
                }
                .padding(.top, 10)
            }
            Spacer()
        }
        .padding(.horizontal, 10)
    }

    var createGameButton: some View {
        Button {
            startGame()
        } label: {
            RoundedRectangle(cornerRadius: 20)
                .fill(.orange)
                .frame(width: 150, height: 60)
                .overlay {
                    Text("Create Game")
                        .bold()
                        .foregroundStyle(.white)
                }
                .frame(width: Screen.width)
                .padding(.vertical, 20)
                .background(Color.white.opacity(0.7))
        }
    }

    func settingView(title: String, value: Binding<Bool>) -> some View {
        Button {
            value.wrappedValue.toggle()
        } label: {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.white.opacity(0.7))
                .frame(width: Screen.width / 5, height: Screen.width / 5)
                .overlay {
                    Text(title)
                        .foregroundStyle(Color.black)
                }
                .overlay {
                    if !value.wrappedValue {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.black.opacity(0.4))
                    }
                }
        }
    }

    private func startGame() {
        let game = Game(map: selectedMap)
        settings.maxCountOfPlayers = selectedMap.getCountOfPlayers()
        menuViewModel.gameCenterManager.isGameCreator = true
        menuViewModel.gameCenterManager.gameViewModel = GameViewModel(game: game, settings: settings)
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
