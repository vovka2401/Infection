import SwiftUI

struct Cell {
    var type: CellType
    let coordinate: CellCoordinate
    let form: CellForm

    init(coordinate: CellCoordinate, form: CellForm = .rectangle, type: CellType = .default) {
        self.coordinate = coordinate
        self.form = form
        self.type = type
    }

    func getPlayerWithPlayerCellType() -> (player: Player?, playerCellType: PlayerCellType?) {
        switch type {
        case .default, .portal:
            return (nil, nil)
        case let .player(player, playerCellType):
            return (player, playerCellType)
        }
    }

    mutating func infect(by player: Player) {
        switch type {
        case .default:
            type = .player(player, .temporary)
        case .player(_, let playerCellType) where playerCellType.isActive:
            type = .player(player, .constant)
        default: return
        }
    }

    func isBoundaryTo(_ other: Cell, obstructions: [Obstruction] = []) -> Bool {
        if form == .rectangle {
            return !obstructions.contains(
                where: {
                    ($0.coordinates.0 + $0.coordinates.1) == other.coordinate + coordinate
                        + CellCoordinate(x: 1, y: 1)
                }
            ) && coordinate.isBoundaryTo(other.coordinate)
        } else if form == .hexagon {
            return !obstructions.contains(
                where: {
                    abs(
                        ($0.coordinates.0 + $0.coordinates.1)
                            .distance(to: other.coordinate + coordinate + CellCoordinate(
                                x: 1,
                                y: 1
                            ))
                    ) < 0.01
                }
            ) && coordinate.isBoundaryTo(other.coordinate)
        }
        return false
    }
}

extension Cell: Equatable {
    static func == (lhs: Cell, rhs: Cell) -> Bool {
        lhs.coordinate == rhs.coordinate
    }
}

extension Cell: Codable {
    enum CodingKeys: String, CodingKey {
        case type
        case coordinate
        case form
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(coordinate, forKey: .coordinate)
        try container.encode(form, forKey: .form)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let type = try values.decode(CellType.self, forKey: .type)
        let coordinate = try values.decode(CellCoordinate.self, forKey: .coordinate)
        let form = try values.decode(CellForm.self, forKey: .form)
        self.init(coordinate: coordinate, form: form, type: type)
    }
}
