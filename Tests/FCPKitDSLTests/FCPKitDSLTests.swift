//
//  FCPKitDSLTests.swift
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

@Suite
internal struct FCPKitDSLTests {
  @Test
  internal func gapWithoutDurationFailsLoudly() {
    struct Example: Document {
      var body: some DocumentContent {
        Sequence {
          Gap()
        }
      }
    }
    #expect(throws: BuildError.missingDuration("gap")) {
      try Example().export()
    }
  }
  @Test
  internal func urlOnlyClipWithoutDurationFailsLoudly() {
    struct Example: Document {
      var body: some DocumentContent {
        Sequence {
          AssetClip(URL(fileURLWithPath: "/tmp/clip.mov"))
        }
      }
    }
    #expect(throws: BuildError.missingDuration("clip")) {
      try Example().export()
    }
  }
  @Test
  internal func titleWithoutDurationFailsLoudly() {
    struct Example: Document {
      var body: some DocumentContent {
        Sequence {
          Title("Heading")
        }
      }
    }
    #expect(throws: BuildError.missingDuration("Basic Title")) {
      try Example().export()
    }
  }
  @Test
  internal func anchoredTitleInheritsHostDurationWhenUnset() throws {
    struct Example: Document {
      var body: some DocumentContent {
        Sequence {
          Color.red.duration(2.0).anchor(lane: 1) {
            Title("Heading")
          }
        }
      }
    }
    let exported = try Example().export()
    let items = try #require(
      exported.library?.events?.first?.projects?.first?.sequence?.spine?.items
    )
    guard case .video(let video) = items[0] else {
      Issue.record("Expected color video host")
      return
    }
    let anchored = try #require(video.anchoredItems)
    guard case .title(let title) = anchored[0] else {
      Issue.record("Expected anchored title")
      return
    }
    #expect(title.duration == "2s")
  }
  @Test
  internal func projectColorProcessingEmitsLibraryAttribute() throws {
    struct WideHDRDoc: Document {
      var body: some DocumentContent {
        Project(name: "Wide") {
          Sequence {
            Gap().duration(FCPTime(numerator: 1))
          }
        }
        .colorProcessing(.wideHDR)
      }
    }
    struct StandardDoc: Document {
      var body: some DocumentContent {
        Project(name: "Standard") {
          Sequence {
            Gap().duration(FCPTime(numerator: 1))
          }
        }
      }
    }

    let wide = try WideHDRDoc().export()
    #expect(wide.library?.colorProcessing == .wideHDR)

    let standard = try StandardDoc().export()
    #expect(standard.library?.colorProcessing == nil)
  }

  @Test
  internal func sequenceFormatIsMaterialized() throws {
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
    let xml = try Example().export()
    #expect(xml.resources?.formats?.count == 1)
    #expect(xml.resources?.formats?.first?.name == "FFVideoFormat1080p24")
  }

  @Test
  internal func libraryWrappedDecodedFormatIsMaterialized() throws {
    let format = FCPKit.Format(
      id: "r1",
      name: "FFVideoFormat1080p24",
      frameDuration: "100/2400s",
      width: "1920",
      height: "1080",
      colorSpace: "1-1-1 (Rec. 709)"
    )
    struct Example: Document {
      let format: FCPKit.Format
      var body: some DocumentContent {
        Library(location: "file:///tmp/", colorProcessing: .wideHDR) {
          Event(name: "Event") {
            Project(name: "Project", modDate: "2026-01-01") {
              Sequence(format: FormatPreset(format)) {
                AssetClip(
                  URL(fileURLWithPath: "/tmp/Left.mov"),
                  name: "Left"
                ).duration(FCPTime(numerator: 10))
              }
            }
          }
        }
      }
    }
    let xml = try Example(format: format).export()
    #expect(xml.resources?.formats?.count == 1)
    #expect(
      xml.resources?.formats?.first?.id.rawValue == "r1"
        || (xml.resources?.formats?.first?.name == "FFVideoFormat1080p24"))
  }

  @Test
  internal func packsCenteredTransitionOverlap() throws {
    struct Example: Document {
      var body: some DocumentContent {
        Sequence(format: .p1080p24) {
          AssetClip(
            URL(fileURLWithPath: "/tmp/Left.mov"),
            name: "Left"
          ).duration(FCPTime(numerator: 10))
          Transition(.crossDissolve)
          AssetClip(
            URL(fileURLWithPath: "/tmp/Right.mov"),
            name: "Right"
          ).duration(FCPTime(numerator: 9))
        }
      }
    }

    let xml = try Example().export(version: FCPXMLVersion("1.14"))
    let spine = try #require(xml.library?.events?.first?.projects?.first?.sequence?.spine)
    #expect(spine.items.count == 3)
    guard case .assetClip(let left) = spine.items[0] else {
      Issue.record("expected left asset-clip")
      return
    }
    guard case .transition(let transition) = spine.items[1] else {
      Issue.record("expected transition")
      return
    }
    guard case .assetClip(let right) = spine.items[2] else {
      Issue.record("expected right asset-clip")
      return
    }
    #expect(left.offset == "0s")
    #expect(left.duration == "22800/2400s")
    #expect(transition.offset == "9s")
    #expect(transition.duration == "1s")
    #expect(right.offset == "22800/2400s")
    #expect(right.start == "1200/2400s")
    #expect(right.duration == "20400/2400s")
    #expect(xml.library?.events?.first?.projects?.first?.sequence?.duration == "18s")
  }
}
