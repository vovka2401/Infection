import Foundation

enum PlayerAuthState: String {
    case authentificating = "Logging in to Game Center ..."
    case unauthentificated = "Please sign in to Game Center to play."
    case authentificated = ""

    case error = "There was an error logging into Game Center."
    case restricted = "You are not allowed to play multiplayer games!"
}

let maxTimeRemaining = 20
