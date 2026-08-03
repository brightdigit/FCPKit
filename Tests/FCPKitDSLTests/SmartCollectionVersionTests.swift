//
//  SmartCollectionVersionTests.swift
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
internal struct SmartCollectionVersionTests {
  private struct MinimalDoc: Document {
    var body: some DocumentContent {
      Project(name: "Minimal") {
        Sequence(format: .p1080p24) {
          AssetClip(
            URL(fileURLWithPath: "/tmp/Left.mov"),
            duration: FCPTime(numerator: 10),
            name: "Left"
          )
        }
      }
    }
  }

  @Test
  internal func defaultVersionOmitsMissingAnalysis() throws {
    let exported = try MinimalDoc().export()
    #expect(exported.version == FCPXMLVersion.supportedGeneration.rawValue)

    let collections = try #require(exported.library?.smartCollections)
    #expect(collections.count == 5)
    #expect(!collections.contains { $0.name == "Missing Analysis" })
    #expect(collections.allSatisfy { $0.matchAnalysisType == nil })

    let data = try FCPXMLParser().encode(exported)
    let xml = try #require(String(data: data, encoding: .utf8))
    #expect(!xml.contains("match-analysis-type"))
  }

  @Test
  internal func version114IncludesMissingAnalysis() throws {
    let exported = try MinimalDoc().export(version: FCPXMLVersion("1.14"))
    let collections = try #require(exported.library?.smartCollections)
    #expect(collections.count == 6)

    let missing = try #require(collections.first { $0.name == "Missing Analysis" })
    #expect(missing.match == "all")
    let analysis = try #require(missing.matchAnalysisType)
    #expect(analysis.count == 1)
    #expect(analysis.first?.rule == "isMissing")
    #expect(analysis.first?.value == "any")
  }

  @Test
  internal func defaultVersionDocumentValidatesAgainstDTD() throws {
    let exported = try MinimalDoc().export()
    let data = try FCPXMLParser().encode(exported)
    try assertDTDValidates(data)
  }
}
