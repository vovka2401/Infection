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

enum PlayerCellType {
    case temporary
    case constant
}
