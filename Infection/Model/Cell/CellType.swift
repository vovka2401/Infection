import Foundation

enum CellType: Equatable {
    case `default`
    case none
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
