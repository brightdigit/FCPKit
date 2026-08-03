//
//  TextStyleIDTests.swift
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
import FCPXMLDiff
import Foundation
import Testing

@Suite
internal struct TextStyleIDTests {
  private struct MultiTitleDoc: Document {
    let count: Int

    var body: some DocumentContent {
      Sequence(format: .p1080p24) {
        Title("Slide 1", duration: FCPTime(numerator: 5))
        if count > 1 {
          Title("Slide 2", duration: FCPTime(numerator: 5))
        }
        if count > 2 {
          Title("Slide 3", duration: FCPTime(numerator: 5))
        }
      }
    }
  }

  private struct SingleTitleDoc: Document {
    var body: some DocumentContent {
      Sequence(format: .p1080p24) {
        Title("Only", duration: FCPTime(numerator: 5))
      }
    }
  }

  /// Returns every title in the exported document's spine, in order.
  private func titles(_ exported: FCPXML) throws -> [FCPKit.Title] {
    let sequence = try #require(exported.library?.events?.first?.projects?.first?.sequence)
    let items = try #require(sequence.spine?.items)
    return items.compactMap { item in
      guard case .title(let title) = item else {
        return nil
      }
      return title
    }
  }

  /// Validates against Final Cut's DTD, soft-skipping when the tooling is absent.
  private func assertDTDValidates(_ data: Data) throws {
    let requireDTD = ProcessInfo.processInfo.environment["FCPKIT_REQUIRE_DTD"] != nil
    do {
      let report = try FCPXMLDTDValidator().validate(data: data)
      #expect(report.isValid, "DTD issues: \(report.issues)")
    } catch FCPXMLValidationError.dtdNotFound, FCPXMLValidationError.xmllintUnavailable {
      if requireDTD {
        Issue.record("FCPKIT_REQUIRE_DTD is set but DTD tooling is unavailable")
      }
    }
  }

  @Test
  internal func threeTitlesGetDistinctSequentialIDs() throws {
    let exported = try MultiTitleDoc(count: 3).export()
    let ids = try titles(exported).compactMap { $0.textStyleDef?.first?.id }
    #expect(ids == ["ts1", "ts2", "ts3"])
    #expect(Set(ids).count == 3)
  }

  @Test
  internal func eachTitleReferencesItsOwnStyleDefinition() throws {
    let exported = try MultiTitleDoc(count: 3).export()

    // Uniqueness alone is not enough: the ref must still point at that title's
    // own definition, not merely at some distinct id.
    for title in try titles(exported) {
      let definitionID = try #require(title.textStyleDef?.first?.id)
      let ref = try #require(title.text?.first?.textStyle?.first?.ref)
      #expect(ref == definitionID)
    }
  }

  @Test
  internal func singleTitleStillEmitsTS1() throws {
    // Backward compatibility: the counter starts at 1, so existing single-title
    // fixtures stay byte-identical and need no edits.
    let exported = try SingleTitleDoc().export()
    let ids = try titles(exported).compactMap { $0.textStyleDef?.first?.id }
    #expect(ids == ["ts1"])
  }

  @Test
  internal func multiTitleDocumentValidatesAgainstDTD() throws {
    // Duplicate `ID` values are invalid XML, so this is the regression guard:
    // it fails against the pre-fix hardcoded "ts1".
    //
    // Exported at 1.14 deliberately. At the 1.13 default the document is also
    // invalid for an unrelated reason — the default smart collections emit
    // `match-analysis-type`, which 1.13 does not declare (#41) — and that
    // failure would mask the ID regression this test exists to catch.
    let exported = try MultiTitleDoc(count: 3).export(version: FCPXMLVersion("1.14"))
    let encoded = try FCPXMLParser().encode(exported)
    try assertDTDValidates(encoded)
  }
}
