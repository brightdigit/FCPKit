//
//  FCPTime.swift
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

/// A rational FCPXML time value that preserves the exact textual form it was written in.
///
/// FCPXML times are rational seconds — `"5s"`, `"0s"`, `"1001/30000s"`,
/// `"22800/2400s"` — and may be negative for some attributes. Parsing stores the
/// numerator and denominator exactly as written plus the written ``Form``, and
/// never renormalizes, so re-encoding is byte-identical: `"5s"` never becomes
/// `"5/1s"` and `"22800/2400s"` never reduces. Equality, ordering, and hashing
/// compare mathematical value only; use ``isIdenticallyFormatted(to:)`` to
/// compare rendered forms, and ``reduced()`` to opt in to fraction reduction.
public struct FCPTime: XMLAttributeValue, Comparable {
  /// How a time value is rendered in FCPXML.
  public enum Form: Hashable, Sendable {
    /// Whole seconds, e.g. `"5s"`; requires a denominator of 1.
    case whole

    /// An explicit fraction, e.g. `"1001/30000s"` or `"5/1s"`.
    case rational
  }

  /// Zero seconds, rendered as `"0s"`.
  public static let zero = FCPTime(numerator: 0)

  /// The numerator in rational seconds; negative values are legal FCPXML times.
  public let numerator: Int64

  /// The denominator in rational seconds; always positive, and 1 for whole-second values.
  public let denominator: Int32

  /// The rendering form preserved from parsing or chosen at construction.
  public let form: Form

  /// The FCPXML attribute string, rendered per ``form`` and never as decimal seconds.
  public var description: String {
    switch form {
    case .whole: "\(numerator)s"
    case .rational: "\(numerator)/\(denominator)s"
    }
  }

  /// The approximate value in floating-point seconds, for display and diagnostics only.
  public var seconds: Double {
    Double(numerator) / Double(denominator)
  }

  /// Creates a time from a rational number of seconds.
  ///
  /// With no explicit `form`, a denominator of 1 renders as whole seconds and any
  /// other denominator renders as a fraction. A `.whole` form is honored only when
  /// the denominator is 1, so rendering can never lose the denominator.
  public init(numerator: Int64, denominator: Int32 = 1, form: Form? = nil) {
    precondition(denominator > 0, "FCPTime denominator must be positive")
    self.numerator = numerator
    self.denominator = denominator
    self.form = denominator == 1 ? (form ?? .whole) : .rational
  }

  /// Creates a time from its FCPXML string, or nil for illegal input.
  ///
  /// Legal forms are `-?digits s` and `-?digits / digits s` with a positive
  /// denominator, such as `"5s"`, `"-3600s"`, or `"1001/30000s"`. Decimal
  /// seconds, whitespace, explicit plus signs, and zero denominators are illegal.
  public init?(_ description: String) {
    guard description.hasSuffix("s"), let parsed = Self.parse(body: description.dropLast())
    else {
      return nil
    }
    self = parsed
  }

  /// Returns true when two times are mathematically equal, regardless of written form.
  public static func == (lhs: FCPTime, rhs: FCPTime) -> Bool {
    crossProduct(lhs, rhs) == crossProduct(rhs, lhs)
  }

  /// Orders times by mathematical value using exact full-width cross-multiplication.
  public static func < (lhs: FCPTime, rhs: FCPTime) -> Bool {
    let left = crossProduct(lhs, rhs)
    let right = crossProduct(rhs, lhs)
    if left.high != right.high {
      return left.high < right.high
    }
    return left.low < right.low
  }

  internal static func greatestCommonDivisor(_ first: UInt64, _ second: UInt64) -> UInt64 {
    var first = first
    var second = second
    while second != 0 {
      (first, second) = (second, first % second)
    }
    return first
  }

  private static func parse(body: Substring) -> FCPTime? {
    let parts = body.split(separator: "/", omittingEmptySubsequences: false)
    guard let first = parts.first, let numerator = parseNumerator(first) else {
      return nil
    }
    if parts.count == 1 {
      return FCPTime(numerator: numerator)
    }
    guard parts.count == 2, let denominator = parseDenominator(parts[1]) else {
      return nil
    }
    return FCPTime(numerator: numerator, denominator: denominator, form: .rational)
  }

  private static func parseNumerator(_ text: Substring) -> Int64? {
    var digits = text
    if digits.first == "-" {
      digits = digits.dropFirst()
    }
    guard isDecimalDigits(digits) else {
      return nil
    }
    return Int64(text)
  }

  private static func parseDenominator(_ text: Substring) -> Int32? {
    guard isDecimalDigits(text), let value = Int32(text), value > 0 else {
      return nil
    }
    return value
  }

  private static func isDecimalDigits(_ text: Substring) -> Bool {
    !text.isEmpty && text.allSatisfy { $0.isASCII && $0.isNumber }
  }

  private static func crossProduct(
    _ value: FCPTime,
    _ other: FCPTime
  ) -> (high: Int64, low: UInt64) {
    value.numerator.multipliedFullWidth(by: Int64(other.denominator))
  }

  /// Hashes the reduced fraction, so mathematically equal values hash equally.
  public func hash(into hasher: inout Hasher) {
    let divisor = Int64(Self.greatestCommonDivisor(numerator.magnitude, UInt64(denominator)))
    hasher.combine(numerator / divisor)
    hasher.combine(Int64(denominator) / divisor)
  }

  /// Returns true when both the value and the written form match exactly.
  ///
  /// Unlike `==`, this distinguishes `"5s"` from `"5/1s"` and `"19/2s"` from
  /// `"22800/2400s"`; it is the byte-stability check for round-trip tests.
  public func isIdenticallyFormatted(to other: FCPTime) -> Bool {
    numerator == other.numerator && denominator == other.denominator && form == other.form
  }
}

// MARK: - Time Interval & Duration Extensions

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
