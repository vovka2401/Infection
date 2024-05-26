import SwiftUI

class Cluster: Equatable {
    var constantCells: [Cell] = []
    var temporaryCells: [Cell] = []
    var isActive: Bool { !temporaryCells.isEmpty }
    unowned var player: Player

    init(player: Player) {
        self.player = player
    }

    func merge(with other: Cluster) {
        constantCells += other.constantCells
        temporaryCells += other.temporaryCells.filter { !temporaryCells.contains($0) }
    }

    func addCell(_ cell: Cell) {
        switch cell.type {
        case let .player(_, playerCellType):
            if playerCellType == .constant {
                addConstantCell(cell)
            } else {
                addTemporaryCell(cell)
            }
        case .portal:
            addConstantCell(cell)
        default: break
        }
    }

    private func addConstantCell(_ cell: Cell) {
        guard !constantCells.contains(where: { $0 == cell }) else { return }
        constantCells.append(cell)
    }

    private func addTemporaryCell(_ cell: Cell) {
        guard !temporaryCells.contains(where: { $0 == cell }) else { return }
        temporaryCells.append(cell)
    }

    func removeTemporaryCell(_ cell: Cell) {
        temporaryCells.removeAll(where: { $0 == cell })
    }

    func isBoundaryToCell(_ cell: Cell, obstructions: [Obstruction] = []) -> Bool {
        constantCells.contains(where: { $0.isBoundaryTo(cell, obstructions: obstructions) })
    }

    static func == (lhs: Cluster, rhs: Cluster) -> Bool {
        lhs === rhs
    }
}
