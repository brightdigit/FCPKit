//
//  FCPXMLDiffCommand.swift
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

@main
internal enum FCPXMLDiffCommand {
  /// Positional inputs plus the value of each `--flag value` pair.
  internal struct Options {
    internal let inputs: [String]
    internal let values: [String: String]

    internal subscript(flag: String) -> String? { values[flag] }
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

  internal static func writeError(_ message: String) {
    FileHandle.standardError.write(Data(message.utf8))
  }
}
