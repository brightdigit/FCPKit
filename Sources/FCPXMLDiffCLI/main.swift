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
  /// Positional inputs plus the value of each `--flag value` pair.
  private struct Options {
    let inputs: [String]
    let values: [String: String]

    subscript(flag: String) -> String? { values[flag] }
  }

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

  /// Splits `arguments` into positional inputs and `--flag value` pairs.
  ///
  /// Every flag in `valueFlags` consumes the argument that follows it; anything
  /// else is treated as a positional input.
  /// - Throws: `CommandError.usage` if a flag is missing its value.
  private static func parseOptions(
    _ arguments: [String],
    valueFlags: Set<String>
  ) throws -> Options {
    var inputs: [String] = []
    var values: [String: String] = [:]
    var index = 0
    while index < arguments.count {
      let argument = arguments[index]
      if valueFlags.contains(argument) {
        index += 1
        guard index < arguments.count else {
          throw CommandError.usage
        }
        values[argument] = arguments[index]
      } else {
        inputs.append(argument)
      }
      index += 1
    }
    return Options(inputs: inputs, values: values)
  }

  /// Prints a rendered report and writes the optional `--markdown`/`--json` copies.
  private static func emit(
    markdown: String,
    jsonData: @autoclosure () throws -> Data,
    options: Options
  ) throws {
    print(markdown, terminator: "")
    if let path = options["--markdown"] {
      try Data(markdown.utf8).writeAtomicallyIfSupported(to: URL(fileURLWithPath: path))
    }
    if let path = options["--json"] {
      try jsonData().writeAtomicallyIfSupported(to: URL(fileURLWithPath: path))
    }
  }

  private static func runSchemaCompleteness(_ arguments: [String]) throws -> Bool {
    let options = try parseOptions(
      arguments,
      valueFlags: ["--markdown", "--json", "--fail-if-total-exceeds"]
    )
    guard !options.inputs.isEmpty else {
      throw CommandError.usage
    }
    var maximumTotalLoss: Int?
    if let raw = options["--fail-if-total-exceeds"] {
      guard let value = Int(raw), value >= 0 else {
        throw CommandError.usage
      }
      maximumTotalLoss = value
    }

    let fileURLs = try collectFiles(options.inputs)
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
    try emit(
      markdown: renderer.markdown(report),
      jsonData: try renderer.jsonData(report),
      options: options
    )
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
    let options = try parseOptions(arguments, valueFlags: ["--markdown", "--json", "--path"])
    guard options.inputs.count == 2 else {
      throw CommandError.usage
    }
    let beforeURL = try existingFile(at: options.inputs[0])
    let afterURL = try existingFile(at: options.inputs[1])
    let report = try RawPairAnalyzer().analyze(
      beforeData: Data(contentsOf: beforeURL),
      afterData: Data(contentsOf: afterURL),
      beforePath: options.inputs[0],
      afterPath: options.inputs[1],
      pathFilter: options["--path"]
    )
    let renderer = RawPairReportRenderer()
    try emit(
      markdown: renderer.markdown(report),
      jsonData: try renderer.jsonData(report),
      options: options
    )
  }

  private static func runValidate(_ arguments: [String]) throws -> Bool {
    let options = try parseOptions(arguments, valueFlags: ["--markdown", "--json", "--dtd"])
    guard options.inputs.count == 1 else {
      throw CommandError.usage
    }
    let inputPath = options.inputs[0]
    let inputURL = try existingFile(at: inputPath)
    let report = try FCPXMLDTDValidator().validate(
      data: try Data(contentsOf: inputURL),
      sourcePath: inputPath,
      dtdURL: options["--dtd"].map { URL(fileURLWithPath: $0) }
    )
    let renderer = FCPXMLValidationReportRenderer()
    try emit(
      markdown: renderer.markdown(report),
      jsonData: try renderer.jsonData(report),
      options: options
    )
    return report.isValid
  }

  /// Resolves a path to a URL, requiring the file to exist.
  /// - Throws: `CommandError.missingInput` if no file exists at `path`.
  private static func existingFile(at path: String) throws -> URL {
    let url = URL(fileURLWithPath: path)
    guard FileManager.default.fileExists(atPath: url.path) else {
      throw CommandError.missingInput(path)
    }
    return url
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
