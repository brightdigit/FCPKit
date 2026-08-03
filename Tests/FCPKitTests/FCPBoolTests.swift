//
//  FCPBoolTests.swift
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
internal struct FCPBoolTests {
  @Test
  internal func parsesOneAndZero() throws {
    let enabled = try #require(FCPBool("1"))
    #expect(enabled.value)
    #expect(enabled.description == "1")

    let disabled = try #require(FCPBool("0"))
    #expect(!disabled.value)
    #expect(disabled.description == "0")
  }

  @Test(arguments: ["", "true", "false", "2", "01", "yes", " 1", "1 "])
  internal func rejectsAnythingElse(_ raw: String) {
    #expect(FCPBool(raw) == nil)
  }

  @Test
  internal func supportsBooleanLiterals() {
    let enabled: FCPBool = true
    let disabled: FCPBool = false
    #expect(enabled.value)
    #expect(!disabled.value)
    #expect(enabled == FCPBool(true))
    #expect(disabled == FCPBool(false))
  }
}
