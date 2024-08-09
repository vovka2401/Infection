import SwiftUI

struct CellView: View {
    let cell: Cell
    let isAvailable: Bool
    let isFogged: Bool
    @State var action: (Cell) -> Void
    @State private var angle = 0.0
    private let side = 45.0

    var body: some View {
        if let portalNumber = cell.type.portalNumber() {
            Image("portal\(portalNumber)")
                .resizable()
                .frame(side: side * sqrt(cell.form == .rectangle ? 2 : 1))
                .disabled(true)
                .frame(side: side)
                .rotationEffect(.degrees(angle))
                .clipShape(CellShape(form: cell.form))
                .onAppear {
                    withAnimation(.linear(duration: 1).speed(0.1).repeatForever(autoreverses: false)) {
                        angle = 360
                    }
                }
        } else if isFogged {
            CellShape(form: cell.form)
                .fill(Color(white: 0.4))
                .frame(side: side)
        } else {
            let (player, playerCellType) = cell.getPlayerWithPlayerCellType()
            CellShape(form: cell.form)
                .fill(player?.color.opacity(playerCellType?.isActive == true ? 0.8 : 0.4) ?? .gray)
                .frame(side: side)
                .overlay {
                    if playerCellType == .base {
                        Image(systemName: "star.fill")
                            .resizable()
                            .frame(side: side / 2)
                    }
                }
                .overlay {
                    if isAvailable {
                        Color.white.opacity(0.3)
                            .clipShape(CellShape(form: cell.form))
                    }
                }
                .onTapGesture {
                    if isAvailable {
                        withAnimation(.easeInOut) {
                            action(cell)
                        }
                    }
                }
        }
    }
}

#Preview {
    CellView(
        cell: Cell(
            coordinate: CellCoordinate(x: 0, y: 0),
            form: .rectangle,
            type: .player(.testPlayer1, .temporary)
        ),
        isAvailable: false,
        isFogged: true,
        action: { _ in }
    )
}
