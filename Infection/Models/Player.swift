import SwiftUI

struct Player: Identifiable, Hashable {
    var id: String
    var name: String
    var color: Color
    var isReady = false

    init(id: String, name: String, color: Color) {
        self.id = id
        self.name = name
        self.color = color
    }
}

extension Player: Equatable {
    static func == (lhs: Player, rhs: Player) -> Bool {
        lhs.id == rhs.id
    }
}

extension Player: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case color
        case isReady
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(color, forKey: .color)
        try container.encode(isReady, forKey: .isReady)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        color = try values.decode(Color.self, forKey: .color)
        isReady = try values.decode(Bool.self, forKey: .isReady)
    }
}

extension Player {
    static let testPlayer1 = Player(id: "1", name: "Player 1", color: .yellow)
    static let testPlayer2 = Player(id: "2", name: "Player 2", color: .blue)
    static let testPlayer3 = Player(id: "3", name: "Player 3", color: .green)
    static let testPlayer4 = Player(id: "4", name: "Player 4", color: .pink)
    static let testPlayer5 = Player(id: "5", name: "Player 5", color: .mint)
    static let testPlayer6 = Player(id: "6", name: "Player 6", color: .orange)
    static let testPlayer7 = Player(id: "7", name: "Player 7", color: .red)
    static let testPlayer8 = Player(id: "8", name: "Player 8", color: .brown)
}

enum PlayerCellType: Codable {
    case temporary
    case constant
    case base
    
    var isActive: Bool {
        switch self {
        case .temporary, .base: true
        default: false
        }
    }
}
