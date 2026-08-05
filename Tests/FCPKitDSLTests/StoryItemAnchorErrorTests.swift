//
//  StoryItemAnchorErrorTests.swift
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
internal struct StoryItemAnchorErrorTests {
  @Test
  internal func generatorLaneZeroThrowsInvalidLane() throws {
    let document = StoryItemDoc(
      content: Generator(.custom).duration(FCPTime(numerator: 6))
        .color(.blue)
        .anchor(lane: 0) {
          Title("Heading").duration(FCPTime(numerator: 4))
        }
    )

    #expect(throws: BuildError.invalidLane) {
      _ = try document.export()
    }
  }

  @Test
  internal func colorLaneZeroThrowsInvalidLane() throws {
    let document = StoryItemDoc(
      content: Color.red
        .duration(FCPTime(numerator: 6))
        .anchor(lane: 0) {
          Title("Heading").duration(FCPTime(numerator: 4))
        }
    )

    #expect(throws: BuildError.invalidLane) {
      _ = try document.export()
    }
  }

  @Test
  internal func colorAnchoredBeforeDurationFailsLoudly() throws {
    // `.anchor` cannot throw from builder position, so promotion uses a zero
    // duration and the mistake surfaces at export() rather than silently
    // producing a zero-length clip.
    let document = StoryItemDoc(
      content: Color.red
        .anchor(lane: 1) {
          Title("Heading").duration(FCPTime(numerator: 4))
        }
    )

    #expect(throws: BuildError.missingDuration("Custom")) {
      _ = try document.export()
    }
  }

  @Test
  internal func transitionAnchorsAreIgnored() throws {
    let exported = try StoryItemSupport.TransitionAnchored().export()
    let items = try StoryItemSupport.spine(exported)
    #expect(items.count == 3)
    guard case .transition(let transition) = items[1] else {
      Issue.record("Expected spine item 1 to be .transition")
      return
    }
    #expect(transition.name == TransitionPreset.crossDissolve.name)

    // The DTD admits no anchored items on <transition>, so anchoring one is a
    // documented no-op rather than an error: the document still builds, and the
    // serialized transition carries no anchored children.
    let encoded = try FCPXMLParser().encode(exported)
    let xml = try #require(String(data: encoded, encoding: .utf8))
    #expect(!xml.contains("Ignored"))
  }
}
