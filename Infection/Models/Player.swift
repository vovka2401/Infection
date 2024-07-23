import SwiftUI

struct Player: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var color: Color

    init(name: String, color: Color) {
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
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(color, forKey: .color)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        color = try values.decode(Color.self, forKey: .color)
    }
}

extension Player {
    static let testPlayer1 = Player(name: "Player 1", color: .yellow)
    static let testPlayer2 = Player(name: "Player 2", color: .blue)
    static let testPlayer3 = Player(name: "Player 3", color: .green)
    static let testPlayer4 = Player(name: "Player 4", color: .pink)
    static let testPlayer5 = Player(name: "Player 5", color: .mint)
}

enum PlayerCellType: Codable {
    case temporary
    case constant
}
