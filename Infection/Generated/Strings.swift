// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import SwiftUI

// MARK: - Strings

public enum L10n {
  /// Count of players
  public static let countOfPlayers = LocalizedString(lookupKey: "count_of_players")
  /// Create Account
  public static let createAccount = LocalizedString(lookupKey: "create_account")
  /// Create lobby
  public static let createLobby = LocalizedString(lookupKey: "create_lobby")
  /// Draw
  public static let draw = LocalizedString(lookupKey: "draw")
  /// Email Address
  public static let emailAddress = LocalizedString(lookupKey: "email_address")
  /// Email or Password Incorrect
  public static let errorMessage = LocalizedString(lookupKey: "error_message")
  /// Fog of war
  public static let fogOfWar = LocalizedString(lookupKey: "fog_of_war")
  /// Game over
  public static let gameOver = LocalizedString(lookupKey: "game_over")
  /// Id
  public static let id = LocalizedString(lookupKey: "id")
  /// Let's play Infection!
  public static let inviteMessage = LocalizedString(lookupKey: "invite_message")
  /// Join lobby
  public static let joinLobby = LocalizedString(lookupKey: "join_lobby")
  /// Kick
  public static let kick = LocalizedString(lookupKey: "kick")
  /// Local game
  public static let localGame = LocalizedString(lookupKey: "local_game")
  /// Login
  public static let login = LocalizedString(lookupKey: "login")
  /// Map
  public static let map = LocalizedString(lookupKey: "map")
  /// Mode
  public static let mode = LocalizedString(lookupKey: "mode")
  /// In this mode you must infect more cells than your opponents
  public static let modeDescription1 = LocalizedString(lookupKey: "mode_description1")
  /// In this mode you must destroy opponents' bases to be the last one to survive
  public static let modeDescription2 = LocalizedString(lookupKey: "mode_description2")
  /// Infect More Cells
  public static let modeTitle1 = LocalizedString(lookupKey: "mode_title1")
  /// Destroy Bases
  public static let modeTitle2 = LocalizedString(lookupKey: "mode_title2")
  /// Name
  public static let name = LocalizedString(lookupKey: "name")
  /// No
  public static let no = LocalizedString(lookupKey: "no")
  /// Password
  public static let password = LocalizedString(lookupKey: "password")
  /// Players
  public static let players = LocalizedString(lookupKey: "players")
  /// Private game
  public static let privateGame = LocalizedString(lookupKey: "private_game")
  /// Are you sure you want to quit?
  public static let quitMessage = LocalizedString(lookupKey: "quit_message")
  /// Random steps
  public static let randomSteps = LocalizedString(lookupKey: "random_steps")
  /// Ready
  public static let ready = LocalizedString(lookupKey: "ready")
  /// Register
  public static let register = LocalizedString(lookupKey: "register")
  /// Restart
  public static let restart = LocalizedString(lookupKey: "restart")
  /// Settings
  public static let settings = LocalizedString(lookupKey: "settings")
  /// Sign In
  public static let signIn = LocalizedString(lookupKey: "sign_in")
  /// Sign Out
  public static let signOut = LocalizedString(lookupKey: "sign_out")
  /// Start game
  public static let startGame = LocalizedString(lookupKey: "start_game")
  /// Steps per turn
  public static let stepsPerTurn = LocalizedString(lookupKey: "steps_per_turn")
  /// Winner
  public static let winner = LocalizedString(lookupKey: "winner")
  /// Yes
  public static let yes = LocalizedString(lookupKey: "yes")
}

// MARK: - Implementation Details

extension L10n {
  fileprivate static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

public struct LocalizedString {
  internal let lookupKey: String

  var key: LocalizedStringKey {
    LocalizedStringKey(lookupKey)
  }

  var text: String {
    L10n.tr("Localizable", lookupKey)
  }
}

private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
      return Bundle.module
    #else
      return Bundle(for: BundleToken.self)
    #endif
  }()
}
