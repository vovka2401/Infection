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

    func reset() {
        clusters = []
        for cell in cells {
            switch cell.type {
            case .player:
                cell.type = .default
            default: continue
            }
        }
    }
}

extension Map: Copyable {
    func copy() -> Map {
        let cellsCopy = cells.map({ $0.copy() })
        let mapCopy = Map(size: size, cells: cellsCopy, obstructions: obstructions)
        return mapCopy
    }
}

struct MapConfiguration {
    let size: CGSize
    var configuration: [[CellType]]

    init(size: CGSize) {
        self.size = size
        configuration = Array(repeating: Array(repeating: CellType.none, count: Int(size.width)), count: Int(size.height))
    }

    mutating func addCell(_ cell: Cell) {
        guard cell.coordinate.x < Int(size.width), cell.coordinate.y < Int(size.height) else { return }
        configuration[cell.coordinate.y][cell.coordinate.x] = cell.type
    }
}

extension Map {
    static var testMap1: Map {
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

    static var testMap2: Map {
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
}
