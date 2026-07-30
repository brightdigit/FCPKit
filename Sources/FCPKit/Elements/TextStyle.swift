//
//  TextStyle.swift
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
import XMLCoder

/// A `text-style` element: a styled run of text, either inline or referencing a `text-style-def`.
public struct TextStyle: Codable {
  internal enum CodingKeys: String, CodingKey {
    case ref
    case font
    case fontSize
    case fontFace
    case fontColor
    case bold
    case kerning
    case alignment
    case param
    case content = ""
  }

  /// The `id` of the `text-style-def` this run references, if any.
  public let ref: String?
  /// The font family name, such as `Helvetica`.
  public var font: String?
  /// The font size in points, as a string.
  public var fontSize: String?
  /// The font face or weight within the family, such as `Regular`.
  public var fontFace: String?
  /// The text color as space-separated RGBA components (for example `1 1 1 1`).
  public var fontColor: String?
  /// Whether the text is bold, as a boolean string (`1` or `0`).
  public var bold: String?
  /// The kerning adjustment applied to the text, as a string.
  public var kerning: String?
  /// The paragraph alignment, such as `left`, `center`, or `right`.
  public var alignment: String?
  /// Additional styling parameters applied to the text run.
  public var param: [ParamElement]?
  /// The run's text content, stored as the element's character data.
  public var content: String?
}

extension TextStyle: DynamicNodeEncoding {
  /// Encodes the text content and `param` as elements and all other keys as XML attributes.
  public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
    key.stringValue.isEmpty || key.stringValue == "param" ? .element : .attribute
  }
}
