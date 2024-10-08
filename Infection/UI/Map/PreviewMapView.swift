import SwiftUI

struct PreviewMapView: View {
    let map: Map
    let winMode: GameWinMode
    let side: CGFloat
    
    init(map: Map, winMode: GameWinMode, side: CGFloat) {
        var map = map
        if winMode == .infectMoreCells {
            for cell in map.cells {
                let (player, playerCellType) = cell.getPlayerWithPlayerCellType()
                if playerCellType == .base, let player {
                    map.cells[cell.coordinate]?.type = .player(player, .temporary)
                }
            }
        }
        self.map = map
        self.winMode = winMode
        self.side = side
    }
    
    var body: some View {
        Rectangle()
            .fill(Color(red: 0.1, green: 0.1, blue: 0.2))
            .frame(width: map.size.width * 50, height: map.size.height * 50)
            .overlay {
                ForEach(map.cells, id: \.coordinate) { cell in
                    CellView(cell: cell, isAvailable: false, isFogged: false, action: { _ in })
                        .position(
                            x: 25 + CGFloat(cell.coordinate.x * 50), y: 25 + CGFloat(cell.coordinate.y * 50)
                        )
                }
            }
            .overlay {
                ForEach(map.obstructions, id: \.id) { obstruction in
                    ObstructionView(obstruction: obstruction)
                        .position(
                            x: CGFloat((obstruction.coordinates.0.x + obstruction.coordinates.1.x) * 25),
                            y: CGFloat((obstruction.coordinates.0.y + obstruction.coordinates.1.y) * 25)
                        )
                }
            }
            .scaleEffect(x: 0.9 * side / map.size.width / 50, y: 0.9 * side / map.size.width / 50)
            .disabled(true)
    }
}
