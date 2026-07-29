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

public struct Spine: Codable {
  public var clips: [Clip]?
  public var gaps: [Gap]?
  public var mcClips: [MCClip]?
  public var refClips: [RefClip]?
  public var syncClips: [SyncClip]?
  public var assetClips: [AssetClip]?
  public var titles: [Title]?
  public var generators: [Generator]?
  public var transitions: [Transition]?
  public var storylines: [Storyline]?
  public var compoundClips: [CompoundClip]?
  public var retimeClips: [RetimeClip]?
  public var captions: [Caption]?
  public var video: [Video]?

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

  enum CodingKeys: String, CodingKey {
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
}
