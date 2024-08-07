import Foundation

struct GameSettings: Codable {
    var maxCountOfPlayers: Int
    var countOfStepsPerTurn: Int
    var isFogOfWarEnabled: Bool
    var isLocalGame: Bool
    var isGamePrivate: Bool

    init(
        maxCountOfPlayers: Int = 2,
        countOfStepsPerTurn: Int = 3,
        isFogOfWarEnabled: Bool = false,
        isLocalGame: Bool = false,
        isGamePrivate: Bool = false
    ) {
        self.maxCountOfPlayers = maxCountOfPlayers
        self.countOfStepsPerTurn = countOfStepsPerTurn
        self.isFogOfWarEnabled = isFogOfWarEnabled
        self.isLocalGame = isLocalGame
        self.isGamePrivate = isGamePrivate
    }
}
