//
//  TitleTextWhitespaceTests.swift
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

import FCPKitDSL
import Foundation
import Testing

@testable import FCPKit

@Suite
internal struct TitleTextWhitespaceTests {
  private struct WelcomeTitle: Document {
    var body: some DocumentContent {
      Sequence {
        Color.white.duration(2.0).anchor(lane: 1) {
          Title("Welcome to FCPKit!")
        }
      }
    }
  }

  @Test
  internal func encodedTitleTextStyleKeepsContentInline() throws {
    let exported = try WelcomeTitle().export()
    let xml = try FCPXMLParser().encodeToString(exported)
    #expect(xml.contains(#"<text-style ref="ts1">Welcome to FCPKit!</text-style>"#))
    #expect(!xml.contains(#"<text-style ref="ts1">\#n"#))
  }

  @Test
  internal func compactingLeavesNestedTextStyleBodiesAlone() {
    let withParam = """
      <text-style font="Helvetica" fontSize="63">
        <param name="Position" key="9999/1" value="0 0"/>
      </text-style>
      """
    #expect(FCPXMLParser.compactingTextStyleCharacterData(in: withParam) == withParam)
  }

  @Test
  internal func compactingCollapsesPrettyPrintedDataPayloads() {
    let pretty = """
      <data key="effectConfig">
        YnBsaXN0MDDUAQID
      </data>
      """
    #expect(
      FCPXMLParser.compactingOpaqueDataCharacterData(in: pretty)
        == #"<data key="effectConfig">YnBsaXN0MDDUAQID</data>"#
    )
  }
}
