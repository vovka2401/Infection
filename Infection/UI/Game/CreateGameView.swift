import SwiftUI

struct CreateGameView: View {
    @State var settings = GameSettings()
    @State var selectedMap: Map
    @State var maps: [Map]
    @State private var selectedRoomState = RoomState.settings
    
    init(
        settings: GameSettings = GameSettings(),
        maps: [Map] = Map.rectangleMaps + Map.hexagonMaps,
        selectedRoomState: RoomState = RoomState.settings
    ) {
        self.settings = settings
        self.selectedMap = maps[0]
        self.maps = maps
        self.selectedRoomState = selectedRoomState
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("View State", selection: $selectedRoomState) {
                Text("Mode").tag(RoomState.mode)
                Text("Map").tag(RoomState.map)
                Text("Settings").tag(RoomState.settings)
            }
            .background(
                RoundedRectangle(cornerRadius: 7)
                    .fill(.orange)
            )
            .foregroundStyle(Color.white)
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .padding(.top, SafeAreaInsets.top + 20)
            .background(Color.blue)
            switch selectedRoomState {
            case .mode: modeView
            case .map: mapView
            case .settings: settingsView
            }
            createRoomButton
        }
        .ignoresSafeArea()
        .background(.yellow.opacity(0.8))
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
        MapPickerView(selectedMap: $selectedMap, maps: $maps)
    }
    
    var settingsView: some View {
        VStack(spacing: 20) {
            Stepper("Steps: \(settings.countOfStepsPerTurn)") {
                settings.countOfStepsPerTurn = min(settings.countOfStepsPerTurn + 1, 8)
            } onDecrement: {
                settings.countOfStepsPerTurn = max(settings.countOfStepsPerTurn - 1, 1)
            }
            .font(.title)
            .padding(.top, 10)
            Toggle("Fog of war", isOn: $settings.isFogOfWarEnabled)
                .font(.title)
            Spacer()
        }
        .padding(.horizontal, 10)
    }
    
    var createRoomButton: some View {
        NavigationLink {
            GameView(game: createGame())
        } label: {
            RoundedRectangle(cornerRadius: 20)
                .fill(.orange)
                .frame(width: 150, height: 60)
                .overlay {
                    Text("Create Room")
                        .bold()
                }
                .frame(width: Screen.width)
                .padding(.vertical, 20)
                .background(Color.blue)
        }
    }

    private func createGame() -> Game {
        let mapCopy = selectedMap.copy()
        return Game(
            map: mapCopy,
            players: [Player.testPlayer1, Player.testPlayer2],
            currentTurn: Turn(player: Player.testPlayer1),
            settings: settings
        )
    }
}

enum RoomState {
    case mode
    case map
    case settings
}
