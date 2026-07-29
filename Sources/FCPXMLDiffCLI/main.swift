//
//  main.swift
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

import FCPXMLDiff
import Foundation

extension Data {
  /// Writes atomically where the platform supports it.
  ///
  /// WASI has no temporary files, so `.atomic` is unavailable there and the write
  /// is direct. Report output is written once at the end of a run, so losing
  /// atomicity only matters if the process dies mid-write.
  internal func writeAtomicallyIfSupported(to url: URL) throws {
    #if os(WASI)
      try write(to: url)
    #else
      try write(to: url, options: .atomic)
    #endif
  }
}

@main
internal enum FCPXMLDiffCommand {
  internal static func main() {
    do {
      let accepted = try run()
      if !accepted {
        Foundation.exit(1)
      }
    } catch {
      writeError("fcpxml-diff: \(error.localizedDescription)\n")
      Foundation.exit(2)
    }
  }

  private static func run() throws -> Bool {
    var arguments = Array(CommandLine.arguments.dropFirst())
    guard let command = arguments.first else { throw CommandError.usage }
    arguments.removeFirst()

    switch command {
    case "schema-completeness":
      return try runSchemaCompleteness(arguments)
    case "compare":
      try runCompare(arguments)
      return true
    case "validate":
      return try runValidate(arguments)
    default:
      throw CommandError.usage
    }
  }

  private static func runSchemaCompleteness(_ arguments: [String]) throws -> Bool {
    var inputs: [String] = []
    var markdownPath: String?
    var jsonPath: String?
    var maximumTotalLoss: Int?
    var index = 0
    while index < arguments.count {
      switch arguments[index] {
      case "--markdown":
        index += 1
        guard index < arguments.count else { throw CommandError.usage }
        markdownPath = arguments[index]
      case "--json":
        index += 1
        guard index < arguments.count else { throw CommandError.usage }
        jsonPath = arguments[index]
      case "--fail-if-total-exceeds":
        index += 1
        guard index < arguments.count,
          let value = Int(arguments[index]),
          value >= 0
        else { throw CommandError.usage }
        maximumTotalLoss = value
      default:
        inputs.append(arguments[index])
      }
      index += 1
    }
    guard !inputs.isEmpty else { throw CommandError.usage }

    let fileURLs = try collectFiles(inputs)
    guard !fileURLs.isEmpty else { throw CommandError.noInputFiles }

    let currentDirectory = URL(
      fileURLWithPath: FileManager.default.currentDirectoryPath,
      isDirectory: true
    )
    let report = try SchemaCompletenessAnalyzer().analyze(
      fileURLs: fileURLs,
      relativeTo: currentDirectory
    )
    let renderer = SchemaCompletenessReportRenderer()
    let markdown = renderer.markdown(report)
    print(markdown, terminator: "")

    if let markdownPath {
      try Data(markdown.utf8).writeAtomicallyIfSupported(to: URL(fileURLWithPath: markdownPath))
    }
    if let jsonPath {
      try renderer.jsonData(report).writeAtomicallyIfSupported(to: URL(fileURLWithPath: jsonPath))
    }
    guard let maximumTotalLoss else {
      return true
    }
    let acceptance = SchemaCompletenessAcceptance(maximumTotalLoss: maximumTotalLoss)
    if !acceptance.accepts(report) {
      writeError(
        "fcpxml-diff: total structural loss \(report.totals.total) "
          + "exceeds accepted baseline \(maximumTotalLoss)\n"
      )
      return false
    }
    return true
  }

  private static func runCompare(_ arguments: [String]) throws {
    var inputs: [String] = []
    var markdownPath: String?
    var jsonPath: String?
    var pathFilter: String?
    var index = 0
    while index < arguments.count {
      switch arguments[index] {
      case "--markdown", "--json", "--path":
        let option = arguments[index]
        index += 1
        guard index < arguments.count else { throw CommandError.usage }
        if option == "--markdown" { markdownPath = arguments[index] }
        if option == "--json" { jsonPath = arguments[index] }
        if option == "--path" { pathFilter = arguments[index] }
      default:
        inputs.append(arguments[index])
      }
      index += 1
    }
    guard inputs.count == 2 else { throw CommandError.usage }
    let beforeURL = URL(fileURLWithPath: inputs[0])
    let afterURL = URL(fileURLWithPath: inputs[1])
    guard FileManager.default.fileExists(atPath: beforeURL.path) else {
      throw CommandError.missingInput(inputs[0])
    }
    guard FileManager.default.fileExists(atPath: afterURL.path) else {
      throw CommandError.missingInput(inputs[1])
    }
    let report = try RawPairAnalyzer().analyze(
      beforeData: Data(contentsOf: beforeURL),
      afterData: Data(contentsOf: afterURL),
      beforePath: inputs[0],
      afterPath: inputs[1],
      pathFilter: pathFilter
    )
    let renderer = RawPairReportRenderer()
    let markdown = renderer.markdown(report)
    print(markdown, terminator: "")
    if let markdownPath {
      try Data(markdown.utf8).writeAtomicallyIfSupported(to: URL(fileURLWithPath: markdownPath))
    }
    if let jsonPath {
      try renderer.jsonData(report).writeAtomicallyIfSupported(to: URL(fileURLWithPath: jsonPath))
    }
  }

  private static func runValidate(_ arguments: [String]) throws -> Bool {
    var inputs: [String] = []
    var markdownPath: String?
    var jsonPath: String?
    var dtdPath: String?
    var index = 0
    while index < arguments.count {
      switch arguments[index] {
      case "--markdown", "--json", "--dtd":
        let option = arguments[index]
        index += 1
        guard index < arguments.count else { throw CommandError.usage }
        if option == "--markdown" { markdownPath = arguments[index] }
        if option == "--json" { jsonPath = arguments[index] }
        if option == "--dtd" { dtdPath = arguments[index] }
      default:
        inputs.append(arguments[index])
      }
      index += 1
    }
    guard inputs.count == 1 else { throw CommandError.usage }
    let inputPath = inputs[0]
    let inputURL = URL(fileURLWithPath: inputPath)
    guard FileManager.default.fileExists(atPath: inputURL.path) else {
      throw CommandError.missingInput(inputPath)
    }
    let data = try Data(contentsOf: inputURL)
    let dtdURL = dtdPath.map { URL(fileURLWithPath: $0) }
    let report = try FCPXMLDTDValidator().validate(
      data: data,
      sourcePath: inputPath,
      dtdURL: dtdURL
    )
    let renderer = FCPXMLValidationReportRenderer()
    let markdown = renderer.markdown(report)
    print(markdown, terminator: "")
    if let markdownPath {
      try Data(markdown.utf8).writeAtomicallyIfSupported(to: URL(fileURLWithPath: markdownPath))
    }
    if let jsonPath {
      try renderer.jsonData(report).writeAtomicallyIfSupported(to: URL(fileURLWithPath: jsonPath))
    }
    return report.isValid
  }

  private static func collectFiles(_ paths: [String]) throws -> [URL] {
    var results: [URL] = []
    for path in paths {
      let url = URL(fileURLWithPath: path)
      var isDirectory: ObjCBool = false
      guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
        throw CommandError.missingInput(path)
      }
      if isDirectory.boolValue {
        let children = try FileManager.default.contentsOfDirectory(
          at: url,
          includingPropertiesForKeys: [.isRegularFileKey],
          options: [.skipsHiddenFiles]
        )
        results.append(contentsOf: children.filter { $0.pathExtension == "fcpxml" })
      } else if url.pathExtension == "fcpxml" {
        results.append(url)
      }
    }
    return Array(Set(results.map(\.standardizedFileURL))).sorted { $0.path < $1.path }
  }

  private static func writeError(_ message: String) {
    FileHandle.standardError.write(Data(message.utf8))
  }
}

private enum CommandError: Error, LocalizedError {
  case usage
  case noInputFiles
  case missingInput(String)

  var errorDescription: String? {
    switch self {
    case .usage:
      return """
        usage: fcpxml-diff schema-completeness <file-or-directory>... [--markdown path] [--json path] [--fail-if-total-exceeds count]
               fcpxml-diff compare <before.fcpxml> <after.fcpxml> [--path structural-path] [--markdown path] [--json path]
               fcpxml-diff validate <file.fcpxml> [--dtd path] [--markdown path] [--json path]
        """
    case .noInputFiles:
      return "no .fcpxml input files found"
    case .missingInput(let path):
      return "input does not exist: \(path)"
    }
  }
}
