import SwiftUI

struct MenuView: View {
    @EnvironmentObject var menuViewModel: MenuViewModel
    @EnvironmentObject var navigator: Navigator

    var body: some View {
        Image("background2")
            .resizable()
            .frame(size: Screen.size)
            .overlay {
                Color.white.opacity(0.25)
                    .frame(size: Screen.size)
            }
            .ignoresSafeArea()
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.orange.opacity(0.8))
                    .frame(width: 300, height: 300)
                    .overlay {
                        VStack(spacing: 30) {
                            Button {
                                navigator.pushCreateGameView(isLocalGame: false)
                            } label: {
                                Text("Create Game")
                                    .fontWeight(.semibold)
                                    .frame(height: 50)
                                    .padding(.horizontal, 30)
                                    .background {
                                        RoundedRectangle(cornerRadius: 25)
                                            .fill(Color.white)
                                    }
                                    .overlay {
                                        if !menuViewModel.gameCenterManager.isAuthenticated {
                                            RoundedRectangle(cornerRadius: 25)
                                                .fill(Color.black.opacity(0.4))
                                        }
                                    }
                            }
                            .disabled(!menuViewModel.gameCenterManager.isAuthenticated)
                            Button {
                                navigator.pushJoinGameView()
                            } label: {
                                Text("Join Game")
                                    .fontWeight(.semibold)
                                    .frame(height: 50)
                                    .padding(.horizontal, 30)
                                    .background {
                                        RoundedRectangle(cornerRadius: 25)
                                            .fill(Color.white)
                                    }
                                    .overlay {
                                        if !menuViewModel.gameCenterManager.isAuthenticated {
                                            RoundedRectangle(cornerRadius: 25)
                                                .fill(Color.black.opacity(0.4))
                                        }
                                    }
                            }
                            .disabled(!menuViewModel.gameCenterManager.isAuthenticated)
                            Button {
                                navigator.pushCreateGameView(isLocalGame: true)
                            } label: {
                                Text("Local Game")
                                    .fontWeight(.semibold)
                                    .frame(height: 50)
                                    .padding(.horizontal, 30)
                                    .background {
                                        RoundedRectangle(cornerRadius: 25)
                                            .fill(Color.white)
                                    }
                            }
                            .animation(.easeInOut, value: menuViewModel.gameCenterManager.isAuthenticated)
                        }
                    }
            }
    }
}
