//
//  FCPXMLValidationReportRenderer.swift
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

/// Renders a DTD validation report as Markdown or JSON.
public struct FCPXMLValidationReportRenderer: Sendable {
  /// Creates a renderer.
  public init() {}

  /// Renders a validation report as Markdown.
  public func markdown(_ report: FCPXMLValidationReport) -> String {
    var lines: [String] = []
    lines.append("# FCPXML DTD Validation")
    lines.append("")
    lines.append("Source: `\(report.sourcePath)`")
    lines.append("Declared version: `\(report.fcpxmlVersion ?? "unknown")`")
    lines.append("DTD: `\(report.dtdPath)`")
    lines.append("Valid: **\(report.isValid ? "yes" : "no")**")
    lines.append("")
    if report.issues.isEmpty {
      lines.append("No validation issues.")
    } else {
      lines.append("| Path | Message |")
      lines.append("| --- | --- |")
      for issue in report.issues {
        let path = issue.path ?? ""
        let message = issue.message.replacingOccurrences(of: "|", with: "\\|")
        lines.append("| `\(path)` | \(message) |")
      }
    }
    lines.append("")
    return lines.joined(separator: "\n")
  }

  /// Encodes a validation report as pretty-printed JSON data.
  public func jsonData(_ report: FCPXMLValidationReport) throws -> Data {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    return try encoder.encode(report)
  }
}
