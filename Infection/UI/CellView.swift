import SwiftUI

struct CellView: View {
    @StateObject var cell: Cell

    // TODO: fix right size
    var body: some View {
        if let portalNumber = cell.type.portalNumber() {
            GifImageView("portal\(portalNumber)")
                .frame(width: 46, height: 46)
        } else {
            let (player, playerCellType) = cell.getPlayerWithPlayerCellType()
            Rectangle()
                .fill(player?.color.opacity(playerCellType == .temporary ? 0.8 : 0.4) ?? .gray)
                .frame(width: 45, height: 45)
        }
    }
}
