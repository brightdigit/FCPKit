//
//  XMLAttributeCaseTests.swift
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
import Foundation
import Testing
import XMLCoder

@Suite
internal struct XMLAttributeCaseTests {
  internal struct SequenceFixture: Codable {
    internal var tcFormat: TCFormat
  }

  @Test
  internal func tcFormatKnownValuesRoundTrip() {
    expectRoundTrip([(TCFormat.dropFrame, "DF"), (.nonDropFrame, "NDF")])
  }

  @Test
  internal func audioLayoutKnownValuesRoundTrip() {
    expectRoundTrip([(AudioLayout.mono, "mono"), (.stereo, "stereo"), (.surround, "surround")])
  }

  @Test
  internal func audioRateKnownValuesRoundTrip() {
    expectRoundTrip([
      (AudioRate.hz32000, "32k"), (.hz44100, "44.1k"), (.hz48000, "48k"), (.hz88200, "88.2k"),
      (.hz96000, "96k"), (.hz176400, "176.4k"), (.hz192000, "192k"),
    ])
  }

  @Test
  internal func srcEnableKnownValuesRoundTrip() {
    expectRoundTrip([
      (SrcEnable.all, "all"), (.audio, "audio"), (.video, "video"), (.none, "none"),
    ])
  }

  @Test
  internal func timeptInterpKnownValuesRoundTrip() {
    expectRoundTrip([
      (TimeptInterp.smooth2, "smooth2"), (.linear, "linear"), (.smooth, "smooth"),
    ])
  }

  @Test
  internal func colorProcessingKnownValuesRoundTrip() {
    expectRoundTrip([
      (ColorProcessing.standard, "standard"), (.wide, "wide"), (.wideHDR, "wide-hdr"),
    ])
  }

  @Test
  internal func mediaRepKindKnownValuesRoundTrip() {
    expectRoundTrip([
      (MediaRepKind.originalMedia, "original-media"), (.proxyMedia, "proxy-media"),
    ])
  }

  @Test
  internal func unknownValuesFailInit() {
    // Route through `String` so `init?(_:)` is selected — a string literal would
    // hit `ExpressibleByStringLiteral` and precondition-fail on unknown values.
    let unknownTCFormat = "PAL"
    let unknownAudioRate = "384k"
    let unknownSrcEnable = "maybe"
    #expect(TCFormat(unknownTCFormat) == nil)
    #expect(AudioRate(unknownAudioRate) == nil)
    #expect(SrcEnable(unknownSrcEnable) == nil)
  }

  @Test
  internal func decodingRejectsUnknownValues() {
    let xml = Data(#"<sequence tcFormat="PAL"/>"#.utf8)
    #expect(throws: DecodingError.self) {
      _ = try XMLDecoder().decode(SequenceFixture.self, from: xml)
    }
  }

  @Test
  internal func decodingAcceptsKnownValues() throws {
    let xml = Data(#"<sequence tcFormat="NDF"/>"#.utf8)
    let decoded = try XMLDecoder().decode(SequenceFixture.self, from: xml)
    #expect(decoded.tcFormat == .nonDropFrame)
  }

  @Test
  internal func allCasesMatchDTDVocabulary() {
    #expect(Set(TCFormat.allCases.map(\.rawValue)) == ["DF", "NDF"])
    #expect(Set(SrcEnable.allCases.map(\.rawValue)) == ["all", "audio", "video", "none"])
  }

  private func expectRoundTrip<Value: XMLAttributeCase>(_ pairs: [(Value, String)]) {
    for (value, raw) in pairs {
      #expect(Value(raw) == value)
      #expect(value.rawValue == raw)
      #expect(value.description == raw)
    }
  }
}
