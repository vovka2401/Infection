import SwiftUI

struct Map: Identifiable, Hashable {
    let id: UUID
    let size: CGSize
    var cells: [Cell]
    var clusters: [Cluster] = []
    let obstructions: [Obstruction]

    init(id: UUID = UUID(), size: CGSize, cells: [Cell], obstructions: [Obstruction] = []) {
        self.id = id
        self.size = size
        self.cells = cells
        self.obstructions = obstructions
    }

    func getCountOfPlayers() -> Int {
        getDefaultPlayers().count
    }

    func getDefaultPlayers() -> [Player] {
        Array(Set(cells.compactMap { $0.getPlayerWithPlayerCellType().player })).sorted { $0.name < $1.name }
    }

    func getActiveCells() -> [Cell] {
        cells.filter { $0.getPlayerWithPlayerCellType().playerCellType?.isActive == true }
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
                            y: (-0.325 + Double(y) + Double(isSecond ? 0.5 : 0.0)) * cos(.pi / 6)
                        ),
                        form: form,
                        type: .default
                    )
                    cells.append(cell)
                }
            }
            cells.removeAll { cell in
                !Hexagon.isCoordinateInsideHexagon(
                    center: CellCoordinate(x: 4.5, y: 4.5),
                    size: 4.6,
                    coordinate: cell.coordinate
                )
            }
        }
        return cells
    }
    
    static func getHexagonCellCoordinate(x: Int, y: Int) -> CellCoordinate {
        let isSecond = x % 2 == 0
        return CellCoordinate(
            x: 0.75 * Double(x),
            y: (-0.325 + Double(y) + Double(isSecond ? 0.5 : 0.0)) * cos(.pi / 6)
        )
    }

    static func getHexagonObstruction(x1: Int, y1: Int, x2: Int, y2: Int) -> Obstruction {
        Obstruction(
            coordinates: (
                getHexagonCellCoordinate(x: x1, y: y1) + .hexagonAdditionToFirstCoordinate,
                getHexagonCellCoordinate(x: x2, y: y2) + .hexagonAdditionToSecondCoordinate)
        )
    }
}
