//
//  Spine.swift
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

/// A `spine` element containing the ordered story elements of a storyline.
public struct Spine: Codable {
  internal enum CodingKeys: String, CodingKey {
    case items = ""
  }

  /// The ordered elements in the spine.
  public var items: [SpineItem]

  /// Creates a spine with the given ordered items.
  public init(items: [SpineItem] = []) {
    self.items = items
  }

  /// Creates a spine from a decoder.
  public init(from decoder: Decoder) throws {
    let itemsContainer = try decoder.singleValueContainer()
    self.items = (try? itemsContainer.decode([SpineItem].self)) ?? []
  }

  /// Creates a spine with the given story elements.
  public init(
    clips: [Clip]? = nil,
    gaps: [Gap]? = nil,
    mcClips: [MCClip]? = nil,
    refClips: [RefClip]? = nil,
    syncClips: [SyncClip]? = nil,
    assetClips: [AssetClip]? = nil,
    titles: [Title]? = nil,
    generators: [Generator]? = nil,
    transitions: [Transition]? = nil,
    storylines: [Storyline]? = nil,
    compoundClips: [CompoundClip]? = nil,
    retimeClips: [RetimeClip]? = nil,
    captions: [Caption]? = nil,
    video: [Video]? = nil
  ) {
    self.items = OrderedChoiceItems.appending([
      clips?.map(SpineItem.clip),
      gaps?.map(SpineItem.gap),
      mcClips?.map(SpineItem.mcClip),
      refClips?.map(SpineItem.refClip),
      syncClips?.map(SpineItem.syncClip),
      assetClips?.map(SpineItem.assetClip),
      titles?.map(SpineItem.title),
      generators?.map(SpineItem.generator),
      transitions?.map(SpineItem.transition),
      storylines?.map(SpineItem.storyline),
      compoundClips?.map(SpineItem.compoundClip),
      retimeClips?.map(SpineItem.retimeClip),
      captions?.map(SpineItem.caption),
      video?.map(SpineItem.video),
    ])
  }
}

extension Spine: DynamicNodeEncoding {
  /// Encodes every key as an XML element.
  public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
    key.stringValue.isEmpty ? .element : .attribute
  }
}
