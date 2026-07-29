//
//  FCPXMLExtended.swift
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

public struct MCClip: Codable {
  public var ref: String?
  public var offset: String?
  public var name: String?
  public var start: String?
  public var duration: String?
  public var modDate: String?
  public var mcSources: [MCSource]?
  public var video: [Video]?

  public init(
    ref: String? = nil,
    offset: String? = nil,
    name: String? = nil,
    start: String? = nil,
    duration: String? = nil,
    modDate: String? = nil,
    mcSources: [MCSource]? = nil,
    video: [Video]? = nil
  ) {
    self.ref = ref
    self.offset = offset
    self.name = name
    self.start = start
    self.duration = duration
    self.modDate = modDate
    self.mcSources = mcSources
    self.video = video
  }

  enum CodingKeys: String, CodingKey {
    case ref
    case offset
    case name
    case start
    case duration
    case modDate
    case mcSources = "mc-source"
    case video
  }
}

public struct MCSource: Codable {
  public let angleID: String?
  public var srcEnable: String?

  public init(angleID: String, srcEnable: String? = nil) {
    self.angleID = angleID
    self.srcEnable = srcEnable
  }

  enum CodingKeys: String, CodingKey {
    case angleID
    case srcEnable
  }
}

public struct Video: Codable {
  public let ref: String?
  public let lane: String?
  public let offset: String?
  public let name: String?
  public let start: String?
  public let duration: String?
  public var param: [ParamElement]?
  public let filterVideo: [FilterVideo]?
  public var adjustTransform: AdjustTransform?
  public var adjustColorConform: AdjustColorConform?

  enum CodingKeys: String, CodingKey {
    case ref
    case lane
    case offset
    case name
    case start
    case duration
    case param
    case filterVideo = "filter-video"
    case adjustTransform = "adjust-transform"
    case adjustColorConform = "adjust-colorConform"
  }
}

public struct FilterVideo: Codable {
  public let ref: String?
  public let name: String?
  public var data: [DataElement]?
  public var param: [ParamElement]?

  enum CodingKeys: String, CodingKey {
    case ref
    case name
    case data
    case param
  }
}

public struct DataElement: Codable {
  public let key: String?
  public var value: String?

  enum CodingKeys: String, CodingKey {
    case key
    case value = ""
  }
}

public struct ParamElement: Codable {
  public let name: String?
  public let key: String?
  public var value: String?
  public var param: [ParamElement]?
  public var data: [DataElement]?
  public var fadeIn: Fade?
  public var fadeOut: Fade?
  public var keyframeAnimation: KeyframeAnimation?

  enum CodingKeys: String, CodingKey {
    case name
    case key
    case value
    case param
    case data
    case fadeIn
    case fadeOut
    case keyframeAnimation
  }
}

public struct Media: Codable {
  public let id: String?
  public var name: String?
  public let uid: String?
  public var modDate: String?
  public var sequence: Sequence?
  public var multicam: Multicam?
  public var mediaRep: [MediaRep]?

  public init(
    id: String,
    name: String? = nil,
    uid: String? = nil,
    modDate: String? = nil,
    sequence: Sequence? = nil,
    multicam: Multicam? = nil,
    mediaRep: [MediaRep]? = nil
  ) {
    self.id = id
    self.name = name
    self.uid = uid
    self.modDate = modDate
    self.sequence = sequence
    self.multicam = multicam
    self.mediaRep = mediaRep
  }

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case uid
    case modDate
    case sequence
    case multicam
    case mediaRep = "media-rep"
  }
}

public struct Multicam: Codable {
  public var format: String?
  public var tcStart: String?
  public var tcFormat: String?
  public var mcAngles: [MCAngle]?

  public init(
    format: String? = nil,
    tcStart: String? = nil,
    tcFormat: String? = nil,
    mcAngles: [MCAngle]? = nil
  ) {
    self.format = format
    self.tcStart = tcStart
    self.tcFormat = tcFormat
    self.mcAngles = mcAngles
  }

  enum CodingKeys: String, CodingKey {
    case format
    case tcStart
    case tcFormat
    case mcAngles = "mc-angle"
  }
}

public struct MCAngle: Codable {
  public var name: String?
  public let angleID: String?
  public var gaps: [Gap]?
  public var refClips: [RefClip]?

  public init(
    name: String? = nil,
    angleID: String,
    gaps: [Gap]? = nil,
    refClips: [RefClip]? = nil
  ) {
    self.name = name
    self.angleID = angleID
    self.gaps = gaps
    self.refClips = refClips
  }

  enum CodingKeys: String, CodingKey {
    case name
    case angleID
    case gaps = "gap"
    case refClips = "ref-clip"
  }
}

public struct RefClip: Codable {
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

  enum CodingKeys: String, CodingKey {
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
}

public struct ConformRate: Codable {
  public let srcFrameRate: String?
  public let scaleEnabled: String?

  enum CodingKeys: String, CodingKey {
    case srcFrameRate
    case scaleEnabled
  }
}

public struct TimeMap: Codable {
  public var timepts: [Timept]?

  public init(timepts: [Timept]? = nil) {
    self.timepts = timepts
  }

  enum CodingKeys: String, CodingKey {
    case timepts = "timept"
  }
}

public struct Timept: Codable {
  public var time: String?
  public var value: String?
  public var interp: String?

  public init(time: String? = nil, value: String? = nil, interp: String? = nil) {
    self.time = time
    self.value = value
    self.interp = interp
  }

  enum CodingKeys: String, CodingKey {
    case time
    case value
    case interp
  }
}

public struct AdjustTransform: Codable {
  public var position: String?
  public var scale: String?

  public init(position: String? = nil, scale: String? = nil) {
    self.position = position
    self.scale = scale
  }

  enum CodingKeys: String, CodingKey {
    case position
    case scale
  }
}

public struct AdjustColorConform: Codable {
  public let enabled: String?
  public let autoOrManual: String?
  public let conformType: String?
  public let peakNitsOfPQSource: String?
  public let peakNitsOfSDRToPQSource: String?

  enum CodingKeys: String, CodingKey {
    case enabled
    case autoOrManual
    case conformType
    case peakNitsOfPQSource
    case peakNitsOfSDRToPQSource
  }
}

public struct AdjustCrop: Codable {
  public var mode: String?
  public var trimRect: TrimRect?

  public init(mode: String? = nil, trimRect: TrimRect? = nil) {
    self.mode = mode
    self.trimRect = trimRect
  }

  enum CodingKeys: String, CodingKey {
    case mode
    case trimRect = "trim-rect"
  }
}

public struct TrimRect: Codable {
  public var left: String?
  public var right: String?
  public var top: String?
  public var bottom: String?

  public init(
    left: String? = nil,
    right: String? = nil,
    top: String? = nil,
    bottom: String? = nil
  ) {
    self.left = left
    self.right = right
    self.top = top
    self.bottom = bottom
  }

  enum CodingKeys: String, CodingKey {
    case left
    case right
    case top
    case bottom
  }
}

public struct SyncClip: Codable {
  public let offset: String?
  public let name: String?
  public let duration: String?
  public let tcFormat: String?
  public let format: String?
  public let start: String?
  public let modDate: String?
  public let assetClips: [AssetClip]?
  public let video: [Video]?
  public let filterVideo: [FilterVideo]?

  enum CodingKeys: String, CodingKey {
    case offset
    case name
    case duration
    case tcFormat
    case format
    case start
    case modDate
    case assetClips = "asset-clip"
    case video
    case filterVideo = "filter-video"
  }
}

public struct MediaRep: Codable {
  public var kind: String?
  public var sig: String?
  public var src: String?
  public var bookmark: String?

  public init(
    kind: String? = nil,
    sig: String? = nil,
    src: String? = nil,
    bookmark: String? = nil
  ) {
    self.kind = kind
    self.sig = sig
    self.src = src
    self.bookmark = bookmark
  }

  enum CodingKeys: String, CodingKey {
    case kind
    case sig
    case src
    case bookmark
  }
}

public struct AssetMetadata: Codable {
  public var entries: [MetadataEntry]?

  public init(entries: [MetadataEntry]? = nil) {
    self.entries = entries
  }

  enum CodingKeys: String, CodingKey {
    case entries = "md"
  }
}

public struct MetadataEntry: Codable {
  public var key: String?
  public var value: String?
  public var array: MetadataArray?

  public init(key: String? = nil, value: String? = nil, array: MetadataArray? = nil) {
    self.key = key
    self.value = value
    self.array = array
  }

  enum CodingKeys: String, CodingKey {
    case key
    case value
    case array
  }
}

public struct MetadataArray: Codable {
  public var strings: [MetadataString]?

  public init(strings: [MetadataString]? = nil) {
    self.strings = strings
  }

  enum CodingKeys: String, CodingKey {
    case strings = "string"
  }
}

public struct MetadataString: Codable {
  public var content: String?

  public init(content: String? = nil) {
    self.content = content
  }

  enum CodingKeys: String, CodingKey {
    case content = ""
  }
}

public struct SmartCollection: Codable {
  public var name: String?
  public var match: String?
  public var matchClip: [MatchClip]?
  public var matchMedia: [MatchMedia]?
  public var matchRatings: [MatchRatings]?
  public var matchAnalysisType: [MatchAnalysisType]?

  public init(
    name: String? = nil,
    match: String? = nil,
    matchClip: [MatchClip]? = nil,
    matchMedia: [MatchMedia]? = nil,
    matchRatings: [MatchRatings]? = nil,
    matchAnalysisType: [MatchAnalysisType]? = nil
  ) {
    self.name = name
    self.match = match
    self.matchClip = matchClip
    self.matchMedia = matchMedia
    self.matchRatings = matchRatings
    self.matchAnalysisType = matchAnalysisType
  }

  enum CodingKeys: String, CodingKey {
    case name
    case match
    case matchClip = "match-clip"
    case matchMedia = "match-media"
    case matchRatings = "match-ratings"
    case matchAnalysisType = "match-analysis-type"
  }
}

public struct MatchClip: Codable {
  public var rule: String?
  public var type: String?

  public init(rule: String? = nil, type: String? = nil) {
    self.rule = rule
    self.type = type
  }

  enum CodingKeys: String, CodingKey {
    case rule
    case type
  }
}

public struct MatchMedia: Codable {
  public var rule: String?
  public var type: String?

  public init(rule: String? = nil, type: String? = nil) {
    self.rule = rule
    self.type = type
  }

  enum CodingKeys: String, CodingKey {
    case rule
    case type
  }
}

public struct MatchRatings: Codable {
  public var value: String?

  public init(value: String? = nil) {
    self.value = value
  }

  enum CodingKeys: String, CodingKey {
    case value
  }
}

public struct MatchAnalysisType: Codable {
  public var rule: String?
  public var value: String?

  public init(rule: String? = nil, value: String? = nil) {
    self.rule = rule
    self.value = value
  }

  enum CodingKeys: String, CodingKey {
    case rule
    case value
  }
}

public struct AdjustVolume: Codable {
  public var amount: String?
  public var param: [ParamElement]?

  enum CodingKeys: String, CodingKey {
    case amount
    case param
  }
}

public struct AdjustLoudness: Codable {
  public let amount: String?
  public let uniformity: String?

  enum CodingKeys: String, CodingKey {
    case amount
    case uniformity
  }
}

public struct AdjustBlend: Codable {
  public let amount: String?
  public let mode: String?

  enum CodingKeys: String, CodingKey {
    case amount
    case mode
  }
}

public struct AudioChannelSource: Codable {
  public var srcCh: String?
  public var role: String?
  public var active: String?
  public var adjustLoudness: AdjustLoudness?

  public init(
    srcCh: String? = nil,
    role: String? = nil,
    active: String? = nil,
    adjustLoudness: AdjustLoudness? = nil
  ) {
    self.srcCh = srcCh
    self.role = role
    self.active = active
    self.adjustLoudness = adjustLoudness
  }

  enum CodingKeys: String, CodingKey {
    case srcCh
    case role
    case active
    case adjustLoudness = "adjust-loudness"
  }
}
