import SwiftUI

enum NavigationDestination: Equatable, Hashable {
    case createGameView(isLocalGame: Bool)
    case gameView
    case joinGameView
}
