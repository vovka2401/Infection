import SwiftUI

class Cell: ObservableObject, Equatable {
    @Published var type: CellType
    let coordinate: CellCoordinate
    let form: CellForm
    weak var cluster: Cluster?

    init(coordinate: CellCoordinate, form: CellForm = .rectangle, type: CellType = .default) {
        self.coordinate = coordinate
        self.form = form
        self.type = type
    }

    func getPlayerWithPlayerCellType() -> (player: Player?, playerCellType: PlayerCellType?) {
        switch type {
        case .default, .portal, .none:
            return (nil, nil)
        case let .player(player, playerCellType):
            return (player, playerCellType)
        }
    }

    func infect(by player: Player) {
        switch type {
        case .default:
            type = .player(player, .temporary)
        case .player(_, .temporary):
            type = .player(player, .constant)
        default: return
        }
    }

    // TODO: make it work with boundaries
    func isBoundaryTo(_ other: Cell, obstructions: [Obstruction] = []) -> Bool {
        if form == .rectangle {
            return !obstructions.contains(
                where: {
                    ($0.coordinates.0 + $0.coordinates.1) == other.coordinate + self.coordinate
                    + CellCoordinate(x: 1, y: 1)
                }
            ) && coordinate.isBoundaryTo(other.coordinate)
        } else if form == .hexagon {
            return !obstructions.contains(
                where: { abs(($0.coordinates.0 + $0.coordinates.1).distance(to: other.coordinate + self.coordinate + CellCoordinate(x: 1, y: 1))) < 0.01 }
            ) && coordinate.isBoundaryTo(other.coordinate)
        }
        return false
    }

    static func == (lhs: Cell, rhs: Cell) -> Bool {
        lhs.self === rhs.self
    }
}

extension Cell: Copyable {
    func copy() -> Cell {
        Cell(coordinate: coordinate, form: form, type: type)
    }
}
