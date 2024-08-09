import SwiftUI

struct MenuView: View {
    @EnvironmentObject var menuViewModel: MenuViewModel
    @EnvironmentObject var navigator: Navigator

    var body: some View {
        ZStack {
            Image("background2")
                .resizable()
                .frame(size: Screen.size)
                .overlay {
                    Color.white.opacity(0.25)
                        .frame(size: Screen.size)
                }
                .ignoresSafeArea()
            RoundedRectangle(cornerRadius: 10)
                .fill(.white.opacity(0.7))
                .frame(width: 300, height: 300)
                .overlay {
                    VStack(spacing: 30) {
                        menuButton(title: L10n.createGame.text, isDisabled: !menuViewModel.gameCenterManager.isAuthenticated) {
                            navigator.pushCreateGameView(isLocalGame: false)
                        }
                        menuButton(title: L10n.joinGame.text, isDisabled: !menuViewModel.gameCenterManager.isAuthenticated) {
                            navigator.pushJoinGameView()
                        }
                        menuButton(title: L10n.localGame.text) {
                            navigator.pushCreateGameView(isLocalGame: true)
                        }
                    }
                    .animation(.easeInOut, value: menuViewModel.gameCenterManager.isAuthenticated)
                }
        }
    }
    
    func menuButton(title: String, isDisabled: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 20)
                .fill(.orange)
                .frame(width: 250, height: 60)
                .overlay {
                    Text(title)
                        .bold()
                        .foregroundStyle(.white)
                }
                .shadow(color: .orange, radius: isDisabled ? 0 : 2)
                .overlay {
                    if isDisabled {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.20))
                            .frame(width: 250, height: 60)
                    }
                }
        }
        .disabled(isDisabled)
    }
}
