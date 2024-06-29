import SwiftUI

struct Hexagon: Shape {
    func path(in rect: CGRect) -> Path {
        let centerX = rect.midX
        let centerY = rect.midY
        let radius = min(rect.width, rect.height) / 2
        let angle: CGFloat = .pi / 3

        var path = Path()

        for i in 0 ..< 6 {
            let x = centerX + radius * cos(CGFloat(i) * angle)
            let y = centerY + radius * sin(CGFloat(i) * angle)
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        path.closeSubpath()
        return path
    }
}
