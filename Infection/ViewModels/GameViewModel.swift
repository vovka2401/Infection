import GameKit
import SwiftUI
import Firebase

class GameViewModel: NSObject, ObservableObject, Codable {
    @Published var game: Game
    @Published var availableCells: [Cell] = []
    @Published var foggedCells: [Cell] = []
    private var gameObserver: UInt?
    
    init(game: Game) {
        self.game = game
    }

    func setup(isHost: Bool = false) {
        if isHost || game.settings.isLocalGame {
            setupPlayers()
            setupCells()
        } else {
            updateCells()
        }
        observeData()
        if isHost {
            sendData()
        }
    }
    
    func cleanup() {
        availableCells.removeAll()
        foggedCells.removeAll()
        removeObservers()
    }

    func infectCell(_ cell: Cell) {
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

    func restart() {
        game.restart()
        updateCells()
        sendData()
        objectWillChange.send()
    }

    func dismiss() {
        game.players.removeAll(where: { $0.id == GameManager.shared.localPlayer?.id })
        game.isOver = true
        sendData()
        Navigator.shared.dismissToMenuView {
            self.cleanup()
        }
    }
    
    private func updateCells() {
        updateAvailableCells()
        updateFoggedCells()
    }

    private func setupPlayers() {
        if game.settings.isLocalGame {
            game.players = game.map.getDefaultPlayers()
        } else {
            let playerColors = [Color.yellow, .blue, .green, .red, .purple, .orange, .mint, .brown]
            game.players.sort { $0.id < $1.id }
            for i in 0 ..< game.players.count {
                game.players[i].color = playerColors[i]
            }
        }
    }

    private func setupCells() {
        let defaultPlayers = game.map.getDefaultPlayers()
        guard defaultPlayers.count == game.players.count else { return }
        for i in 0 ..< defaultPlayers.count {
            let defaultPlayer = defaultPlayers[i]
            let defaultPlayerCells = game.map.cells.filter { $0.getPlayerWithPlayerCellType().player == defaultPlayer }
            for cell in defaultPlayerCells {
                guard var playerCellType = cell.getPlayerWithPlayerCellType().playerCellType else { return }
                if game.settings.gameWinMode == .infectMoreCells {
                    playerCellType = .temporary
                }
                game.map.cells[cell.coordinate]?.type = .player(game.players[i], playerCellType)
            }
        }
        game.defaultMap = game.map
        game.currentTurn = Turn(player: game.players[0])
        setRandomStepsCountIfNeeded()
        updateCells()
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
                && (boundaryCell.type == .player(game.currentTurn.player, .temporary)
                    || boundaryCell.type == .player(game.currentTurn.player, .base)) {
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
                    && (boundaryCell.type == .player(game.currentTurn.player, .temporary) || boundaryCell.type == .player(game.currentTurn.player, .base)) {
                    generalCluster.addCell(boundaryCell)
                }
                game.map.clusters.append(generalCluster)
            } else {
                var edgeCluster = edgeClusters[0]
                edgeCluster.addCell(cell)
                for boundaryCell in game.map.cells
                    where boundaryCell.isBoundaryTo(cell, obstructions: game.map.obstructions)
                    && (boundaryCell.type == .player(game.currentTurn.player, .temporary) || boundaryCell.type == .player(game.currentTurn.player, .base)) {
                    edgeCluster.addCell(boundaryCell)
                }
                addClusters([edgeCluster])
            }
        } else if (cell.type == .player(game.currentTurn.player, .temporary) || cell.type == .player(game.currentTurn.player, .base)) {
            for id in edgeClusters.map(\.id) {
                edgeClusters[id]?.addCell(cell)
            }
            addClusters(edgeClusters)
        }
    }

    private func updateCurrentTurn() {
        if game.currentTurn.step != game.settings.countOfStepsPerTurn + 1 {
            updateCells()
        }
        if game.currentTurn.step == game.settings.countOfStepsPerTurn + 1 || availableCells.isEmpty {
            selectNextPlayer()
            availableCells.removeAll()
            if game.settings.isLocalGame {
                updateCells()
            }
        }
        checkIfGameIsOver()
    }

    private func selectNextPlayer(startingIndex: Int? = nil) {
        if let playerIndex = game.players.firstIndex(where: { $0 == game.currentTurn.player }) {
            let nextPlayerIndex = playerIndex + 1 < game.players.count ? playerIndex + 1 : 0
            if nextPlayerIndex == 0, game.isFirstLap {
                game.isFirstLap = false
            }
            game.currentTurn = Turn(player: game.players[nextPlayerIndex])
            setRandomStepsCountIfNeeded()
            updateAvailableCells()
            if availableCells.isEmpty, startingIndex != playerIndex {
                selectNextPlayer(startingIndex: startingIndex ?? playerIndex)
            } else if let startingIndex, startingIndex == nextPlayerIndex {
                infectAllCells()
            }
        }
    }

    private func setRandomStepsCountIfNeeded() {
        guard game.settings.areRandomStepsEnabled else { return }
        game.settings.countOfStepsPerTurn = (0 ... 4).randomElement()! + (1 ... 4).randomElement()!
    }
    
    private func checkIfGameIsOver() {
        if game.settings.gameWinMode == .destroyBase {
            let baseCells = game.map.cells.filter({ $0.getPlayerWithPlayerCellType().playerCellType == .base })
            if baseCells.count == 1, let player = baseCells.first?.getPlayerWithPlayerCellType().player {
                game.winner = player
                game.isOver = true
            }
        }
        if availableCells.isEmpty, isLocalPlayersTurn() || game.settings.isLocalGame {
            chooseWinnerWithMoreCells()
            game.isOver = true
        }
    }
    
    private func chooseWinnerWithMoreCells() {
        var playersWithCellsCounts: [Player: Int] = [:]
        for player in game.players {
            let cellsCount = game.map.cells.filter({ $0.getPlayerWithPlayerCellType().player == player }).count
            playersWithCellsCounts[player] = cellsCount
        }
        let maxCellsCount = playersWithCellsCounts.map(\.value).max()
        let playersWithMaxCellsCount = playersWithCellsCounts.filter({ $0.value == maxCellsCount })
        if playersWithMaxCellsCount.count == 1,
           let winner = playersWithMaxCellsCount.keys.first {
            game.winner = winner
        }
    }

    private func updateAvailableCells() {
        availableCells = game.map.cells.filter { isCellAvailable(cell: $0) }
    }

    private func isCellAvailable(cell: Cell) -> Bool {
        let currentPlayer = game.currentTurn.player
        let (player, playerCellType) = cell.getPlayerWithPlayerCellType()
        guard cell.type == .default || playerCellType?.isActive == true && player != currentPlayer
                && !(game.isFirstLap && game.defaultMap.getActiveCells().contains(cell)) else { return false }
        for cluster in game.map.clusters.filter({ $0.player == currentPlayer })
            where cluster.isBoundaryToCell(cell, obstructions: game.map.obstructions) {
            if isClusterActiveThroughPortals(cluster) {
                return true
            }
        }
        for temporaryCell in game.map.cells.filter({ $0.type == .player(currentPlayer, .temporary) || $0.type == .player(currentPlayer, .base) }) {
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
        guard game.settings.isFogOfWarEnabled else { return }
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
        where infectedCell.getPlayerWithPlayerCellType().player == game.players.first(where: { $0.name == GKLocalPlayer.local.displayName }) {
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
                    if boundaryCellOfConnectedPortal.type == .player(game.currentTurn.player, .temporary) || boundaryCellOfConnectedPortal.type == .player(game.currentTurn.player, .base) {
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
            if boundaryCellOfConnectedPortal.type == .player(game.currentTurn.player, .temporary) || boundaryCellOfConnectedPortal.type == .player(game.currentTurn.player, .base) {
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
        game.currentTurn.player.id == GameManager.shared.localPlayer?.id
    }
    
    private func infectAllCells() {
        guard !availableCells.isEmpty else {
            chooseWinnerWithMoreCells()
            game.isOver = true
            return
        }
        for availableCell in availableCells {
            removeCellFromClusters(availableCell)
            var availableCell = availableCell
            availableCell.infect(by: game.currentTurn.player)
            game.map.cells[availableCell.coordinate] = availableCell
            addCellToClusters(availableCell)
        }
        updateCells()
        infectAllCells()
    }

    enum CodingKeys: String, CodingKey {
        case game
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(game, forKey: .game)
    }

    required convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let game = try values.decode(Game.self, forKey: .game)
        self.init(game: game)
    }
}

extension GameViewModel {
    private func sendData() {
        FirebaseManager.shared.sendGameData(game)
    }

    private func observeData() {
        if !game.settings.isLocalGame {
            gameObserver = FirebaseManager.shared.ref.child("lobbies").child(game.id).child("game").observe(.value) { [self] snapshot in
                if let stringData = snapshot.value as? String {
                    let data = Data(stringData.utf8)
                    do {
                        let game = try JSONDecoder().decode(Game.self, from: data)
                        withAnimation(.easeInOut) {
                            self.game = game
                        }
                        if isLocalPlayersTurn() {
                            updateCells()
                        } else {
                            availableCells.removeAll()
                        }
                        objectWillChange.send()
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    private func removeObservers() {
        if let gameObserver {
            FirebaseManager.shared.ref.child("lobbies").child(game.id).child("game").removeObserver(withHandle: gameObserver)
        }
    }
}
