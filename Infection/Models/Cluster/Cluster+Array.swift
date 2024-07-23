import Foundation

extension [Cluster] {
    subscript(id: UUID) -> Cluster? {
        get {
            guard let index = firstIndex(where: { $0.id == id }) else { return nil }
            return self[index]
        }
        set(newValue) {
            guard let index = firstIndex(where: { $0.id == id }), let newValue else { return }
            self[index] = newValue
        }
    }
}
