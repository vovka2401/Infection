import SwiftUI

extension Map {
    static var testMapRectangle1: Map {
        let mapSize = CGSize(width: 10, height: 10)
        var cells = Map.getCells(in: mapSize, form: .rectangle)
        cells[CellCoordinate(x: 0, y: 0)]?.type = .player(Player.testPlayer1, .base)
        cells[CellCoordinate(x: 2, y: 0)]?.type = .portal(2)
        cells[CellCoordinate(x: 2, y: 7)]?.type = .portal(1)
        cells[CellCoordinate(x: 7, y: 2)]?.type = .portal(2)
        cells[CellCoordinate(x: 7, y: 9)]?.type = .portal(1)
        cells[CellCoordinate(x: 9, y: 9)]?.type = .player(Player.testPlayer2, .base)
        let map = Map(
            size: mapSize,
            cells: cells,
            obstructions: [
                Obstruction(coordinates: (CellCoordinate(x: 2, y: 2), CellCoordinate(x: 2, y: 3))),
                Obstruction(coordinates: (CellCoordinate(x: 2, y: 0), CellCoordinate(x: 2, y: 1))),
                Obstruction(coordinates: (CellCoordinate(x: 8, y: 8), CellCoordinate(x: 8, y: 7))),
                Obstruction(coordinates: (CellCoordinate(x: 8, y: 10), CellCoordinate(x: 8, y: 9))),
                Obstruction(coordinates: (CellCoordinate(x: 5, y: 4), CellCoordinate(x: 5, y: 5))),
                Obstruction(coordinates: (CellCoordinate(x: 5, y: 5), CellCoordinate(x: 5, y: 6))),
            ]
        )
        return map
    }

    static var testMapRectangle2: Map {
        let mapSize = CGSize(width: 10, height: 10)
        var cells = Map.getCells(in: mapSize, form: .rectangle)
        cells[CellCoordinate(x: 0, y: 0)]?.type = .player(Player.testPlayer1, .base)
        cells[CellCoordinate(x: 0, y: 9)]?.type = .player(Player.testPlayer2, .base)
        cells[CellCoordinate(x: 9, y: 0)]?.type = .player(Player.testPlayer3, .base)
        cells[CellCoordinate(x: 9, y: 9)]?.type = .player(Player.testPlayer4, .base)
        let map = Map(
            size: mapSize,
            cells: cells,
            obstructions: []
        )
        return map
    }

    static var testMapRectangle3: Map {
        let mapSize = CGSize(width: 10, height: 10)
        var cells = Map.getCells(in: mapSize, form: .rectangle)
        cells[CellCoordinate(x: 0, y: 0)]?.type = .player(Player.testPlayer1, .base)
        cells[CellCoordinate(x: 2, y: 9)]?.type = .player(Player.testPlayer2, .base)
        cells[CellCoordinate(x: 9, y: 2)]?.type = .player(Player.testPlayer3, .base)
        cells[CellCoordinate(x: 3, y: 3)]?.type = .portal(1)
        cells[CellCoordinate(x: 6, y: 6)]?.type = .portal(1)
        let map = Map(
            size: mapSize,
            cells: cells,
            obstructions: []
        )
        return map
    }
    
    static var testMapRectangle4: Map {
        let mapSize = CGSize(width: 14, height: 9)
        var cells = Map.getCells(in: mapSize, form: .rectangle)
        cells[CellCoordinate(x: 0, y: 0)]?.type = .portal(1)
        cells[CellCoordinate(x: 13, y: 0)]?.type = .portal(1)
        cells[CellCoordinate(x: 0, y: 2)]?.type = .portal(2)
        cells[CellCoordinate(x: 13, y: 2)]?.type = .portal(2)
        cells[CellCoordinate(x: 0, y: 4)]?.type = .portal(3)
        cells[CellCoordinate(x: 13, y: 4)]?.type = .portal(3)
        cells[CellCoordinate(x: 0, y: 6)]?.type = .portal(4)
        cells[CellCoordinate(x: 13, y: 6)]?.type = .portal(4)
        cells[CellCoordinate(x: 0, y: 8)]?.type = .portal(5)
        cells[CellCoordinate(x: 13, y: 8)]?.type = .portal(5)
        cells[CellCoordinate(x: 2, y: 0)]?.type = .player(.testPlayer1, .base)
        cells[CellCoordinate(x: 4, y: 8)]?.type = .player(.testPlayer2, .base)
        cells[CellCoordinate(x: 6, y: 0)]?.type = .player(.testPlayer3, .base)
        cells[CellCoordinate(x: 8, y: 8)]?.type = .player(.testPlayer4, .base)
        cells[CellCoordinate(x: 10, y: 0)]?.type = .player(.testPlayer5, .base)
        let map = Map(
            size: mapSize,
            cells: cells,
            obstructions: []
        )
        return map
    }

    static var testMapHexagon1: Map {
        let mapSize = CGSize(width: 10, height: 10)
        var cells = getCells(in: mapSize, form: .hexagon)
        cells[getHexagonCellCoordinate(x: 6, y: 0)]?.type = .player(.testPlayer1, .base)
        cells[getHexagonCellCoordinate(x: 1, y: 3)]?.type = .player(.testPlayer2, .base)
        cells[getHexagonCellCoordinate(x: 1, y: 8)]?.type = .player(.testPlayer3, .base)
        cells[getHexagonCellCoordinate(x: 6, y: 10)]?.type = .player(.testPlayer4, .base)
        cells[getHexagonCellCoordinate(x: 11, y: 8)]?.type = .player(.testPlayer5, .base)
        cells[getHexagonCellCoordinate(x: 11, y: 3)]?.type = .player(.testPlayer6, .base)
        let map = Map(
            size: mapSize,
            cells: cells,
            obstructions: [
                getHexagonObstruction(x1: 3, y1: 1, x2: 4, y2: 2),
                getHexagonObstruction(x1: 8, y1: 1, x2: 9, y2: 2),
                getHexagonObstruction(x1: 3, y1: 9, x2: 4, y2: 9),
                getHexagonObstruction(x1: 8, y1: 8, x2: 9, y2: 10),
                getHexagonObstruction(x1: 1, y1: 5, x2: 1, y2: 6),
                getHexagonObstruction(x1: 11, y1: 5, x2: 11, y2: 6),
            ]
        )
        return map
    }

    static var testMapHexagon2: Map {
        let mapSize = CGSize(width: 10, height: 10)
        var cells = getCells(in: mapSize, form: .hexagon)
        cells[getHexagonCellCoordinate(x: 6, y: 0)]?.type = .player(.testPlayer1, .base)
        cells[getHexagonCellCoordinate(x: 1, y: 3)]?.type = .player(.testPlayer2, .base)
        cells[getHexagonCellCoordinate(x: 1, y: 8)]?.type = .player(.testPlayer3, .base)
        cells[getHexagonCellCoordinate(x: 6, y: 10)]?.type = .player(.testPlayer4, .base)
        cells[getHexagonCellCoordinate(x: 11, y: 8)]?.type = .player(.testPlayer5, .base)
        cells[getHexagonCellCoordinate(x: 11, y: 3)]?.type = .player(.testPlayer6, .base)
        cells[getHexagonCellCoordinate(x: 5, y: 4)]?.type = .portal(1)
        cells[getHexagonCellCoordinate(x: 7, y: 4)]?.type = .portal(2)
        cells[getHexagonCellCoordinate(x: 8, y: 5)]?.type = .portal(3)
        cells[getHexagonCellCoordinate(x: 7, y: 7)]?.type = .portal(1)
        cells[getHexagonCellCoordinate(x: 5, y: 7)]?.type = .portal(2)
        cells[getHexagonCellCoordinate(x: 4, y: 5)]?.type = .portal(3)
        cells.removeAll { cell in
            let excludingCellCoordinates = [
                getHexagonCellCoordinate(x: 5, y: 5),
                getHexagonCellCoordinate(x: 6, y: 5),
                getHexagonCellCoordinate(x: 6, y: 6),
                getHexagonCellCoordinate(x: 5, y: 6),
                getHexagonCellCoordinate(x: 6, y: 4),
                getHexagonCellCoordinate(x: 7, y: 5),
                getHexagonCellCoordinate(x: 7, y: 6),
            ]
            return excludingCellCoordinates.contains(cell.coordinate)
        }
        let map = Map(size: mapSize, cells: cells)
        return map
    }

    static var testMapHexagon3: Map {
        let mapSize = CGSize(width: 10, height: 10)
        var cells = getCells(in: mapSize, form: .hexagon)
        cells[getHexagonCellCoordinate(x: 6, y: 0)]?.type = .player(.testPlayer1, .base)
        cells[getHexagonCellCoordinate(x: 1, y: 8)]?.type = .player(.testPlayer2, .base)
        cells[getHexagonCellCoordinate(x: 11, y: 8)]?.type = .player(.testPlayer3, .base)
        let map = Map(size: mapSize, cells: cells)
        return map
    }

    static var testMapHexagon4: Map {
        let mapSize = CGSize(width: 10, height: 10)
        var cells = getCells(in: mapSize, form: .hexagon)
        cells[getHexagonCellCoordinate(x: 6, y: 0)]?.type = .player(.testPlayer1, .base)
        cells[getHexagonCellCoordinate(x: 1, y: 8)]?.type = .player(.testPlayer2, .base)
        cells[getHexagonCellCoordinate(x: 11, y: 8)]?.type = .player(.testPlayer3, .base)
        cells[getHexagonCellCoordinate(x: 5, y: 4)]?.type = .portal(1)
        cells[getHexagonCellCoordinate(x: 7, y: 4)]?.type = .portal(2)
        cells[getHexagonCellCoordinate(x: 8, y: 5)]?.type = .portal(3)
        cells[getHexagonCellCoordinate(x: 7, y: 7)]?.type = .portal(1)
        cells[getHexagonCellCoordinate(x: 5, y: 7)]?.type = .portal(2)
        cells[getHexagonCellCoordinate(x: 4, y: 5)]?.type = .portal(3)
        cells.removeAll { cell in
            let excludingCellCoordinates = [
                getHexagonCellCoordinate(x: 5, y: 5),
                getHexagonCellCoordinate(x: 6, y: 5),
                getHexagonCellCoordinate(x: 6, y: 6),
                getHexagonCellCoordinate(x: 5, y: 6),
                getHexagonCellCoordinate(x: 6, y: 4),
                getHexagonCellCoordinate(x: 7, y: 5),
                getHexagonCellCoordinate(x: 7, y: 6),
            ]
            return excludingCellCoordinates.contains(cell.coordinate)
        }
        let map = Map(size: mapSize, cells: cells)
        return map
    }

    static var testMapHexagon5: Map {
        let mapSize = CGSize(width: 10, height: 10)
        var cells = getCells(in: mapSize, form: .hexagon)
        cells[getHexagonCellCoordinate(x: 6, y: 0)]?.type = .player(.testPlayer1, .base)
        cells[getHexagonCellCoordinate(x: 6, y: 10)]?.type = .player(.testPlayer2, .base)
        let map = Map(size: mapSize, cells: cells)
        return map
    }

    static var testMapHexagon6: Map {
        let mapSize = CGSize(width: 10, height: 10)
        var cells = getCells(in: mapSize, form: .hexagon)
        cells[getHexagonCellCoordinate(x: 2, y: 2)]?.type = .player(.testPlayer1, .base)
        cells[getHexagonCellCoordinate(x: 2, y: 8)]?.type = .player(.testPlayer2, .base)
        cells[getHexagonCellCoordinate(x: 10, y: 8)]?.type = .player(.testPlayer3, .base)
        cells[getHexagonCellCoordinate(x: 10, y: 2)]?.type = .player(.testPlayer4, .base)
        let map = Map(size: mapSize, cells: cells)
        return map
    }

    static var rectangleMaps = [testMapRectangle1, Map.testMapRectangle2, testMapRectangle3, testMapRectangle4]

    static var hexagonMaps = [testMapHexagon1, testMapHexagon2, testMapHexagon3, testMapHexagon4, testMapHexagon5, testMapHexagon6]
}

#Preview {
    PreviewMapView(map: .testMapHexagon6, winMode: .infectMoreCells, side: Screen.width)
}
