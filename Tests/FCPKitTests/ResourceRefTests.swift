//
//  ResourceRefTests.swift
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
import Testing

@Suite
internal struct ResourceRefTests {
  @Test
  internal func resourceIDRoundTripsIdentifiers() throws {
    let identifier = try #require(ResourceID(fcpxmlString: "r1"))
    #expect(identifier.rawValue == "r1")
    #expect(identifier.fcpxmlString == "r1")
  }

  @Test(arguments: ["", "r 1", " r1", "r1 ", "\tr1"])
  internal func resourceIDRejectsEmptyOrWhitespace(_ raw: String) {
    #expect(ResourceID(fcpxmlString: raw) == nil)
  }

  @Test
  internal func typedReferencesRoundTripAnyIdentifier() throws {
    let asset = try #require(ResourceRef<AssetKind>(fcpxmlString: "r2"))
    #expect(asset.rawValue == "r2")
    #expect(asset.fcpxmlString == "r2")

    let format = try #require(ResourceRef<FormatKind>(fcpxmlString: "r1"))
    let effect = try #require(ResourceRef<EffectKind>(fcpxmlString: "r3"))
    let media = try #require(ResourceRef<MediaKind>(fcpxmlString: "not-an-r-id"))
    #expect(format.fcpxmlString == "r1")
    #expect(effect.fcpxmlString == "r3")
    #expect(media.fcpxmlString == "not-an-r-id")
  }

  @Test(arguments: ["", "r 1"])
  internal func typedReferencesRejectEmptyOrWhitespace(_ raw: String) {
    #expect(ResourceRef<AssetKind>(fcpxmlString: raw) == nil)
  }
}
