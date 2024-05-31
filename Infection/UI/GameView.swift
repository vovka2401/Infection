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
        MapView {
            Rectangle()
                .fill(Color(red: 0.1, green: 0.1, blue: 0.2))
                .frame(width: game.map.size.width * 50, height: game.map.size.height * 50)
                .overlay {
                    ForEach(game.map.cells, id: \.coordinate) { cell in
                        CellView(cell: cell)
                            .overlay {
                                if game.availableCells.contains(cell) {
                                    Color.white.opacity(0.3)
                                }
                            }
                            .position(
                                x: 25 + CGFloat(cell.coordinate.x * 50), y: 25 + CGFloat(cell.coordinate.y * 50)
                            )
                            .onTapGesture {
                                game.infectCell(cell)
                            }
                    }
                }
                .overlay {
                    ForEach(game.map.obstructions, id: \.id) { obstruction in
                        ObstructionView(obstruction: obstruction)
                            .position(
                                x: CGFloat((obstruction.coordinates.0.x + obstruction.coordinates.1.x) * 25),
                                y: CGFloat((obstruction.coordinates.0.y + obstruction.coordinates.1.y) * 25)
                            )
                    }
                }
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
