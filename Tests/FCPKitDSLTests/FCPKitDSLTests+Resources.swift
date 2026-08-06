//
//  FCPKitDSLResourceTests.swift
//  FCPKitDSLTests
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

extension FCPKitDSLTests {
  @Test
  internal func urlBuiltAssetEmitsMediaRepInsteadOfSrcAttribute() throws {
    struct Example: Document {
      var body: some DocumentContent {
        Sequence(format: .p1080p24) {
          AssetClip(
            URL(fileURLWithPath: "/tmp/Left.mov"),
            name: "Left"
          ).duration(FCPTime(numerator: 10))
        }
      }
    }
    let xml = try Example().export(version: FCPXMLVersion("1.14"))
    let asset = try #require(xml.resources?.assets?.first)
    #expect(asset.src == nil)
    #expect(asset.mediaRep?.count == 1)
    let rep = try #require(asset.mediaRep?.first)
    #expect(rep.kind == .originalMedia)
    #expect(rep.src == "file:///tmp/Left.mov")
    #expect(rep.sig == nil)
  }

  @Test
  internal func conflictingExplicitResourceIDsFail() {
    struct Example: Document {
      var body: some DocumentContent {
        Sequence {
          AssetClip(
            AssetSource(
              url: URL(fileURLWithPath: "/tmp/a.mov"),
              duration: FCPTime(numerator: 1),
              id: "r9"
            )
          )
          AssetClip(
            AssetSource(
              url: URL(fileURLWithPath: "/tmp/b.mov"),
              duration: FCPTime(numerator: 1),
              id: "r9"
            )
          )
        }
      }
    }
    #expect(throws: BuildError.conflictingResourceID("r9")) {
      try Example().export()
    }
  }

  @Test
  internal func stillAssetEmitsRateUndefinedFormatAndZeroDuration() throws {
    struct Example: Document {
      var body: some DocumentContent {
        Sequence(format: .p1080p24) {
          AssetClip(
            .still(
              url: URL(fileURLWithPath: "/tmp/Slide.png"),
              width: 1_920,
              height: 1_080
            )
          ).duration(FCPTime(numerator: 4))
        }
      }
    }
    let xml = try Example().export(version: FCPXMLVersion("1.14"))
    let asset = try #require(xml.resources?.assets?.first)
    #expect(asset.duration == "0s")
    #expect(asset.start == "0s")
    #expect(asset.hasVideo?.value == true)
    #expect(asset.videoSources == "1")
    #expect(asset.mediaRep?.first?.src == "file:///tmp/Slide.png")
    let formatRef = try #require(asset.format)
    let format = try #require(
      xml.resources?.formats?.first { $0.id.rawValue == formatRef.rawValue }
    )
    #expect(format.name == "FFVideoFormatRateUndefined")
    #expect(format.width == "1920")
    #expect(format.height == "1080")
    #expect(format.frameDuration == nil)

    let items = try StoryItemSupport.spine(xml)
    #expect(items.count == 1)
    guard case .video(let video) = items[0] else {
      Issue.record("Expected still to lower to spine <video>, got \(items[0])")
      return
    }
    #expect(video.ref?.rawValue == asset.id.rawValue)
    #expect(video.duration == "4s")
    #expect(items.contains { if case .assetClip = $0 { return true }; return false } == false)
  }

  @Test
  internal func stillVideoAfterTransitionHasNoMediaStart() throws {
    struct Example: Document {
      var body: some DocumentContent {
        Sequence(format: .p1080p24) {
          Generator(.custom).duration(FCPTime(numerator: 5)).color(.blue)
          Transition(.crossDissolve)
          AssetClip(
            .still(
              url: URL(fileURLWithPath: "/tmp/Slide.png"),
              width: 1_920,
              height: 1_080
            )
          ).duration(FCPTime(numerator: 4))
        }
      }
    }
    let xml = try Example().export(version: FCPXMLVersion("1.14"))
    let stillAsset = try #require(
      xml.resources?.assets?.first { $0.duration == "0s" }
    )
    let items = try StoryItemSupport.spine(xml)
    let stillVideo = items.compactMap { item -> FCPKit.Video? in
      guard case .video(let video) = item, video.ref?.rawValue == stillAsset.id.rawValue else {
        return nil
      }
      return video
    }.first
    let video = try #require(stillVideo)
    #expect(video.start == nil)
  }
}
