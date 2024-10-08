import SwiftUI

struct SettingsBar: View {
    let action: (() -> Void)?

    var body: some View {
        HStack {
            Button {
                action?()
            } label: {
                RoundedRectangle(cornerRadius: 5)
                    .fill(.white)
                    .frame(width: 30, height: 30)
                    .overlay {
                        Image(systemName: "gearshape")
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(x: 0.6, y: 0.6)
                            .foregroundStyle(.black)
                    }
            }
            .padding(.leading, 20)
            Spacer()
        }
        .padding(.top, SafeAreaInsets.hasTop ? SafeAreaInsets.top : 15)
        .padding(.bottom, 10)
    }
}
