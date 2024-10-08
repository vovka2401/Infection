import Firebase

class FirebaseManager {
    static let shared = FirebaseManager()
    let ref = Database.database().reference()
    
    private init() {}

    func sendData<T: Codable>(_ value: T, to path: [String]) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        let stringData = String(decoding: data, as: UTF8.self)
        var currentReference = ref
        for node in path {
            currentReference = currentReference.child(node)
        }
        currentReference.setValue(stringData)
    }

    func sendLobbyData(_ lobby: Lobby) {
        sendData(lobby, to: ["lobbies", lobby.id, "lobby"])
    }

    func sendGameData(_ game: Game) {
        sendData(game, to: ["lobbies", game.id, "game"])
    }
}
