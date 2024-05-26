import SwiftUI

struct Obstruction: Identifiable, Equatable {
    let id = UUID()
    let coordinates: (CellCoordinate, CellCoordinate)
}
