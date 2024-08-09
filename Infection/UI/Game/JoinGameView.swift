import SwiftUI

struct JoinGameView: View {
    @EnvironmentObject var menuViewModel: MenuViewModel
    @EnvironmentObject var navigator: Navigator
    @State var selectedMap: Map
    @State var settings = GameSettings()
    let maps = Map.rectangleMaps + Map.hexagonMaps

    init() {
        _selectedMap = State(initialValue: maps[0])
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
                NavigationBar {
                    navigator.dismiss()
                }
                .background(Color(red: 0.863, green: 0.918, blue: 0.992))
                mapView
                joinGameButton
            }
        }
        .ignoresSafeArea()
        .background(.yellow.opacity(0.8))
        .navigationBarBackButtonHidden()
    }

    var mapView: some View {
        MapPickerView(selectedMap: $selectedMap, maps: maps, selectedWinMode: settings.gameWinMode)
    }

    var joinGameButton: some View {
        Button(action: joinGame) {
            RoundedRectangle(cornerRadius: 20)
                .fill(.orange)
                .frame(width: 150, height: 60)
                .overlay {
                    Text(L10n.joinGame.text)
                        .bold()
                        .foregroundStyle(.white)
                }
                .shadow(color: .orange, radius: 2)
        }
        .frame(width: Screen.width)
        .padding(.vertical, 20)
        .background(Color(red: 0.863, green: 0.918, blue: 0.992))
    }

    private func joinGame() {
        settings.maxCountOfPlayers = selectedMap.getCountOfPlayers()
        settings.isLocalGame = false
        let game = Game(map: selectedMap, settings: settings)
        menuViewModel.gameCenterManager.isGameCreator = false
        menuViewModel.gameCenterManager.gameViewModel = GameViewModel(game: game)
        menuViewModel.gameCenterManager.presentMatchmaker()
    }
}
