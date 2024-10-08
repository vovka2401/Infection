import SwiftUI

struct AlertView: View {
    let message: String
    let onAccept: () -> Void
    let onDecline: (() -> Void)?
    
    var body: some View {
        Color.black.opacity(0.2)
            .overlay {
                VStack(spacing: 30) {
                    Text(message)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .font(.title)
                        .foregroundStyle(Color.black)
                    HStack(spacing: 0) {
                        if let onDecline {
                            Button(action: onDecline) {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color(white: 0.8))
                                    .frame(height: 30)
                                    .overlay {
                                        Text(L10n.no.text)
                                            .font(.subheadline)
                                            .foregroundStyle(Color.black)
                                    }
                                    .padding(.trailing, 10)
                            }
                        }
                        Button(action: onAccept) {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color(white: 0.8))
                                .frame(height: 30)
                                .overlay {
                                    Text(L10n.yes.text)
                                        .font(.subheadline)
                                        .foregroundStyle(Color.black)
                                }
                        }
                    }
                }
                .padding(10)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                }
                .frame(width: Screen.width * 0.7)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .navigationBarBackButtonHidden()
                .transition(.opacity)
            }
    }
}
