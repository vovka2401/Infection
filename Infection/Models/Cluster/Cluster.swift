import SwiftUI

struct Cluster: Identifiable {
    let id: UUID
    var constantCells: [Cell] = []
    var temporaryCells: [Cell] = []
    var player: Player
    var isActive: Bool { !temporaryCells.isEmpty }

    init(id: UUID = UUID(), player: Player) {
        self.id = id
        self.player = player
    }

    mutating func addCell(_ cell: Cell) {
        switch cell.type {
        case let .player(_, playerCellType):
            if playerCellType == .constant {
                addConstantCell(cell)
            } else if playerCellType.isActive {
                addTemporaryCell(cell)
            }
        case .portal:
            addConstantCell(cell)
        default: break
        }
    }

    mutating func removeTemporaryCell(_ cell: Cell) {
        temporaryCells.removeAll(where: { $0 == cell })
    }

    mutating func merge(with other: Cluster) {
        constantCells += other.constantCells
        temporaryCells += other.temporaryCells.filter { !temporaryCells.contains($0) }
    }

    func isBoundaryToCell(_ cell: Cell, obstructions: [Obstruction] = []) -> Bool {
        constantCells.contains(where: { $0.isBoundaryTo(cell, obstructions: obstructions) })
    }

    private mutating func addConstantCell(_ cell: Cell) {
        guard !constantCells.contains(where: { $0 == cell }) else { return }
        constantCells.append(cell)
    }

    private mutating func addTemporaryCell(_ cell: Cell) {
        guard !temporaryCells.contains(where: { $0 == cell }) else { return }
        temporaryCells.append(cell)
    }
}

extension Cluster: Equatable {
    static func == (lhs: Cluster, rhs: Cluster) -> Bool {
        lhs.id == rhs.id
    }
}

extension Cluster: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case constantCells
        case temporaryCells
        case player
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(constantCells, forKey: .constantCells)
        try container.encode(temporaryCells, forKey: .temporaryCells)
        try container.encode(player, forKey: .player)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let id = try values.decode(UUID.self, forKey: .id)
        let constantCells = try values.decode([Cell].self, forKey: .constantCells)
        let temporaryCells = try values.decode([Cell].self, forKey: .temporaryCells)
        let player = try values.decode(Player.self, forKey: .player)
        self.init(id: id, player: player)
        self.constantCells = constantCells
        self.temporaryCells = temporaryCells
    }
}
