import FCPKit
import FCPXMLDiff
import Foundation
import XCTest

/// Pins the sibling order of spine children in the transitions FeaturePair.
///
/// The schema-completeness gate counts elements by ancestor path with no
/// sibling ordering, so it stays green through an ordering regression.
/// These raw-tree assertions are the guardrail: the fixture is
/// `asset-clip, transition, asset-clip` on disk, and a faithful round trip
/// must re-encode it in the same order.
internal final class SpineOrderTests: XCTestCase {
  private var transitionsAfterURL: URL {
    URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()
      .appendingPathComponent("FeaturePairs", isDirectory: true)
      .appendingPathComponent("transitions", isDirectory: true)
      .appendingPathComponent("after.fcpxml")
  }

  private func firstNode(named name: String, in node: XMLTreeNode) -> XMLTreeNode? {
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

  internal func testTransitionsFixtureSpineChildrenAreInterleavedOnDisk() throws {
    let data = try Data(contentsOf: transitionsAfterURL)
    let root = try XMLTreeParser().parse(data)
    let spine = try XCTUnwrap(firstNode(named: "spine", in: root))
    XCTAssertEqual(spine.children.map(\.name), ["asset-clip", "transition", "asset-clip"])
  }

  internal func testRoundTripPreservesSpineChildOrder() throws {
    let data = try Data(contentsOf: transitionsAfterURL)
    let document = try FCPXMLParser().parse(data: data)
    let encoded = try FCPXMLParser().encode(document)
    let root = try XMLTreeParser().parse(encoded)
    let spine = try XCTUnwrap(firstNode(named: "spine", in: root))
    #if canImport(ObjectiveC)
      // Strict by default: once #8 lands ordered Spine.items, this wrapper
      // must be removed or the test fails for succeeding unexpectedly.
      XCTExpectFailure(
        "Spine buckets children into parallel typed arrays; ordered Spine.items (#8) flips this"
      ) {
        XCTAssertEqual(spine.children.map(\.name), ["asset-clip", "transition", "asset-clip"])
      }
    #else
      throw XCTSkip(
        "XCTExpectFailure unavailable on corelibs-xctest; tracked by the Darwin leg until #8"
      )
    #endif
  }
}
