import SwiftUI

struct JoinGameView: View {
    @EnvironmentObject var menuViewModel: MenuViewModel
    @State var selectedMap: Map
    @State var settings = GameSettings()
    let maps = Map.rectangleMaps + Map.hexagonMaps

    init() {
        _selectedMap = State(initialValue: maps[0])
    }

    var body: some View {
        VStack(spacing: 0) {
            mapView
            joinGameButton
        }
        .ignoresSafeArea()
        .background(.yellow.opacity(0.8))
    }

    var mapView: some View {
        MapPickerView(selectedMap: $selectedMap, maps: maps)
    }

    var joinGameButton: some View {
        Button {
            joinGame()
        } label: {
            RoundedRectangle(cornerRadius: 20)
                .fill(.orange)
                .frame(width: 150, height: 60)
                .overlay {
                    Text("Join Game")
                        .bold()
                        .foregroundStyle(.white)
                }
                .frame(width: Screen.width)
                .padding(.vertical, 20)
                .background(Color.blue)
        }
    }

    private func joinGame() {
        let game = Game(map: selectedMap)
        settings.maxCountOfPlayers = selectedMap.getCountOfPlayers()
        settings.isLocalGame = false
        menuViewModel.gameCenterManager.isGameCreator = false
        menuViewModel.gameCenterManager.gameViewModel = GameViewModel(game: game, settings: settings)
        menuViewModel.gameCenterManager.presentMatchmaker()
    }
}
