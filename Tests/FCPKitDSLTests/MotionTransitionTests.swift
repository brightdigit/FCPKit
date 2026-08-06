//
//  MotionTransitionTests.swift
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
internal struct MotionTransitionTests {
  private struct DiagonalCut: Document {
    var body: some DocumentContent {
      Sequence {
        Color.white.duration(3.0)
        Transition(.diagonal)
        Color.green.duration(3.0)
      }
    }
  }

  @Test
  internal func motionTransitionOmitsCrossDissolvePayload() throws {
    let exported = try DiagonalCut().export()
    let items = try StoryItemSupport.spine(exported)
    guard case .transition(let transition) = items[1] else {
      Issue.record("Expected middle spine item to be a transition")
      return
    }
    #expect(transition.name == "Diagonal")
    let videoFilter = try #require(transition.filterVideo?.first)
    #expect(videoFilter.name == "Diagonal")
    #expect(videoFilter.param == nil)
    #expect(videoFilter.data == nil)
    #expect(transition.filterAudio?.first?.name == "Audio Crossfade")

    let encoded = try FCPXMLParser().encode(exported)
    try assertDTDValidates(encoded)
  }

  @Test
  internal func crossDissolveUsesVideoLookIndexTwelveAndDisableDRT() throws {
    struct Cut: Document {
      var body: some DocumentContent {
        Sequence {
          Color.white.duration(3.0)
          Transition(.crossDissolve)
          Color.green.duration(3.0)
        }
      }
    }
    let exported = try Cut().export()
    let items = try StoryItemSupport.spine(exported)
    guard case .transition(let transition) = items[1] else {
      Issue.record("Expected middle spine item to be Cross Dissolve")
      return
    }
    let videoFilter = try #require(transition.filterVideo?.first)
    #expect(videoFilter.param?.map(\.name) == [
      "Look", "Amount", "Ease", "Ease Amount", "disableDRT",
    ])
    #expect(videoFilter.param?.first { $0.name == "Look" }?.value == "12 (Video)")
    #expect(videoFilter.param?.first { $0.name == "disableDRT" }?.value == "1")

    let xml = try FCPXMLParser().encodeToString(exported)
    #expect(xml.contains(#"value="12 (Video)""#))
    #expect(!xml.contains(#"<data key="effectConfig">\#n"#))
  }
}
