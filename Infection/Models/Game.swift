import GameKit
import SwiftUI

struct Game: Identifiable {
    var id: String
    var defaultMap: Map
    var map: Map
    var players: [Player]
    var settings: GameSettings
    var currentTurn: Turn!
    var isOver = false
    var isFirstLap = true
    var winner: Player?

    init(id: String, map: Map, defaultMap: Map? = nil, players: [Player], settings: GameSettings) {
        self.id = id
        self.defaultMap = defaultMap ?? map
        self.map = map
        self.players = players
        self.settings = settings
    }

    init(lobby: Lobby) {
        self.id = lobby.id
        defaultMap = lobby.map
        self.map = lobby.map
        self.players = lobby.players
        self.currentTurn = Turn(player: players[0])
        self.settings = lobby.settings
    }
    
    mutating func restart() {
        isOver = false
        isFirstLap = true
        map = defaultMap
        currentTurn = Turn(player: players[0])
        winner = nil
    }
}

extension Game: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case map
        case defaultMap
        case players
        case settings
        case currentTurn
        case isOver
        case isFirstLap
        case winner
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(map, forKey: .map)
        try container.encode(defaultMap, forKey: .defaultMap)
        try container.encode(players, forKey: .players)
        try container.encode(settings, forKey: .settings)
        try container.encode(currentTurn, forKey: .currentTurn)
        try container.encode(isOver, forKey: .isOver)
        try container.encode(isFirstLap, forKey: .isFirstLap)
        try container.encode(winner, forKey: .winner)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let id = try values.decode(String.self, forKey: .id)
        let map = try values.decode(Map.self, forKey: .map)
        let defaultMap = try values.decode(Map.self, forKey: .defaultMap)
        let players = try values.decode([Player].self, forKey: .players)
        let settings = try values.decode(GameSettings.self, forKey: .settings)
        let currentTurn = try values.decode(Turn?.self, forKey: .currentTurn)
        let isOver = try values.decode(Bool.self, forKey: .isOver)
        let isFirstLap = try values.decode(Bool.self, forKey: .isFirstLap)
        let winner = try values.decode(Player?.self, forKey: .winner)
        self.init(id: id, map: map, defaultMap: defaultMap, players: players, settings: settings)
        self.currentTurn = currentTurn
        self.isOver = isOver
        self.isFirstLap = isFirstLap
        self.winner = winner
    }
}
