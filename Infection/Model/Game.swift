import SwiftUI

class Game: ObservableObject {
    @Published var map: Map
    @Published var isOver = false
    let players: [Player]
    let settings = GameSettings()
    var currentTurn: Turn
    var availableCells: [Cell] = []

    init(map: Map, players: [Player], currentTurn: Turn) {
        self.map = map
        self.players = players
        self.currentTurn = currentTurn
        updateAvailableCells()
    }

    func restart() {
        isOver = false
        map.reset()
        currentTurn = Turn(player: players[0])
        updateAvailableCells()
    }

    func infectCell(_ cell: Cell) {
        let (player, playerCellType) = cell.getPlayerWithPlayerCellType()
        guard !cell.type.isPortal(), player != currentTurn.player, playerCellType != .constant else {
            return
        }
        if availableCells.contains(cell) {
            removeCellFromClusters(cell)
            cell.infect(by: currentTurn.player)
            addCellToClusters(cell)
            currentTurn.step += 1
            updateCurrentTurn()
            objectWillChange.send()
            return
        }
    }

    func updateCurrentTurn() {
        if currentTurn.step == settings.countOfStepsPerTurn + 1 {
            selectNextPlayer()
        }
        updateAvailableCells()
        if availableCells.isEmpty {
            isOver = true
        }
    }

    func selectNextPlayer() {
        if let playerIndex = players.firstIndex(where: { $0 == currentTurn.player }) {
            let nextPlayerIndex = playerIndex + 1 < players.count ? playerIndex + 1 : 0
            currentTurn = Turn(player: players[nextPlayerIndex])
        }
    }

    func updateAvailableCells() {
        availableCells = map.cells.filter { isCellAvailable(cell: $0) }
    }

    // TODO: we can look for either active clusters or active cells, which are connected to portals
    func isCellAvailable(cell: Cell) -> Bool {
        let currentPlayer = currentTurn.player
        let (player, playerCellType) = cell.getPlayerWithPlayerCellType()
        if playerCellType == .temporary && player != currentPlayer || cell.type == .default {
            for cluster in map.clusters.filter({ $0.player == currentPlayer })
                where cluster.isBoundaryToCell(cell, obstructions: map.obstructions)
                || isCellAvailableToClusterThroughPortals(cell: cell, cluster: cluster) {
                if isClusterActiveThroughPortals(cluster) {
                    return true
                }
            }
            for temporaryCell in map.cells.filter({ $0.type == .player(currentPlayer, .temporary) }) {
                if cell.isBoundaryTo(temporaryCell, obstructions: map.obstructions)
                    || isCellAvailableToCellThroughPortals(cell: cell, temporaryCell: temporaryCell) {
                    return true
                }
            }
        }
        return false
    }

    // TODO: implement
    func isCellConnectedWithCluster(cell _: Cell, cluster _: Cluster) -> Bool { false }

    // TODO: make portals not recursive to crash
    func isCellAvailableToClusterThroughPortals(cell: Cell, cluster: Cluster, excluding cells: [Cell] = []) -> Bool {
        if cluster.isBoundaryToCell(cell, obstructions: map.obstructions) {
            return true
        }
        var isAvailable = false
        for boundaryCell in map.cells.filter({ !cells.contains($0) && $0.isBoundaryTo(
            cell,
            obstructions: map.obstructions
        ) })
            where boundaryCell.type.isPortal() {
            if let connectedPortal = getConnectedPortal(of: boundaryCell) {
                isAvailable =
                    isCellAvailableToClusterThroughPortals(
                        cell: connectedPortal,
                        cluster: cluster,
                        excluding: cells + [boundaryCell, connectedPortal]
                    )
                    || isAvailable
            }
        }
        return isAvailable
    }

    // TODO: make portals not recursive to crash
    func isCellAvailableToCellThroughPortals(cell: Cell, temporaryCell: Cell) -> Bool {
        if temporaryCell.isBoundaryTo(cell, obstructions: map.obstructions) {
            return true
        }
        var isAvailable = false
        for boundaryCell in map.cells.filter({ $0.isBoundaryTo(cell, obstructions: map.obstructions) })
            where boundaryCell.type.isPortal() {
            if let connectedPortal = getConnectedPortal(of: boundaryCell) {
                isAvailable =
                    isCellAvailableToCellThroughPortals(cell: connectedPortal, temporaryCell: temporaryCell)
                        || isAvailable
            }
        }
        return isAvailable
    }

    func isClusterActiveThroughPortals(_ cluster: Cluster, excluding portals: [Cell] = []) -> Bool {
        if cluster.isActive {
            return true
        }
        for portal in map.cells.filter({ !portals.contains($0) })
            where portal.type.isPortal() && cluster.isBoundaryToCell(portal) {
            if let connectedPortal = getConnectedPortal(of: portal) {
                for boundaryClusterOfConnectedPortal in map.clusters.filter({
                    $0.isBoundaryToCell(connectedPortal, obstructions: map.obstructions)
                }) {
                    if isClusterActiveThroughPortals(
                        boundaryClusterOfConnectedPortal, excluding: portals + [portal, connectedPortal]
                    ) {
                        return true
                    }
                }
                for boundaryCellOfConnectedPortal in map.cells.filter({
                    $0.isBoundaryTo(connectedPortal, obstructions: map.obstructions)
                }) {
                    if boundaryCellOfConnectedPortal.type == .player(currentTurn.player, .temporary) {
                        return true
                    }
                    if let connectedPortalOfBoundaryCell = getConnectedPortal(
                        of: boundaryCellOfConnectedPortal
                    ),
                        isPortalActive(
                            connectedPortalOfBoundaryCell,
                            excluding: portals + [
                                portal, connectedPortal, boundaryCellOfConnectedPortal,
                                connectedPortalOfBoundaryCell,
                            ]
                        ) {
                        return true
                    }
                }
            }
        }
        return false
    }

    func isPortalActive(_ portal: Cell, excluding cells: [Cell] = []) -> Bool {
        if let connectedPortal = getConnectedPortal(of: portal) {
            for boundaryClusterOfConnectedPortal in map.clusters.filter({
                $0.isBoundaryToCell(connectedPortal, obstructions: map.obstructions)
            }) {
                if isClusterActiveThroughPortals(
                    boundaryClusterOfConnectedPortal, excluding: cells + [portal, connectedPortal]
                ) {
                    return true
                }
            }
            for boundaryCellOfConnectedPortal in map.cells.filter({
                !cells.contains($0) && $0.isBoundaryTo(connectedPortal, obstructions: map.obstructions)
            }) {
                if boundaryCellOfConnectedPortal.type == .player(currentTurn.player, .temporary) {
                    return true
                }
                if let connectedPortalOfBoundaryCell = getConnectedPortal(
                    of: boundaryCellOfConnectedPortal
                ),
                    isPortalActive(
                        connectedPortalOfBoundaryCell,
                        excluding: cells + [
                            portal, connectedPortal, boundaryCellOfConnectedPortal, connectedPortalOfBoundaryCell,
                        ]
                    ) {
                    return true
                }
            }
        }
        return false
    }

    func getConnectedPortal(of cell: Cell) -> Cell? {
        cell.type.isPortal() ? map.cells.first(where: { $0 != cell && $0.type == cell.type }) : nil
    }

    func removeCellFromClusters(_ cell: Cell) {
        let cellClusters = map.clusters.filter { $0.temporaryCells.contains(cell) }
        for cellCluster in cellClusters {
            cellCluster.removeTemporaryCell(cell)
        }
    }

    func addCellToClusters(_ cell: Cell) {
        let edgeClusters = map.clusters.filter {
            $0.isBoundaryToCell(cell, obstructions: map.obstructions) && $0.player == currentTurn.player
        }
        if edgeClusters.isEmpty, cell.type == .player(currentTurn.player, .constant) {
            let cluster = Cluster(player: currentTurn.player)
            cluster.addCell(cell)
            for boundaryCell in map.cells
                where boundaryCell.isBoundaryTo(cell, obstructions: map.obstructions)
                && boundaryCell.type == .player(currentTurn.player, .temporary) {
                cluster.addCell(boundaryCell)
            }
            map.clusters.append(cluster)
            debugPrint(map.clusters)
            return
        }
        if cell.type == .player(currentTurn.player, .constant) {
            if edgeClusters.count > 1 {
                let generalCluster = Cluster(player: currentTurn.player)
                for edgeCluster in edgeClusters {
                    generalCluster.merge(with: edgeCluster)
                    map.clusters.removeAll(where: { $0 == edgeCluster })
                }
                generalCluster.addCell(cell)
                map.clusters.append(generalCluster)
            } else {
                edgeClusters.first?.addCell(cell)
            }
        } else if cell.type == .player(currentTurn.player, .temporary) {
            for edgeCluster in edgeClusters {
                edgeCluster.addCell(cell)
            }
        }
        debugPrint(map.clusters)
    }

    func addCellToCluster(cell: Cell, cluster: Cluster) {
        cell.cluster = cluster
        cluster.addCell(cell)
    }
}

struct GameSettings {
    let maxCountOfPlayers: Int
    let countOfStepsPerTurn: Int

    init(maxCountOfPlayers: Int = 2, countOfStepsPerTurn: Int = 3) {
        self.maxCountOfPlayers = maxCountOfPlayers
        self.countOfStepsPerTurn = countOfStepsPerTurn
    }
}
