//
//  SchemaCompletenessReport.swift
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

/// Aggregated round-trip loss results across a corpus of FCPXML documents.
public struct SchemaCompletenessReport: Codable, Equatable, Sendable {
  /// The version of this report's serialized format.
  public let formatVersion: Int
  /// Descriptions of the normalization rules applied before comparison.
  public let normalization: [String]
  /// Loss counts summed across all analyzed files.
  public let totals: SchemaCompletenessSummary
  /// Structural differences merged and summed across all analyzed files.
  public let aggregateFindings: [FCPXMLDifference]
  /// The per-file reports that contributed to the aggregate results.
  public let files: [SchemaCompletenessFileReport]

  /// Creates a report from aggregate totals, findings, and per-file results.
  public init(
    formatVersion: Int,
    normalization: [String],
    totals: SchemaCompletenessSummary,
    aggregateFindings: [FCPXMLDifference],
    files: [SchemaCompletenessFileReport]
  ) {
    self.formatVersion = formatVersion
    self.normalization = normalization
    self.totals = totals
    self.aggregateFindings = aggregateFindings
    self.files = files
  }
}
