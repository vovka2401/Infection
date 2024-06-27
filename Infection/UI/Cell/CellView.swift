import SwiftUI

struct CellView: View {
    @StateObject var cell: Cell
    var isAvailable: Bool
    let action: (Cell) -> Void
    
//    init(cell: Cell, isAvailable: Bool, action: @escaping (Cell) -> Void) {
//        self._cell = StateObject(wrappedValue: cell)
//        self.isAvailable = isAvailable
//        self.action = action
//    }

    // TODO: fix right size
    var body: some View {
        VStack {
            if let portalNumber = cell.type.portalNumber() {
                GifImageView("portal\(portalNumber)")
                    .frame(width: 46, height: 46)
                    .disabled(true)
            } else {
                let (player, playerCellType) = cell.getPlayerWithPlayerCellType()
                Rectangle()
                    .fill(player?.color.opacity(playerCellType == .temporary ? 0.8 : 0.4) ?? .gray)
                    .frame(width: 45, height: 45)
            }
        }
        .overlay {
            if isAvailable {
                Color.white.opacity(0.3)
            }
        }
        .onTapGesture {
            if isAvailable {
                action(cell)
            }
        }
    }
}
