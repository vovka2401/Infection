import SwiftUI

class Game: ObservableObject {
    @Published var map: Map
    @Published var isOver = false
    @Published var availableCells: [Cell] = []
    @Published var foggedCells: [Cell] = []
    @Published var settings: GameSettings
    let players: [Player]
    var currentTurn: Turn

    init(map: Map, players: [Player], currentTurn: Turn, settings: GameSettings) {
        self.map = map
        self.players = players
        self.currentTurn = currentTurn
        self.settings = settings
        updateAvailableCells()
    }

    func restart() {
        isOver = false
        map = Map.testMap1
//        map.reset()
        currentTurn = Turn(player: players[0])
        updateAvailableCells()
    }

    func infectCell(_ cell: Cell) {
        let (player, playerCellType) = cell.getPlayerWithPlayerCellType()
        guard !cell.type.isPortal(), player != currentTurn.player, playerCellType != .constant,
              availableCells.contains(cell) else { return }
        removeCellFromClusters(cell)
        cell.infect(by: currentTurn.player)
        addCellToClusters(cell)
        currentTurn.step += 1
        updateCurrentTurn()
        objectWillChange.send()
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
        objectWillChange.send()
        map.objectWillChange.send()
        print(availableCells.map({ $0.coordinate }))
    }

    // TODO: we can look for either active clusters or active cells, which are connected to portals
    func isCellAvailable(cell: Cell) -> Bool {
        let currentPlayer = currentTurn.player
        let (player, playerCellType) = cell.getPlayerWithPlayerCellType()
        guard playerCellType == .temporary && player != currentPlayer || cell.type == .default else { return false }
        for cluster in map.clusters.filter({ $0.player == currentPlayer })
            where cluster.isBoundaryToCell(cell, obstructions: map.obstructions) {
            if isClusterActiveThroughPortals(cluster) {
                return true
            }
        }
        for temporaryCell in map.cells.filter({ $0.type == .player(currentPlayer, .temporary) }) {
            if temporaryCell.isBoundaryTo(cell, obstructions: map.obstructions) {
                return true
            }
        }
        for portal in map.cells.filter({ $0.type.isPortal() }) where portal.isBoundaryTo(
            cell,
            obstructions: map.obstructions
        ) {
            if isPortalActive(portal) {
                return true
            }
        }
        return false
    }

    func isClusterActiveThroughPortals(_ cluster: Cluster, excluding portals: [Cell] = []) -> Bool {
        if cluster.player == currentTurn.player, cluster.isActive {
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
                    if boundaryCellOfConnectedPortal.type.isPortal(),
                       isPortalActive(
                           boundaryCellOfConnectedPortal,
                           excluding: portals + [
                               portal, connectedPortal, boundaryCellOfConnectedPortal,
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
        guard let connectedPortal = getConnectedPortal(of: portal) else { return false }
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
            if boundaryCellOfConnectedPortal.type.isPortal(),
               isPortalActive(
                   boundaryCellOfConnectedPortal,
                   excluding: cells + [portal, connectedPortal, boundaryCellOfConnectedPortal]
               ) {
                return true
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
