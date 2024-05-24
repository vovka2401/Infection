import SwiftUI

struct ContentView: View {
    @StateObject var game: Game

    init() {
        let players = [
            Player(name: "Player 1", color: .yellow),
            Player(name: "Player 2", color: .blue),
        ]
        let cells = [
            Cell(coordinate: CellCoordinate(x: 0, y: 0), type: .player(players[0], .temporary)),
            Cell(coordinate: CellCoordinate(x: 0, y: 1)),
            Cell(coordinate: CellCoordinate(x: 0, y: 2)),
            Cell(coordinate: CellCoordinate(x: 0, y: 3)),
            Cell(coordinate: CellCoordinate(x: 0, y: 4)),
            Cell(coordinate: CellCoordinate(x: 0, y: 5)),
            Cell(coordinate: CellCoordinate(x: 0, y: 6)),
            Cell(coordinate: CellCoordinate(x: 0, y: 7)),
            Cell(coordinate: CellCoordinate(x: 1, y: 0)),
            Cell(coordinate: CellCoordinate(x: 1, y: 1)),
            Cell(coordinate: CellCoordinate(x: 1, y: 2)),
            Cell(coordinate: CellCoordinate(x: 1, y: 3)),
            Cell(coordinate: CellCoordinate(x: 1, y: 4)),
            Cell(coordinate: CellCoordinate(x: 1, y: 5)),
            Cell(coordinate: CellCoordinate(x: 1, y: 6)),
            Cell(coordinate: CellCoordinate(x: 1, y: 7)),
            Cell(coordinate: CellCoordinate(x: 2, y: 0), type: .portal(2)),
            Cell(coordinate: CellCoordinate(x: 2, y: 1)),
            Cell(coordinate: CellCoordinate(x: 2, y: 2)),
            Cell(coordinate: CellCoordinate(x: 2, y: 3)),
            Cell(coordinate: CellCoordinate(x: 2, y: 4)),
            Cell(coordinate: CellCoordinate(x: 2, y: 5)),
            Cell(coordinate: CellCoordinate(x: 2, y: 6)),
            Cell(coordinate: CellCoordinate(x: 2, y: 7)),
            Cell(coordinate: CellCoordinate(x: 3, y: 2)),
            Cell(coordinate: CellCoordinate(x: 3, y: 3)),
            Cell(coordinate: CellCoordinate(x: 3, y: 4)),
            Cell(coordinate: CellCoordinate(x: 3, y: 5)),
            Cell(coordinate: CellCoordinate(x: 3, y: 6)),
            Cell(coordinate: CellCoordinate(x: 3, y: 7)),
            Cell(coordinate: CellCoordinate(x: 3, y: 8)),
            Cell(coordinate: CellCoordinate(x: 3, y: 9)),
            Cell(coordinate: CellCoordinate(x: 4, y: 2)),
            Cell(coordinate: CellCoordinate(x: 4, y: 3)),
            Cell(coordinate: CellCoordinate(x: 4, y: 4)),
            Cell(coordinate: CellCoordinate(x: 4, y: 5), type: .portal(1)),
            Cell(coordinate: CellCoordinate(x: 4, y: 6)),
            Cell(coordinate: CellCoordinate(x: 4, y: 7)),
            Cell(coordinate: CellCoordinate(x: 4, y: 8)),
            Cell(coordinate: CellCoordinate(x: 4, y: 9)),
            Cell(coordinate: CellCoordinate(x: 5, y: 2)),
            Cell(coordinate: CellCoordinate(x: 5, y: 3)),
            Cell(coordinate: CellCoordinate(x: 5, y: 4)),
            Cell(coordinate: CellCoordinate(x: 5, y: 5)),
            Cell(coordinate: CellCoordinate(x: 5, y: 6)),
            Cell(coordinate: CellCoordinate(x: 5, y: 7)),
            Cell(coordinate: CellCoordinate(x: 5, y: 8)),
            Cell(coordinate: CellCoordinate(x: 5, y: 9)),
            Cell(coordinate: CellCoordinate(x: 6, y: 2)),
            Cell(coordinate: CellCoordinate(x: 6, y: 3)),
            Cell(coordinate: CellCoordinate(x: 6, y: 4)),
            Cell(coordinate: CellCoordinate(x: 6, y: 5)),
            Cell(coordinate: CellCoordinate(x: 6, y: 6)),
            Cell(coordinate: CellCoordinate(x: 6, y: 7)),
            Cell(coordinate: CellCoordinate(x: 6, y: 8)),
            Cell(coordinate: CellCoordinate(x: 6, y: 9)),
            Cell(coordinate: CellCoordinate(x: 7, y: 2)),
            Cell(coordinate: CellCoordinate(x: 7, y: 3), type: .portal(1)),
            Cell(coordinate: CellCoordinate(x: 7, y: 4), type: .portal(2)),
            Cell(coordinate: CellCoordinate(x: 7, y: 5)),
            Cell(coordinate: CellCoordinate(x: 7, y: 6)),
            Cell(coordinate: CellCoordinate(x: 7, y: 7)),
            Cell(coordinate: CellCoordinate(x: 7, y: 8)),
            Cell(coordinate: CellCoordinate(x: 7, y: 9), type: .player(players[1], .temporary)),
        ]
        let map = Map(
            size: CGSize(width: 10, height: 10),
            cells: cells,
            obstructions: [
                Obstruction(
                    firstCoordinate: CellCoordinate(x: 2, y: 2), secondCoordinate: CellCoordinate(x: 2, y: 3)
                ),
                Obstruction(
                    firstCoordinate: CellCoordinate(x: 2, y: 0), secondCoordinate: CellCoordinate(x: 2, y: 1)
                ),
            ]
        )
        let game = Game(map: map, players: players, currentTurn: Turn(player: players[0]))
        _game = StateObject(wrappedValue: game)
    }

    var body: some View {
        GameView(game: game)
    }
}

#Preview {
    ContentView()
}
