//
//  TitleStyle.swift
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

import FCPKit

/// Text styling applied to a ``Title``.
///
/// The defaults reproduce Final Cut Pro's Basic Title styling exactly, so an
/// unstyled title serializes byte-identically to a real Final Cut export.
public struct TitleStyle: Equatable, Sendable {
  /// Paragraph alignment within the title's text box.
  public enum Alignment: String, Equatable, Sendable {
    /// Align text to the leading edge.
    case left
    /// Center text horizontally.
    case center
    /// Align text to the trailing edge.
    case right
    /// Stretch text to fill the line.
    case justified
  }

  /// Final Cut Pro's Basic Title default styling.
  public static let `default` = TitleStyle()

  /// The font family, such as `Helvetica`.
  public var font: String
  /// The font size in points.
  public var fontSize: Double
  /// The font face or weight within the family, such as `Regular` or `Bold`.
  public var fontFace: String
  /// The text color.
  public var fontColor: Color
  /// The paragraph alignment.
  public var alignment: Alignment
  /// Whether the text renders bold.
  ///
  /// Emitted only when `true`: real Final Cut output never writes the attribute,
  /// so leaving it off keeps default output identical to the fixtures.
  public var bold: Bool

  /// Creates a title style, defaulting to Final Cut's Basic Title styling.
  public init(
    font: String = "Helvetica",
    fontSize: Double = 63,
    fontFace: String = "Regular",
    fontColor: Color = .white,
    alignment: Alignment = .center,
    bold: Bool = false
  ) {
    self.font = font
    self.fontSize = fontSize
    self.fontFace = fontFace
    self.fontColor = fontColor
    self.alignment = alignment
    self.bold = bold
  }
}

extension TitleStyle {
  /// The `fontSize` attribute value, collapsing whole numbers (`63`, not `63.0`).
  internal var fontSizeString: String {
    String(fcpxmlValue: fontSize)
  }

  /// Lowers this style into the model's `text-style` element.
  internal func textStyle() -> FCPKit.TextStyle {
    FCPKit.TextStyle(
      font: font,
      fontSize: fontSizeString,
      fontFace: fontFace,
      fontColor: fontColor.description,
      bold: bold ? "1" : nil,
      alignment: alignment.rawValue
    )
  }
}
