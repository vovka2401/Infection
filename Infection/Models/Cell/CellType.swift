import Foundation

enum CellType {
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
}

extension CellType: Equatable {
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

extension CellType: Codable {
    enum CodingKeys: String, CodingKey {
        case rawValue
        case associatedValue1
        case associatedValue2
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .portal(number):
            try container.encode(number, forKey: .associatedValue1)
        case let .player(player, playerCellType):
            try container.encode(player, forKey: .associatedValue1)
            try container.encode(playerCellType, forKey: .associatedValue2)
        case .default:
            try container.encode("default", forKey: .rawValue)
        case .none:
            try container.encode("none", forKey: .rawValue)
        }
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let rawValue = try? values.decode(String.self, forKey: .rawValue) {
            self = rawValue == "default" ? .default : .none
        } else if let portalNumber = try? values.decode(Int.self, forKey: .associatedValue1) {
            self = .portal(portalNumber)
        } else if let player = try? values.decode(Player.self, forKey: .associatedValue1),
                  let playerCellType = try? values.decode(PlayerCellType.self, forKey: .associatedValue2) {
            self = .player(player, playerCellType)
        } else {
            throw CellTypeCodingError.decoding("error")
        }
    }

    enum CellTypeCodingError: Error {
        case decoding(String)
    }
}
