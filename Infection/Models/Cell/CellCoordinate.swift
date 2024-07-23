import SwiftUI

struct CellCoordinate: Hashable, Codable {
    var x: Double
    var y: Double

    func isBoundaryTo(_ other: Self) -> Bool {
        abs(y - other.y) == 1 && x == other.x
            || y == other.y && abs(x - other.x) == 1
            || abs(abs(y - other.y) - cos(.pi / 6)) < 0.1 && x == other.x
            || abs(abs(y - other.y) - 0.5 * cos(.pi / 6)) < 0.1 && abs(x - other.x) == 0.75
    }

    func distance(to other: Self) -> CGFloat {
        sqrt(pow(x - other.x, 2) + pow(y - other.y, 2))
    }

    func angle(to other: Self) -> CGFloat {
        let originX = other.x - x
        let originY = other.y - y
        var bearingRadians = atan2f(Float(originY), Float(originX))
        while bearingRadians < 0 {
            bearingRadians += .pi
        }
        return CGFloat(bearingRadians)
    }
}

extension CellCoordinate: Equatable {
    static func + (lhs: CellCoordinate, rhs: CellCoordinate) -> CellCoordinate {
        CellCoordinate(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}

extension CellCoordinate {
    static let hexagonAdditionToFirstCoordinate = CellCoordinate(x: 0.75, y: 0.5 + 0.5 * cos(.pi / 6))
    static let hexagonAdditionToSecondCoordinate = CellCoordinate(x: 0.25, y: 0.5 - 0.5 * cos(.pi / 6))
}
