//
//  PositionedSpineOrderingTests.swift
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
internal struct PositionedSpineOrderingTests {
  private static func firstNode(named name: String, in node: XMLTreeNode) -> XMLTreeNode? {
    if node.name == name {
      return node
    }
    for child in node.children {
      if let match = firstNode(named: name, in: child) {
        return match
      }
    }
    return nil
  }

  @Test
  internal func spineOrderSurvivesPositionResolution() throws {
    let exported = try PositionedOrderingDoc().export()
    let sequence = try #require(exported.library?.events?.first?.projects?.first?.sequence)
    let items = try #require(sequence.spine?.items)

    #expect(items.count == 3)
    guard case .title(let first) = items[0] else {
      Issue.record("Expected item 0 to be .title")
      return
    }
    guard case .transition = items[1] else {
      Issue.record("Expected item 1 to be .transition")
      return
    }
    guard case .title(let third) = items[2] else {
      Issue.record("Expected item 2 to be .title")
      return
    }

    // Both titles resolved a position, and they stayed in authored order.
    #expect(first.adjustTransform?.position != nil)
    #expect(third.adjustTransform?.position != nil)
    #expect(first.text?.first?.textStyle?.first?.content == "First")
    #expect(third.text?.first?.textStyle?.first?.content == "Second")
  }

  @Test
  internal func serializedChildOrderSurvivesPositionResolution() throws {
    let exported = try PositionedOrderingDoc().export()
    let encoded = try FCPXMLParser().encode(exported)
    let root = try XMLTreeParser().parse(encoded)

    let spine = try #require(Self.firstNode(named: "spine", in: root))
    #expect(spine.children.map(\.name) == ["title", "transition", "title"])
  }
}
