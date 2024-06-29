import SwiftUI

struct ObstructionView: View {
    @State var obstruction: Obstruction
//    var isVertical: Bool { obstruction.coordinates.0.x == obstruction.coordinates.1.x }

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(.white)
            .frame(width: 45 * obstruction.coordinates.0.distance(to: obstruction.coordinates.1), height: 5)
            .rotationEffect(.radians(obstruction.coordinates.1.angle(to: obstruction.coordinates.0)))
    }
}
