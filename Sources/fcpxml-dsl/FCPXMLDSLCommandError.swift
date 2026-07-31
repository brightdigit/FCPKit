//
//  FCPXMLDSLCommandError.swift
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

/// Failures from the `fcpxml-dsl` command-line tool.
internal enum FCPXMLDSLCommandError: Error, LocalizedError {
  case usage
  case fileNotFound(String)
  case invalidDuration(String)
  case unsupportedPlatform
  case missingProjectName(String)
  case finalCutUnavailable
  case importRejected(String)
  case importTimedOut(String)

  internal var errorDescription: String? {
    switch self {
    case .usage:
      return "invalid arguments; run fcpxml-dsl --help"
    case .fileNotFound(let path):
      return "file not found: \(path)"
    case .invalidDuration(let path):
      return "could not read a usable duration from \(path)"
    case .unsupportedPlatform:
      return "fcpxml-dsl requires AVFoundation to probe media durations"
    case .missingProjectName(let path):
      return "no project name found in \(path); pass --project <name>"
    case .finalCutUnavailable:
      return "Final Cut Pro is not installed or did not become scriptable"
    case .importRejected(let message):
      return "Final Cut Pro rejected the import:\n\(message)"
    case .importTimedOut(let names):
      return "timed out waiting for project(s) \(names) to appear in Final Cut Pro"
    }
  }
}
