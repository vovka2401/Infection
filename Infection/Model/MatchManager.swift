import GameKit
import SwiftUI

class MatchManager: ObservableObject {
    @Published var inGame = false
    @Published var isGameOver = false
    @Published var authentificationState = PlayerAuthState.authentificating

    @Published var score = 0

    var match: GKMatch?
    var otherPlayer: GKPlayer?
    var localPlayer = GKLocalPlayer.local

    var playerUUIDKey = UUID().uuidString

    var rootViewController: UIViewController? {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return windowScene?.windows.first?.rootViewController
    }

    func authentificateUser() {
        GKLocalPlayer.local.authenticateHandler = { [self] viewController, error in
            if let viewController {
                rootViewController?.present(viewController, animated: true)
                return
            }
            if let error {
                authentificationState = .error
                return
            }
            if localPlayer.isAuthenticated {
                if localPlayer.isMultiplayerGamingRestricted {
                    authentificationState = .restricted
                } else {
                    authentificationState = .authentificated
                }
            } else {
                authentificationState = .unauthentificated
            }
        }
    }
}
