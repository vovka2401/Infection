import SwiftUI

struct ContentView: View {
    @StateObject var matchManager = MatchManager()
//    @StateObject var game: Game

//    init() {
//        _game = StateObject(wrappedValue: ContentView.testGame)
//    }

    var body: some View {
        NavigationStack {
            ZStack {
                if matchManager.isGameOver {
                } else if matchManager.inGame {
//                GameView(game: game)
                } else {
//                MenuView(matchManager: matchManager)
                    MenuView()
                        .environmentObject(matchManager)
                }
            }
            .onAppear {
                matchManager.authentificateUser()
            }
        }
    }
}

#Preview {
    ContentView()
}
