//
//  FCPBool.swift
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

/// A boolean FCPXML attribute encoded as `"1"` or `"0"`.
///
/// FCPXML boolean attributes (for example `enabled="1"`) use exactly these two
/// strings; any other input is illegal and fails parsing.
public struct FCPBool: ExpressibleByBooleanLiteral, ExpressibleByStringLiteral, XMLAttributeValue {
  /// The wrapped boolean value.
  public var value: Bool

  /// The FCPXML attribute string: `"1"` for true, `"0"` for false.
  public var description: String {
    value ? "1" : "0"
  }

  /// Creates a value wrapping the given boolean.
  public init(_ value: Bool) {
    self.value = value
  }

  /// Creates a value from a boolean literal.
  public init(booleanLiteral value: Bool) {
    self.init(value)
  }

  /// Creates a value from a string literal ("1" or "0").
  public init(stringLiteral value: String) {
    guard let boolVal = FCPBool(value) else {
      preconditionFailure("Invalid FCPBool string literal: '\(value)'")
    }
    self = boolVal
  }

  /// Creates a value from `"1"` or `"0"`; any other string is illegal.
  public init?(_ description: String) {
    switch description {
    case "1":
      self.init(true)
    case "0":
      self.init(false)
    default:
      return nil
    }
  }
}
