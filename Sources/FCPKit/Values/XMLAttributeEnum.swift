//
//  XMLAttributeEnum.swift
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

/// A DTD-enumeration attribute value that preserves unknown raw values by default.
///
/// FCPXML vocabularies gain cases across schema versions, so conformers are not
/// closed: an out-of-vocabulary string decodes into the conformer's
/// `unknown(String)` case and re-encodes byte-identically. Callers that want
/// fail-loud validation opt in by setting ``XMLEnumDecodingMode/strict`` in the
/// decoder's `userInfo` under ``XMLEnumDecodingMode/userInfoKey``.
public protocol XMLAttributeEnum: XMLAttributeValue {
  /// Creates a value from the known DTD vocabulary, or nil for out-of-vocabulary strings.
  static func known(fcpxmlString: String) -> Self?

  /// Wraps an out-of-vocabulary raw value so it survives a decode/encode round trip.
  static func unknown(_ rawValue: String) -> Self
}

extension XMLAttributeEnum {
  /// True when this value is an out-of-vocabulary pass-through.
  public var isUnknown: Bool {
    Self.known(fcpxmlString: fcpxmlString) == nil
  }

  /// Creates a value from any raw string, wrapping out-of-vocabulary input as unknown.
  public init(fcpxmlString: String) {
    self = Self.known(fcpxmlString: fcpxmlString) ?? Self.unknown(fcpxmlString)
  }

  /// Decodes the value from a single-value string container, honoring the decoder's
  /// ``XMLEnumDecodingMode``.
  ///
  /// - Throws: `DecodingError.dataCorrupted` for out-of-vocabulary values when the
  ///   decoder declares ``XMLEnumDecodingMode/strict``.
  public init(from decoder: any Decoder) throws {
    let raw = try decoder.singleValueContainer().decode(String.self)
    let value = Self.known(fcpxmlString: raw) ?? Self.unknown(raw)
    if value.isUnknown, XMLEnumDecodingMode.resolved(from: decoder) == .strict {
      throw DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: decoder.codingPath,
          debugDescription: "Unknown \(Self.self) value: \(raw)"
        )
      )
    }
    self = value
  }
}
