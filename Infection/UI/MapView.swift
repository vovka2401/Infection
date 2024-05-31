import SwiftUI

struct MapView<Content: View>: UIViewRepresentable {
    @ViewBuilder private let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = MapUIScrollView()
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

extension MapView {
    class Coordinator: NSObject, UIScrollViewDelegate {
        let parent: MapView
        var hostingController: UIHostingController<Content>?
        var viewHeightConstraint: NSLayoutConstraint?

        init(parent: MapView) {
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

class MapUIScrollView: UIScrollView {
    var targetOffset: CGPoint?

    override func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        if animated {
            targetOffset = contentOffset
        }
        super.setContentOffset(contentOffset, animated: animated)
    }
}
