import FCPXMLDiff
import Foundation
import XCTest
import XMLCoder

/// Spike for issue #8's ordered `Spine.items` design.
///
/// Verdict: `items = ""` + `XMLChoiceCodingKey` + `DynamicNodeEncoding` does
/// not compose because the synthesized decode of the empty-string key
/// silently yields an empty array instead of the interleaved element
/// children — Step 3 (#8) must use a hand-written `init(from:)` (the
/// XMLCoder "MixedEitherSide" pattern): attributes through the keyed
/// container, items through `singleValueContainer().decode([ToyItem].self)`,
/// which preserves document order even when the parent carries attributes.
/// The encode side does compose: the synthesized `encode(to:)` with
/// `items = ""` and `DynamicNodeEncoding` returning `.element` for the
/// empty-string key emits the choice array as inline children in array
/// order while the sibling keys stay attributes, so only the decode side
/// needs hand-written code.
internal final class ChoiceEncodingSpike: XCTestCase {
  /// Toy stand-in for `AssetClip`: a single `ref` attribute.
  private struct ToyClip: Codable, DynamicNodeEncoding, Equatable {
    fileprivate let ref: String

    fileprivate static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
      .attribute
    }
  }

  /// Toy stand-in for `Transition`: a single `name` attribute.
  private struct ToyTransition: Codable, DynamicNodeEncoding, Equatable {
    fileprivate let name: String

    fileprivate static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
      .attribute
    }
  }

  /// Toy stand-in for `SpineItem`: one case per child element name.
  private enum ToyItem: Codable, Equatable {
    case clip(ToyClip)
    case transition(ToyTransition)

    fileprivate enum CodingKeys: String, XMLChoiceCodingKey {
      case clip
      case transition
    }

    fileprivate init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      if container.contains(.clip) {
        self = .clip(try container.decode(ToyClip.self, forKey: .clip))
      } else if container.contains(.transition) {
        self = .transition(try container.decode(ToyTransition.self, forKey: .transition))
      } else {
        throw DecodingError.dataCorrupted(
          DecodingError.Context(
            codingPath: decoder.codingPath,
            debugDescription: "No known toy spine item key present"
          )
        )
      }
    }

    fileprivate func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      switch self {
      case .clip(let clip):
        try container.encode(clip, forKey: .clip)
      case .transition(let transition):
        try container.encode(transition, forKey: .transition)
      }
    }
  }

  /// Toy stand-in for `Spine`: attributes plus one ordered choice array.
  private struct ToySpine: Codable, DynamicNodeEncoding, Equatable {
    fileprivate enum CodingKeys: String, CodingKey {
      case lane
      case offset
      case items = ""
    }

    fileprivate let lane: String
    fileprivate let offset: String
    fileprivate let items: [ToyItem]

    fileprivate init(lane: String, offset: String, items: [ToyItem]) {
      self.lane = lane
      self.offset = offset
      self.items = items
    }

    // Hand-written: the synthesized decode of the empty-string key silently
    // yields an empty array, so items must come from a single-value
    // container (XMLCoder's NestedChoiceArrayTest pattern).
    fileprivate init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      lane = try container.decode(String.self, forKey: .lane)
      offset = try container.decode(String.self, forKey: .offset)
      let itemsContainer = try decoder.singleValueContainer()
      items = try itemsContainer.decode([ToyItem].self)
    }

    fileprivate static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
      key.stringValue.isEmpty ? .element : .attribute
    }
  }

  /// An encoder configured exactly like `FCPXMLParser.encode(_:)`.
  private func parserConfiguredEncoder() -> XMLEncoder {
    let encoder = XMLEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.keyEncodingStrategy = .useDefaultKeys
    encoder.outputFormatting = [.prettyPrinted]
    return encoder
  }

  private func decodeInterleavedFixture() throws -> ToySpine {
    let data = try XCTUnwrap(fixture("ChoiceSpikeInterleavedSpineXml").data(using: .utf8))
    return try XMLDecoder().decode(ToySpine.self, from: data)
  }

  internal func testDecodingInterleavedChildrenYieldsOneArrayInDocumentOrder() throws {
    let spine = try decodeInterleavedFixture()
    XCTAssertEqual(spine.lane, "1")
    XCTAssertEqual(spine.offset, "0s")
    XCTAssertEqual(
      spine.items,
      [
        .clip(ToyClip(ref: "r2")),
        .transition(ToyTransition(name: "Cross Dissolve")),
        .clip(ToyClip(ref: "r5")),
      ]
    )
  }

  internal func testReencodingEmitsItemsInArrayOrderAndAttributesAsAttributes() throws {
    let spine = try decodeInterleavedFixture()
    let encoded = try parserConfiguredEncoder().encode(spine, withRootKey: "toy-spine")
    let root = try XMLTreeParser().parse(encoded)
    XCTAssertEqual(root.name, "toy-spine")
    XCTAssertEqual(root.attributes, ["lane": "1", "offset": "0s"])
    XCTAssertEqual(root.children.map(\.name), ["clip", "transition", "clip"])
    XCTAssertEqual(root.children.map(\.attributes["ref"]), ["r2", nil, "r5"])
    XCTAssertEqual(root.children.map(\.attributes["name"]), [nil, "Cross Dissolve", nil])
  }

  internal func testEncodingConstructedValueHonorsInsertionOrder() throws {
    let spine = ToySpine(
      lane: "2",
      offset: "5s",
      items: [
        .transition(ToyTransition(name: "Fade")),
        .clip(ToyClip(ref: "r9")),
        .clip(ToyClip(ref: "r2")),
      ]
    )
    let encoded = try parserConfiguredEncoder().encode(spine, withRootKey: "toy-spine")
    let root = try XMLTreeParser().parse(encoded)
    XCTAssertEqual(root.attributes, ["lane": "2", "offset": "5s"])
    XCTAssertEqual(root.children.map(\.name), ["transition", "clip", "clip"])
    XCTAssertEqual(root.children.map(\.attributes["ref"]), [nil, "r9", "r2"])
    XCTAssertEqual(root.children.map(\.attributes["name"]), ["Fade", nil, nil])
  }
}
