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
    // Real Final Cut output contains position="-17.8241 7.77778"
    // (TestData/UntitledXML.fcpxml:448). That fixture's sequence uses format r2,
    // FFVideoFormat3840x2160p24 — 3840x2160, not 1080p.
    //
    // The unit is percent of frame HEIGHT on both axes, from the centre, Y-up,
    // which makes it scale-invariant: the same percentages describe the same
    // relative position at any resolution. So the fixture's values reproduce on
    // a 1080p sequence at the proportionally equivalent pixels — Y=7.77778 is
    // 0.0777778 * 1080 = 84px above centre (absolute y 456), and X=-17.8241 is
    // 192.5px left of centre (absolute x 767.5).
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

  @Test
  internal func hugeFontSizeDoesNotTrap() throws {
    // Whole-but-huge doubles took an unguarded Int(_:) conversion, which traps
    // and takes the host process down. A library must not crash on user input.
    let huge = Double("1e21") ?? 0
    let style = try TitleStyleSupport.definitionStyle(
      Title("Hello", duration: .seconds(5)).fontSize(huge)
    )
    #expect(style.fontSize != nil)
  }

  @Test
  internal func nonFiniteFontSizeDoesNotTrap() throws {
    let style = try TitleStyleSupport.definitionStyle(
      Title("Hello", duration: .seconds(5)).fontSize(.infinity)
    )
    #expect(style.fontSize != nil)
  }

  @Test
  internal func centerIgnoresInsetAndEmitsNoTransform() throws {
    // `.center` is the frame centre on both axes, so an inset has no direction
    // to move along. It must still emit nothing rather than a no-op transform.
    let built = try TitleStyleSupport.firstTitle(
      Title("Hello", duration: .seconds(5)).position(.center, inset: 100)
    )
    #expect(built.adjustTransform == nil)
  }

  @Test
  internal func insetWithoutFormatThrowsRatherThanSilentlyDropping() throws {
    // An inset is in points; converting to percent-of-height needs the frame
    // height. Silently dropping it would emit a position never asked for.
    let document = TitleStyleSupport.TitleDoc(
      Title("Hello", duration: .seconds(5)).position(.top, inset: 80),
      format: nil
    )
    #expect(throws: BuildError.missingFrameSize) {
      _ = try document.export()
    }
  }

  @Test
  internal func zeroInsetAlignmentWithoutFormatStillResolves() throws {
    // Only a non-zero inset needs the frame size; plain alignments never throw.
    let document = TitleStyleSupport.TitleDoc(
      Title("Hello", duration: .seconds(5)).position(.top),
      format: nil
    )
    #expect(throws: Never.self) {
      _ = try document.export()
    }
  }
}
