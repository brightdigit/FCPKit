//
//  CommandError.swift
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

internal enum CommandError: Error, LocalizedError {
  case usage
  case noInputFiles
  case missingInput(String)

  internal var errorDescription: String? {
    switch self {
    case .usage:
      // Usage text is laid out for a terminal: the continuation lines are
      // aligned under the first, and rewrapping them would change what users
      // see. The layout rules measure this prose as if it were Swift.
      // swiftlint:disable indentation_width line_length
      return """
        usage: fcpxml-diff schema-completeness <file-or-directory>... [--markdown path] [--json path] [--fail-if-total-exceeds count]
               fcpxml-diff compare <before.fcpxml> <after.fcpxml> [--path structural-path] [--markdown path] [--json path]
               fcpxml-diff validate <file.fcpxml> [--dtd path] [--markdown path] [--json path]
        """
    // swiftlint:enable indentation_width line_length
    case .noInputFiles:
      return "no .fcpxml input files found"
    case .missingInput(let path):
      return "input does not exist: \(path)"
    }
  }
}
