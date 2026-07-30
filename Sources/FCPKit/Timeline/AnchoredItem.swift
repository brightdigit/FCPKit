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

// swiftlint:disable cyclomatic_complexity file_length

/// An ordered element within an `%anchor_item;` sequence.
public enum AnchoredItem: Codable {
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

  /// Creates an anchored item by decoding from the given decoder.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    if container.contains(.clip) {
      self = .clip(try container.decode(Clip.self, forKey: .clip))
    } else if container.contains(.gap) {
      self = .gap(try container.decode(Gap.self, forKey: .gap))
    } else if container.contains(.mcClip) {
      self = .mcClip(try container.decode(MCClip.self, forKey: .mcClip))
    } else if container.contains(.refClip) {
      self = .refClip(try container.decode(RefClip.self, forKey: .refClip))
    } else if container.contains(.syncClip) {
      self = .syncClip(try container.decode(SyncClip.self, forKey: .syncClip))
    } else if container.contains(.assetClip) {
      self = .assetClip(try container.decode(AssetClip.self, forKey: .assetClip))
    } else if container.contains(.title) {
      self = .title(try container.decode(Title.self, forKey: .title))
    } else if container.contains(.generator) {
      self = .generator(try container.decode(Generator.self, forKey: .generator))
    } else if container.contains(.storyline) {
      self = .storyline(try container.decode(Storyline.self, forKey: .storyline))
    } else if container.contains(.compoundClip) {
      self = .compoundClip(try container.decode(CompoundClip.self, forKey: .compoundClip))
    } else if container.contains(.retimeClip) {
      self = .retimeClip(try container.decode(RetimeClip.self, forKey: .retimeClip))
    } else if container.contains(.caption) {
      self = .caption(try container.decode(Caption.self, forKey: .caption))
    } else if container.contains(.video) {
      self = .video(try container.decode(Video.self, forKey: .video))
    } else if container.contains(.spine) {
      self = .spine(try container.decode(Spine.self, forKey: .spine))
    } else {
      self = .unsupported
    }
  }

  /// Encodes this anchored item into the given encoder.
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case .clip(let clip):
      try container.encode(clip, forKey: .clip)
    case .gap(let gap):
      try container.encode(gap, forKey: .gap)
    case .mcClip(let mcClip):
      try container.encode(mcClip, forKey: .mcClip)
    case .refClip(let refClip):
      try container.encode(refClip, forKey: .refClip)
    case .syncClip(let syncClip):
      try container.encode(syncClip, forKey: .syncClip)
    case .assetClip(let assetClip):
      try container.encode(assetClip, forKey: .assetClip)
    case .title(let title):
      try container.encode(title, forKey: .title)
    case .generator(let generator):
      try container.encode(generator, forKey: .generator)
    case .storyline(let storyline):
      try container.encode(storyline, forKey: .storyline)
    case .compoundClip(let compoundClip):
      try container.encode(compoundClip, forKey: .compoundClip)
    case .retimeClip(let retimeClip):
      try container.encode(retimeClip, forKey: .retimeClip)
    case .caption(let caption):
      try container.encode(caption, forKey: .caption)
    case .video(let video):
      try container.encode(video, forKey: .video)
    case .spine(let spine):
      try container.encode(spine, forKey: .spine)
    case .unsupported:
      break
    }
  }
}

extension AnchoredItem {
  internal var clip: Clip? {
    if case .clip(let val) = self {
      return val
    }
    return nil
  }

  internal var isClip: Bool {
    if case .clip = self {
      return true
    }
    return false
  }

  internal var gap: Gap? {
    if case .gap(let val) = self {
      return val
    }
    return nil
  }

  internal var isGap: Bool {
    if case .gap = self {
      return true
    }
    return false
  }

  internal var mcClip: MCClip? {
    if case .mcClip(let val) = self {
      return val
    }
    return nil
  }

  internal var isMCClip: Bool {
    if case .mcClip = self {
      return true
    }
    return false
  }

  internal var refClip: RefClip? {
    if case .refClip(let val) = self {
      return val
    }
    return nil
  }

  internal var isRefClip: Bool {
    if case .refClip = self {
      return true
    }
    return false
  }

  internal var syncClip: SyncClip? {
    if case .syncClip(let val) = self {
      return val
    }
    return nil
  }

  internal var isSyncClip: Bool {
    if case .syncClip = self {
      return true
    }
    return false
  }

  internal var assetClip: AssetClip? {
    if case .assetClip(let val) = self {
      return val
    }
    return nil
  }

  internal var isAssetClip: Bool {
    if case .assetClip = self {
      return true
    }
    return false
  }

  internal var title: Title? {
    if case .title(let val) = self {
      return val
    }
    return nil
  }

  internal var isTitle: Bool {
    if case .title = self {
      return true
    }
    return false
  }

  internal var generator: Generator? {
    if case .generator(let val) = self {
      return val
    }
    return nil
  }

  internal var isGenerator: Bool {
    if case .generator = self {
      return true
    }
    return false
  }

  internal var storyline: Storyline? {
    if case .storyline(let val) = self {
      return val
    }
    return nil
  }

  internal var isStoryline: Bool {
    if case .storyline = self {
      return true
    }
    return false
  }

  internal var compoundClip: CompoundClip? {
    if case .compoundClip(let val) = self {
      return val
    }
    return nil
  }

  internal var isCompoundClip: Bool {
    if case .compoundClip = self {
      return true
    }
    return false
  }

  internal var retimeClip: RetimeClip? {
    if case .retimeClip(let val) = self {
      return val
    }
    return nil
  }

  internal var isRetimeClip: Bool {
    if case .retimeClip = self {
      return true
    }
    return false
  }

  internal var caption: Caption? {
    if case .caption(let val) = self {
      return val
    }
    return nil
  }

  internal var isCaption: Bool {
    if case .caption = self {
      return true
    }
    return false
  }

  internal var video: Video? {
    if case .video(let val) = self {
      return val
    }
    return nil
  }

  internal var isVideo: Bool {
    if case .video = self {
      return true
    }
    return false
  }

  internal var spine: Spine? {
    if case .spine(let val) = self {
      return val
    }
    return nil
  }

  internal var isSpine: Bool {
    if case .spine = self {
      return true
    }
    return false
  }
}

// swiftlint:enable cyclomatic_complexity
