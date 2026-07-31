//
//  FCPScriptingTimecodeFormatParserTests.swift
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

#if os(macOS)

  @testable import FCPKitScripting
  import Foundation
  import Testing

  @Suite
  internal struct FCPScriptingTimecodeFormatParserTests {
    // Live ScriptingBridge proxies return the sdef `timecode formats`
    // enumerator as an OSType number ('drop' / 'ndrp' / 'unsp'), verified
    // against a running Final Cut Pro (#27).
    @Test
    internal func parsesLiveFourCharCodeNumbers() {
      #expect(
        FCPScriptingTimecodeFormatParser.parse(NSNumber(value: 0x6472_6F70 as UInt32))
          == .dropFrame)
      #expect(
        FCPScriptingTimecodeFormatParser.parse(NSNumber(value: 0x6E64_7270 as UInt32))
          == .nonDropFrame)
      #expect(
        FCPScriptingTimecodeFormatParser.parse(NSNumber(value: 0x756E_7370 as UInt32))
          == .unspecified)
    }

    @Test
    internal func parsesDescriptiveStrings() {
      #expect(FCPScriptingTimecodeFormatParser.parse("Drop Frame") == .dropFrame)
      #expect(FCPScriptingTimecodeFormatParser.parse("non drop frame") == .nonDropFrame)
      #expect(FCPScriptingTimecodeFormatParser.parse(nil) == .unspecified)
      #expect(FCPScriptingTimecodeFormatParser.parse(NSNumber(value: 12)) == .unspecified)
    }
  }

#endif
