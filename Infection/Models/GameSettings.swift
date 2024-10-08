import Foundation

struct GameSettings: Codable, Hashable {
    var maxCountOfPlayers: Int
    var countOfStepsPerTurn: Int
    var isFogOfWarEnabled: Bool
    var isLocalGame: Bool
    var isGamePrivate: Bool
    var gameWinMode: GameWinMode
    var areRandomStepsEnabled: Bool

    init(
        maxCountOfPlayers: Int = 2,
        countOfStepsPerTurn: Int = 3,
        isFogOfWarEnabled: Bool = false,
        isLocalGame: Bool = false,
        isGamePrivate: Bool = false,
        gameWinMode: GameWinMode = .infectMoreCells,
        areRandomStepsEnabled: Bool = false
    ) {
        self.maxCountOfPlayers = maxCountOfPlayers
        self.countOfStepsPerTurn = countOfStepsPerTurn
        self.isFogOfWarEnabled = isFogOfWarEnabled
        self.isLocalGame = isLocalGame
        self.isGamePrivate = isGamePrivate
        self.gameWinMode = gameWinMode
        self.areRandomStepsEnabled = areRandomStepsEnabled
    }
}
