import Foundation
import FirebaseAuth

class GameManager {
    static let shared = GameManager()
    var localPlayer: Player?
    
    private init() {}
    
    func authentificatePlayer() {
        guard let currentUser = Auth.auth().currentUser, let displayName = currentUser.displayName else { return }
        localPlayer = Player(id: currentUser.uid, name: displayName, color: .white)
    }
}
