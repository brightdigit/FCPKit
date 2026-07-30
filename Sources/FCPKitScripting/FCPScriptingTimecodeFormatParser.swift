//
//  FCPScriptingTimecodeFormatParser.swift
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

internal enum FCPScriptingTimecodeFormatParser {
  internal static func parse(_ value: Any?) -> FCPScriptedTimecodeFormat {
    let normalized = stringValue(value)
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .lowercased()
    switch normalized {
    case "drop frame", "dropframe", "df":
      return .dropFrame
    case "non drop frame", "non-drop frame", "nondropframe", "ndf", "non dropframe":
      return .nonDropFrame
    default:
      return .unspecified
    }
  }

  private static func stringValue(_ value: Any?) -> String {
    switch value {
    case let text as String:
      text
    case let text as NSString:
      text as String
    case let number as NSNumber:
      number.stringValue
    default:
      ""
    }
  }
}
