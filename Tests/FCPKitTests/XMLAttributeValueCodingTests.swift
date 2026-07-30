//
//  XMLAttributeValueCodingTests.swift
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
internal struct XMLAttributeValueCodingTests {
  internal struct ClipFixture: Codable, Equatable, FCPNodeEncodable {
    internal static let elementKeys: Set<String> = ["note"]

    internal var offset: FCPTime
    internal var enabled: FCPBool
    internal var tcFormat: TCFormat
    internal var audioRate: AudioRate
    internal var ref: ResourceRef<AssetKind>
    internal var note: String
  }

  private static let fixtureXML = Data(
    #"""
    <clip offset="1001/30000s" enabled="1" tcFormat="NDF" audioRate="44.1k" ref="r2">\#
    <note>edit point</note></clip>
    """#.utf8
  )

  @Test
  internal func decodesTypedValuesFromAttributes() throws {
    let decoded = try XMLDecoder().decode(ClipFixture.self, from: Self.fixtureXML)
    #expect(decoded.offset.description == "1001/30000s")
    #expect(decoded.offset == FCPTime(numerator: 1_001, denominator: 30_000))
    #expect(decoded.enabled.value)
    #expect(decoded.tcFormat == .nonDropFrame)
    #expect(decoded.audioRate == .hz44100)
    #expect(decoded.ref.rawValue == "r2")
    #expect(decoded.note == "edit point")
  }

  @Test
  internal func encodesTypedValuesAsSingleValueAttributeStrings() throws {
    let decoded = try XMLDecoder().decode(ClipFixture.self, from: Self.fixtureXML)
    let data = try XMLEncoder().encode(decoded, withRootKey: "clip")
    let xml = try #require(String(data: data, encoding: .utf8))
    #expect(xml.contains(#"offset="1001/30000s""#))
    #expect(xml.contains(#"enabled="1""#))
    #expect(xml.contains(#"tcFormat="NDF""#))
    #expect(xml.contains(#"audioRate="44.1k""#))
    #expect(xml.contains(#"ref="r2""#))
    #expect(xml.contains("<note>edit point</note>"))
    #expect(!xml.contains("<offset>"))
  }

  @Test
  internal func roundTripsThroughXMLCoderUnchanged() throws {
    let decoded = try XMLDecoder().decode(ClipFixture.self, from: Self.fixtureXML)
    let reencoded = try XMLEncoder().encode(decoded, withRootKey: "clip")
    let redecoded = try XMLDecoder().decode(ClipFixture.self, from: reencoded)
    #expect(redecoded == decoded)
    #expect(redecoded.offset.isIdenticallyFormatted(to: decoded.offset))
  }

  @Test
  internal func illegalAttributeStringsFailDecoding() {
    let xml = Data(
      #"<clip offset="oops" enabled="1" tcFormat="NDF" audioRate="44.1k" ref="r2"/>"#.utf8
    )
    #expect(throws: DecodingError.self) {
      _ = try XMLDecoder().decode(ClipFixture.self, from: xml)
    }
  }
}
