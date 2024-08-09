import Foundation
import GameKit

protocol GameCenterManagerDelegate: AnyObject {
    func didChangeAuthStatus(isAuthenticated: Bool)
    func presentGameCenterAuth(viewController: UIViewController?)
    func presentMatchmaking(viewController: UIViewController?)
    func presentGame(match: GKMatch)
}

final class GameCenterManager: NSObject, GKLocalPlayerListener, ObservableObject {
    @Published var gameViewModel: GameViewModel!
    @Published var isGameCreator = true
    @Published var isInGame = false
    @Published var isAuthenticated = GKLocalPlayer.local.isAuthenticated
    weak var delegate: GameCenterManagerDelegate?
    private let inviteMessage = L10n.inviteMessage.text
    private var matchmakerViewController: GKMatchmakerViewController?
    var rootViewController: UIViewController? = {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return windowScene?.windows.first?.rootViewController
    }()

    func authenticatePlayer() {
        GKLocalPlayer.local.authenticateHandler = { gameCenterAuthViewController, _ in
            self.delegate?.didChangeAuthStatus(isAuthenticated: GKLocalPlayer.local.isAuthenticated)
            guard GKLocalPlayer.local.isAuthenticated else {
                self.delegate?.presentGameCenterAuth(viewController: gameCenterAuthViewController)
                return
            }
            GKLocalPlayer.local.register(self)
        }
    }

    func presentMatchmaker(withInvite invite: GKInvite? = nil) {
        guard GKLocalPlayer.local.isAuthenticated,
              let viewController = createMatchmaker(withInvite: invite) else { return }
        matchmakerViewController = viewController
        viewController.matchmakerDelegate = self
        delegate?.presentMatchmaking(viewController: viewController)
    }

    private func createMatchmaker(withInvite invite: GKInvite? = nil) -> GKMatchmakerViewController? {
        var controller: GKMatchmakerViewController?
        if let invite {
            controller = GKMatchmakerViewController(invite: invite)
        } else {
            controller = GKMatchmakerViewController(matchRequest: createRequest())
        }
        controller?.matchmakerDelegate = self
        if gameViewModel?.game.settings.isGamePrivate == true {
            controller?.matchmakingMode = .inviteOnly
        } else if !isGameCreator {
            controller?.matchmakingMode = .automatchOnly
        }
        return controller
    }

    private func createRequest() -> GKMatchRequest {
        let request = GKMatchRequest()
        request.minPlayers = gameViewModel.game.settings.maxCountOfPlayers
        request.maxPlayers = gameViewModel.game.settings.maxCountOfPlayers
        request.inviteMessage = inviteMessage
        request.playerAttributes = isGameCreator ?
            0xFFFF_FFFF - UInt32(gameViewModel.game.settings.maxCountOfPlayers - 1) * 0x0000_000F : 0x0000_000F
        return request
    }
}

extension GameCenterManager: GKMatchDelegate {
    func sendData(match: GKMatch) {
        guard let gameViewModel, let data = try? JSONEncoder().encode(gameViewModel) else { return }
        do {
            try match.sendData(toAllPlayers: data, with: .reliable)
        } catch {
            print("Failed to send data: \(error.localizedDescription)")
        }
    }

    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer _: GKPlayer) {
        do {
            guard !isInGame else { return }
            let gameViewModel = try JSONDecoder().decode(GameViewModel.self, from: data)
            self.gameViewModel = gameViewModel
            delegate?.presentGame(match: match)
        } catch let DecodingError.dataCorrupted(context) {
            print(context)
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("error: ", error)
        }
    }
    
    func match(_ match: GKMatch, didReceive data: Data, forRecipient recipient: GKPlayer, fromRemotePlayer player: GKPlayer) {
        do {
            guard !isInGame else { return }
            let gameViewModel = try JSONDecoder().decode(GameViewModel.self, from: data)
            self.gameViewModel = gameViewModel
            delegate?.presentGame(match: match)
        } catch let DecodingError.dataCorrupted(context) {
            print(context)
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("error: ", error)
        }
    }
}

extension GameCenterManager: GKMatchmakerViewControllerDelegate {
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        match.delegate = self
        viewController.matchmakerDelegate = self
        viewController.dismiss(animated: true)
        if isGameCreator {
            self.sendData(match: match)
        }
        if gameViewModel != nil {
            delegate?.presentGame(match: match)
        }
    }

    func player(_: GKPlayer, didAccept invite: GKInvite) {
        isGameCreator = false
        if let matchmakerViewController {
            matchmakerViewController.dismiss(animated: true, completion: {
                self.presentMatchmaker(withInvite: invite)
            })
        } else {
            presentMatchmaker(withInvite: invite)
        }
    }

    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        viewController.dismiss(animated: true)
    }

    func matchmakerViewController(_: GKMatchmakerViewController, didFailWithError error: Error) {
        print("Matchmaker viewController did fail with error: \(error.localizedDescription).")
    }
}
