//
//  FCPTimeArithmeticTests.swift
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
import Testing

@Suite
internal struct FCPTimeArithmeticTests {
  @Test
  internal func addsExactlyOverCommonDenominator() throws {
    let frame = try #require(FCPTime("1001/30000s"))
    let sum = try frame.adding(frame)
    #expect(sum.description == "2002/30000s")

    let five = try #require(FCPTime("5s"))
    let mixed = try five.adding(FCPTime(numerator: 1, denominator: 2))
    #expect(mixed.description == "11/2s")
  }

  @Test
  internal func wholeResultsRenderAsWholeSeconds() throws {
    let five = try #require(FCPTime("5s"))
    let sum = try five.adding(five)
    #expect(sum.description == "10s")
  }

  @Test
  internal func subtractsExactlyOverCommonDenominator() throws {
    let five = try #require(FCPTime("5s"))
    let frame = try #require(FCPTime("1001/30000s"))
    let difference = try five.subtracting(frame)
    #expect(difference.description == "148999/30000s")

    let negative = try FCPTime.zero.subtracting(five)
    #expect(negative.description == "-5s")
  }

  @Test
  internal func neverRendersDecimalSeconds() throws {
    let tenTwentyFourths = FCPTime(numerator: 10, denominator: 24)
    let third = FCPTime(numerator: 1, denominator: 3)
    let sum = try tenTwentyFourths.adding(third)
    #expect(!sum.description.contains("."))
    #expect(sum.description == "18/24s")
    #expect(sum == FCPTime(numerator: 3, denominator: 4))
  }

  @Test
  internal func throwsOnNumeratorOverflow() {
    let huge = FCPTime(numerator: Int64.max)
    #expect(throws: FCPTimeError.overflow) {
      _ = try huge.adding(FCPTime(numerator: 1))
    }
    #expect(throws: FCPTimeError.overflow) {
      _ = try FCPTime(numerator: Int64.min).subtracting(FCPTime(numerator: 1))
    }
  }

  @Test
  internal func throwsOnCommonDenominatorOverflow() {
    let first = FCPTime(numerator: 1, denominator: Int32.max)
    let second = FCPTime(numerator: 1, denominator: Int32.max - 1)
    #expect(throws: FCPTimeError.overflow) {
      _ = try first.adding(second)
    }
  }

  @Test
  internal func convertsFrameCountsExactly() throws {
    let frameDuration = try #require(FCPTime("1001/30000s"))
    let duration = try FCPTime.frames(120, at: frameDuration)
    #expect(duration.description == "120120/30000s")
    #expect(throws: FCPTimeError.overflow) {
      _ = try FCPTime.frames(Int64.max, at: frameDuration)
    }
  }

  @Test
  internal func reductionIsExplicitlyOptIn() throws {
    let unreduced = try #require(FCPTime("22800/2400s"))
    let reduced = unreduced.reduced()
    #expect(unreduced.description == "22800/2400s")
    #expect(reduced.description == "19/2s")

    let unitDenominator = try #require(FCPTime("5/1s"))
    #expect(unitDenominator.reduced().description == "5s")
  }
}
