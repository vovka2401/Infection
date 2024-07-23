import GameKit
import SwiftUI

struct Game {
    let defaultMap: Map
    var map: Map
    var players: [Player]
    var currentTurn: Turn!
    var isOver = false

    init(map: Map, players: [Player] = []) {
        defaultMap = map
        self.map = map
        self.players = players
    }
}

extension Game: Codable {
    enum CodingKeys: String, CodingKey {
        case map
        case players
        case currentTurn
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(map, forKey: .map)
        try container.encode(players, forKey: .players)
        try container.encode(currentTurn, forKey: .currentTurn)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let map = try values.decode(Map.self, forKey: .map)
        let players = try values.decode([Player].self, forKey: .players)
        let currentTurn = try values.decode(Turn?.self, forKey: .currentTurn)
        self.init(map: map, players: players)
        self.currentTurn = currentTurn
    }
}
