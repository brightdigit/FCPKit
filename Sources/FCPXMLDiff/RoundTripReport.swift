//
//  RoundTripReport.swift
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
import Foundation

/// Reports structural content that the typed model does not retain across an
/// XML decode/encode cycle.
public struct FCPXMLRoundTripReport: Codable, Equatable, Sendable {
  public let formatVersion: Int
  public let sourcePath: String
  public let fcpxmlVersion: String?
  public let normalization: [String]
  public let summary: SchemaCompletenessSummary
  public let findings: [FCPXMLDifference]

  public var hasLoss: Bool { summary.total > 0 }

  public init(
    sourcePath: String,
    fcpxmlVersion: String?,
    findings: [FCPXMLDifference]
  ) {
    formatVersion = 1
    self.sourcePath = sourcePath
    self.fcpxmlVersion = fcpxmlVersion
    normalization = FCPXMLNormalizer.rules
    summary = SchemaCompletenessSummary(findings: findings)
    self.findings = findings
  }
}

/// Exercises the public FCPKit parser and reports content omitted by encoding.
public struct FCPXMLRoundTripAnalyzer: Sendable {
  private let treeParser = XMLTreeParser()
  private let diffEngine = FCPXMLDiffEngine()

  public init() {}

  public func analyze(
    data: Data,
    sourcePath: String = "input.fcpxml"
  ) throws -> FCPXMLRoundTripReport {
    let parser = FCPXMLParser()
    let model = try parser.parse(data: data)
    let encodedData = try parser.encode(model)
    return try analyze(
      originalData: data,
      encodedData: encodedData,
      sourcePath: sourcePath
    )
  }

  public func analyze(
    originalData: Data,
    encodedData: Data,
    sourcePath: String = "input.fcpxml"
  ) throws -> FCPXMLRoundTripReport {
    let original = try treeParser.parse(originalData)
    let encoded = try treeParser.parse(encodedData)
    let findings = diffEngine.compare(original, encoded, mode: .completeness)
    return FCPXMLRoundTripReport(
      sourcePath: sourcePath,
      fcpxmlVersion: original.attributes["version"],
      findings: findings
    )
  }
}
