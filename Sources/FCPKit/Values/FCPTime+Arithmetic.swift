//
//  FCPTime+Arithmetic.swift
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

extension FCPTime {
  /// A frame count converted to a time at the given frame duration.
  ///
  /// - Throws: ``FCPTimeError/overflow`` when the exact product cannot be represented.
  public static func frames(_ count: Int64, at frameDuration: FCPTime) throws -> FCPTime {
    let (numerator, overflow) = count.multipliedReportingOverflow(by: frameDuration.numerator)
    guard !overflow else {
      throw FCPTimeError.overflow
    }
    return FCPTime(numerator: numerator, denominator: frameDuration.denominator)
  }

  private static func commonDenominator(_ first: Int32, _ second: Int32) throws -> Int32 {
    let divisor = Int32(greatestCommonDivisor(UInt64(first), UInt64(second)))
    let (multiple, overflow) = (first / divisor).multipliedReportingOverflow(by: second)
    guard !overflow else {
      throw FCPTimeError.overflow
    }
    return multiple
  }

  /// Adds another time exactly over the least common denominator.
  ///
  /// The result is a rational value — never decimal seconds — rendered as whole
  /// seconds only when the common denominator is 1.
  ///
  /// - Throws: ``FCPTimeError/overflow`` when the exact result cannot be represented.
  public func adding(_ other: FCPTime) throws -> FCPTime {
    let common = try Self.commonDenominator(denominator, other.denominator)
    let lhs = try numeratorScaled(to: common)
    let rhs = try other.numeratorScaled(to: common)
    let (sum, overflow) = lhs.addingReportingOverflow(rhs)
    guard !overflow else {
      throw FCPTimeError.overflow
    }
    return FCPTime(numerator: sum, denominator: common)
  }

  /// Subtracts another time exactly over the least common denominator.
  ///
  /// The result is a rational value — never decimal seconds — rendered as whole
  /// seconds only when the common denominator is 1.
  ///
  /// - Throws: ``FCPTimeError/overflow`` when the exact result cannot be represented.
  public func subtracting(_ other: FCPTime) throws -> FCPTime {
    let common = try Self.commonDenominator(denominator, other.denominator)
    let lhs = try numeratorScaled(to: common)
    let rhs = try other.numeratorScaled(to: common)
    let (difference, overflow) = lhs.subtractingReportingOverflow(rhs)
    guard !overflow else {
      throw FCPTimeError.overflow
    }
    return FCPTime(numerator: difference, denominator: common)
  }

  /// This time with its fraction fully reduced and rendered in canonical form.
  ///
  /// Reduction is strictly opt-in: parsed values always keep their written
  /// fraction, so `"22800/2400s"` round-trips unchanged unless a caller asks
  /// for `reduced()`, which yields `"19/2s"`.
  public func reduced() -> FCPTime {
    let divisor = Int64(Self.greatestCommonDivisor(numerator.magnitude, UInt64(denominator)))
    return FCPTime(
      numerator: numerator / divisor,
      denominator: Int32(Int64(denominator) / divisor)
    )
  }

  private func numeratorScaled(to common: Int32) throws -> Int64 {
    let (scaled, overflow) = numerator.multipliedReportingOverflow(by: Int64(common / denominator))
    guard !overflow else {
      throw FCPTimeError.overflow
    }
    return scaled
  }
}
