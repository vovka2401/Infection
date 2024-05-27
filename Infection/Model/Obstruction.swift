import SwiftUI

struct Obstruction: Identifiable {
    let id = UUID()
    let coordinates: (CellCoordinate, CellCoordinate)
}

extension Obstruction: Equatable {
    static func == (lhs: Obstruction, rhs: Obstruction) -> Bool {
        lhs.id == rhs.id
    }
}
