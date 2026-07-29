//
//  DTDValidation.swift
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

/// Result of validating an FCPXML document against an Apple FCPXML DTD.
public struct FCPXMLValidationReport: Codable, Equatable, Sendable {
  public let formatVersion: Int
  public let sourcePath: String
  public let fcpxmlVersion: String?
  public let dtdPath: String
  public let isValid: Bool
  public let issues: [FCPXMLValidationIssue]

  public init(
    sourcePath: String,
    fcpxmlVersion: String?,
    dtdPath: String,
    isValid: Bool,
    issues: [FCPXMLValidationIssue]
  ) {
    formatVersion = 1
    self.sourcePath = sourcePath
    self.fcpxmlVersion = fcpxmlVersion
    self.dtdPath = dtdPath
    self.isValid = isValid
    self.issues = issues
  }
}

public struct FCPXMLValidationIssue: Codable, Equatable, Sendable {
  public let path: String?
  public let message: String

  public init(path: String?, message: String) {
    self.path = path
    self.message = message
  }
}

public enum FCPXMLValidationError: Error, LocalizedError, Equatable {
  case dtdNotFound(version: String)
  case xmllintUnavailable
  case invalidDocument(FCPXMLValidationReport)

  public var errorDescription: String? {
    switch self {
    case .dtdNotFound(let version):
      return "No FCPXML DTD found for version \(version)"
    case .xmllintUnavailable:
      return "xmllint is not available on PATH"
    case .invalidDocument(let report):
      let details = report.issues.map(\.message).joined(separator: "; ")
      return "FCPXML failed DTD validation: \(details)"
    }
  }
}

/// Locates Apple FCPXML DTDs bundled with Final Cut Pro when present.
public struct FCPXMLDTDLocator: Sendable {
  public var searchRoots: [URL]

  public init(searchRoots: [URL] = FCPXMLDTDLocator.defaultSearchRoots()) {
    self.searchRoots = searchRoots
  }

  public static func defaultSearchRoots() -> [URL] {
    let applications = URL(fileURLWithPath: "/Applications", isDirectory: true)
    let names = [
      "Final Cut Pro Creator Studio.app",
      "Final Cut Pro.app",
    ]
    return names.map {
      applications
        .appendingPathComponent($0, isDirectory: true)
        .appendingPathComponent(
          "Contents/Frameworks/Interchange.framework/Versions/A/Resources", isDirectory: true)
    }
  }

  public func dtdURL(forVersion version: String) -> URL? {
    let sanitized = version.replacingOccurrences(of: ".", with: "_")
    let fileName = "FCPXMLv\(sanitized).dtd"
    for root in searchRoots {
      let candidate = root.appendingPathComponent(fileName)
      if FileManager.default.fileExists(atPath: candidate.path) {
        return candidate
      }
    }
    return nil
  }
}

/// Validates FCPXML documents against Apple DTDs using `xmllint`.
public struct FCPXMLDTDValidator: Sendable {
  private let locator: FCPXMLDTDLocator

  public init(locator: FCPXMLDTDLocator = FCPXMLDTDLocator()) {
    self.locator = locator
  }

  // Validation spawns `/usr/bin/xmllint`; `Foundation.Process` is unavailable on
  // WebAssembly, which has no process model.
  #if !os(WASI)

    public func validate(
      data: Data,
      sourcePath: String = "input.fcpxml",
      dtdURL: URL? = nil
    ) throws -> FCPXMLValidationReport {
      guard xmllintAvailable() else {
        throw FCPXMLValidationError.xmllintUnavailable
      }

      let version = try declaredVersion(in: data) ?? "1.13"
      let resolvedDTD: URL
      if let dtdURL {
        resolvedDTD = dtdURL
      } else if let located = locator.dtdURL(forVersion: version) {
        resolvedDTD = located
      } else {
        throw FCPXMLValidationError.dtdNotFound(version: version)
      }

      let tempDirectory = FileManager.default.temporaryDirectory
        .appendingPathComponent("fcpxml-dtd-\(UUID().uuidString)", isDirectory: true)
      try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
      defer { try? FileManager.default.removeItem(at: tempDirectory) }

      // xmllint fails to resolve SYSTEM DTD paths that contain spaces
      // (e.g. Final Cut Pro app bundles). Copy into a spaceless temp path.
      let localDTD = tempDirectory.appendingPathComponent(resolvedDTD.lastPathComponent)
      try FileManager.default.copyItem(at: resolvedDTD, to: localDTD)

      let xmlURL = tempDirectory.appendingPathComponent("document.fcpxml")
      try data.write(to: xmlURL)

      let process = Process()
      process.executableURL = URL(fileURLWithPath: "/usr/bin/xmllint")
      process.arguments = ["--noout", "--dtdvalid", localDTD.path, xmlURL.path]
      let stderr = Pipe()
      process.standardError = stderr
      process.standardOutput = Pipe()
      try process.run()
      process.waitUntilExit()

      let errorData = stderr.fileHandleForReading.readDataToEndOfFile()
      let errorText = String(data: errorData, encoding: .utf8) ?? ""
      let issues = parseIssues(from: errorText)
      let report = FCPXMLValidationReport(
        sourcePath: sourcePath,
        fcpxmlVersion: version,
        dtdPath: resolvedDTD.path,
        isValid: process.terminationStatus == 0 && issues.isEmpty,
        issues: issues
      )
      return report
    }

    private func xmllintAvailable() -> Bool {
      FileManager.default.isExecutableFile(atPath: "/usr/bin/xmllint")
    }
  #else

    /// DTD validation shells out to `xmllint`, and WebAssembly has no process model
    /// (`Foundation.Process` does not exist there). The API stays present so callers
    /// still compile; it reports the tool as unavailable, the same path taken on a
    /// host that simply lacks xmllint.
    public func validate(
      data: Data,
      sourcePath: String = "input.fcpxml",
      dtdURL: URL? = nil
    ) throws -> FCPXMLValidationReport {
      throw FCPXMLValidationError.xmllintUnavailable
    }
  #endif

  private func declaredVersion(in data: Data) throws -> String? {
    guard let xml = String(data: data, encoding: .utf8) else { return nil }
    guard let regex = try? NSRegularExpression(pattern: #"<fcpxml\s+[^>]*version=\"([^\"]+)\""#)
    else {
      return nil
    }
    let range = NSRange(xml.startIndex..<xml.endIndex, in: xml)
    guard let match = regex.firstMatch(in: xml, range: range),
      match.numberOfRanges > 1,
      let versionRange = Range(match.range(at: 1), in: xml)
    else {
      return nil
    }
    return String(xml[versionRange])
  }

  private func parseIssues(from stderr: String) -> [FCPXMLValidationIssue] {
    stderr
      .split(whereSeparator: \.isNewline)
      .map(String.init)
      .filter { !$0.isEmpty }
      .map { line in
        let path = extractPath(from: line)
        return FCPXMLValidationIssue(path: path, message: line)
      }
  }

  private func extractPath(from line: String) -> String? {
    // xmllint often reports element names; surface them as coarse paths.
    if let range = line.range(of: #"element\s+([A-Za-z0-9:_-]+)"#, options: .regularExpression) {
      let token = line[range]
        .split(whereSeparator: \.isWhitespace)
        .last
        .map(String.init)
      if let token {
        return "/fcpxml//\(token)"
      }
    }
    if let range = line.range(
      of: #"No declaration for element\s+([A-Za-z0-9:_-]+)"#, options: .regularExpression)
    {
      let token = line[range]
        .split(whereSeparator: \.isWhitespace)
        .last
        .map(String.init)
      if let token {
        return "/fcpxml//\(token)"
      }
    }
    return nil
  }
}

public struct FCPXMLValidationReportRenderer: Sendable {
  public init() {}

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

  public func jsonData(_ report: FCPXMLValidationReport) throws -> Data {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    return try encoder.encode(report)
  }
}
