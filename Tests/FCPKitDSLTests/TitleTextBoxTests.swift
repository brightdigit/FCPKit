//
//  TitleTextBoxTests.swift
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
import FCPKitDSL
import Foundation
import Testing

@Suite
internal struct TitleTextBoxTests {
  private struct WrapDoc: Document {
    var body: some DocumentContent {
      Sequence {
        Color.white.duration(3.0).anchor(lane: 1) {
          Title("Nunc in vulputate felis, at tincidunt arcu. Cras.")
            .alignment(.center)
            .textBox(.fillFrame(inset: 80))
        }
      }
    }
  }

  @Test
  internal func fillFrameEmitsParagraphLayoutAndDerivedMargins() throws {
    let title = try TitleStyleSupport.firstTitle(
      Title("Long body copy for wrapping.")
        .duration(.seconds(5))
        .textBox(.fillFrame(inset: 80))
    )
    let params = try #require(title.param)
    #expect(params.contains { $0.name == "Layout Method" && $0.value == "1 (Paragraph)" })
    #expect(params.contains { $0.name == "Flatten" && $0.value == "1" })

    let left = try #require(params.first { $0.name == "Left Margin" }?.value)
    let right = try #require(params.first { $0.name == "Right Margin" }?.value)
    let top = try #require(params.first { $0.name == "Top Margin" }?.value)
    let bottom = try #require(params.first { $0.name == "Bottom Margin" }?.value)
    // 1080p defaults: half 960×540, inset 80 → ±880, 880, 460, −460
    #expect(left == "-880")
    #expect(right == "880")
    #expect(top == "460")
    #expect(bottom == "-460")

    #expect(params.contains { $0.key == "9999/999166631/999166633/2/314" })
    #expect(params.contains { $0.key == "9999/999166631/999166633/2/323" })
  }

  @Test
  internal func explicitMarginsEmitFixtureKeys() throws {
    let title = try TitleStyleSupport.firstTitle(
      Title("Body")
        .duration(.seconds(5))
        .layout(.paragraph)
        .margins(left: -952.652, right: 954.592, top: 527.887, bottom: -523.048)
    )
    let params = try #require(title.param)
    #expect(params.first { $0.name == "Left Margin" }?.value == "-952.652")
    #expect(params.first { $0.name == "Right Margin" }?.value == "954.592")
    #expect(params.first { $0.name == "Top Margin" }?.value == "527.887")
    #expect(params.first { $0.name == "Bottom Margin" }?.value == "-523.048")
  }

  @Test
  internal func wrapDocumentDTDValidates() throws {
    let exported = try WrapDoc().export()
    let encoded = try FCPXMLParser().encode(exported)
    try assertDTDValidates(encoded)
  }
}
