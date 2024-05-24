import SwiftUI

struct GameView: View {
    @ObservedObject var game: Game

    var body: some View {
        VStack {
            Spacer()
            Text("Step \(game.currentTurn.step) of \(game.currentTurn.player.name)")
                .font(.title)
                .bold()
                .animation(.easeInOut, value: game.currentTurn.step)
            Spacer()
            ScrollView([.horizontal]) {
                Rectangle()
                    .fill(Color(red: 0.1, green: 0.1, blue: 0.2))
                    .frame(width: game.map.size.width * 50, height: game.map.size.height * 50)
                    .overlay {
                        ForEach(game.map.cells, id: \.coordinate) { cell in
                            CellView(cell: cell)
                                .overlay {
                                    if game.availableCells.contains(cell) {
                                        Color.white.opacity(0.3)
                                    }
                                }
                                .position(
                                    x: 25 + CGFloat(cell.coordinate.x * 50), y: 25 + CGFloat(cell.coordinate.y * 50)
                                )
                                .onTapGesture {
                                    game.infectCell(cell)
                                }
                        }
                    }
                    .overlay {
                        ForEach(game.map.obstructions, id: \.id) { obstruction in
                            ObstructionView(obstruction: obstruction)
                                .position(
                                    x: CGFloat((obstruction.firstCoordinate.x + obstruction.secondCoordinate.x) * 25),
                                    y: CGFloat((obstruction.firstCoordinate.y + obstruction.secondCoordinate.y) * 25)
                                )
                        }
                    }
            }
            .frame(height: game.map.size.height * 50)
            Spacer()
        }
        .overlay {
            if game.isOver {
                Color.white.opacity(0.5)
            }
        }
        .animation(.easeInOut(duration: 2), value: game.isOver)
        .disabled(game.isOver)
        .overlay {
            if game.isOver {
                VStack {
                    Text("GAME OVER")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.green)
                    Button {
                        game.restart()
                    } label: {
                        Text("RESTART")
                    }
                }
            }
        }
        .ignoresSafeArea()
        .background(game.currentTurn.player.color)
        .animation(.easeInOut, value: game.currentTurn.player.color)
    }
}

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

struct ObstructionView: View {
    @State var obstruction: Obstruction
    var isVertical: Bool { obstruction.firstCoordinate.x == obstruction.secondCoordinate.x }

    // TODO: fix right size
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(.white)
            .frame(width: isVertical ? 5 : 45, height: isVertical ? 45 : 5)
    }
}

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
        // TODO: change finding method to availableCells
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

    func isCellAvailable(cell: Cell) -> Bool {
        let currentPlayer = currentTurn.player
        let (player, playerCellType) = cell.getPlayerWithPlayerCellType()
        if playerCellType == .temporary && player != currentPlayer || cell.type == .default {
            for cluster in map.clusters.filter({ $0.player == currentPlayer })
                where isClusterActiveThroughPortals(cluster) {
                if cluster.isBoundaryToCell(cell, obstructions: map.obstructions)
                    || isCellAvailableToClusterThroughPortals(cell: cell, cluster: cluster) {
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

    // TODO:
    func isCellConnectedWithCluster(cell _: Cell, cluster _: Cluster) -> Bool { false }

    // TODO: make portals not recursive to crash
    func isCellAvailableToClusterThroughPortals(cell: Cell, cluster: Cluster) -> Bool {
        if cluster.isBoundaryToCell(cell, obstructions: map.obstructions) {
            return true
        }
        var isAvailable = false
        for boundaryCell in map.cells.filter({ $0.isBoundaryTo(cell, obstructions: map.obstructions) })
            where boundaryCell.type.isPortal() {
            if let connectedPortal = getConnectedPortal(of: boundaryCell) {
                isAvailable =
                    isCellAvailableToClusterThroughPortals(cell: connectedPortal, cluster: cluster)
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

class Player: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var color: Color

    init(name: String, color: Color) {
        self.name = name
        self.color = color
    }

    static func == (lhs: Player, rhs: Player) -> Bool {
        lhs.id == rhs.id
    }
}

struct Turn {
    unowned let player: Player
    var step = 1
}

class Cell: ObservableObject, Equatable {
    let coordinate: CellCoordinate
    @Published var type: CellType
    weak var cluster: Cluster?

    init(coordinate: CellCoordinate, type: CellType = .default) {
        self.coordinate = coordinate
        self.type = type
    }

    func getPlayerWithPlayerCellType() -> (player: Player?, playerCellType: PlayerCellType?) {
        switch type {
        case .default, .portal:
            return (nil, nil)
        case let .player(player, playerCellType):
            return (player, playerCellType)
        }
    }

    func infect(by player: Player) {
        switch type {
        case .default:
            type = .player(player, .temporary)
        case .player(_, .temporary):
            type = .player(player, .constant)
        default: return
        }
    }

    func isBoundaryTo(_ other: Cell, obstructions: [Obstruction] = []) -> Bool {
        !obstructions.contains(
            where: {
                ($0.firstCoordinate + $0.secondCoordinate) == other.coordinate + self.coordinate
                    + CellCoordinate(x: 1, y: 1)
            }
        ) && coordinate.isBoundaryTo(other.coordinate)
    }

    static func == (lhs: Cell, rhs: Cell) -> Bool {
        lhs.self === rhs.self
    }
}

class Cluster: Equatable {
    var constantCells: [Cell] = []
    var temporaryCells: [Cell] = []
    var isActive: Bool { !temporaryCells.isEmpty }
    unowned var player: Player

    init(player: Player) {
        self.player = player
    }

    // TODO: rework
    func merge(with other: Cluster) {
        constantCells += other.constantCells
        temporaryCells += other.temporaryCells
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

struct Obstruction: Identifiable, Equatable {
    let id = UUID()
    let firstCoordinate: CellCoordinate
    let secondCoordinate: CellCoordinate
}

enum CellType: Equatable {
    case `default`
    case portal(Int)
    case player(Player, PlayerCellType)

    func isPortal() -> Bool {
        switch self {
        case .portal: return true
        default: return false
        }
    }

    func portalNumber() -> Int? {
        switch self {
        case let .portal(number): return number
        default: return nil
        }
    }

    static func == (lhs: CellType, rhs: CellType) -> Bool {
        switch (lhs, rhs) {
        case (.default, .default): return true
        case let (.portal(portal1), .portal(portal2)): return portal1 == portal2
        case let (.player(player1, type1), .player(player2, type2)):
            return player1 == player2 && type1 == type2
        default: return false
        }
    }
}

enum PlayerCellType {
    case temporary
    case constant
}

struct CellCoordinate: Equatable, Hashable {
    var x: Int
    var y: Int

    static func + (lhs: CellCoordinate, rhs: CellCoordinate) -> CellCoordinate {
        CellCoordinate(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}

extension CellCoordinate {
    func isBoundaryTo(_ other: Self) -> Bool {
        x == other.x && abs(y - other.y) == 1
            || y == other.y && abs(x - other.x) == 1
    }
}

struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: ZoomableScrollView

        init(parent: ZoomableScrollView) {
            self.parent = parent
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            scrollView.subviews.first
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            guard let imageView = scrollView.subviews.first else { return }
            let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0)
            let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0)
            imageView.center = CGPoint(
                x: scrollView.contentSize.width * 0.5 + offsetX,
                y: scrollView.contentSize.height * 0.5 + offsetY
            )
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.scrollsToTop = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false

        let hostedView = UIHostingController(rootView: content)
        hostedView.view.translatesAutoresizingMaskIntoConstraints = false
        hostedView.view.backgroundColor = .clear
        scrollView.addSubview(hostedView.view)

        NSLayoutConstraint.activate([
            hostedView.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostedView.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hostedView.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostedView.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            //            hostedView.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            //            hostedView.view.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])

        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context _: Context) {
        if let hostedView = uiView.subviews.first as? UIHostingController<Content> {
            hostedView.rootView = content
        }
    }
}
