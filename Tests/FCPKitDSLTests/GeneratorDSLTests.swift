//
//  GeneratorDSLTests.swift
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
internal struct GeneratorDSLTests {
  private struct SolidDoc: Document {
    let duration: FCPTime
    let color: Color?
    let name: String?

    var body: some DocumentContent {
      Sequence(format: .p1080p24) {
        if let color, let name {
          Generator(.custom, duration: duration)
            .name(name)
            .color(color)
        } else if let color {
          Generator(.custom, duration: duration)
            .color(color)
        } else if let name {
          Generator(.custom, duration: duration)
            .name(name)
        } else {
          Generator(.custom, duration: duration)
        }
      }
    }

    init(duration: FCPTime, color: Color? = nil, name: String? = nil) {
      self.duration = duration
      self.color = color
      self.name = name
    }
  }

  @Test
  internal func exportsCustomGeneratorWithColorParam() throws {
    let document = SolidDoc(duration: FCPTime(numerator: 5), color: .red, name: "Red Solid")
    let exported = try document.export()

    // Assert effect resource
    let effects = try #require(exported.resources?.effects)
    #expect(
      effects.contains(where: { $0.name == "Custom" && $0.uid == GeneratorPreset.custom.uid }))

    // Assert generator spine element
    let sequence = try #require(exported.library?.events?.first?.projects?.first?.sequence)
    let items = try #require(sequence.spine?.items)
    #expect(items.count == 1)

    guard case .video(let gen) = items[0] else {
      Issue.record("Expected spine item to be .video")
      return
    }

    #expect(gen.name == "Red Solid")
    #expect(gen.duration == "5s")

    let params = try #require(gen.param)
    #expect(params.count == 1)
    #expect(params[0].name == "Color")
    #expect(params[0].value == "1 0 0 1")
  }

  @Test
  internal func exportsGeneratorWithAnchoredTitle() throws {
    struct AnchoredDoc: Document {
      var body: some DocumentContent {
        Sequence(format: .p1080p24) {
          AssetClip(URL(fileURLWithPath: "/tmp/video.mp4"), duration: FCPTime(numerator: 10))
            .anchor(lane: 1) {
              Generator(.custom, duration: FCPTime(numerator: 5))
                .color(.blue)
            }
        }
      }
    }

    let exported = try AnchoredDoc().export()
    let sequence = try #require(exported.library?.events?.first?.projects?.first?.sequence)
    let items = try #require(sequence.spine?.items)
    guard case .assetClip(let clip) = items[0] else {
      Issue.record("Expected spine item to be .assetClip")
      return
    }

    let anchored = try #require(clip.anchoredItems)
    #expect(anchored.count == 1)
    guard case .video(let gen) = anchored[0] else {
      Issue.record("Expected anchored item to be .video")
      return
    }

    #expect(gen.lane == "1")
    #expect(gen.duration == "5s")
    let params = try #require(gen.param)
    #expect(params[0].value == "0 0 1 1")
  }
}
