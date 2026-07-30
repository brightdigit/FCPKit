//
//  ColorProcessing.swift
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

/// The `colorProcessing` attribute: a library or project's color processing pipeline.
///
/// DTD vocabulary: `(standard | wide | wide-hdr)`. Out-of-vocabulary values decode
/// as ``unknown(_:)`` by default; see ``XMLEnumDecodingMode`` for strict decoding.
public enum ColorProcessing: XMLAttributeEnum {
  /// Standard-gamut processing, written `"standard"`.
  case standard

  /// Wide-gamut processing, written `"wide"`.
  case wide

  /// Wide-gamut HDR processing, written `"wide-hdr"`.
  case wideHDR

  /// An out-of-vocabulary value preserved for round-tripping.
  case unknown(String)

  /// The FCPXML attribute string for this value.
  public var fcpxmlString: String {
    switch self {
    case .standard: "standard"
    case .wide: "wide"
    case .wideHDR: "wide-hdr"
    case .unknown(let rawValue): rawValue
    }
  }

  /// Creates a value from the known `colorProcessing` vocabulary.
  public static func known(fcpxmlString: String) -> ColorProcessing? {
    switch fcpxmlString {
    case "standard": .standard
    case "wide": .wide
    case "wide-hdr": .wideHDR
    default: nil
    }
  }
}
