//
//  FCPTimeEqualityTests.swift
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
internal struct FCPTimeEqualityTests {
  @Test
  internal func equalityIgnoresRenderingForm() throws {
    let unreduced = try #require(FCPTime(fcpxmlString: "22800/2400s"))
    let reduced = try #require(FCPTime(fcpxmlString: "19/2s"))
    let scaled = FCPTime(numerator: 95, denominator: 10)
    #expect(unreduced == reduced)
    #expect(unreduced == scaled)

    let whole = try #require(FCPTime(fcpxmlString: "5s"))
    let fraction = try #require(FCPTime(fcpxmlString: "5/1s"))
    #expect(whole == fraction)
  }

  @Test
  internal func distinctValuesAreNotEqual() throws {
    let ntsc = try #require(FCPTime(fcpxmlString: "1001/30000s"))
    let ideal = try #require(FCPTime(fcpxmlString: "1/30s"))
    #expect(ntsc != ideal)
  }

  @Test
  internal func equalValuesHashEqually() throws {
    let unreduced = try #require(FCPTime(fcpxmlString: "22800/2400s"))
    let reduced = try #require(FCPTime(fcpxmlString: "19/2s"))
    #expect(unreduced.hashValue == reduced.hashValue)

    let whole = try #require(FCPTime(fcpxmlString: "5s"))
    let fraction = try #require(FCPTime(fcpxmlString: "5/1s"))
    #expect(whole.hashValue == fraction.hashValue)
  }

  @Test
  internal func identicalFormattingIsStricterThanEquality() throws {
    let whole = try #require(FCPTime(fcpxmlString: "5s"))
    let fraction = try #require(FCPTime(fcpxmlString: "5/1s"))
    #expect(whole.isIdenticallyFormatted(to: whole))
    #expect(!whole.isIdenticallyFormatted(to: fraction))

    let unreduced = try #require(FCPTime(fcpxmlString: "22800/2400s"))
    let reduced = try #require(FCPTime(fcpxmlString: "19/2s"))
    #expect(!unreduced.isIdenticallyFormatted(to: reduced))
  }

  @Test
  internal func comparesByMathematicalValue() throws {
    let ntsc = try #require(FCPTime(fcpxmlString: "1001/30000s"))
    let ideal = try #require(FCPTime(fcpxmlString: "1/30s"))
    #expect(ideal < ntsc)

    let negative = try #require(FCPTime(fcpxmlString: "-1s"))
    #expect(negative < FCPTime.zero)
    #expect(FCPTime.zero < ntsc)
  }

  @Test
  internal func comparesExtremeMagnitudesWithoutOverflow() {
    let largest = FCPTime(numerator: Int64.max, denominator: 30_000)
    let nextLargest = FCPTime(numerator: Int64.max - 1, denominator: 30_000)
    let smallest = FCPTime(numerator: Int64.min, denominator: 24_000)
    #expect(nextLargest < largest)
    #expect(smallest < nextLargest)
    #expect(largest == FCPTime(numerator: Int64.max, denominator: 30_000))
  }

  @Test
  internal func exposesApproximateSeconds() throws {
    let time = try #require(FCPTime(fcpxmlString: "22800/2400s"))
    #expect(time.seconds == 9.5)
  }
}
