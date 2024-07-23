import GameKit
import SwiftUI

class GameViewModel: NSObject, ObservableObject, Codable {
    @Published var match: GKMatch?
    @Published var game: Game!
    @Published var availableCells: [Cell] = []
    @Published var foggedCells: [Cell] = []
    var settings: GameSettings
    var onDismiss: (() -> Void)?

    init(game: Game, settings: GameSettings) {
        self.game = game
        self.settings = settings
    }

    func setup() {
        setupPlayers()
        setupCells()
        sendData()
    }

    func infectCell(_ cell: Cell) {
        let (player, playerCellType) = cell.getPlayerWithPlayerCellType()
        guard !cell.type.isPortal(), player != game.currentTurn.player, playerCellType != .constant,
              availableCells.contains(cell) else { return }
        removeCellFromClusters(cell)
        var cell = cell
        cell.infect(by: game.currentTurn.player)
        game.map.cells[cell.coordinate] = cell
        addCellToClusters(cell)
        game.currentTurn.step += 1
        updateCurrentTurn()
        sendData()
        objectWillChange.send()
    }

    func updateCells() {
        updateAvailableCells()
        updateFoggedCells()
    }

    func restart() {
        match?.rematch()
        game.isOver = false
        game.map = game.defaultMap
        game.currentTurn = Turn(player: game.players[0])
        updateCells()
        sendData()
        objectWillChange.send()
    }

    func dismiss() {
        Navigator.shared.dismiss {
            self.onDismiss?()
        }
    }

    private func setupPlayers() {
        if settings.isLocalGame {
            game.players = getDefaultPlayers()
        } else {
            let playerColors = [Color.yellow, .blue, .green, .red, .purple, .orange, .mint, .brown]
            guard var playerNames = match?.players.map(\.displayName) else { return }
            playerNames = [GKLocalPlayer.local.displayName] + playerNames
            playerNames.sort { $0 < $1 }
            game.players.removeAll()
            for i in 0 ..< playerNames.count {
                game.players.append(Player(name: playerNames[i], color: playerColors[i]))
            }
        }
    }

    private func getDefaultPlayers() -> [Player] {
        Array(Set(game.map.cells.compactMap { $0.getPlayerWithPlayerCellType().player })).sorted { $0.name < $1.name }
    }

    private func setupCells() {
        let defaultPlayers = getDefaultPlayers()
        guard defaultPlayers.count == game.players.count else { return }
        for i in 0 ..< defaultPlayers.count {
            let defaultPlayer = defaultPlayers[i]
            let defaultPlayerCells = game.map.cells.filter { $0.getPlayerWithPlayerCellType().player == defaultPlayer }
            for cell in defaultPlayerCells {
                guard let playerCellType = cell.getPlayerWithPlayerCellType().playerCellType else { return }
                game.map.cells[cell.coordinate]?.type = .player(game.players[i], playerCellType)
            }
        }
        game.currentTurn = Turn(player: game.players[0])
    }

    private func removeCellFromClusters(_ cell: Cell) {
        var cellClusters = game.map.clusters.filter { $0.temporaryCells.contains(cell) }
        for id in cellClusters.map(\.id) {
            cellClusters[id]?.removeTemporaryCell(cell)
        }
        addClusters(cellClusters)
    }

    private func addCellToClusters(_ cell: Cell) {
        var edgeClusters = game.map.clusters.filter {
            $0.isBoundaryToCell(cell, obstructions: game.map.obstructions) && $0.player == game.currentTurn.player
        }
        if edgeClusters.isEmpty, cell.type == .player(game.currentTurn.player, .constant) {
            var cluster = Cluster(player: game.currentTurn.player)
            cluster.addCell(cell)
            for boundaryCell in game.map.cells
                where boundaryCell.isBoundaryTo(cell, obstructions: game.map.obstructions)
                && boundaryCell.type == .player(game.currentTurn.player, .temporary) {
                cluster.addCell(boundaryCell)
            }
            game.map.clusters.append(cluster)
            return
        }
        if cell.type == .player(game.currentTurn.player, .constant) {
            if edgeClusters.count > 1 {
                var generalCluster = Cluster(player: game.currentTurn.player)
                for edgeCluster in edgeClusters {
                    generalCluster.merge(with: edgeCluster)
                    game.map.clusters.removeAll(where: { $0 == edgeCluster })
                }
                generalCluster.addCell(cell)
                for boundaryCell in game.map.cells
                    where boundaryCell.isBoundaryTo(cell, obstructions: game.map.obstructions)
                    && boundaryCell.type == .player(game.currentTurn.player, .temporary) {
                    generalCluster.addCell(boundaryCell)
                }
                game.map.clusters.append(generalCluster)
            } else {
                var edgeCluster = edgeClusters[0]
                edgeCluster.addCell(cell)
                for boundaryCell in game.map.cells
                    where boundaryCell.isBoundaryTo(cell, obstructions: game.map.obstructions)
                    && boundaryCell.type == .player(game.currentTurn.player, .temporary) {
                    edgeCluster.addCell(boundaryCell)
                }
                addClusters([edgeCluster])
            }
        } else if cell.type == .player(game.currentTurn.player, .temporary) {
            for id in edgeClusters.map(\.id) {
                edgeClusters[id]?.addCell(cell)
            }
            addClusters(edgeClusters)
        }
    }

    private func updateCurrentTurn() {
        if game.currentTurn.step == settings.countOfStepsPerTurn + 1 {
            selectNextPlayer()
            availableCells.removeAll()
            if settings.isLocalGame {
                updateCells()
            }
        } else {
            updateCells()
        }
        if availableCells.isEmpty, isLocalPlayersTurn() || settings.isLocalGame {
            game.isOver = true
        }
    }

    private func selectNextPlayer() {
        if let playerIndex = game.players.firstIndex(where: { $0 == game.currentTurn.player }) {
            let nextPlayerIndex = playerIndex + 1 < game.players.count ? playerIndex + 1 : 0
            game.currentTurn = Turn(player: game.players[nextPlayerIndex])
        }
    }

    private func updateAvailableCells() {
        availableCells = game.map.cells.filter { isCellAvailable(cell: $0) }
    }

    private func isCellAvailable(cell: Cell) -> Bool {
        let currentPlayer = game.currentTurn.player
        let (player, playerCellType) = cell.getPlayerWithPlayerCellType()
        guard playerCellType == .temporary && player != currentPlayer || cell.type == .default else { return false }
        for cluster in game.map.clusters.filter({ $0.player == currentPlayer })
            where cluster.isBoundaryToCell(cell, obstructions: game.map.obstructions) {
            if isClusterActiveThroughPortals(cluster) {
                return true
            }
        }
        for temporaryCell in game.map.cells.filter({ $0.type == .player(currentPlayer, .temporary) }) {
            if temporaryCell.isBoundaryTo(cell, obstructions: game.map.obstructions) {
                return true
            }
        }
        for portal in game.map.cells.filter({ $0.type.isPortal() }) where portal.isBoundaryTo(
            cell,
            obstructions: game.map.obstructions
        ) {
            if isPortalActive(portal) {
                return true
            }
        }
        return false
    }

    private func updateFoggedCells() {
        guard settings.isFogOfWarEnabled else { return }
        foggedCells = game.map.cells.filter { isCellFogged(cell: $0) }
    }

    private func isCellFogged(cell: Cell, minimalDistance: Double = 3, arePortalsIncluded: Bool = true) -> Bool {
        if arePortalsIncluded {
            for boundaryPortal in game.map.cells where cell.isBoundaryTo(boundaryPortal) {
                if let connectedPortal = getConnectedPortal(of: boundaryPortal), !isCellFogged(
                    cell: connectedPortal,
                    minimalDistance: minimalDistance - 1,
                    arePortalsIncluded: false
                ) {
                    return false
                }
            }
        }
        for infectedCell in game.map.cells
            where infectedCell.getPlayerWithPlayerCellType().player == game.currentTurn.player {
            if cell.coordinate.distance(to: infectedCell.coordinate) <= minimalDistance {
                return false
            }
        }
        return true
    }

    private func isClusterActiveThroughPortals(_ cluster: Cluster, excluding portals: [Cell] = []) -> Bool {
        if cluster.player == game.currentTurn.player, cluster.isActive {
            return true
        }
        for portal in game.map.cells.filter({ !portals.contains($0) })
            where portal.type.isPortal() && cluster.isBoundaryToCell(portal) {
            if let connectedPortal = getConnectedPortal(of: portal) {
                for boundaryClusterOfConnectedPortal in game.map.clusters.filter({
                    $0.isBoundaryToCell(connectedPortal, obstructions: game.map.obstructions)
                }) {
                    if isClusterActiveThroughPortals(
                        boundaryClusterOfConnectedPortal, excluding: portals + [portal, connectedPortal]
                    ) {
                        return true
                    }
                }
                for boundaryCellOfConnectedPortal in game.map.cells.filter({
                    $0.isBoundaryTo(connectedPortal, obstructions: game.map.obstructions)
                }) {
                    if boundaryCellOfConnectedPortal.type == .player(game.currentTurn.player, .temporary) {
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

    private func isPortalActive(_ portal: Cell, excluding cells: [Cell] = []) -> Bool {
        guard let connectedPortal = getConnectedPortal(of: portal) else { return false }
        for boundaryClusterOfConnectedPortal in game.map.clusters.filter({
            $0.isBoundaryToCell(connectedPortal, obstructions: game.map.obstructions)
        }) {
            if isClusterActiveThroughPortals(
                boundaryClusterOfConnectedPortal, excluding: cells + [portal, connectedPortal]
            ) {
                return true
            }
        }
        for boundaryCellOfConnectedPortal in game.map.cells.filter({
            !cells.contains($0) && $0.isBoundaryTo(connectedPortal, obstructions: game.map.obstructions)
        }) {
            if boundaryCellOfConnectedPortal.type == .player(game.currentTurn.player, .temporary) {
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

    private func getConnectedPortal(of cell: Cell) -> Cell? {
        cell.type.isPortal() ? game.map.cells.first(where: { $0 != cell && $0.type == cell.type }) : nil
    }

    private func addClusters(_ clusters: [Cluster]) {
        for id in clusters.map(\.id) {
            game.map.clusters[id] = clusters[id]
        }
    }

    private func isLocalPlayersTurn() -> Bool {
        game.currentTurn.player.name == GKLocalPlayer.local.displayName
    }

    enum CodingKeys: String, CodingKey {
        case game
        case settings
    }

    func encode(to encoder: Encoder) throws {
        guard let game else { return }
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(game, forKey: .game)
        try container.encode(settings, forKey: .settings)
    }

    required convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let game = try values.decode(Game.self, forKey: .game)
        let settings = try values.decode(GameSettings.self, forKey: .settings)
        self.init(game: game, settings: settings)
    }
}

extension GameViewModel: GKMatchDelegate {
    private func sendData() {
        guard !settings.isLocalGame, let match else { return }
        do {
            guard let data = try? JSONEncoder().encode(game) else { return }
            try match.sendData(toAllPlayers: data, with: .reliable)
        } catch {
            print("Failed to send data: \(error.localizedDescription)")
        }
    }

    func match(_: GKMatch, didReceive data: Data, fromRemotePlayer _: GKPlayer) {
        do {
            let game = try JSONDecoder().decode(Game.self, from: data)
            self.game = game
            if isLocalPlayersTurn() {
                updateCells()
                if availableCells.isEmpty, !self.game.isOver {
                    self.game.isOver = true
                    sendData()
                }
            } else {
                availableCells.removeAll()
            }
            objectWillChange.send()
        } catch {
            print("Failed to receive data: \(error.localizedDescription)")
        }
    }
}
