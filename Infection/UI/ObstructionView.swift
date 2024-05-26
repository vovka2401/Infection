import SwiftUI

struct ObstructionView: View {
    @State var obstruction: Obstruction
    var isVertical: Bool { obstruction.coordinates.0.x == obstruction.coordinates.1.x }

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(.white)
            .frame(width: isVertical ? 5 : 45, height: isVertical ? 45 : 5)
    }
}
