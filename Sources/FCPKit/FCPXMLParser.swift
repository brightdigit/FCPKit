//
//  FCPXMLParser.swift
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

/// Decodes and encodes FCPXML documents.
///
/// Encoding emits child elements in each type's `CodingKeys` declaration
/// order; `.sortedKeys` is deliberately not set, because ordered DTD content
/// models depend on that declaration order.
public class FCPXMLParser {
  private let decoder: XMLDecoder

  /// Creates a parser configured for ISO 8601 dates and unmodified coding keys.
  public init() {
    decoder = XMLDecoder()
    decoder.dateDecodingStrategy = .iso8601
    decoder.keyDecodingStrategy = .useDefaultKeys
  }

  /// Decodes a document from raw FCPXML data.
  /// - Parameter data: The FCPXML payload to decode.
  /// - Returns: The decoded document.
  /// - Throws: A `DecodingError` if the payload does not match the model.
  public func parse(data: Data) throws -> FCPXML {
    try decoder.decode(FCPXML.self, from: data)
  }

  /// Decodes a document from an FCPXML string.
  /// - Parameter xmlString: The FCPXML text to decode.
  /// - Returns: The decoded document.
  /// - Throws: `FCPXMLError.invalidXMLString` if the text is not valid UTF-8.
  public func parse(xmlString: String) throws -> FCPXML {
    guard let data = xmlString.data(using: .utf8) else {
      throw FCPXMLError.invalidXMLString
    }
    return try parse(data: data)
  }

  /// Decodes a document from a file on disk.
  /// - Parameter fileURL: Location of the `.fcpxml` file to read.
  /// - Returns: The decoded document.
  /// - Throws: An error if the file cannot be read or decoded.
  public func parse(fileURL: URL) throws -> FCPXML {
    let data = try Data(contentsOf: fileURL)
    return try parse(data: data)
  }

  /// Encodes a document as pretty-printed FCPXML data.
  /// - Parameter fcpxml: The document to encode.
  /// - Returns: The encoded payload, rooted at `<fcpxml>`.
  /// - Throws: An `EncodingError` if the document cannot be encoded.
  public func encode(_ fcpxml: FCPXML) throws -> Data {
    let encoder = XMLEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.keyEncodingStrategy = .useDefaultKeys
    encoder.outputFormatting = [.prettyPrinted]
    let data = try encoder.encode(fcpxml, withRootKey: "fcpxml")
    guard let xml = String(data: data, encoding: .utf8) else {
      return data
    }
    return Data(Self.compactingTextStyleCharacterData(in: xml).utf8)
  }

  /// Encodes a document as an FCPXML string.
  /// - Parameter fcpxml: The document to encode.
  /// - Returns: The encoded document as UTF-8 text.
  /// - Throws: `FCPXMLError.encodingFailed` if the payload is not valid UTF-8.
  public func encodeToString(_ fcpxml: FCPXML) throws -> String {
    let data = try encode(fcpxml)
    guard let string = String(data: data, encoding: .utf8) else {
      throw FCPXMLError.encodingFailed
    }
    return string
  }

  /// Encodes a document and writes it to disk.
  /// - Parameters:
  ///   - fcpxml: The document to encode.
  ///   - url: Destination file URL.
  /// - Throws: An error if the document cannot be encoded or written.
  public func write(_ fcpxml: FCPXML, to url: URL) throws {
    let data = try encode(fcpxml)
    try data.write(to: url)
  }
}

extension FCPXMLParser {
  /// Collapses pretty-print whitespace around pure-text `<text-style>` runs.
  ///
  /// XMLCoder's `.prettyPrinted` wraps element character data onto indented
  /// lines. Final Cut Pro treats that leading/trailing whitespace as part of
  /// the title string. Elements that contain nested children (for example a
  /// definition style with `<param>` children) are left unchanged.
  internal static func compactingTextStyleCharacterData(in xml: String) -> String {
    let pattern = #"<text-style([^>]*)>([^<]*)</text-style>"#
    guard let regex = try? NSRegularExpression(pattern: pattern) else {
      return xml
    }
    let nsRange = NSRange(xml.startIndex..<xml.endIndex, in: xml)
    var result = ""
    var lastEnd = xml.startIndex
    for match in regex.matches(in: xml, range: nsRange) {
      guard
        let fullRange = Range(match.range, in: xml),
        let attrsRange = Range(match.range(at: 1), in: xml),
        let bodyRange = Range(match.range(at: 2), in: xml)
      else {
        continue
      }
      result += xml[lastEnd..<fullRange.lowerBound]
      let trimmed = xml[bodyRange].trimmingCharacters(in: .whitespacesAndNewlines)
      result += "<text-style\(xml[attrsRange])>\(trimmed)</text-style>"
      lastEnd = fullRange.upperBound
    }
    result += xml[lastEnd...]
    return result
  }
}
