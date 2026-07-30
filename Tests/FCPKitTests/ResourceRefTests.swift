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
    let identifier = try #require(ResourceID("r1"))
    #expect(identifier.rawValue == "r1")
    #expect(identifier.description == "r1")
  }

  @Test(arguments: ["", "r 1", " r1", "r1 ", "\tr1"])
  internal func resourceIDRejectsEmptyOrWhitespace(_ raw: String) {
    #expect(ResourceID(raw) == nil)
  }

  @Test
  internal func typedReferencesRoundTripAnyIdentifier() throws {
    let asset = try #require(ResourceRef<AssetKind>("r2"))
    #expect(asset.rawValue == "r2")
    #expect(asset.description == "r2")

    let format = try #require(ResourceRef<FormatKind>("r1"))
    let effect = try #require(ResourceRef<EffectKind>("r3"))
    let media = try #require(ResourceRef<MediaKind>("not-an-r-id"))
    #expect(format.description == "r1")
    #expect(effect.description == "r3")
    #expect(media.description == "not-an-r-id")
  }

  @Test(arguments: ["", "r 1"])
  internal func typedReferencesRejectEmptyOrWhitespace(_ raw: String) {
    #expect(ResourceRef<AssetKind>(raw) == nil)
  }
}
