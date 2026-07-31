//
//  Color.swift
//  FCPKit
//
//  Created by Leo Dion.
//  Copyright © 2026 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation

#if canImport(CoreGraphics)
  import CoreGraphics
#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
  import AppKit
#endif

#if canImport(UIKit)
  import UIKit
#endif

#if canImport(SwiftUI)
  import SwiftUI
#endif

/// An RGBA color representation for FCPXML generator and effect parameters.
public struct Color: Equatable, Sendable, CustomStringConvertible {
  /// Pure Red (1, 0, 0, 1).
  public static let red = Color(red: 1, green: 0, blue: 0)
  /// Pure Green (0, 1, 0, 1).
  public static let green = Color(red: 0, green: 1, blue: 0)
  /// Pure Blue (0, 0, 1, 1).
  public static let blue = Color(red: 0, green: 0, blue: 1)
  /// Pure Black (0, 0, 0, 1).
  public static let black = Color(red: 0, green: 0, blue: 0)
  /// Pure White (1, 1, 1, 1).
  public static let white = Color(red: 1, green: 1, blue: 1)
  /// Clear / Transparent (0, 0, 0, 0).
  public static let clear = Color(red: 0, green: 0, blue: 0, alpha: 0)

  /// Red component between 0.0 and 1.0.
  public var red: Double
  /// Green component between 0.0 and 1.0.
  public var green: Double
  /// Blue component between 0.0 and 1.0.
  public var blue: Double
  /// Alpha component between 0.0 and 1.0.
  public var alpha: Double
  /// Optional duration when used as a generator clip in FCPKitDSL.
  public var duration: FCPTime?

  /// Formatted FCPXML rational color string (e.g. `"1 0 0"` or `"1 0 0 1"`).
  public var description: String {
    if alpha == 1.0 {
      return
        "\(Self.formatComponent(red)) \(Self.formatComponent(green)) \(Self.formatComponent(blue))"
    } else {
      return
        "\(Self.formatComponent(red)) \(Self.formatComponent(green)) \(Self.formatComponent(blue)) \(Self.formatComponent(alpha))"
    }
  }

  /// Creates a color from red, green, blue, and alpha components.
  public init(
    red: Double, green: Double, blue: Double, alpha: Double = 1.0, duration: FCPTime? = nil
  ) {
    self.red = red
    self.green = green
    self.blue = blue
    self.alpha = alpha
    self.duration = duration
  }

  /// Creates a grayscale color.
  public init(white: Double, alpha: Double = 1.0) {
    self.init(red: white, green: white, blue: white, alpha: alpha)
  }

  /// Parses an FCPXML rational color string (e.g. `"1 0 0 1"` or `"0.5 0.5 0.5 1"`).
  public init?(fcpString: String) {
    let parts = fcpString.trimmingCharacters(in: .whitespacesAndNewlines)
      .components(separatedBy: .whitespaces)
      .compactMap(Double.init)
    guard parts.count >= 3 else { return nil }
    self.red = parts[0]
    self.green = parts[1]
    self.blue = parts[2]
    self.alpha = parts.count >= 4 ? parts[3] : 1.0
  }

  /// Parses a hex color string (e.g. `"#FF0000"`, `"FF0000"`, `"#FF0000FF"`).
  public init?(hex: String) {
    var cleanHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    if cleanHex.hasPrefix("#") {
      cleanHex.removeFirst()
    }
    let scanner = Scanner(string: cleanHex)
    var hexNumber: UInt64 = 0
    guard scanner.scanHexInt64(&hexNumber) else { return nil }

    switch cleanHex.count {
    case 3:  // RGB (12-bit)
      let redVal = Double((hexNumber & 0xF00) >> 8) / 15.0
      let greenVal = Double((hexNumber & 0x0F0) >> 4) / 15.0
      let blueVal = Double(hexNumber & 0x00F) / 15.0
      self.init(red: redVal, green: greenVal, blue: blueVal, alpha: 1.0)
    case 6:  // RGB (24-bit)
      let redVal = Double((hexNumber & 0xFF0000) >> 16) / 255.0
      let greenVal = Double((hexNumber & 0x00FF00) >> 8) / 255.0
      let blueVal = Double(hexNumber & 0x0000FF) / 255.0
      self.init(red: redVal, green: greenVal, blue: blueVal, alpha: 1.0)
    case 8:  // RGBA (32-bit)
      let redVal = Double((hexNumber & 0xFF00_0000) >> 24) / 255.0
      let greenVal = Double((hexNumber & 0x00FF_0000) >> 16) / 255.0
      let blueVal = Double((hexNumber & 0x0000_FF00) >> 8) / 255.0
      let alphaVal = Double(hexNumber & 0x0000_00FF) / 255.0
      self.init(red: redVal, green: greenVal, blue: blueVal, alpha: alphaVal)
    default:
      return nil
    }
  }

  private static func formatComponent(_ val: Double) -> String {
    if val.truncatingRemainder(dividingBy: 1) == 0 {
      return String(Int(val))
    } else {
      return String(val)
    }
  }
}

// MARK: - Native Color Conversions

#if canImport(CoreGraphics)
  extension Color {
    /// Creates a ``Color`` from a `CGColor`.
    public init?(_ cgColor: CGColor) {
      guard let srgbSpace = CGColorSpace(name: CGColorSpace.sRGB),
        let converted = cgColor.converted(to: srgbSpace, intent: .defaultIntent, options: nil),
        let components = converted.components,
        components.count >= 3
      else {
        return nil
      }
      let redVal = Double(components[0])
      let greenVal = Double(components[1])
      let blueVal = Double(components[2])
      let alphaVal = components.count >= 4 ? Double(components[3]) : 1.0
      self.init(red: redVal, green: greenVal, blue: blueVal, alpha: alphaVal)
    }
  }
#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
  extension Color {
    /// Creates a ``Color`` from an `NSColor`.
    public init(_ nsColor: NSColor) {
      if let srgb = nsColor.usingColorSpace(.sRGB) {
        self.init(
          red: Double(srgb.redComponent),
          green: Double(srgb.greenComponent),
          blue: Double(srgb.blueComponent),
          alpha: Double(srgb.alphaComponent)
        )
      } else if let converted = Color(nsColor.cgColor) {
        self = converted
      } else {
        self.init(red: 0, green: 0, blue: 0, alpha: 1)
      }
    }
  }
#endif

#if canImport(UIKit)
  extension Color {
    /// Creates a ``Color`` from a `UIColor`.
    public init(_ uiColor: UIColor) {
      var redVal: CGFloat = 0
      var greenVal: CGFloat = 0
      var blueVal: CGFloat = 0
      var alphaVal: CGFloat = 0
      if uiColor.getRed(&redVal, green: &greenVal, blue: &blueVal, alpha: &alphaVal) {
        self.init(
          red: Double(redVal),
          green: Double(greenVal),
          blue: Double(blueVal),
          alpha: Double(alphaVal)
        )
      } else if let converted = Color(uiColor.cgColor) {
        self = converted
      } else {
        self.init(red: 0, green: 0, blue: 0, alpha: 1)
      }
    }
  }
#endif

#if canImport(SwiftUI)
  extension Color {
    /// Creates a ``Color`` from a `SwiftUI.Color`.
    public init?(_ color: SwiftUI.Color) {
      if let cgColor = color.cgColor, let converted = Color(cgColor) {
        self = converted
        return
      }
      #if canImport(AppKit) && !targetEnvironment(macCatalyst)
        self.init(NSColor(color))
      #elseif canImport(UIKit)
        self.init(UIColor(color))
      #else
        return nil
      #endif
    }
  }
#endif
