//
//  AnchoredItem.swift
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

/// An ordered element within an `%anchor_item;` sequence.
public enum AnchoredItem: XMLChoiceCodable {
  /// A `clip` element.
  case clip(Clip)
  /// A `gap` element.
  case gap(Gap)
  /// An `mc-clip` element.
  case mcClip(MCClip)
  /// A `ref-clip` element.
  case refClip(RefClip)
  /// A `sync-clip` element.
  case syncClip(SyncClip)
  /// An `asset-clip` element.
  case assetClip(AssetClip)
  /// A `title` element.
  case title(Title)
  /// A `generator` element.
  case generator(Generator)
  /// A `storyline` element.
  case storyline(Storyline)
  /// A `compound-clip` element.
  case compoundClip(CompoundClip)
  /// A `retime-clip` element.
  case retimeClip(RetimeClip)
  /// A `caption` element.
  case caption(Caption)
  /// A `video` element.
  case video(Video)
  /// A `spine` element.
  case spine(Spine)
  /// An unsupported or unrecognized anchored element.
  case unsupported

  internal typealias ChoiceKey = CodingKeys

  internal enum CodingKeys: String, XMLChoiceCodingKey {
    case clip
    case gap
    case mcClip = "mc-clip"
    case refClip = "ref-clip"
    case syncClip = "sync-clip"
    case assetClip = "asset-clip"
    case title
    case generator
    case storyline
    case compoundClip = "compound-clip"
    case retimeClip = "retime-clip"
    case caption
    case video
    case spine
  }

  internal static var unsupportedChoice: AnchoredItem { .unsupported }

  internal static var choiceFields: [XMLChoiceField<AnchoredItem, CodingKeys>] {
    [
      .init(key: .clip, wrap: AnchoredItem.clip, unwrap: { $0.clip }),
      .init(key: .gap, wrap: AnchoredItem.gap, unwrap: { $0.gap }),
      .init(key: .mcClip, wrap: AnchoredItem.mcClip, unwrap: { $0.mcClip }),
      .init(key: .refClip, wrap: AnchoredItem.refClip, unwrap: { $0.refClip }),
      .init(key: .syncClip, wrap: AnchoredItem.syncClip, unwrap: { $0.syncClip }),
      .init(key: .assetClip, wrap: AnchoredItem.assetClip, unwrap: { $0.assetClip }),
      .init(key: .title, wrap: AnchoredItem.title, unwrap: { $0.title }),
      .init(key: .generator, wrap: AnchoredItem.generator, unwrap: { $0.generator }),
      .init(key: .storyline, wrap: AnchoredItem.storyline, unwrap: { $0.storyline }),
      .init(key: .compoundClip, wrap: AnchoredItem.compoundClip, unwrap: { $0.compoundClip }),
      .init(key: .retimeClip, wrap: AnchoredItem.retimeClip, unwrap: { $0.retimeClip }),
      .init(key: .caption, wrap: AnchoredItem.caption, unwrap: { $0.caption }),
      .init(key: .video, wrap: AnchoredItem.video, unwrap: { $0.video }),
      .init(key: .spine, wrap: AnchoredItem.spine, unwrap: { $0.spine }),
    ]
  }
}
