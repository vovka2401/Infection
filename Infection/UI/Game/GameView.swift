import SwiftUI

struct GameView: View {
    @ObservedObject var gameViewModel: GameViewModel

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Text(gameViewModel.game.currentTurn.player.name)
                    .font(.title)
                    .bold()
                    .animation(.easeInOut, value: gameViewModel.game.currentTurn.step)
                stepsScale
                Spacer()
                map
                Spacer()
            }
            .disabled(gameViewModel.game.isOver)
            .overlay {
                if gameViewModel.game.isOver {
                    gameOverView
                }
            }
            VStack {
                NavigationBar(dismiss: gameViewModel.dismiss)
                Spacer()
            }
        }
        .animation(.easeInOut(duration: 1), value: gameViewModel.game.isOver)
        .ignoresSafeArea()
        .background(gameViewModel.game.currentTurn.player.color)
        .animation(.easeInOut, value: gameViewModel.game.currentTurn.player.color)
        .navigationBarBackButtonHidden()
    }

    var stepsScale: some View {
        ScaleView(
            selectedStepsCount: $gameViewModel.game.currentTurn.step,
            range: 1 ... gameViewModel.game.settings.countOfStepsPerTurn,
            color: Color.clear,
            strokeColor: Color.white,
            isDisabled: true
        )
    }

    var map: some View {
        MapScrollView {
            MapView(gameViewModel: gameViewModel, action: gameViewModel.infectCell)
        }
        .frame(height: gameViewModel.game.map.size.height * 50)
    }

    var gameOverView: some View {
        Color.white.opacity(0.9)
            .overlay {
                VStack {
                    Text(gameViewModel.game.winner != nil ? "\(L10n.winner.text): \(gameViewModel.game.winner!.name)" : L10n.draw.text)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.orange)
                        .shadow(color: .orange.opacity(0.1), radius: 1)
                        .padding(.bottom, 30)
                    Button(action: gameViewModel.restart) {
                        Text(L10n.restart.text)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.orange)
                            .shadow(color: .orange.opacity(0.1), radius: 1)
                    }
                }
            }
    }
}
