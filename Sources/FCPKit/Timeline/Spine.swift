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
    case clips = "clip"
    case gaps = "gap"
    case mcClips = "mc-clip"
    case refClips = "ref-clip"
    case syncClips = "sync-clip"
    case assetClips = "asset-clip"
    case titles = "title"
    case generators = "generator"
    case transitions = "transition"
    case storylines = "storyline"
    case compoundClips = "compound-clip"
    case retimeClips = "retime-clip"
    case captions = "caption"
    case video
  }

  /// The `clip` elements in the spine.
  public var clips: [Clip]?
  /// The `gap` elements filling empty stretches of the spine.
  public var gaps: [Gap]?
  /// The `mc-clip` elements referencing multicam media resources.
  public var mcClips: [MCClip]?
  /// The `ref-clip` elements referencing compound clips or other media resources.
  public var refClips: [RefClip]?
  /// The `sync-clip` elements containing synchronized audio and video.
  public var syncClips: [SyncClip]?
  /// The `asset-clip` elements referencing asset resources.
  public var assetClips: [AssetClip]?
  /// The `title` elements in the spine.
  public var titles: [Title]?
  /// The `generator` elements referencing generator effects.
  public var generators: [Generator]?
  /// The `transition` elements joining adjacent story elements.
  public var transitions: [Transition]?
  /// Nested `storyline` elements connected to the spine.
  public var storylines: [Storyline]?
  /// The `compound-clip` elements in the spine.
  public var compoundClips: [CompoundClip]?
  /// The `retime-clip` elements applying retiming to their contents.
  public var retimeClips: [RetimeClip]?
  /// The `caption` elements in the spine.
  public var captions: [Caption]?
  /// The `video` elements in the spine.
  public var video: [Video]?

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
    self.clips = clips
    self.gaps = gaps
    self.mcClips = mcClips
    self.refClips = refClips
    self.syncClips = syncClips
    self.assetClips = assetClips
    self.titles = titles
    self.generators = generators
    self.transitions = transitions
    self.storylines = storylines
    self.compoundClips = compoundClips
    self.retimeClips = retimeClips
    self.captions = captions
    self.video = video
  }
}

extension Spine: DynamicNodeEncoding {
  /// Encodes every key as an XML element.
  public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .element }
}
