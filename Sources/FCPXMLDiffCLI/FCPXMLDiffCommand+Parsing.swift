//
//  FCPXMLDiffCommand+Parsing.swift
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

extension FCPXMLDiffCommand {
  /// Splits `arguments` into positional inputs and `--flag value` pairs.
  ///
  /// Every flag in `valueFlags` consumes the argument that follows it; anything
  /// else is treated as a positional input.
  /// - Throws: `CommandError.usage` if a flag is missing its value.
  internal static func parseOptions(
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

  /// Resolves a path to a URL, requiring the file to exist.
  /// - Throws: `CommandError.missingInput` if no file exists at `path`.
  internal static func existingFile(at path: String) throws -> URL {
    let url = URL(fileURLWithPath: path)
    guard FileManager.default.fileExists(atPath: url.path) else {
      throw CommandError.missingInput(path)
    }
    return url
  }

  internal static func collectFiles(_ paths: [String]) throws -> [URL] {
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
}
