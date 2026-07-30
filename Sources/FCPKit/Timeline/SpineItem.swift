//
//  SpineItem.swift
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

/// An ordered element within a `spine`.
public enum SpineItem: XMLChoiceCodable {
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
  /// A `transition` element.
  case transition(Transition)
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
  /// An unsupported or unrecognized spine element.
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
    case transition
    case storyline
    case compoundClip = "compound-clip"
    case retimeClip = "retime-clip"
    case caption
    case video
  }

  internal static var unsupportedChoice: SpineItem { .unsupported }

  internal static var choiceFields: [XMLChoiceField<SpineItem, CodingKeys>] {
    [
      .init(key: .clip, wrap: SpineItem.clip, unwrap: { $0.clip }),
      .init(key: .gap, wrap: SpineItem.gap, unwrap: { $0.gap }),
      .init(key: .mcClip, wrap: SpineItem.mcClip, unwrap: { $0.mcClip }),
      .init(key: .refClip, wrap: SpineItem.refClip, unwrap: { $0.refClip }),
      .init(key: .syncClip, wrap: SpineItem.syncClip, unwrap: { $0.syncClip }),
      .init(key: .assetClip, wrap: SpineItem.assetClip, unwrap: { $0.assetClip }),
      .init(key: .title, wrap: SpineItem.title, unwrap: { $0.title }),
      .init(key: .generator, wrap: SpineItem.generator, unwrap: { $0.generator }),
      .init(key: .transition, wrap: SpineItem.transition, unwrap: { $0.transition }),
      .init(key: .storyline, wrap: SpineItem.storyline, unwrap: { $0.storyline }),
      .init(key: .compoundClip, wrap: SpineItem.compoundClip, unwrap: { $0.compoundClip }),
      .init(key: .retimeClip, wrap: SpineItem.retimeClip, unwrap: { $0.retimeClip }),
      .init(key: .caption, wrap: SpineItem.caption, unwrap: { $0.caption }),
      .init(key: .video, wrap: SpineItem.video, unwrap: { $0.video }),
    ]
  }
}
