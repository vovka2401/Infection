import SwiftUI
import Firebase

struct MenuView: View {
    @EnvironmentObject var menuViewModel: MenuViewModel
    @EnvironmentObject var navigator: Navigator
    @EnvironmentObject var authViewModel: AuthViewModel

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
                .frame(width: 300, height: 400)
                .overlay {
                    VStack(spacing: 30) {
                        menuButton(title: L10n.createLobby.text) {
                            navigator.pushCreateLobbyView(isLocalGame: false)
                        }
                        menuButton(title: L10n.joinLobby.text) {
                            navigator.pushLobbiesView()
                        }
                        menuButton(title: L10n.localGame.text) {
                            navigator.pushCreateLobbyView(isLocalGame: true)
                        }
                        menuButton(title: L10n.signOut.text) {
                            authViewModel.signOut()
                        }
                    }
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
