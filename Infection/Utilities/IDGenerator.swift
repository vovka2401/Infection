import Foundation

class IDGenerator {
    static let shared = IDGenerator()
    
    private init() {}
    
    func generateLobbyID() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0 ..< 4).map { _ in letters.randomElement()! })
    }
}
