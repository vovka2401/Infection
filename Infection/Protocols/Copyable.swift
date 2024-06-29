import Foundation

protocol Copyable where Element: Copyable {
    associatedtype Element
    func copy() -> Element
}
