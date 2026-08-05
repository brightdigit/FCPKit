//
//  PresentationDocumentTests.swift
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
import FCPKitDemo
import FCPKitDSL
import FCPXMLDiff
import Foundation
import Testing

@Suite
internal struct PresentationDocumentTests {
  @Test
  internal func exportsWideHDRLibraryAndTitledColorSlides() throws {
    let exported = try PresentationDocument().export()
    #expect(exported.library?.colorProcessing == .wideHDR)

    let sequence = try #require(exported.library?.events?.first?.projects?.first?.sequence)
    let items = try #require(sequence.spine?.items)
    #expect(items.count == 2)

    let expected: [(host: Double, title: Double)] = [(2.0, 2.0), (5.0, 5.0)]
    for (index, pair) in expected.enumerated() {
      guard case .video(let video) = items[index] else {
        Issue.record("Expected spine item \(index) to be a color video")
        return
      }
      let hostDuration = try #require(video.duration.flatMap(FCPTime.init))
      #expect(abs(hostDuration.seconds - pair.host) < 0.0001)

      let anchored = try #require(video.anchoredItems)
      #expect(anchored.count == 1)
      guard case .title(let title) = anchored[0] else {
        Issue.record("Expected anchored item on video \(index) to be a title")
        return
      }
      let titleDuration = try #require(title.duration.flatMap(FCPTime.init))
      #expect(abs(titleDuration.seconds - pair.title) < 0.0001)
      #expect(titleDuration != .zero)
    }
  }

  @Test
  internal func shellValidatesAgainstTheDTD() throws {
    let exported = try PresentationDocument().export()
    let encoded = try FCPXMLParser().encode(exported)
    try assertDTDValidates(encoded)
  }
}
