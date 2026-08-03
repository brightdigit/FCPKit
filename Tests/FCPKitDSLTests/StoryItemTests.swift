//
//  StoryItemTests.swift
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
internal struct StoryItemTests {
  @Test
  internal func generatorAnchorsTitleOnLaneOne() throws {
    let document = StoryItemDoc(
      content: Generator(.custom, duration: FCPTime(numerator: 6))
        .color(.blue)
        .anchor(lane: 1) {
          Title("Heading", duration: FCPTime(numerator: 4))
        }
    )

    let items = try StoryItemSupport.spine(try document.export())
    guard case .video(let video) = items[0] else {
      Issue.record("Expected spine item to be .video")
      return
    }

    let anchored = try #require(video.anchoredItems)
    #expect(anchored.count == 1)
    #expect(StoryItemSupport.anchoredTitleLanes(anchored) == ["1"])
    guard case .title(let title) = anchored[0] else {
      Issue.record("Expected anchored item to be .title")
      return
    }
    #expect(title.duration == "4s")
  }

  @Test
  internal func colorPromotesToGeneratorWhenAnchored() throws {
    let document = StoryItemDoc(
      content: Color.red
        .duration(FCPTime(numerator: 6))
        .anchor(lane: 1) {
          Title("Heading", duration: FCPTime(numerator: 4))
        }
    )

    let items = try StoryItemSupport.spine(try document.export())
    guard case .video(let video) = items[0] else {
      Issue.record("Expected promoted color to build as .video")
      return
    }

    // The color survives promotion as the Custom generator's Color param.
    let params = try #require(video.param)
    #expect(params[0].value == "1 0 0 1")

    let anchored = try #require(video.anchoredItems)
    #expect(StoryItemSupport.anchoredTitleLanes(anchored) == ["1"])
  }

  @Test
  internal func chainedAnchorsAccumulateLanes() throws {
    let document = StoryItemDoc(
      content: Generator(.custom, duration: FCPTime(numerator: 8))
        .color(.blue)
        .anchor(lane: 1) {
          Title("First", duration: FCPTime(numerator: 3))
        }
        .anchor(lane: 2) {
          Title("Second", duration: FCPTime(numerator: 3))
        }
    )

    let items = try StoryItemSupport.spine(try document.export())
    guard case .video(let video) = items[0] else {
      Issue.record("Expected spine item to be .video")
      return
    }

    // Chaining must append. Replacing would drop lane 1 entirely.
    let anchored = try #require(video.anchoredItems)
    #expect(anchored.count == 2)
    #expect(StoryItemSupport.anchoredTitleLanes(anchored) == ["1", "2"])
  }

  @Test
  internal func anchoredTitleLongerThanBackgroundExtendsSequence() throws {
    let document = StoryItemDoc(
      content: Generator(.custom, duration: FCPTime(numerator: 4))
        .color(.blue)
        .anchor(lane: 1) {
          Title("Long", duration: FCPTime(numerator: 9))
        }
    )

    let exported = try document.export()
    let sequence = try #require(exported.library?.events?.first?.projects?.first?.sequence)
    // The anchored title outruns its 4s background, so the sequence must span 9s.
    #expect(sequence.duration == "9s")
  }

  @Test
  internal func nestedSpineInsideAnchorPassesThrough() throws {
    let document = StoryItemDoc(
      content: Generator(.custom, duration: FCPTime(numerator: 10))
        .color(.blue)
        .anchor(lane: 1) {
          Spine {
            Title("First", duration: FCPTime(numerator: 3))
            Title("Second", duration: FCPTime(numerator: 3))
          }
        }
    )

    let items = try StoryItemSupport.spine(try document.export())
    guard case .video(let video) = items[0] else {
      Issue.record("Expected spine item to be .video")
      return
    }

    let anchored = try #require(video.anchoredItems)
    #expect(anchored.count == 1)
    guard case .spine(let nested) = anchored[0] else {
      Issue.record("Expected anchored item to be .spine")
      return
    }
    #expect(nested.items.count == 2)
  }
}
