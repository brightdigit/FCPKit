//
//  SchemaCompletenessAnalyzer.swift
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

/// Measures how completely the typed FCPKit schema round-trips real FCPXML files.
public struct SchemaCompletenessAnalyzer: Sendable {
  private struct FindingKey: Hashable {
    let kind: FCPXMLDifferenceKind
    let path: String

    init(_ finding: FCPXMLDifference) {
      kind = finding.kind
      path = finding.path
    }
  }

  private let treeParser = XMLTreeParser()
  private let diffEngine = FCPXMLDiffEngine()

  /// Creates a schema-completeness analyzer.
  public init() {}

  /// Analyzes the given FCPXML files and returns a schema-completeness report.
  public func analyze(
    fileURLs: [URL],
    relativeTo baseURL: URL? = nil
  ) throws -> SchemaCompletenessReport {
    let parser = FCPXMLParser()
    let files = try fileURLs.sorted { $0.path < $1.path }.map { fileURL in
      let originalData = try Data(contentsOf: fileURL)
      let originalTree = try treeParser.parse(originalData)
      let model = try parser.parse(data: originalData)
      let encodedData = try parser.encode(model)
      let encodedTree = try treeParser.parse(encodedData)
      let findings = diffEngine.compare(originalTree, encodedTree, mode: .completeness)
      return SchemaCompletenessFileReport(
        path: displayPath(fileURL, relativeTo: baseURL),
        fcpxmlVersion: originalTree.attributes["version"],
        summary: SchemaCompletenessSummary(findings: findings),
        findings: findings
      )
    }

    var aggregate: [FindingKey: Int] = [:]
    for finding in files.flatMap(\.findings) {
      aggregate[FindingKey(finding), default: 0] += finding.count
    }
    let aggregateFindings =
      aggregate
      .map { key, count in
        FCPXMLDifference(kind: key.kind, path: key.path, count: count)
      }
      .sorted(by: findingOrdering)

    return SchemaCompletenessReport(
      formatVersion: 1,
      normalization: FCPXMLNormalizer.rules,
      totals: SchemaCompletenessSummary(findings: aggregateFindings),
      aggregateFindings: aggregateFindings,
      files: files
    )
  }

  private func displayPath(_ url: URL, relativeTo baseURL: URL?) -> String {
    guard let baseURL else {
      return url.lastPathComponent
    }
    let base = baseURL.standardizedFileURL.path
    let path = url.standardizedFileURL.path
    guard path.hasPrefix(base + "/") else {
      return path
    }
    return String(path.dropFirst(base.count + 1))
  }

  private func findingOrdering(_ lhs: FCPXMLDifference, _ rhs: FCPXMLDifference) -> Bool {
    if lhs.count != rhs.count {
      return lhs.count > rhs.count
    }
    if lhs.kind.rawValue != rhs.kind.rawValue {
      return lhs.kind.rawValue < rhs.kind.rawValue
    }
    return lhs.path < rhs.path
  }
}
