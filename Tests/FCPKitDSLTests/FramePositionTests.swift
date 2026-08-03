//
//  FramePositionTests.swift
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
internal struct FramePositionTests {
  @Test
  internal func unpositionedTitleEmitsNoAdjustTransform() throws {
    // Regression guard: existing output must stay byte-identical.
    let built = try TitleStyleSupport.firstTitle(Title("Hello", duration: .seconds(5)))
    #expect(built.adjustTransform == nil)
  }

  @Test
  internal func frameCentreEmitsNoAdjustTransform() throws {
    let built = try TitleStyleSupport.firstTitle(
      Title("Hello", duration: .seconds(5)).position(.center)
    )
    #expect(built.adjustTransform == nil)
  }

  @Test
  internal func absoluteCentreResolvesToZero() throws {
    let position = try TitleStyleSupport.transformPosition(
      Title("Hello", duration: .seconds(5)).position(x: 960, y: 540)
    )
    #expect(position == "0 0")
  }

  @Test
  internal func absoluteCoordinatesMatchTheFixtureFormula() throws {
    // Real Final Cut output on a 1920x1080 sequence contains
    // position="-17.8241 7.77778" (TestData/UntitledXML.fcpxml:448). The unit is
    // percent of frame HEIGHT on both axes, from the centre, Y-up. So Y=7.77778
    // is 84px ABOVE centre, i.e. an absolute y of 540 - 84 = 456, and
    // X=-17.8241 is 192.5px left of centre, i.e. an absolute x of 767.5.
    let position = try #require(
      try TitleStyleSupport.transformPosition(
        Title("Hello", duration: .seconds(5)).position(x: 960 - 192.5, y: 540 - 84)
      )
    )

    let parts = position.split(separator: " ")
    #expect(parts.count == 2)
    let xComponent = try #require(Double(parts[0]))
    let yComponent = try #require(Double(parts[1]))

    #expect(abs(yComponent - 7.77778) < 0.001)
    #expect(abs(xComponent - (-17.8241)) < 0.001)

    // The divisor is the height on both axes, not the width.
    #expect(abs(yComponent - 84.0 / 1_080.0 * 100.0) < 0.001)
    #expect(abs(xComponent - (-192.5 / 1_080.0 * 100.0)) < 0.001)
  }

  @Test
  internal func topAndBottomAreSymmetric() throws {
    let top = try #require(
      try TitleStyleSupport.transformPosition(
        Title("Hello", duration: .seconds(5)).position(.top)
      )
    )
    let bottom = try #require(
      try TitleStyleSupport.transformPosition(
        Title("Hello", duration: .seconds(5)).position(.bottom)
      )
    )
    #expect(top == "0 50")
    #expect(bottom == "0 -50")
  }

  @Test
  internal func absolutePositionWithoutFormatThrows() throws {
    let document = TitleStyleSupport.TitleDoc(
      Title("Hello", duration: .seconds(5)).position(x: 100, y: 100),
      format: nil
    )
    #expect(throws: BuildError.missingFrameSize) {
      _ = try document.export()
    }
  }

  @Test
  internal func alignmentPositionWithoutFormatDoesNotThrow() throws {
    let document = TitleStyleSupport.TitleDoc(
      Title("Hello", duration: .seconds(5)).position(.topLeading),
      format: nil
    )
    #expect(throws: Never.self) {
      _ = try document.export()
    }
  }

  @Test
  internal func adjustTransformRoundTripsNewAttributes() throws {
    let transform = FCPKit.AdjustTransform(
      enabled: "1",
      position: "10 20",
      scale: "2 2",
      rotation: "45",
      anchor: "0 0"
    )
    #expect(transform.rotation == "45")
    #expect(transform.anchor == "0 0")
    #expect(transform.enabled == "1")
  }
}
