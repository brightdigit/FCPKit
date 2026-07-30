//
//  FCPTimeParsingTests.swift
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
internal struct FCPTimeParsingTests {
  @Test(
    arguments: [
      "5s", "0s", "1001/30000s", "22800/2400s", "-3600s", "5/1s", "3600s", "-1001/30000s",
    ]
  )
  internal func roundTripsByteIdentically(_ raw: String) throws {
    let time = try #require(FCPTime(raw))
    #expect(time.description == raw)
    #expect(time.description == raw)
  }

  @Test(
    arguments: [
      "", "5", "s", "5/0s", "0/0s", "abc", "5.5s", "5 s", " 5s", "+5s", "5/-2s", "-5/-2s",
      "5/s", "/2s", "5//2s", "1/2/3s", "5S", "٥s", "9223372036854775808s", "5/4294967296s",
      "5/+2s", "1e3s",
    ]
  )
  internal func rejectsIllegalStrings(_ raw: String) {
    #expect(FCPTime(raw) == nil)
  }

  @Test
  internal func remembersWrittenForm() throws {
    let whole = try #require(FCPTime("5s"))
    #expect(whole.form == .whole)
    #expect(whole.numerator == 5)
    #expect(whole.denominator == 1)

    let rational = try #require(FCPTime("1001/30000s"))
    #expect(rational.form == .rational)
    #expect(rational.numerator == 1_001)
    #expect(rational.denominator == 30_000)
  }

  @Test
  internal func neverReducesOrRewritesFractions() throws {
    let unreduced = try #require(FCPTime("22800/2400s"))
    #expect(unreduced.description == "22800/2400s")

    let unitDenominator = try #require(FCPTime("5/1s"))
    #expect(unitDenominator.description == "5/1s")
    #expect(unitDenominator.form == .rational)
  }

  @Test
  internal func constructionPicksNaturalForm() {
    #expect(FCPTime(numerator: 5).description == "5s")
    #expect(FCPTime(numerator: 5, denominator: 2).description == "5/2s")
    #expect(FCPTime(numerator: 5, denominator: 1, form: .rational).description == "5/1s")
    #expect(FCPTime.zero.description == "0s")
  }

  @Test
  internal func parsesNegativeWholeAndRationalTimes() throws {
    let negativeWhole = try #require(FCPTime("-3600s"))
    #expect(negativeWhole.numerator == -3_600)
    #expect(negativeWhole.denominator == 1)

    let negativeRational = try #require(FCPTime("-1001/30000s"))
    #expect(negativeRational.numerator == -1_001)
    #expect(negativeRational.denominator == 30_000)
  }

  @Test
  internal func supportsLosslessStringConvertible() throws {
    let time = try #require(FCPTime("22800/2400s"))
    #expect(String(describing: time) == "22800/2400s")
  }
}
