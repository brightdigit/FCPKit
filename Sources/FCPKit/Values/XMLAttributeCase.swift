//
//  XMLAttributeCase.swift
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

/// A closed DTD vocabulary attribute: finite known cases, fail on unknown wire text.
///
/// Conformers expose a wire-form ``rawValue`` and ``CaseIterable/allCases``. The
/// default ``init?(_:)`` succeeds only when the string matches some case — used
/// by both `String` raw enums and string-backed static vocabularies. A pre-release
/// unknowns scan can compare fixture attribute values against
/// `Set(Self.allCases.map(\.rawValue))`.
public protocol XMLAttributeCase: ExpressibleByStringLiteral, XMLAttributeValue, CaseIterable,
  Equatable
{
  /// Wire-form string compared during ``init?(_:)`` lookup.
  var rawValue: String { get }
}

extension XMLAttributeCase {
  /// The FCPXML attribute string for this value.
  public var description: String { rawValue }

  /// Creates a value from a string literal.
  public init(stringLiteral value: String) {
    guard let match = Self(value) else {
      preconditionFailure("Invalid \(Self.self) string literal: '\(value)'")
    }
    self = match
  }

  /// Succeeds only when `description` matches some ``allCases`` entry’s `rawValue`.
  public init?(_ description: String) {
    guard let match = Self.allCases.first(where: { $0.rawValue == description }) else {
      return nil
    }
    self = match
  }

  /// Decodes from a single-value string, looking up ``allCases``.
  ///
  /// Concrete enums must call this from their own `init(from:)` so it overrides
  /// Swift’s synthesized case-name `Codable` (which is wrong for FCPXML attributes).
  public static func decodeXMLAttribute(from decoder: any Decoder) throws -> Self {
    let raw = try decoder.singleValueContainer().decode(String.self)
    guard let value = Self(raw) else {
      throw DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: decoder.codingPath,
          debugDescription: "Invalid \(Self.self) value: \(raw)"
        )
      )
    }
    return value
  }

  /// Encodes as a single-value wire string.
  public func encodeXMLAttribute(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(rawValue)
  }
}
