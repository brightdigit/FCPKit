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

// swiftlint:disable sorted_imports
import FCPKit
import FCPKitDSL
import FCPKitDemo
import FCPXMLDiff
import Foundation
import Testing
// swiftlint:enable sorted_imports

@Suite
internal struct PresentationDocumentTests {
  @Test
  internal func exportsWideHDRLibraryAndTitledColorSlides() throws {
    let exported = try PresentationDocument().export()
    #expect(exported.library?.colorProcessing == .wideHDR)

    let sequence = try #require(exported.library?.events?.first?.projects?.first?.sequence)
    let items = try #require(sequence.spine?.items)
    #expect(items.count == 5)

    let names: [String] = items.map { item in
      switch item {
      case .video: "video"
      case .transition: "transition"
      default: "other"
      }
    }
    #expect(names == ["video", "transition", "video", "transition", "video"])
    try expectTransition(items[1], named: TransitionPreset.diagonal.name)
    try expectTransition(items[3], named: TransitionPreset.push.name)

    // Host durations after 1s centered-overlap packing; titles inherit authored host length.
    let expected: [(host: Double, title: Double)] = [
      (1.5, 2.0),
      (4.0, 5.0),
      (2.5, 3.0),
    ]
    for (pairIndex, pair) in expected.enumerated() {
      try expectTitledVideo(items[pairIndex * 2], host: pair.host, title: pair.title)
    }
  }

  @Test
  internal func shellValidatesAgainstTheDTD() throws {
    let exported = try PresentationDocument().export()
    let encoded = try FCPXMLParser().encode(exported)
    try assertDTDValidates(encoded)
    let xml = try FCPXMLParser().encodeToString(exported)
    #expect(xml.contains(#"<text-style ref="ts1">Welcome to FCPKit!</text-style>"#))
  }
}

extension PresentationDocumentTests {
  private func expectTransition(_ item: SpineItem, named name: String) throws {
    guard case .transition(let transition) = item else {
      Issue.record("Expected \(name) transition")
      return
    }
    #expect(transition.name == name)
  }

  private func expectTitledVideo(_ item: SpineItem, host: Double, title: Double) throws {
    guard case .video(let video) = item else {
      Issue.record("Expected color video spine item")
      return
    }
    let hostDuration = try #require(video.duration.flatMap(FCPTime.init))
    #expect(abs(hostDuration.seconds - host) < 0.0001)

    let anchored = try #require(video.anchoredItems)
    #expect(anchored.count == 1)
    guard case .title(let titleItem) = anchored[0] else {
      Issue.record("Expected anchored title on color video")
      return
    }
    let titleDuration = try #require(titleItem.duration.flatMap(FCPTime.init))
    #expect(abs(titleDuration.seconds - title) < 0.0001)
    #expect(titleDuration != .zero)

    let styleContent = titleItem.text?.first?.textStyle?.first?.content
    #expect(styleContent?.hasPrefix(" ") != true)
  }
}
