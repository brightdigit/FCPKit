//
//  FCPXMLRoundTripReport.swift
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
  /// The version of this report's serialized format.
  public let formatVersion: Int
  /// The path of the FCPXML document that was analyzed.
  public let sourcePath: String
  /// The FCPXML version declared by the source document, if any.
  public let fcpxmlVersion: String?
  /// Descriptions of the normalization rules applied before comparison.
  public let normalization: [String]
  /// Aggregated counts of dropped elements, attributes, and text.
  public let summary: SchemaCompletenessSummary
  /// The individual structural differences detected by the round trip.
  public let findings: [FCPXMLDifference]

  /// Whether the round trip dropped any structural content.
  public var hasLoss: Bool { summary.total > 0 }

  /// Creates a report from round-trip findings for the given source document.
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
