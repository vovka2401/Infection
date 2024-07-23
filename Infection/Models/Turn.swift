import SwiftUI

struct Turn {
    var player: Player
    var step = 1
}

extension Turn: Codable {
    enum CodingKeys: String, CodingKey {
        case player
        case step
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(player, forKey: .player)
        try container.encode(step, forKey: .step)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        player = try values.decode(Player.self, forKey: .player)
        step = try values.decode(Int.self, forKey: .step)
    }
}
