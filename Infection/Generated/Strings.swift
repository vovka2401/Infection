// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import SwiftUI

// MARK: - Strings

public enum L10n {
  /// Count of players
  public static let countOfPlayers = LocalizedString(lookupKey: "count_of_players")
  /// Create game
  public static let createGame = LocalizedString(lookupKey: "create_game")
  /// Fog of war
  public static let fogOfWar = LocalizedString(lookupKey: "fog_of_war")
  /// Game over
  public static let gameOver = LocalizedString(lookupKey: "game_over")
  /// Let's play Infection!
  public static let inviteMessage = LocalizedString(lookupKey: "invite_message")
  /// Join game
  public static let joinGame = LocalizedString(lookupKey: "join_game")
  /// Local game
  public static let localGame = LocalizedString(lookupKey: "local_game")
  /// Map
  public static let map = LocalizedString(lookupKey: "map")
  /// Mode
  public static let mode = LocalizedString(lookupKey: "mode")
  /// In this mode you must infect cells to have more infected cells than your oponnents
  public static let modeDescription1 = LocalizedString(lookupKey: "mode_description1")
  /// In this mode you must destroy oponnents' bases to be the last one to survive
  public static let modeDescription2 = LocalizedString(lookupKey: "mode_description2")
  /// Infect More Cells
  public static let modeTitle1 = LocalizedString(lookupKey: "mode_title1")
  /// Destroy Base
  public static let modeTitle2 = LocalizedString(lookupKey: "mode_title2")
  /// Private game
  public static let privateGame = LocalizedString(lookupKey: "private_game")
  /// Random steps
  public static let randomSteps = LocalizedString(lookupKey: "random_steps")
  /// Restart
  public static let restart = LocalizedString(lookupKey: "restart")
  /// Settings
  public static let settings = LocalizedString(lookupKey: "settings")
  /// Steps per turn
  public static let stepsPerTurn = LocalizedString(lookupKey: "steps_per_turn")
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
