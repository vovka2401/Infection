import Foundation

extension [Cell] {
    subscript(coordinate: CellCoordinate) -> Cell? {
        get {
            guard let index = firstIndex(where: { $0.coordinate == coordinate }) else { return nil }
            return self[index]
        }
        set(newValue) {
            guard let index = firstIndex(where: { $0.coordinate == coordinate }), let newValue else { return }
            self[index] = newValue
        }
    }
}
