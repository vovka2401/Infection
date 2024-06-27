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

    func isBoundaryTo(_ other: Cell, obstructions: [Obstruction] = []) -> Bool {
        !obstructions.contains(
            where: {
                ($0.coordinates.0 + $0.coordinates.1) == other.coordinate + self.coordinate
                    + CellCoordinate(x: 1, y: 1)
            }
        ) && coordinate.isBoundaryTo(other.coordinate)
    }

    static func == (lhs: Cell, rhs: Cell) -> Bool {
        lhs.self === rhs.self
    }
}

extension Cell: Copyable {
    func copy() -> Cell {
        Cell(coordinate: coordinate, type: type)
    }
}
