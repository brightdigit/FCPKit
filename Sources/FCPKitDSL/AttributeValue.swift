//
//  AttributeValue.swift
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

/// Renders Swift values as FCPXML attribute strings.
internal enum AttributeValue {
  /// Formats a `Double` for an FCPXML attribute, collapsing whole numbers.
  ///
  /// Final Cut writes `63` rather than `63.0`, so whole values lose their
  /// fractional part. Values outside `Int`'s range, and non-finite values, fall
  /// back to the plain `Double` description: converting them with `Int(_:)`
  /// would trap and take the host process down with it.
  ///
  /// `Decimal.FormatStyle` is deliberately not used here. It is locale-aware, so
  /// `63.5` renders as `63,5` under a German or French locale, which is invalid
  /// FCPXML; it rounds to six fractional digits, which would corrupt position
  /// values like `7.777777777`; and `Decimal(Double.infinity)` traps outright.
  internal static func decimal(_ value: Double) -> String {
    guard value.isFinite else {
      return String(value)
    }
    guard value.truncatingRemainder(dividingBy: 1) == 0,
      value >= Double(Int.min), value <= Double(Int.max)
    else {
      return String(value)
    }
    return String(Int(value))
  }
}
