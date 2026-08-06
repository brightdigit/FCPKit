//
//  TitleStyleSupport.swift
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

/// Shared fixtures and assertions for the title styling and positioning suites.
internal enum TitleStyleSupport {
  /// Wraps a single title in a sequence of the given format.
  internal struct TitleDoc: Document {
    internal let title: FCPKitDSL.Title
    internal let format: FormatPreset?

    internal var body: some DocumentContent {
      Sequence(format: format) {
        title
      }
    }

    internal init(_ title: FCPKitDSL.Title, format: FormatPreset? = .p1080p24) {
      self.title = title
      self.format = format
    }
  }

  /// Two styled titles, used to prove a styled multi-title document validates.
  internal struct StyledPair: Document {
    internal var body: some DocumentContent {
      Sequence(format: .p1080p24) {
        Title("Heading").duration(.seconds(5))
          .font("Helvetica")
          .fontSize(96)
          .fontColor(.white)
          .position(.top, inset: 80)
        Title("Body").duration(.seconds(5))
          .fontSize(48)
          .alignment(.left)
          .position(.bottomLeading, inset: 40)
      }
    }
  }

  /// Exports a document holding `title` and returns the built title element.
  internal static func firstTitle(
    _ title: FCPKitDSL.Title,
    format: FormatPreset? = .p1080p24
  ) throws -> FCPKit.Title {
    let exported = try TitleDoc(title, format: format).export()
    let sequence = try #require(exported.library?.events?.first?.projects?.first?.sequence)
    let items = try #require(sequence.spine?.items)
    guard case .title(let built) = items[0] else {
      throw TitleStyleSupportError.notATitle
    }
    return built
  }

  /// Returns the `text-style` inside the title's `text-style-def`.
  internal static func definitionStyle(
    _ title: FCPKitDSL.Title,
    format: FormatPreset? = .p1080p24
  ) throws -> FCPKit.TextStyle {
    let built = try firstTitle(title, format: format)
    return try #require(built.textStyleDef?.first?.textStyle)
  }

  /// Returns the resolved `adjust-transform position`, or `nil` when absent.
  internal static func transformPosition(
    _ title: FCPKitDSL.Title,
    format: FormatPreset? = .p1080p24
  ) throws -> String? {
    try firstTitle(title, format: format).adjustTransform?.position
  }

  /// Validates against Final Cut's DTD, soft-skipping when tooling is absent.
  internal static func assertDTDValidates(_ data: Data) throws {
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
}
