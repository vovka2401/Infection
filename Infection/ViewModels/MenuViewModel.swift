import Foundation
import GameKit
import SwiftUI
import Firebase

class MenuViewModel: ObservableObject {
    @Published var gameViewModel: GameViewModel!
    @Published var wasTutorialShown = UserDefaults.standard.wasTutorialShown
}
