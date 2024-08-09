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

extension Hexagon {
    // Function to calculate the vertices of a hexagon
    static private func hexagonVertices(center: CellCoordinate, size: CGFloat) -> [CellCoordinate] {
        var vertices = [CellCoordinate]()
        for i in 0 ..< 6 {
            let angle = .pi / 6 + CGFloat(i) * .pi / 3
            let vertexX = center.x + size * cos(angle)
            let vertexY = center.y + size * sin(angle)
            vertices.append(CellCoordinate(x: vertexX, y: vertexY))
        }
        return vertices
    }

    // Function to check if a point is inside a polygon using ray-casting algorithm
    static private func isPointInPolygon(point: CellCoordinate, vertices: [CellCoordinate]) -> Bool {
        var isInside = false
        let n = vertices.count
        var j = n - 1
        
        for i in 0..<n {
            let vertexI = vertices[i]
            let vertexJ = vertices[j]
            
            if ((vertexI.y >= point.y) != (vertexJ.y >= point.y)) &&
                (point.x <= (vertexJ.x - vertexI.x) * (point.y - vertexI.y) / (vertexJ.y - vertexI.y) + vertexI.x) {
                isInside = !isInside
            }
            j = i
        }
        return isInside
    }

    // Function to check if a coordinate is inside a hexagon
    static func isCoordinateInsideHexagon(center: CellCoordinate, size: CGFloat, coordinate: CellCoordinate) -> Bool {
        let vertices = hexagonVertices(center: center, size: size)
        return isPointInPolygon(point: coordinate, vertices: vertices)
    }
}
