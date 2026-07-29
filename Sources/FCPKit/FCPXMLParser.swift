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

public class FCPXMLParser {
  private let decoder: XMLDecoder

  public init() {
    decoder = XMLDecoder()
    decoder.dateDecodingStrategy = .iso8601
    decoder.keyDecodingStrategy = .useDefaultKeys
  }

  public func parse(data: Data) throws -> FCPXML {
    try decoder.decode(FCPXML.self, from: data)
  }

  public func parse(xmlString: String) throws -> FCPXML {
    guard let data = xmlString.data(using: .utf8) else {
      throw FCPXMLError.invalidXMLString
    }
    return try parse(data: data)
  }

  public func parse(fileURL: URL) throws -> FCPXML {
    let data = try Data(contentsOf: fileURL)
    return try parse(data: data)
  }

  public func encode(_ fcpxml: FCPXML) throws -> Data {
    let encoder = XMLEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.keyEncodingStrategy = .useDefaultKeys
    encoder.outputFormatting = [.prettyPrinted]
    return try encoder.encode(fcpxml, withRootKey: "fcpxml")
  }

  public func encodeToString(_ fcpxml: FCPXML) throws -> String {
    let data = try encode(fcpxml)
    guard let string = String(data: data, encoding: .utf8) else {
      throw FCPXMLError.encodingFailed
    }
    return string
  }

  public func write(_ fcpxml: FCPXML, to url: URL) throws {
    let data = try encode(fcpxml)
    try data.write(to: url)
  }
}

public enum FCPXMLError: Error, LocalizedError {
  case invalidXMLString
  case encodingFailed
  case decodingFailed(String)
  case fileNotFound
  case unsupportedVersion(String)

  public var errorDescription: String? {
    switch self {
    case .invalidXMLString:
      return "Invalid XML string provided"
    case .encodingFailed:
      return "Failed to encode FCPXML to string"
    case .decodingFailed(let message):
      return "Failed to decode FCPXML: \(message)"
    case .fileNotFound:
      return "FCPXML file not found"
    case .unsupportedVersion(let version):
      return "Malformed or unsupported FCPXML version declaration: \(version)"
    }
  }
}
