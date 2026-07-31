//
//  FCPScriptingMediaTimeTests.swift
//  FCPKitScriptingTests
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
import Testing

@testable import FCPKitScripting

@Suite
internal struct FCPScriptingMediaTimeTests {
  @Test
  internal func mapsMediaTimeRecordToFCPTime() throws {
    let record: [String: Any] = [
      "value": NSNumber(value: 1_001), "timescale": NSNumber(value: 24_000),
    ]
    let time = try #require(FCPScriptingMediaTime.fcpTime(from: record))
    #expect(time == FCPTime(numerator: 1_001, denominator: 24_000))
    #expect(time.description == "1001/24000s")
  }

  @Test
  internal func rejectsZeroTimescale() {
    let record: [String: Any] = ["value": NSNumber(value: 1), "timescale": NSNumber(value: 0)]
    #expect(FCPScriptingMediaTime.fcpTime(from: record) == nil)
  }
}
