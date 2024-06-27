import SwiftUI

class Player: Identifiable {
    let id = UUID()
    var name: String
    var color: Color

    init(name: String, color: Color) {
        self.name = name
        self.color = color
    }
}

extension Player: Equatable {
    static func == (lhs: Player, rhs: Player) -> Bool {
        lhs.id == rhs.id
    }
}

extension Player {
    static let testPlayer1 = Player(name: "Player 1", color: .yellow)
    static let testPlayer2 = Player(name: "Player 2", color: .blue)
    static let testPlayer3 = Player(name: "Player 3", color: .green)
    static let testPlayer4 = Player(name: "Player 4", color: .pink)
    static let testPlayer5 = Player(name: "Player 5", color: .mint)
}

enum PlayerCellType {
    case temporary
    case constant
}
