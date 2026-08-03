//
//  TitleStyleTests.swift
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
internal struct TitleStyleTests {
  @Test
  internal func unstyledTitleMatchesFinalCutDefaults() throws {
    // Fixture parity guard: these are exactly the attributes real Final Cut
    // writes (Tests/FCPKitTests/FeaturePairs/titles/after.fcpxml).
    let style = try TitleStyleSupport.definitionStyle(Title("Hello", duration: .seconds(5)))
    #expect(style.font == "Helvetica")
    #expect(style.fontSize == "63")
    #expect(style.fontFace == "Regular")
    #expect(style.fontColor == "1 1 1 1")
    #expect(style.alignment == "center")
    #expect(style.bold == nil)
  }

  @Test
  internal func modifiersApplyToTextStyle() throws {
    let title = Title("Hello", duration: .seconds(5))
      .font("Avenir Next")
      .fontSize(96)
      .fontColor(.red)
      .alignment(.left)

    let style = try TitleStyleSupport.definitionStyle(title)
    #expect(style.font == "Avenir Next")
    #expect(style.fontSize == "96")
    #expect(style.fontColor == "1 0 0 1")
    #expect(style.alignment == "left")
  }

  @Test
  internal func boldIsEmittedOnlyWhenSet() throws {
    let plain = try TitleStyleSupport.definitionStyle(Title("Hello", duration: .seconds(5)))
    #expect(plain.bold == nil)

    let bolded = try TitleStyleSupport.definitionStyle(
      Title("Hello", duration: .seconds(5)).bold()
    )
    #expect(bolded.bold == "1")
  }

  @Test
  internal func fontSizeCollapsesWholeNumbers() throws {
    let whole = try TitleStyleSupport.definitionStyle(
      Title("Hello", duration: .seconds(5)).fontSize(63)
    )
    #expect(whole.fontSize == "63")

    let fractional = try TitleStyleSupport.definitionStyle(
      Title("Hello", duration: .seconds(5)).fontSize(63.5)
    )
    #expect(fractional.fontSize == "63.5")
  }

  @Test
  internal func fontFaceIsSettable() throws {
    let style = try TitleStyleSupport.definitionStyle(
      Title("Hello", duration: .seconds(5)).fontFace("Bold")
    )
    #expect(style.fontFace == "Bold")
  }

  @Test
  internal func nameOverridesDisplayNameWithoutChangingText() throws {
    let title = try TitleStyleSupport.firstTitle(
      Title("Body copy", duration: .seconds(5)).name("Slide Heading")
    )
    #expect(title.name == "Slide Heading")

    let run = try #require(title.text?.first?.textStyle?.first)
    #expect(run.content == "Body copy")
  }

  @Test
  internal func styledMultiTitleDocumentValidatesAgainstDTD() throws {
    // Exported at 1.14: at the 1.13 default the document is invalid for the
    // unrelated `match-analysis-type` reason (#41), which would mask this.
    let exported = try TitleStyleSupport.StyledPair().export(version: FCPXMLVersion("1.14"))
    let encoded = try FCPXMLParser().encode(exported)
    try TitleStyleSupport.assertDTDValidates(encoded)
  }
}
