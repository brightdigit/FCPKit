//
//  FCPXMLDSLCommand.swift
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

@main
internal enum FCPXMLDSLCommand {
  internal static func main() async {
    do {
      try await run(Array(CommandLine.arguments.dropFirst()))
    } catch {
      FileHandle.standardError.write(
        Data("fcpxml-dsl: \(error.localizedDescription)\n".utf8)
      )
      printUsage()
      Foundation.exit(2)
    }
  }

  private static func run(_ arguments: [String]) async throws {
    if arguments.isEmpty || arguments.contains("-h") || arguments.contains("--help") {
      printUsage()
      return
    }
    var rest = Array(arguments.dropFirst())
    switch arguments.first {
    case "export":
      guard !rest.isEmpty else {
        throw FCPXMLDSLCommandError.usage
      }
      let kind = rest.removeFirst()
      let options = try parseOptions(&rest)
      try await export(kind: kind, positionals: rest, options: options)
    case "verify-import":
      let options = try parseOptions(&rest)
      try await verifyImport(positionals: rest, options: options)
    default:
      throw FCPXMLDSLCommandError.usage
    }
  }

  private static func export(
    kind: String,
    positionals: [String],
    options: [String: String]
  ) async throws {
    #if canImport(AVFoundation)
      let version = FCPXMLVersion(options["version"] ?? "1.14")
      let projectName = options["project"] ?? defaultProjectName(for: kind)
      switch kind {
      case "transitions":
        try await exportTransitionsCommand(positionals, projectName: projectName, version: version)
      case "titles":
        try await exportTitlesCommand(
          positionals,
          projectName: projectName,
          titleText: options["text"] ?? "Title",
          version: version
        )
      case "rgb":
        try await exportRGBCommand(positionals, projectName: projectName, version: version)
      case "presentation":
        try await exportPresentationCommand(
          positionals,
          projectName: projectName,
          version: version
        )
      default:
        throw FCPXMLDSLCommandError.usage
      }
    #else
      throw FCPXMLDSLCommandError.unsupportedPlatform
    #endif
  }

  #if canImport(AVFoundation)
    private static func exportTransitionsCommand(
      _ positionals: [String],
      projectName: String,
      version: FCPXMLVersion
    ) async throws {
      guard positionals.count >= 2 else {
        throw FCPXMLDSLCommandError.usage
      }
      try await exportTransitions(
        left: URL(fileURLWithPath: positionals[0]),
        right: URL(fileURLWithPath: positionals[1]),
        output: URL(fileURLWithPath: positionals.count > 2 ? positionals[2] : "transitions.fcpxml"),
        projectName: projectName,
        version: version
      )
    }

    private static func exportTitlesCommand(
      _ positionals: [String],
      projectName: String,
      titleText: String,
      version: FCPXMLVersion
    ) async throws {
      guard positionals.count >= 1 else {
        throw FCPXMLDSLCommandError.usage
      }
      try await exportTitles(
        media: URL(fileURLWithPath: positionals[0]),
        output: URL(fileURLWithPath: positionals.count > 1 ? positionals[1] : "titles.fcpxml"),
        projectName: projectName,
        titleText: titleText,
        version: version
      )
    }

    private static func exportRGBCommand(
      _ positionals: [String],
      projectName: String,
      version: FCPXMLVersion
    ) async throws {
      let output = URL(fileURLWithPath: positionals.first ?? "rgb.fcpxml")
      try await exportRGB(
        output: output,
        projectName: projectName,
        version: version
      )
    }

    private static func exportPresentationCommand(
      _ positionals: [String],
      projectName: String,
      version: FCPXMLVersion
    ) async throws {
      let output = URL(fileURLWithPath: positionals.first ?? "presentation.fcpxml")
      try await exportPresentation(
        output: output,
        projectName: projectName,
        version: version
      )
    }
  #endif

  private static func parseOptions(_ arguments: inout [String]) throws -> [String: String] {
    var values: [String: String] = [:]
    var index = 0
    while index < arguments.count {
      let token = arguments[index]
      guard token.hasPrefix("--") else {
        index += 1
        continue
      }
      guard index + 1 < arguments.count else {
        throw FCPXMLDSLCommandError.usage
      }
      values[String(token.dropFirst(2))] = arguments[index + 1]
      arguments.removeSubrange(index...(index + 1))
    }
    return values
  }

  private static func defaultProjectName(for kind: String) -> String {
    switch kind {
    case "transitions":
      return "DSL Transitions"
    case "titles":
      return "DSL Titles"
    case "rgb":
      return "DSL RGB"
    case "presentation":
      return "FCPKit Presentation"
    default:
      return "DSL Export"
    }
  }
}
