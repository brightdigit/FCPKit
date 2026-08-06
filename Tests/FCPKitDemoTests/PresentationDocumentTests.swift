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
    #expect(items.count == 7)

    let names: [String] = items.map { item in
      switch item {
      case .video: "video"
      case .assetClip: "asset-clip"
      case .transition: "transition"
      default: "other"
      }
    }
    #expect(
      names == [
        "video", "transition", "video", "transition", "video", "transition", "asset-clip",
      ]
    )
    try expectTransition(items[1], named: TransitionPreset.diagonal.name)
    try expectTransition(items[3], named: TransitionPreset.push.name)
    try expectTransition(items[5], named: TransitionPreset.crossDissolve.name)

    // Host durations after 1s centered-overlap packing; titles inherit authored host length.
    let expected: [(host: Double, title: Double)] = [
      (1.5, 2.0),
      (4.0, 5.0),
      (2.0, 3.0),
      (3.5, 4.0),
    ]
    for (pairIndex, pair) in expected.enumerated() {
      try expectTitledHost(items[pairIndex * 2], host: pair.host, title: pair.title)
    }

    let assets = try #require(exported.resources?.assets)
    #expect(assets.count == 1)
    let asset = assets[0]
    #expect(asset.mediaRep?.first?.src?.hasSuffix("Placeholder.png") == true)
    #expect(asset.duration == "0s")
    #expect(asset.start == "0s")
    #expect(asset.hasVideo?.value == true)
    #expect(asset.videoSources == "1")
    #expect(asset.format != nil)
    let formats = try #require(exported.resources?.formats)
    #expect(formats.contains { $0.name == "FFVideoFormatRateUndefined" })
  }

  @Test
  internal func shellValidatesAgainstTheDTD() throws {
    let exported = try PresentationDocument().export()
    let encoded = try FCPXMLParser().encode(exported)
    try assertDTDValidates(encoded)
    let xml = try FCPXMLParser().encodeToString(exported)
    #expect(xml.contains(#"<text-style ref="ts1">Welcome to FCPKit!</text-style>"#))
  }

  @Test
  internal func placeholderImageIsBundled() {
    let url = PresentationDocument.placeholderImageURL
    #expect(FileManager.default.fileExists(atPath: url.path))
    #expect(url.pathExtension == "png")
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

  private func expectTitledHost(_ item: SpineItem, host: Double, title: Double) throws {
    let hostDuration: FCPTime
    let anchored: [AnchoredItem]
    switch item {
    case .video(let video):
      hostDuration = try #require(video.duration.flatMap(FCPTime.init))
      anchored = try #require(video.anchoredItems)
    case .assetClip(let clip):
      hostDuration = try #require(clip.duration.flatMap(FCPTime.init))
      anchored = try #require(clip.anchoredItems)
    default:
      Issue.record("Expected color video or asset-clip spine item")
      return
    }
    #expect(abs(hostDuration.seconds - host) < 0.0001)

    #expect(anchored.count == 1)
    guard case .title(let titleItem) = anchored[0] else {
      Issue.record("Expected anchored title on host")
      return
    }
    let titleDuration = try #require(titleItem.duration.flatMap(FCPTime.init))
    #expect(abs(titleDuration.seconds - title) < 0.0001)
    #expect(titleDuration != .zero)

    let styleContent = titleItem.text?.first?.textStyle?.first?.content
    #expect(styleContent?.hasPrefix(" ") != true)
  }
}
