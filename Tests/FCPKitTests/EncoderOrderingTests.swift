import FCPXMLDiff
import Foundation
import XCTest
import XMLCoder

/// Pins XMLCoder's child-element ordering behavior.
///
/// Ordered DTD content models (spine children, `%anchor_item;` sequences)
/// depend on XMLCoder emitting child elements in `CodingKeys` declaration
/// order, and on sorting being opt-in via `.sortedKeys`. These tests fail
/// loudly if a future XMLCoder bump changes either default.
internal final class EncoderOrderingTests: XCTestCase {
  /// Stored properties declared `alpha, beta`, but `CodingKeys` declares
  /// the `b` element before the `a` element.
  ///
  /// If encoded child order follows `CodingKeys` declaration order, the
  /// output is `<b/><a/>`; property order or alphabetical order would
  /// yield `<a/><b/>`.
  private struct ReversedKeyPair: Codable {
    fileprivate enum CodingKeys: String, CodingKey {
      case beta = "b"
      case alpha = "a"
    }

    fileprivate let alpha: String
    fileprivate let beta: String
  }

  /// An encoder configured exactly like `FCPXMLParser.encode(_:)`.
  private func parserConfiguredEncoder() -> XMLEncoder {
    let encoder = XMLEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.keyEncodingStrategy = .useDefaultKeys
    encoder.outputFormatting = [.prettyPrinted]
    return encoder
  }

  internal func testEncoderEmitsChildrenInCodingKeysDeclarationOrder() throws {
    let data = try parserConfiguredEncoder().encode(
      ReversedKeyPair(alpha: "first property", beta: "second property"), withRootKey: "root"
    )
    let root = try XMLTreeParser().parse(data)
    XCTAssertEqual(root.children.map(\.name), ["b", "a"])
  }

  internal func testSortedKeysOptInOverridesCodingKeysDeclarationOrder() throws {
    let encoder = parserConfiguredEncoder()
    encoder.outputFormatting = [.sortedKeys]
    let data = try encoder.encode(
      ReversedKeyPair(alpha: "first property", beta: "second property"), withRootKey: "root"
    )
    let root = try XMLTreeParser().parse(data)
    XCTAssertEqual(root.children.map(\.name), ["a", "b"])
  }
}
