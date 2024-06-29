import SwiftUI

struct CellShape: Shape {
    let form: CellForm

    func path(in rect: CGRect) -> Path {
        switch form {
        case .triangle:
            Triangle().path(in: rect)
        case .rectangle:
            Rectangle().path(in: rect)
        case .hexagon:
            Hexagon().path(in: rect)
        }
    }
}
