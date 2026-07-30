//
//  Storyline.swift
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

import Foundation
import XMLCoder

/// A `storyline` element: a connected secondary storyline anchored to the primary spine.
public struct Storyline: Codable {
  internal enum CodingKeys: String, CodingKey {
    // Attributes
    case lane
    case offset
    case name
    case format

    case spine
    case anchoredItems = ""
  }

  /// The vertical lane the storyline occupies relative to the primary spine.
  public var lane: String?
  /// The storyline's start position on the parent timeline, as a rational time string.
  public var offset: String?
  /// The display name of the storyline.
  public var name: String?
  /// The format resource reference describing the storyline's video format.
  public var format: ResourceRef<FormatKind>?

  /// The nested `spine` element, if present.
  public var spine: Spine?
  /// The ordered anchored items in the storyline.
  public var anchoredItems: [AnchoredItem]?

  /// The `clip` elements in the storyline.
  public var clips: [Clip]? {
    get { anchoredPayloads(\.clip) }
    set { setAnchoredPayloads(newValue, extract: \.clip, wrap: AnchoredItem.clip) }
  }

  /// The `asset-clip` elements referencing asset resources.
  public var assetClips: [AssetClip]? {
    get { anchoredPayloads(\.assetClip) }
    set { setAnchoredPayloads(newValue, extract: \.assetClip, wrap: AnchoredItem.assetClip) }
  }

  /// The `ref-clip` elements referencing compound clips or other media resources.
  public var refClips: [RefClip]? {
    get { anchoredPayloads(\.refClip) }
    set { setAnchoredPayloads(newValue, extract: \.refClip, wrap: AnchoredItem.refClip) }
  }

  /// The `title` elements in the storyline.
  public var titles: [Title]? {
    get { anchoredPayloads(\.title) }
    set { setAnchoredPayloads(newValue, extract: \.title, wrap: AnchoredItem.title) }
  }

  /// The `generator` elements referencing generator effects.
  public var generators: [Generator]? {
    get { anchoredPayloads(\.generator) }
    set { setAnchoredPayloads(newValue, extract: \.generator, wrap: AnchoredItem.generator) }
  }

  /// Creates a storyline by decoding from the given decoder.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.lane = try container.decodeIfPresent(String.self, forKey: .lane)
    self.offset = try container.decodeIfPresent(String.self, forKey: .offset)
    self.name = try container.decodeIfPresent(String.self, forKey: .name)
    self.format = try container.decodeIfPresent(ResourceRef<FormatKind>.self, forKey: .format)
    self.spine = try container.decodeIfPresent(Spine.self, forKey: .spine)

    let itemsContainer = try decoder.singleValueContainer()
    let decodedItems = (try? itemsContainer.decode([AnchoredItem].self)) ?? []
    let filteredItems = decodedItems.filter { item in
      if case .unsupported = item {
        return false
      }
      return true
    }
    self.anchoredItems = filteredItems.isEmpty ? nil : filteredItems
  }

  /// Creates a storyline with the given attributes and contents.
  public init(
    lane: String? = nil,
    offset: String? = nil,
    name: String? = nil,
    format: ResourceRef<FormatKind>? = nil,
    spine: Spine? = nil,
    clips: [Clip]? = nil,
    assetClips: [AssetClip]? = nil,
    refClips: [RefClip]? = nil,
    titles: [Title]? = nil,
    generators: [Generator]? = nil,
    anchoredItems: [AnchoredItem]? = nil
  ) {
    self.lane = lane
    self.offset = offset
    self.name = name
    self.format = format
    self.spine = spine

    let items = OrderedChoiceItems.appending(
      [
        clips?.map(AnchoredItem.clip),
        assetClips?.map(AnchoredItem.assetClip),
        refClips?.map(AnchoredItem.refClip),
        titles?.map(AnchoredItem.title),
        generators?.map(AnchoredItem.generator),
      ],
      onto: anchoredItems ?? []
    )
    self.anchoredItems = items.isEmpty ? nil : items
  }
}

extension Storyline: AnchoredChoiceContainer {}

extension Storyline: FCPNodeEncodable {
  /// Encodes child clip content as XML elements and remaining keys as attributes.
  public static let elementKeys: Set<String> = [
    "", "spine",
  ]
}
