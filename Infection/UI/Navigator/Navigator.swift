import SwiftUI

class Navigator: ObservableObject {
    static let shared = Navigator()
    var path = NavigationPath()

    private init() {}

    func pushCreateGameView(isLocalGame: Bool) {
        pushView(NavigationDestination.createGameView(isLocalGame: isLocalGame))
    }

    func pushGameView(completion: (() -> Void)? = nil) {
        pushView(NavigationDestination.gameView, completion: completion)
    }

    func pushJoinGameView() {
        pushView(NavigationDestination.joinGameView)
    }

    func dismiss(_ completion: (() -> Void)? = nil) {
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
