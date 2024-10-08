import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import AuthenticationServices

class AuthViewModel: NSObject, ObservableObject {
    
    enum SignInState {
        case signedIn
        case signedOut
    }
    
    @Published var state: SignInState = .signedOut
    @Published var errorMessage: String = ""

    func login(email: String, password: String) async {
        await signInWithEmail(email: email, password: password)
    }

    @MainActor
    func signInWithEmail(email: String, password: String) async {
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            self.state = .signedIn
            UserDefaults.standard.isLoggedIn = true
        }
        catch {
            print(error.localizedDescription)
            self.errorMessage = error.localizedDescription
        }
    }

    @MainActor
    func signUp(displayName: String, email: String, password: String) async {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error {
                print(error)
                self.errorMessage = error.localizedDescription
            } else {
                if let currentUser = Auth.auth().currentUser?.createProfileChangeRequest() {
                    currentUser.displayName = displayName
                    currentUser.commitChanges { error in
                        if let error {
                            print(error)
                        } else {
                            UserDefaults.standard.isLoggedIn = true
                            GameManager.shared.authentificatePlayer()
                            self.state = .signedIn
                        }
                    }
                }
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.state = .signedOut
            UserDefaults.standard.isLoggedIn = false
            GameManager.shared.localPlayer = nil
        } catch {
            print(error.localizedDescription)
        }
    }
}
