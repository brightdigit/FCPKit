//
//  RawPairReport.swift
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

public struct RawPairReport: Codable, Equatable, Sendable {
  public let formatVersion: Int
  public let beforePath: String
  public let afterPath: String
  public let beforeFCPXMLVersion: String?
  public let afterFCPXMLVersion: String?
  public let pathFilter: String?
  public let normalization: [String]
  public let findings: [FCPXMLDifference]

  public init(
    beforePath: String,
    afterPath: String,
    beforeFCPXMLVersion: String?,
    afterFCPXMLVersion: String?,
    pathFilter: String?,
    findings: [FCPXMLDifference]
  ) {
    formatVersion = 1
    self.beforePath = beforePath
    self.afterPath = afterPath
    self.beforeFCPXMLVersion = beforeFCPXMLVersion
    self.afterFCPXMLVersion = afterFCPXMLVersion
    self.pathFilter = pathFilter
    normalization = FCPXMLNormalizer.rules
    self.findings = findings
  }
}

public struct RawPairAnalyzer: Sendable {
  private let parser = XMLTreeParser()
  private let engine = FCPXMLDiffEngine()

  public init() {}

  public func analyze(
    beforeData: Data,
    afterData: Data,
    beforePath: String = "before.fcpxml",
    afterPath: String = "after.fcpxml",
    pathFilter: String? = nil
  ) throws -> RawPairReport {
    let before = try parser.parse(beforeData)
    let after = try parser.parse(afterData)
    let findings = engine.compare(before, after, mode: .symmetric).filter {
      guard let pathFilter else { return true }
      return $0.path.hasPrefix(pathFilter)
    }
    return RawPairReport(
      beforePath: beforePath,
      afterPath: afterPath,
      beforeFCPXMLVersion: before.attributes["version"],
      afterFCPXMLVersion: after.attributes["version"],
      pathFilter: pathFilter,
      findings: findings
    )
  }
}

public struct RawPairReportRenderer: Sendable {
  public init() {}

  public func jsonData(_ report: RawPairReport) throws -> Data {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
    return try encoder.encode(report)
  }

  public func markdown(_ report: RawPairReport) -> String {
    var lines = [
      "# FCPXML Raw-Pair Diff",
      "",
      "Before: `\(report.beforePath)` (FCPXML `\(report.beforeFCPXMLVersion ?? "unknown")`)",
      "After: `\(report.afterPath)` (FCPXML `\(report.afterFCPXMLVersion ?? "unknown")`)",
      "",
    ]
    if let pathFilter = report.pathFilter {
      lines += ["Path filter: `\(pathFilter)`", ""]
    }
    if report.findings.isEmpty {
      lines.append("No structural differences detected.")
    } else {
      lines += [
        "| Count | Kind | Structural path |",
        "| ---: | --- | --- |",
      ]
      lines += report.findings.map {
        "| \($0.count) | `\($0.kind.rawValue)` | `\($0.path)` |"
      }
    }
    return lines.joined(separator: "\n") + "\n"
  }
}
