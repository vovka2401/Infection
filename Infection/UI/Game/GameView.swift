import SwiftUI

struct GameView: View {
    @ObservedObject var game: Game

    var body: some View {
        VStack {
            Spacer()
            Text("Step \(game.currentTurn.step) of \(game.currentTurn.player.name)")
                .font(.title)
                .bold()
                .animation(.easeInOut, value: game.currentTurn.step)
            Spacer()
            map
            Spacer()
        }
        .animation(.easeInOut(duration: 2), value: game.isOver)
        .disabled(game.isOver)
        .overlay {
            if game.isOver {
                gameOverView
            }
        }
        .ignoresSafeArea()
        .background(game.currentTurn.player.color)
        .animation(.easeInOut, value: game.currentTurn.player.color)
    }

    var map: some View {
        MapScrollView {
            MapView(game: game, action: game.infectCell)
        }
        .frame(height: game.map.size.height * 50)
    }

    var gameOverView: some View {
        Color.white.opacity(0.5)
            .overlay {
                VStack {
                    Text("GAME OVER")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.green)
                    Button {
                        game.restart()
                    } label: {
                        Text("RESTART")
                    }
                }
            }
    }
}
