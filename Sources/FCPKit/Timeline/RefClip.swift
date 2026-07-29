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

  public var ref: String?
  public var offset: String?
  public var name: String?
  public var duration: String?
  public var start: String?
  public var lane: String?
  public var modDate: String?
  public var useAudioSubroles: String?
  public var conformRate: ConformRate?
  public var timeMap: TimeMap?
  public var adjustCrop: AdjustCrop?
  public var adjustTransform: AdjustTransform?
  public var assetClips: [AssetClip]?
  public var video: [Video]?
  public var refClips: [RefClip]?
  public var adjustVolume: AdjustVolume?
  public var filterVideo: [FilterVideo]?

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

extension RefClip: DynamicNodeEncoding {
  public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
    fcpNodeEncoding(
      for: key,
      elementKeys: [
        "conform-rate", "timeMap", "adjust-transform", "adjust-crop", "asset-clip",
        "video",
        "ref-clip", "adjust-volume", "filter-video",
      ]
    )
  }
}
