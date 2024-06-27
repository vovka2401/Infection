import SwiftUI

struct MenuView: View {
    @EnvironmentObject var matchManager: MatchManager

    var body: some View {
        Color.yellow
            .ignoresSafeArea()
            .overlay {
                VStack(spacing: 30) {
                    NavigationLink {
                        CreateGameView()
                    } label: {
                        Text("Create Game")
                            .fontWeight(.semibold)
                            .frame(height: 50)
                            .padding(.horizontal, 30)
                            .background {
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.white)
                            }
                    }
                    NavigationLink {
                        CreateGameView()
                    } label: {
                        Text("Join Game")
                            .fontWeight(.semibold)
                            .frame(height: 50)
                            .padding(.horizontal, 30)
                            .background {
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.white)
                            }
                    }
                }
            }
    }
}

#Preview {
    MenuView().environmentObject(MatchManager())
}
