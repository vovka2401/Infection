import SwiftUI

class Cell: ObservableObject, Equatable {
    let coordinate: CellCoordinate
    @Published var type: CellType
    weak var cluster: Cluster?

    init(coordinate: CellCoordinate, type: CellType = .default) {
        self.coordinate = coordinate
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

enum CellType: Equatable {
    case `default`
    case portal(Int)
    case player(Player, PlayerCellType)

    func isPortal() -> Bool {
        switch self {
        case .portal: return true
        default: return false
        }
    }

    func portalNumber() -> Int? {
        switch self {
        case let .portal(number): return number
        default: return nil
        }
    }

    static func == (lhs: CellType, rhs: CellType) -> Bool {
        switch (lhs, rhs) {
        case (.default, .default): return true
        case let (.portal(portal1), .portal(portal2)): return portal1 == portal2
        case let (.player(player1, type1), .player(player2, type2)):
            return player1 == player2 && type1 == type2
        default: return false
        }
    }
}
