import Foundation

class MatchManager: ObservableObject {
    @Published var inGame = false
    @Published var isGameOver = false
    @Published var authentificationState = PlayerAuthState.authentificating
}
