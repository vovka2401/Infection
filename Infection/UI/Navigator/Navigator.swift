import SwiftUI

class Navigator: ObservableObject {
    static let shared = Navigator()
    var path = NavigationPath()

    private init() {}

    func pushCreateLobbyView(isLocalGame: Bool) {
        pushView(NavigationDestination.createLobbyView(isLocalGame: isLocalGame))
    }

    func pushGameView(completion: (() -> Void)? = nil) {
        pushView(NavigationDestination.gameView, completion: completion)
    }

    func pushLobbiesView() {
        pushView(NavigationDestination.lobbiesView)
    }

    func pushLobbyView(lobby: Lobby) {
        pushView(NavigationDestination.lobbyView(lobby: lobby))
    }

    func dismissToMenuView(_ completion: (() -> Void)? = nil) {
        guard !path.isEmpty else { return }
        path = NavigationPath()
        completion?()
        objectWillChange.send()
    }

    func dismiss(_ completion: (() -> Void)? = nil) {
        guard !path.isEmpty else { return }
        path.removeLast()
        completion?()
        objectWillChange.send()
    }

    private func pushView(_ destination: NavigationDestination, completion: (() -> Void)? = nil) {
        path.append(destination)
        completion?()
        objectWillChange.send()
    }
}
