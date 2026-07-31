//
//  FCPScriptingMediaTime.swift
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

internal enum FCPScriptingMediaTime {
  internal static func fcpTime(from value: Any?) -> FCPTime? {
    guard let dictionary = value as? [String: Any] else {
      return nil
    }
    guard let rawValue = dictionary["value"],
      let rawTimescale = dictionary["timescale"]
    else {
      return nil
    }
    let numerator = (rawValue as? NSNumber)?.int64Value ?? Int64((rawValue as? Double) ?? 0)
    let timescale = (rawTimescale as? NSNumber)?.int32Value ?? Int32((rawTimescale as? Int) ?? 0)
    guard timescale > 0 else {
      return nil
    }
    return FCPTime(numerator: numerator, denominator: timescale)
  }
}
