import SwiftUI

struct LoginView: View {
    @State private var selectedAuthLoginState = AuthLoginState.login
    @State private var displayName: String = ""
    @State private var emailAddress: String = ""
    @State private var password: String = ""
    @State private var showAuthLoader: Bool = false
    @State private var showInvalidPWAlert: Bool = false
    @State private var isAuthenticated: Bool = false
    @FocusState private var displayNameIsFocused: Bool
    @FocusState private var emailIsFocused: Bool
    @FocusState private var passwordIsFocused: Bool
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            NavigationLink("", value: isAuthenticated)
            Picker("View State", selection: $selectedAuthLoginState) {
                Text(L10n.login.text).tag(AuthLoginState.login)
                Text(L10n.register.text).tag(AuthLoginState.register)
            }
            .foregroundStyle(Color.white)
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: Screen.width - 40)
            .padding(.bottom, 10)
            VStack {
                if selectedAuthLoginState == .register {
                    TextField(L10n.name.text, text: $displayName)
                        .withLoginStyles()
                        .autocapitalization(.none)
                        .textInputAutocapitalization(.never)
                        .textContentType(.username)
                        .keyboardType(.default)
                        .submitLabel(.next)
                        .focused($displayNameIsFocused)
                }
                TextField(L10n.emailAddress.text, text: $emailAddress)
                    .withLoginStyles()
                    .autocapitalization(.none)
                    .textInputAutocapitalization(.never)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .submitLabel(.next)
                    .focused($emailIsFocused)
                SecureField(L10n.password.text, text: $password)
                    .withSecureFieldStyles()
                    .submitLabel(.next)
                    .focused($passwordIsFocused)
                if selectedAuthLoginState == .login {
                    LoginButton(
                        showAuthLoader: $showAuthLoader,
                        showInvalidPWAlert: $showInvalidPWAlert,
                        isAuthenticated: $isAuthenticated,
                        text: L10n.signIn.text
                    ) {
                        await authViewModel.login(email: emailAddress, password: password)
                    }
                } else {
                    LoginButton(
                        showAuthLoader: $showAuthLoader,
                        showInvalidPWAlert: $showInvalidPWAlert,
                        isAuthenticated: $isAuthenticated,
                        text: L10n.createAccount.text
                    ) {
                        await authViewModel.signUp(displayName: displayName, email: emailAddress, password: password)
                    }
                }
            }
            .padding()
        }
        .animation(.easeInOut, value: selectedAuthLoginState)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .overlay {
            if showAuthLoader {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .frame(size: Screen.size)
                    .overlay {
                        ProgressView()
                            .scaleEffect(x: 2, y: 2)
                    }
            }
        }
        .onChange(of: authViewModel.state) { newValue in
            if newValue == .signedIn {
                isAuthenticated = true
            } else {
                showInvalidPWAlert = true
            }
        }
    }
}

enum AuthLoginState {
    case login
    case register
}
