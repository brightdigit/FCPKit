//
//  TCFormat.swift
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

/// The `tcFormat` attribute: whether timecode displays as drop frame or non-drop frame.
///
/// DTD vocabulary: `(DF | NDF)`. Out-of-vocabulary values fail decoding.
public enum TCFormat: String, XMLAttributeCase {
  /// Drop-frame timecode, written `"DF"`.
  case dropFrame = "DF"

  /// Non-drop-frame timecode, written `"NDF"`.
  case nonDropFrame = "NDF"

  /// Decodes from a single-value FCPXML attribute string via ``allCases`` lookup.
  public init(from decoder: any Decoder) throws {
    self = try Self.decodeXMLAttribute(from: decoder)
  }

  /// Encodes as a single-value FCPXML attribute string.
  public func encode(to encoder: any Encoder) throws {
    try encodeXMLAttribute(to: encoder)
  }
}
