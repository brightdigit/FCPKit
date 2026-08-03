//
//  FCPTime+Interval.swift
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

extension FCPTime {
  /// Creates an ``FCPTime`` from a floating-point `TimeInterval` (seconds).
  public init(_ interval: TimeInterval) {
    self = FCPTime.seconds(interval)
  }

  /// Creates an ``FCPTime`` from Swift's `Duration` type.
  @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
  public init(_ duration: Swift.Duration) {
    let (seconds, attoseconds) = duration.components
    let fractional = Double(attoseconds) / 1e18
    let total = Double(seconds) + fractional
    self = FCPTime.seconds(total)
  }

  /// Creates an ``FCPTime`` from seconds.
  public static func seconds(_ seconds: Double) -> FCPTime {
    if seconds.truncatingRemainder(dividingBy: 1) == 0 {
      return FCPTime(numerator: Int64(seconds), denominator: 1, form: .whole)
    } else {
      let scale: Int32 = 1_000
      let num = Int64((seconds * Double(scale)).rounded())
      return FCPTime(numerator: num, denominator: scale, form: .rational)
    }
  }

  /// Creates an ``FCPTime`` from seconds.
  public static func seconds(_ seconds: Int) -> FCPTime {
    FCPTime.seconds(Double(seconds))
  }

  /// Creates an ``FCPTime`` from minutes (1 minute = 60 seconds).
  public static func minutes(_ minutes: Double) -> FCPTime {
    FCPTime.seconds(minutes * 60.0)
  }

  /// Creates an ``FCPTime`` from minutes (1 minute = 60 seconds).
  public static func minutes(_ minutes: Int) -> FCPTime {
    FCPTime.minutes(Double(minutes))
  }

  /// Creates an ``FCPTime`` from hours (1 hour = 3600 seconds).
  public static func hours(_ hours: Double) -> FCPTime {
    FCPTime.seconds(hours * 3_600.0)
  }

  /// Creates an ``FCPTime`` from hours (1 hour = 3600 seconds).
  public static func hours(_ hours: Int) -> FCPTime {
    FCPTime.hours(Double(hours))
  }
}
