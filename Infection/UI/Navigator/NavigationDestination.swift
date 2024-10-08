import SwiftUI

enum NavigationDestination {
    case createLobbyView(isLocalGame: Bool)
    case gameView
    case lobbiesView
    case lobbyView(lobby: Lobby)
}

extension NavigationDestination: Hashable {
    var rawValue: String {
        switch self {
        case .createLobbyView(let isLocalGame):
            "createLobbyView(isLocalGame: \(isLocalGame)"
        case .gameView:
            "gameView"
        case .lobbiesView:
            "lobbiesView"
        case .lobbyView(let lobby):
            "lobbyView(lobby: \(lobby.id)"
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

extension NavigationDestination: Equatable {
    static func == (lhs: NavigationDestination, rhs: NavigationDestination) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}
