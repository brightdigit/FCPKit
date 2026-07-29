//
//  RawPairReportRenderer.swift
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
