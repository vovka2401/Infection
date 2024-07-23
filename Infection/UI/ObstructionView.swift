import SwiftUI

struct ObstructionView: View {
    let obstruction: Obstruction

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(.white)
            .frame(width: 45 * obstruction.coordinates.0.distance(to: obstruction.coordinates.1), height: 5)
            .rotationEffect(.radians(obstruction.coordinates.1.angle(to: obstruction.coordinates.0)))
    }
}
