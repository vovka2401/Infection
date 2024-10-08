import SwiftUI

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }

    func frame(size: CGSize) -> some View {
        frame(width: size.width, height: size.height)
    }

    func frame(side: CGFloat) -> some View {
        frame(width: side, height: side)
    }
}
