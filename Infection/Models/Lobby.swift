import Foundation

struct Lobby: Identifiable, Hashable {
    var id: String = IDGenerator.shared.generateLobbyID()
    var settings: GameSettings = GameSettings()
    var players: [Player] = []
    var map: Map
    var host: Player
    var creationDate = Date()
}

extension Lobby: Codable {}
