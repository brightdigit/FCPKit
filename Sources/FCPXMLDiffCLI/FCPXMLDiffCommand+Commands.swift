//
//  FCPXMLDiffCommand+Commands.swift
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

extension FCPXMLDiffCommand {
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

  internal static func runSchemaCompleteness(_ arguments: [String]) throws -> Bool {
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

  internal static func runCompare(_ arguments: [String]) throws {
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

  internal static func runValidate(_ arguments: [String]) throws -> Bool {
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
}
