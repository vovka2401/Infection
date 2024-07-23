import SwiftUI

struct GameView: View {
    @ObservedObject var gameViewModel: GameViewModel

    var body: some View {
        VStack {
            HStack {
                Button {
                    gameViewModel.dismiss()
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
            .padding(.top, SafeAreaInsets.top + 15)
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
        .animation(.easeInOut(duration: 2), value: gameViewModel.game.isOver)
        .disabled(gameViewModel.game.isOver)
        .overlay {
            if gameViewModel.game.isOver {
                gameOverView
            }
        }
        .ignoresSafeArea()
        .background(gameViewModel.game.currentTurn.player.color)
        .animation(.easeInOut, value: gameViewModel.game.currentTurn.player.color)
        .onAppear {
            gameViewModel.updateCells()
        }
        .navigationBarBackButtonHidden()
    }

    var stepsScale: some View {
        HStack(spacing: 5) {
            ForEach(0 ..< gameViewModel.settings.countOfStepsPerTurn) { step in
                Rectangle()
                    .fill(step < gameViewModel.game.currentTurn.step ? Color.clear : Color.black.opacity(0.5))
                    .border(Color.white, width: 4)
                    .frame(width: Screen.width / 10, height: Screen.width / 20)
            }
        }
        .animation(.easeInOut, value: gameViewModel.game.currentTurn.step)
    }

    var map: some View {
        MapScrollView {
            MapView(gameViewModel: gameViewModel, action: gameViewModel.infectCell)
        }
        .frame(height: gameViewModel.game.map.size.height * 50)
    }

    var gameOverView: some View {
        Color.white.opacity(0.7)
            .overlay {
                VStack {
                    Text("GAME OVER")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.blue)
                        .padding(.bottom, 30)
                    Button {
                        gameViewModel.restart()
                    } label: {
                        Text("RESTART")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                }
            }
    }
}
