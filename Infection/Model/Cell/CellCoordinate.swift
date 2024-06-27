import SwiftUI

struct CellCoordinate: Hashable {
    var x: Int
    var y: Int

    func isBoundaryTo(_ other: Self) -> Bool {
        x == other.x && abs(y - other.y) == 1
            || y == other.y && abs(x - other.x) == 1
    }
}

extension CellCoordinate: Equatable {
    static func + (lhs: CellCoordinate, rhs: CellCoordinate) -> CellCoordinate {
        CellCoordinate(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}
