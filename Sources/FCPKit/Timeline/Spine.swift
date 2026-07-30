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

  /// The `clip` elements in the spine.
  public var clips: [Clip]? {
    get { OrderedChoiceItems.payloads(in: items, extract: \.clip) }
    set {
      OrderedChoiceItems.replace(&items, with: newValue, extract: \.clip, wrap: SpineItem.clip)
    }
  }

  /// The `gap` elements filling empty stretches of the spine.
  public var gaps: [Gap]? {
    get { OrderedChoiceItems.payloads(in: items, extract: \.gap) }
    set {
      OrderedChoiceItems.replace(&items, with: newValue, extract: \.gap, wrap: SpineItem.gap)
    }
  }

  /// The `mc-clip` elements referencing multicam media resources.
  public var mcClips: [MCClip]? {
    get { OrderedChoiceItems.payloads(in: items, extract: \.mcClip) }
    set {
      OrderedChoiceItems.replace(&items, with: newValue, extract: \.mcClip, wrap: SpineItem.mcClip)
    }
  }

  /// The `ref-clip` elements referencing compound clips or other media resources.
  public var refClips: [RefClip]? {
    get { OrderedChoiceItems.payloads(in: items, extract: \.refClip) }
    set {
      OrderedChoiceItems.replace(
        &items,
        with: newValue,
        extract: \.refClip,
        wrap: SpineItem.refClip
      )
    }
  }

  /// The `sync-clip` elements containing synchronized audio and video.
  public var syncClips: [SyncClip]? {
    get { OrderedChoiceItems.payloads(in: items, extract: \.syncClip) }
    set {
      OrderedChoiceItems.replace(
        &items,
        with: newValue,
        extract: \.syncClip,
        wrap: SpineItem.syncClip
      )
    }
  }

  /// The `asset-clip` elements referencing asset resources.
  public var assetClips: [AssetClip]? {
    get { OrderedChoiceItems.payloads(in: items, extract: \.assetClip) }
    set {
      OrderedChoiceItems.replace(
        &items,
        with: newValue,
        extract: \.assetClip,
        wrap: SpineItem.assetClip
      )
    }
  }

  /// The `title` elements in the spine.
  public var titles: [Title]? {
    get { OrderedChoiceItems.payloads(in: items, extract: \.title) }
    set {
      OrderedChoiceItems.replace(&items, with: newValue, extract: \.title, wrap: SpineItem.title)
    }
  }

  /// The `generator` elements referencing generator effects.
  public var generators: [Generator]? {
    get { OrderedChoiceItems.payloads(in: items, extract: \.generator) }
    set {
      OrderedChoiceItems.replace(
        &items,
        with: newValue,
        extract: \.generator,
        wrap: SpineItem.generator
      )
    }
  }

  /// The `transition` elements joining adjacent story elements.
  public var transitions: [Transition]? {
    get { OrderedChoiceItems.payloads(in: items, extract: \.transition) }
    set {
      OrderedChoiceItems.replace(
        &items,
        with: newValue,
        extract: \.transition,
        wrap: SpineItem.transition
      )
    }
  }

  /// Nested `storyline` elements connected to the spine.
  public var storylines: [Storyline]? {
    get { OrderedChoiceItems.payloads(in: items, extract: \.storyline) }
    set {
      OrderedChoiceItems.replace(
        &items,
        with: newValue,
        extract: \.storyline,
        wrap: SpineItem.storyline
      )
    }
  }

  /// The `compound-clip` elements in the spine.
  public var compoundClips: [CompoundClip]? {
    get { OrderedChoiceItems.payloads(in: items, extract: \.compoundClip) }
    set {
      OrderedChoiceItems.replace(
        &items,
        with: newValue,
        extract: \.compoundClip,
        wrap: SpineItem.compoundClip
      )
    }
  }

  /// The `retime-clip` elements applying retiming to their contents.
  public var retimeClips: [RetimeClip]? {
    get { OrderedChoiceItems.payloads(in: items, extract: \.retimeClip) }
    set {
      OrderedChoiceItems.replace(
        &items,
        with: newValue,
        extract: \.retimeClip,
        wrap: SpineItem.retimeClip
      )
    }
  }

  /// The `caption` elements in the spine.
  public var captions: [Caption]? {
    get { OrderedChoiceItems.payloads(in: items, extract: \.caption) }
    set {
      OrderedChoiceItems.replace(
        &items,
        with: newValue,
        extract: \.caption,
        wrap: SpineItem.caption
      )
    }
  }

  /// The `video` elements in the spine.
  public var video: [Video]? {
    get { OrderedChoiceItems.payloads(in: items, extract: \.video) }
    set {
      OrderedChoiceItems.replace(&items, with: newValue, extract: \.video, wrap: SpineItem.video)
    }
  }

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
