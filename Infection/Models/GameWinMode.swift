import Foundation

enum GameWinMode: String, CaseIterable, Codable {
    case infectMoreCells
    case destroyBase
    
    var title: String {
        switch self {
        case .infectMoreCells:
            L10n.modeTitle1.text
        case .destroyBase:
            L10n.modeTitle2.text
        }
    }

    var description: String {
        switch self {
        case .infectMoreCells:
            L10n.modeDescription1.text
        case .destroyBase:
            L10n.modeDescription2.text
        }
    }
    
}
