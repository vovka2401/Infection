import SwiftUI
import FirebaseAuth

struct LoginButton: View {
    @Binding var showAuthLoader: Bool
    @Binding var showInvalidPWAlert: Bool
    @Binding var isAuthenticated: Bool
    let text: String
    let action: () async -> Void
    
    var body: some View {
        Button {
            showAuthLoader = true
            Task {
                await action()
                showAuthLoader = false
            }
        } label: {
            Text(text)
                .withButtonStyles()
                .alert(isPresented: $showInvalidPWAlert) {
                    Alert(title: Text(L10n.errorMessage.text))
                }
        }
    }
}
