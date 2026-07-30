//
//  XMLAttributeValue.swift
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

/// A strongly typed FCPXML attribute value that encodes as a single-value string.
///
/// Conformers parse from and render to the exact attribute text FCPXML uses, so
/// XMLCoder sees the same single-value `String` it sees for plain `String`
/// properties today. Attribute-versus-element dispatch stays key-based in
/// ``FCPNodeEncodable``, so adopting a conformer requires no node-encoding
/// changes at the container type.
public protocol XMLAttributeValue: Codable, Hashable, LosslessStringConvertible, Sendable {
  /// The FCPXML attribute string for this value.
  var fcpxmlString: String { get }

  /// Creates a value from its FCPXML attribute string, or nil when the string is illegal.
  init?(fcpxmlString: String)
}

extension XMLAttributeValue {
  /// The FCPXML attribute string for this value.
  public var description: String {
    fcpxmlString
  }

  /// Creates a value from its FCPXML attribute string, or nil when the string is illegal.
  public init?(_ description: String) {
    self.init(fcpxmlString: description)
  }

  /// Decodes the value from a single-value string container.
  ///
  /// - Throws: `DecodingError.dataCorrupted` when the string is not a legal value.
  public init(from decoder: any Decoder) throws {
    let raw = try decoder.singleValueContainer().decode(String.self)
    guard let value = Self(fcpxmlString: raw) else {
      throw DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: decoder.codingPath,
          debugDescription: "Invalid \(Self.self) value: \(raw)"
        )
      )
    }
    self = value
  }

  /// Encodes the value into a single-value string container.
  ///
  /// - Throws: Any error thrown by the underlying encoder.
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(fcpxmlString)
  }
}
