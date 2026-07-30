//
//  RefClip.swift
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

/// A `ref-clip` element referencing a compound clip or other media resource.
public struct RefClip: Codable {
  internal enum CodingKeys: String, CodingKey {
    case ref
    case offset
    case name
    case duration
    case start
    case lane
    case modDate
    case useAudioSubroles
    case conformRate = "conform-rate"
    case timeMap
    case adjustCrop = "adjust-crop"
    case adjustTransform = "adjust-transform"
    case assetClips = "asset-clip"
    case video
    case refClips = "ref-clip"
    case adjustVolume = "adjust-volume"
    case filterVideo = "filter-video"
  }

  /// The identifier of the referenced media resource.
  public var ref: String?
  /// The clip's start position on the parent timeline, as a rational time string.
  public var offset: String?
  /// The display name of the clip.
  public var name: String?
  /// The playback duration of the clip, as a rational time string.
  public var duration: String?
  /// The start time within the clip's local timeline, as a rational time string.
  public var start: String?
  /// The vertical lane the clip occupies when connected to a primary storyline item.
  public var lane: String?
  /// The date the clip was last modified.
  public var modDate: String?
  /// Whether the referenced media's audio subroles are active (`1`) or not (`0`).
  public var useAudioSubroles: String?
  /// The `conform-rate` element describing frame-rate conforming behavior.
  public var conformRate: ConformRate?
  /// The `timeMap` element applying retiming to the clip.
  public var timeMap: TimeMap?
  /// The `adjust-crop` element applying crop adjustments to the clip.
  public var adjustCrop: AdjustCrop?
  /// The `adjust-transform` element applying position, scale, and rotation adjustments.
  public var adjustTransform: AdjustTransform?
  /// Nested `asset-clip` elements anchored to the clip.
  public var assetClips: [AssetClip]?
  /// Nested `video` elements anchored to the clip.
  public var video: [Video]?
  /// Nested `ref-clip` elements anchored to the clip.
  public var refClips: [RefClip]?
  /// The `adjust-volume` element applying an audio volume adjustment.
  public var adjustVolume: AdjustVolume?
  /// The `filter-video` elements applying video effects to the clip.
  public var filterVideo: [FilterVideo]?

  /// Creates a reference clip with the given attributes and contents.
  public init(
    ref: String? = nil,
    offset: String? = nil,
    name: String? = nil,
    duration: String? = nil,
    start: String? = nil,
    lane: String? = nil,
    modDate: String? = nil,
    useAudioSubroles: String? = nil,
    conformRate: ConformRate? = nil,
    timeMap: TimeMap? = nil,
    adjustTransform: AdjustTransform? = nil,
    adjustCrop: AdjustCrop? = nil,
    assetClips: [AssetClip]? = nil,
    video: [Video]? = nil,
    refClips: [RefClip]? = nil,
    adjustVolume: AdjustVolume? = nil,
    filterVideo: [FilterVideo]? = nil
  ) {
    self.ref = ref
    self.offset = offset
    self.name = name
    self.duration = duration
    self.start = start
    self.lane = lane
    self.modDate = modDate
    self.useAudioSubroles = useAudioSubroles
    self.conformRate = conformRate
    self.timeMap = timeMap
    self.adjustTransform = adjustTransform
    self.adjustCrop = adjustCrop
    self.assetClips = assetClips
    self.video = video
    self.refClips = refClips
    self.adjustVolume = adjustVolume
    self.filterVideo = filterVideo
  }
}

extension RefClip: FCPNodeEncodable {
  /// Encodes child clip content as XML elements and remaining keys as attributes.
  public static let elementKeys: Set<String> = [
    "conform-rate", "timeMap", "adjust-transform", "adjust-crop", "asset-clip",
    "video",
    "ref-clip", "adjust-volume", "filter-video",
  ]
}
