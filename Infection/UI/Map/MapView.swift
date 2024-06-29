import SwiftUI

struct MapView: View {
    @ObservedObject var game: Game
    let action: (Cell) -> Void
    
    init(game: Game, action: @escaping (Cell) -> Void = { _ in }) {
        self.game = game
        self.action = action
    }

    var body: some View {
        Rectangle()
            .fill(Color(red: 0.1, green: 0.1, blue: 0.2))
            .frame(width: game.map.size.width * 50, height: game.map.size.height * 50)
            .overlay {
                ForEach(game.map.cells, id: \.coordinate) { cell in
                    CellView(
                        cell: cell,
                        isAvailable: game.availableCells.contains(cell),
                        isFogged: game.foggedCells.contains(cell),
                        action: action
                    )
                    .position(
                        x: 25 + CGFloat(cell.coordinate.x * 50), y: 25 + CGFloat(cell.coordinate.y * 50)
                    )
                }
            }
            .overlay {
                ForEach(game.map.obstructions, id: \.id) { obstruction in
                    ObstructionView(obstruction: obstruction)
                        .position(
                            x: CGFloat((obstruction.coordinates.0.x + obstruction.coordinates.1.x) * 25),
                            y: CGFloat((obstruction.coordinates.0.y + obstruction.coordinates.1.y) * 25)
                        )
                }
            }
    }
}

struct MapScrollView<Content: View>: UIViewRepresentable {
    @ViewBuilder private let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.bounces = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.alwaysBounceVertical = false
        let hostingController = UIHostingController(rootView: content())
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        context.coordinator.hostingController = hostingController
        scrollView.addSubview(hostingController.view)
        scrollView.delegate = context.coordinator
        scrollView.backgroundColor = .clear
        scrollView.isScrollEnabled = true
        scrollView.contentSize.width = hostingController.view.intrinsicContentSize.width
        scrollView.contentSize.height = hostingController.view.intrinsicContentSize.height
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }

    func updateUIView(_: UIScrollView, context: Context) {
        context.coordinator.setView(content())
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

extension MapScrollView {
    class Coordinator: NSObject, UIScrollViewDelegate {
        let parent: MapScrollView
        var hostingController: UIHostingController<Content>?
        var viewHeightConstraint: NSLayoutConstraint?

        init(parent: MapScrollView) {
            self.parent = parent
        }

        func setView(_ view: Content) {
            guard let hostingController else { return }
            hostingController.rootView = view
            let newSize = hostingController.view.sizeThatFits(CGSize(width: CGFloat.infinity, height: CGFloat.infinity))
            viewHeightConstraint?.isActive = false
            viewHeightConstraint = hostingController.view.heightAnchor.constraint(equalToConstant: newSize.height)
            viewHeightConstraint?.isActive = true
        }
    }
}
