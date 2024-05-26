import SwiftUI

class Map: ObservableObject {
    let size: CGSize
    @Published var cells: [Cell]
    @Published var clusters: [Cluster] = []
    let obstructions: [Obstruction]

    init(size: CGSize, cells: [Cell], obstructions: [Obstruction]) {
        self.size = size
        self.cells = cells
        self.obstructions = obstructions
    }

    func reset() {
        clusters = []
        for cell in cells {
            switch cell.type {
            case .player:
                cell.type = .default
            default: continue
            }
        }
    }
}
