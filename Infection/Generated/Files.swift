// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length line_length implicit_return

// MARK: - Files

// swiftlint:disable explicit_type_interface identifier_name
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum Files {
  /// de.lproj/
  internal enum DeLproj {
    /// Localizable.strings
    internal static let localizableStrings = File(name: "Localizable", ext: "strings", relativePath: "", mimeType: "application/octet-stream")
  }
  /// en.lproj/
  internal enum EnLproj {
    /// Localizable.strings
    internal static let localizableStrings = File(name: "Localizable", ext: "strings", relativePath: "", mimeType: "application/octet-stream")
  }
  /// es.lproj/
  internal enum EsLproj {
    /// Localizable.strings
    internal static let localizableStrings = File(name: "Localizable", ext: "strings", relativePath: "", mimeType: "application/octet-stream")
  }
  /// uk.lproj/
  internal enum UkLproj {
    /// Localizable.strings
    internal static let localizableStrings = File(name: "Localizable", ext: "strings", relativePath: "", mimeType: "application/octet-stream")
  }
  /// zh-Hans.lproj/
  internal enum ZhHansLproj {
    /// Localizable.strings
    internal static let localizableStrings = File(name: "Localizable", ext: "strings", relativePath: "", mimeType: "application/octet-stream")
  }
}
// swiftlint:enable explicit_type_interface identifier_name
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

internal struct File {
  internal let name: String
  internal let ext: String?
  internal let relativePath: String
  internal let mimeType: String

  internal var url: URL {
    return url(locale: nil)
  }

  internal func url(locale: Locale?) -> URL {
    let bundle = BundleToken.bundle
    let url = bundle.url(
      forResource: name,
      withExtension: ext,
      subdirectory: relativePath,
      localization: locale?.identifier
    )
    guard let result = url else {
      let file = name + (ext.flatMap { ".\($0)" } ?? "")
      fatalError("Could not locate file named \(file)")
    }
    return result
  }

  internal var path: String {
    return path(locale: nil)
  }

  internal func path(locale: Locale?) -> String {
    return url(locale: locale).path
  }
}

// swiftlint:disable convenience_type explicit_type_interface
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type explicit_type_interface
