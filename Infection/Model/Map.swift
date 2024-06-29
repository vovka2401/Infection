import SwiftUI

class Map: ObservableObject, Identifiable {
    let id = UUID()
    let size: CGSize
    @Published var cells: [Cell]
    @Published var clusters: [Cluster] = []
    let obstructions: [Obstruction]

    init(size: CGSize, cells: [Cell], obstructions: [Obstruction]) {
        self.size = size
        self.cells = cells
        self.obstructions = obstructions
    }
    
//    init(configuration: MapConfiguration) {
//        size = configuration.size
//        cells.
//    }
}

extension Map: Copyable {
    func copy() -> Map {
        let cellsCopy = cells.map({ $0.copy() })
        let mapCopy = Map(size: size, cells: cellsCopy, obstructions: obstructions)
        return mapCopy
    }
}

//struct MapConfiguration {
//    let size: CGSize
//    var configuration: [[CellType]]
//
//    init(size: CGSize) {
//        self.size = size
//        configuration = Array(repeating: Array(repeating: CellType.none, count: Int(size.width)), count: Int(size.height))
//    }
//
//    mutating func addCell(_ cell: Cell) {
//        guard cell.coordinate.x < size.width, cell.coordinate.y < size.height else { return }
//        configuration[cell.coordinate.y][cell.coordinate.x] = cell.type
//    }
//}

extension Map {
    static var testMapRectangle1: Map {
        let cells = [
            Cell(coordinate: CellCoordinate(x: 0, y: 0), type: .player(Player.testPlayer1, .temporary)),
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
            Cell(coordinate: CellCoordinate(x: 7, y: 9), type: .player(Player.testPlayer2, .temporary)),
        ]
        let map = Map(
            size: CGSize(width: 10, height: 10),
            cells: cells,
            obstructions: [
                Obstruction(coordinates: (CellCoordinate(x: 2, y: 2), CellCoordinate(x: 2, y: 3))),
                Obstruction(coordinates: (CellCoordinate(x: 2, y: 0), CellCoordinate(x: 2, y: 1))),
            ]
        )
        return map
    }

    static var testMapRectangle2: Map {
        let cells = [
            Cell(coordinate: CellCoordinate(x: 0, y: 0), type: .player(Player.testPlayer1, .temporary)),
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
            Cell(coordinate: CellCoordinate(x: 4, y: 0), type: .portal(2)),
            Cell(coordinate: CellCoordinate(x: 2, y: 1)),
            Cell(coordinate: CellCoordinate(x: 2, y: 2)),
            Cell(coordinate: CellCoordinate(x: 2, y: 3)),
            Cell(coordinate: CellCoordinate(x: 2, y: 4)),
            Cell(coordinate: CellCoordinate(x: 2, y: 5)),
            Cell(coordinate: CellCoordinate(x: 2, y: 6)),
            Cell(coordinate: CellCoordinate(x: 2, y: 7)),
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
            Cell(coordinate: CellCoordinate(x: 7, y: 9), type: .player(Player.testPlayer2, .temporary)),
        ]
        let map = Map(
            size: CGSize(width: 10, height: 10),
            cells: cells,
            obstructions: [
                Obstruction(coordinates: (CellCoordinate(x: 2, y: 2), CellCoordinate(x: 2, y: 3))),
                Obstruction(coordinates: (CellCoordinate(x: 2, y: 0), CellCoordinate(x: 2, y: 1))),
            ]
        )
        return map
    }
    
    static var testMapHexagon1: Map {
        let cells = [
            Cell(coordinate: CellCoordinate(x: 0, y: 0), form: .hexagon, type: .player(Player.testPlayer1, .temporary)),
            Cell(coordinate: CellCoordinate(x: 0.75, y: 0.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 0.75, y: 1.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 0.75, y: 2.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 0.75, y: 3.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 0.75, y: 4.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 0.75, y: 5.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 0.75, y: 6.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 0.75, y: 7.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 1.5, y: 1 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 1.5, y: 2 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 1.5, y: 3 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 1.5, y: 4 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 1.5, y: 5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 1.5, y: 6 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 1.5, y: 7 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 1.5, y: 8 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 2.25, y: 0.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 2.25, y: 1.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 2.25, y: 2.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 2.25, y: 3.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 2.25, y: 4.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 2.25, y: 5.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 2.25, y: 6.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 2.25, y: 7.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 3, y: 1 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 3, y: 2 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 3, y: 3 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 3, y: 4 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 3, y: 5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 3, y: 6 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 3, y: 7 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 3, y: 8 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 3.75, y: 0.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 3.75, y: 1.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 3.75, y: 2.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 3.75, y: 3.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 3.75, y: 4.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 3.75, y: 5.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 3.75, y: 6.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 3.75, y: 7.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 4.5, y: 1 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 4.5, y: 2 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 4.5, y: 3 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 4.5, y: 4 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 4.5, y: 5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 4.5, y: 6 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 4.5, y: 7 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 4.5, y: 8 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 5.25, y: 0.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 5.25, y: 1.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 5.25, y: 2.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 5.25, y: 3.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 5.25, y: 4.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 5.25, y: 5.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 5.25, y: 6.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 5.25, y: 7.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 6, y: 1 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 6, y: 2 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 6, y: 3 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 6, y: 4 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 6, y: 5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 6, y: 6 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 6, y: 7 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 6, y: 8 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 6.75, y: 0.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 6.75, y: 1.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 6.75, y: 2.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 6.75, y: 3.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 6.75, y: 4.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 6.75, y: 5.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 6.75, y: 6.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 6.75, y: 7.5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 7.5, y: 1 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 7.5, y: 2 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 7.5, y: 3 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 7.5, y: 4 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 7.5, y: 5 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 7.5, y: 6 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 7.5, y: 7 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 7.5, y: 8 * cos(.pi / 6)), form: .hexagon),
            Cell(coordinate: CellCoordinate(x: 7.5, y: 9 * cos(.pi / 6)), form: .hexagon, type: .player(Player.testPlayer2, .temporary)),
        ]
        let map = Map(
            size: CGSize(width: 10, height: 10),
            cells: cells,
            obstructions: [
                Obstruction(
                    coordinates: (
                        CellCoordinate(x: 0.75, y: 0.5 * cos(.pi / 6)) + .hexagonAdditionToFirstCoordinate,
                        CellCoordinate(x: 1.5, y: 1 * cos(.pi / 6)) + .hexagonAdditionToSecondCoordinate
                    )
                ),
                Obstruction(
                    coordinates: (
                        CellCoordinate(x: 6, y: 1 * cos(.pi / 6)) + .hexagonAdditionToFirstCoordinate,
                        CellCoordinate(x: 6.75, y: 1.5 * cos(.pi / 6)) + .hexagonAdditionToSecondCoordinate
                    )
                )
            ]
        )
        return map
    }
    
    static var rectangleMaps = [Map.testMapRectangle1, Map.testMapRectangle2]
    
    static var hexagonMaps = [Map.testMapHexagon1]
}
