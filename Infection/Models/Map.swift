import SwiftUI

struct Map: Identifiable {
    let id: UUID
    let size: CGSize
    var cells: [Cell]
    var clusters: [Cluster] = []
    let obstructions: [Obstruction]

    init(id: UUID = UUID(), size: CGSize, cells: [Cell], obstructions: [Obstruction]) {
        self.id = id
        self.size = size
        self.cells = cells
        self.obstructions = obstructions
    }

    func getCountOfPlayers() -> Int {
        cells.filter { $0.getPlayerWithPlayerCellType().player != nil }.count
    }
}

extension Map: Equatable {
    static func == (lhs: Map, rhs: Map) -> Bool {
        lhs.id == rhs.id
    }
}

extension Map: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case size
        case cells
        case clusters
        case obstructions
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(size, forKey: .size)
        try container.encode(cells, forKey: .cells)
        try container.encode(clusters, forKey: .clusters)
        try container.encode(obstructions, forKey: .obstructions)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let id = try values.decode(UUID.self, forKey: .id)
        let size = try values.decode(CGSize.self, forKey: .size)
        let cells = try values.decode([Cell].self, forKey: .cells)
        let clusters = try values.decode([Cluster].self, forKey: .clusters)
        let obstructions = try values.decode([Obstruction].self, forKey: .obstructions)
        self.init(id: id, size: size, cells: cells, obstructions: obstructions)
        self.clusters = clusters
    }
}

extension Map {
    static func getCells(in size: CGSize, form: CellForm) -> [Cell] {
        var cells: [Cell] = []
        if form == .rectangle {
            for x in 0 ..< Int(size.width) {
                for y in 0 ..< Int(size.height) {
                    let cell = Cell(coordinate: CellCoordinate(x: Double(x), y: Double(y)), form: form, type: .default)
                    cells.append(cell)
                }
            }
        } else if form == .hexagon {
            for x in 0 ..< Int(size.width / 0.75) {
                for y in 0 ... Int(size.height) {
                    let isSecond = x % 2 == 0
                    let cell = Cell(
                        coordinate: CellCoordinate(
                            x: 0.75 * Double(x),
                            y: (Double(y) + Double(isSecond ? 0.5 : 0.0)) * cos(.pi / 6)
                        ),
                        form: form,
                        type: .default
                    )
                    cells.append(cell)
                }
            }
        }
        return cells
    }

    static var testMapRectangle1: Map {
        let mapSize = CGSize(width: 10, height: 10)
        var cells = Map.getCells(in: mapSize, form: .rectangle)
        cells[CellCoordinate(x: 0, y: 0)]?.type = .player(Player.testPlayer1, .temporary)
        cells[CellCoordinate(x: 2, y: 0)]?.type = .portal(2)
        cells[CellCoordinate(x: 2, y: 7)]?.type = .portal(1)
        cells[CellCoordinate(x: 7, y: 2)]?.type = .portal(2)
        cells[CellCoordinate(x: 7, y: 9)]?.type = .portal(1)
        cells[CellCoordinate(x: 9, y: 9)]?.type = .player(Player.testPlayer2, .temporary)
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
        cells[CellCoordinate(x: 0, y: 0)]?.type = .player(Player.testPlayer1, .temporary)
        cells[CellCoordinate(x: 0, y: 9)]?.type = .player(Player.testPlayer2, .temporary)
        cells[CellCoordinate(x: 9, y: 0)]?.type = .player(Player.testPlayer3, .temporary)
        cells[CellCoordinate(x: 9, y: 9)]?.type = .player(Player.testPlayer4, .temporary)
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
        cells[CellCoordinate(x: 0, y: 0)]?.type = .player(Player.testPlayer1, .temporary)
        cells[CellCoordinate(x: 2, y: 9)]?.type = .player(Player.testPlayer2, .temporary)
        cells[CellCoordinate(x: 9, y: 2)]?.type = .player(Player.testPlayer3, .temporary)
        cells[CellCoordinate(x: 3, y: 3)]?.type = .portal(1)
        cells[CellCoordinate(x: 6, y: 6)]?.type = .portal(1)
        let map = Map(
            size: mapSize,
            cells: cells,
            obstructions: []
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
            Cell(
                coordinate: CellCoordinate(x: 7.5, y: 9 * cos(.pi / 6)),
                form: .hexagon,
                type: .player(Player.testPlayer2, .temporary)
            ),
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
                ),
            ]
        )
        return map
    }

    static var testMapHexagon2: Map {
        let mapSize = CGSize(width: 10, height: 10)
        let cells = getCells(in: mapSize, form: .hexagon)
        let map = Map(
            size: mapSize,
            cells: cells,
            obstructions: []
        )
        return map
    }

    static var rectangleMaps = [Map.testMapRectangle1, Map.testMapRectangle2, testMapRectangle3]

    static var hexagonMaps = [Map.testMapHexagon1]
}

#Preview {
    PreviewMapView(map: .testMapHexagon2, side: Screen.width)
}
