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
}
