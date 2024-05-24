import SwiftUI

struct MenuView: View {
    @ObservedObject var matchManager = MatchManager()

    var body: some View {
        Color.yellow
            .ignoresSafeArea()
            .overlay {
                Button {} label: {
                    Text("PLAY")
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

#Preview {
    MenuView(matchManager: MatchManager())
}
