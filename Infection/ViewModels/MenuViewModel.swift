import Foundation
import GameKit
import SwiftUI

class MenuViewModel: ObservableObject {
    @Published var gameCenterManager: GameCenterManager!

    init() {
        gameCenterManager = GameCenterManager()
        gameCenterManager.delegate = self
        gameCenterManager.authenticatePlayer()
    }
}

extension MenuViewModel: GameCenterManagerDelegate {
    func didChangeAuthStatus(isAuthenticated: Bool) {
        gameCenterManager.isAuthenticated = isAuthenticated
        objectWillChange.send()
    }

    func presentGameCenterAuth(viewController: UIViewController?) {
        guard let viewController else { return }
        gameCenterManager.rootViewController?.present(viewController, animated: true)
    }

    func presentMatchmaking(viewController: UIViewController?) {
        guard !gameCenterManager.isInGame, let viewController,
              let rootViewController = gameCenterManager.rootViewController else { return }
        rootViewController.present(viewController, animated: true)
    }

    func presentGame(match: GKMatch) {
        guard !gameCenterManager.isInGame else { return }
        gameCenterManager.gameViewModel.match = match
        gameCenterManager.gameViewModel.match?.delegate = gameCenterManager.gameViewModel
        gameCenterManager.gameViewModel.setup()
        gameCenterManager.rootViewController?.dismiss(animated: true)
        gameCenterManager.gameViewModel.onDismiss = {
            self.gameCenterManager.isInGame = false
        }
        Navigator.shared.pushGameView {
            self.gameCenterManager.isInGame = true
        }
    }
}
