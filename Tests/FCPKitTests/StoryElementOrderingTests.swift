//
//  StoryElementOrderingTests.swift
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
import FCPXMLDiff
import Foundation
import XCTest

/// Pins DTD child-element order and time-attribute character-identity across all FeaturePairs.
internal final class StoryElementOrderingTests: XCTestCase {
  private static let featurePairs = ["markers", "retiming", "roles", "titles", "transitions"]
  private static let timeAttributeNames: Set<String> = [
    "duration", "start", "offset", "tcStart", "frameDuration", "audioStart", "audioDuration",
  ]

  private func featurePairURL(_ feature: String, file name: String) -> URL {
    URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()
      .appendingPathComponent("FeaturePairs", isDirectory: true)
      .appendingPathComponent(feature, isDirectory: true)
      .appendingPathComponent(name)
  }

  private func assertTreeNamesEqual(_ lhs: XMLTreeNode, _ rhs: XMLTreeNode, path: String = "") {
    let currentPath = path.isEmpty ? lhs.name : "\(path)/\(lhs.name)"
    XCTAssertEqual(
      lhs.name,
      rhs.name,
      "Element name mismatch at path \(currentPath)"
    )
    XCTAssertEqual(
      lhs.children.map(\.name),
      rhs.children.map(\.name),
      "Child element order mismatch at path \(currentPath)"
    )
    for (index, lhsChild) in lhs.children.enumerated() where index < rhs.children.count {
      assertTreeNamesEqual(lhsChild, rhs.children[index], path: currentPath)
    }
  }

  private func collectTimeAttributes(from node: XMLTreeNode, path: String = "") -> [(
    String, String
  )] {
    let currentPath = path.isEmpty ? node.name : "\(path)/\(node.name)"
    var results = [(String, String)]()
    for (key, val) in node.attributes where Self.timeAttributeNames.contains(key) {
      results.append(("\(currentPath)/@\(key)", val))
    }
    for child in node.children {
      results.append(contentsOf: collectTimeAttributes(from: child, path: currentPath))
    }
    return results
  }

  private func findNodes(named name: String, in node: XMLTreeNode) -> [XMLTreeNode] {
    var matches = [XMLTreeNode]()
    if node.name == name {
      matches.append(node)
    }
    for child in node.children {
      matches.append(contentsOf: findNodes(named: name, in: child))
    }
    return matches
  }

  internal func testRawTreeChildOrderPreservedAcrossAllFeaturePairs() throws {
    for feature in Self.featurePairs {
      let data = try Data(contentsOf: featurePairURL(feature, file: "after.fcpxml"))
      let originalTree = try XMLTreeParser().parse(data)

      let document = try FCPXMLParser().parse(data: data)
      let encoded = try FCPXMLParser().encode(document)
      let encodedTree = try XMLTreeParser().parse(encoded)

      let origSpines = findNodes(named: "spine", in: originalTree)
      let encSpines = findNodes(named: "spine", in: encodedTree)

      XCTAssertEqual(origSpines.count, encSpines.count, "Spine count mismatch in \(feature)")
      for (idx, origSpine) in origSpines.enumerated() where idx < encSpines.count {
        assertTreeNamesEqual(origSpine, encSpines[idx], path: "[\(feature)] spine[\(idx)]")
      }
    }
  }

  internal func testTimeAttributesCharacterIdenticalAfterRoundTrip() throws {
    for feature in Self.featurePairs {
      let data = try Data(contentsOf: featurePairURL(feature, file: "after.fcpxml"))
      let originalTree = try XMLTreeParser().parse(data)

      let document = try FCPXMLParser().parse(data: data)
      let encoded = try FCPXMLParser().encode(document)
      let encodedTree = try XMLTreeParser().parse(encoded)

      let originalTimeAttrs = Dictionary(
        collectTimeAttributes(from: originalTree, path: "[\(feature)]"),
        uniquingKeysWith: { first, _ in first }
      )
      let encodedTimeAttrs = Dictionary(
        collectTimeAttributes(from: encodedTree, path: "[\(feature)]"),
        uniquingKeysWith: { first, _ in first }
      )

      XCTAssertFalse(originalTimeAttrs.isEmpty, "No time attributes found in \(feature)")
      for (path, originalVal) in originalTimeAttrs {
        guard let encodedVal = encodedTimeAttrs[path] else {
          XCTFail("Missing time attribute at path \(path) in feature pair \(feature)")
          continue
        }
        XCTAssertEqual(
          originalVal,
          encodedVal,
          "Time attribute character representation changed at \(path) in feature pair \(feature)"
        )
      }
    }
  }
}
