//
//  PresentationDocumentTests.swift
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
import FCPXMLDiff
import Foundation
import Testing

@Suite
internal struct PresentationDocumentTests {
  private static func spine(_ exported: FCPXML) throws -> [FCPKit.SpineItem] {
    let sequence = try #require(exported.library?.events?.first?.projects?.first?.sequence)
    return try #require(sequence.spine?.items)
  }

  private static func firstNode(named name: String, in node: XMLTreeNode) -> XMLTreeNode? {
    if node.name == name {
      return node
    }
    for child in node.children {
      if let match = firstNode(named: name, in: child) {
        return match
      }
    }
    return nil
  }

  @Test
  internal func spineAlternatesBackgroundsAndTransitions() throws {
    let exported = try PresentationDocument().export()
    let encoded = try FCPXMLParser().encode(exported)
    let root = try XMLTreeParser().parse(encoded)
    let spine = try #require(Self.firstNode(named: "spine", in: root))

    // Seven slides interleaved with six dissolves.
    var expected: [String] = []
    for index in 0..<7 {
      if index > 0 {
        expected.append("transition")
      }
      expected.append("video")
    }
    #expect(spine.children.map(\.name) == expected)
  }

  @Test
  internal func everyBackgroundCarriesOneAnchoredTitleOnLaneOne() throws {
    let items = try Self.spine(try PresentationDocument().export())
    var videoCount = 0

    for item in items {
      guard case .video(let video) = item else {
        continue
      }
      videoCount += 1
      let anchored = try #require(video.anchoredItems)
      #expect(anchored.count == 1)
      guard case .title(let title) = anchored[0] else {
        Issue.record("Expected the anchored item to be a title")
        return
      }
      #expect(title.lane == "1")
    }

    #expect(videoCount == 7)
  }

  @Test
  internal func everyTextStyleDefIDIsUnique() throws {
    // Ties #35 to the showcase: seven titles must not collide on "ts1".
    let items = try Self.spine(try PresentationDocument().export())
    var ids: [String] = []

    for item in items {
      guard case .video(let video) = item, let anchored = video.anchoredItems else {
        continue
      }
      for entry in anchored {
        guard case .title(let title) = entry else {
          continue
        }
        ids.append(contentsOf: title.textStyleDef?.compactMap(\.id) ?? [])
      }
    }

    #expect(ids.count == 7)
    #expect(Set(ids).count == ids.count)
  }

  @Test
  internal func titleDurationsFollowTheDissolveSafeFormula() throws {
    let document = PresentationDocument()
    let slides = document.slides

    // First and last slides have only one dissolve; the middle slides have two.
    let first = document.titleDuration(for: slides[0], at: 0)
    let middle = document.titleDuration(for: slides[1], at: 1)
    let last = document.titleDuration(for: slides[slides.count - 1], at: slides.count - 1)

    let slideSeconds = slides[0].duration.seconds
    let half = document.transitionDuration.seconds / 2
    #expect(abs(first.seconds - (slideSeconds - half)) < 0.0001)
    #expect(abs(middle.seconds - (slideSeconds - half - half)) < 0.0001)
    #expect(abs(last.seconds - (slideSeconds - half)) < 0.0001)
  }

  @Test
  internal func sequenceDurationLandsInTheTargetRange() throws {
    let exported = try PresentationDocument().export()
    let sequence = try #require(exported.library?.events?.first?.projects?.first?.sequence)
    let durationString = try #require(sequence.duration)
    let duration = try #require(FCPTime(durationString))

    // Assert on the packer's computed duration rather than hand arithmetic.
    // Seven 6s slides with six 1s dissolves pack to 36s.
    #expect(duration.seconds >= 30)
    #expect(duration.seconds <= 45)
  }

  @Test
  internal func effectsAreInternedAcrossSlides() throws {
    let exported = try PresentationDocument().export()
    let effects = try #require(exported.resources?.effects)

    // Seven slides and six transitions, but each distinct effect is interned once.
    #expect(effects.filter { $0.name == "Custom" }.count == 1)
    #expect(effects.filter { $0.name == "Basic Title" }.count == 1)
    #expect(effects.filter { $0.name == "Cross Dissolve" }.count == 1)
  }

  @Test
  internal func documentValidatesAgainstTheDTD() throws {
    let exported = try PresentationDocument().export()
    let encoded = try FCPXMLParser().encode(exported)
    try assertDTDValidates(encoded)
  }
}
