import SwiftUI

struct CellView: View {
    let cell: Cell
    let isAvailable: Bool
    let isFogged: Bool
    @State var action: (Cell) -> Void

    var body: some View {
        if let portalNumber = cell.type.portalNumber() {
            GifImageView("portal\(portalNumber)")
                .frame(width: 46, height: 46)
                .disabled(true)
        } else if isFogged {
            CellShape(form: cell.form)
                .fill(Color(white: 0.2))
                .frame(width: 45, height: 45)
        } else {
            let (player, playerCellType) = cell.getPlayerWithPlayerCellType()
            CellShape(form: cell.form)
                .fill(player?.color.opacity(playerCellType == .temporary ? 0.8 : 0.4) ?? .gray)
                .frame(width: 45, height: 45)
                .overlay {
                    if isAvailable {
                        Color.white.opacity(0.3)
                            .clipShape(CellShape(form: cell.form))
                    }
                }
                .onTapGesture {
                    if isAvailable {
                        action(cell)
                    }
                }
        }
    }
}
