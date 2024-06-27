import Foundation

struct GameSettings {
    var maxCountOfPlayers: Int
    var countOfStepsPerTurn: Int
    var isFogOfWarEnabled: Bool

    init(maxCountOfPlayers: Int = 2, countOfStepsPerTurn: Int = 3, isFogOfWarEnabled: Bool = false) {
        self.maxCountOfPlayers = maxCountOfPlayers
        self.countOfStepsPerTurn = countOfStepsPerTurn
        self.isFogOfWarEnabled = isFogOfWarEnabled
    }
}
