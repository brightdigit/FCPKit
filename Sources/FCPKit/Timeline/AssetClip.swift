//
//  AssetClip.swift
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

public struct AssetClip: Codable {
  public var ref: String?
  public var name: String?
  public var duration: String?
  public var start: String?
  public var format: String?
  public var tcFormat: String?
  public var audioChannels: String?
  public var audioRate: String?
  public var audioRole: String?
  public var lane: String?
  public var offset: String?
  public var useAudioSubroles: String?
  public var modDate: String?
  public var audioStart: String?
  public var audioDuration: String?
  public var keywords: [Keyword]?
  public var note: String?
  public var conformRate: ConformRate?
  public var adjustVolume: AdjustVolume?
  public var adjustBlend: AdjustBlend?
  public var audioChannelSource: [AudioChannelSource]?
  public var markers: [Marker]?
  public var rating: Rating?
  public var chapterMarkers: [ChapterMarker]?
  public var filterAudio: [FilterAudio]?
  public var filterVideo: [FilterVideo]?
  public var titles: [Title]?
  public var assetClips: [AssetClip]?
  public var video: [Video]?
  public var adjustTransform: AdjustTransform?
  public var adjustCrop: AdjustCrop?
  public var timeMap: TimeMap?

  public init(
    ref: String? = nil,
    name: String? = nil,
    duration: String? = nil,
    start: String? = nil,
    format: String? = nil,
    tcFormat: String? = nil,
    audioChannels: String? = nil,
    audioRate: String? = nil,
    audioRole: String? = nil,
    lane: String? = nil,
    offset: String? = nil,
    useAudioSubroles: String? = nil,
    modDate: String? = nil,
    audioStart: String? = nil,
    audioDuration: String? = nil,
    keywords: [Keyword]? = nil,
    note: String? = nil,
    conformRate: ConformRate? = nil,
    adjustVolume: AdjustVolume? = nil,
    adjustBlend: AdjustBlend? = nil,
    audioChannelSource: [AudioChannelSource]? = nil,
    markers: [Marker]? = nil,
    rating: Rating? = nil,
    chapterMarkers: [ChapterMarker]? = nil,
    filterAudio: [FilterAudio]? = nil,
    filterVideo: [FilterVideo]? = nil,
    titles: [Title]? = nil,
    assetClips: [AssetClip]? = nil,
    video: [Video]? = nil,
    adjustTransform: AdjustTransform? = nil,
    adjustCrop: AdjustCrop? = nil,
    timeMap: TimeMap? = nil
  ) {
    self.ref = ref
    self.name = name
    self.duration = duration
    self.start = start
    self.format = format
    self.tcFormat = tcFormat
    self.audioChannels = audioChannels
    self.audioRate = audioRate
    self.audioRole = audioRole
    self.lane = lane
    self.offset = offset
    self.useAudioSubroles = useAudioSubroles
    self.modDate = modDate
    self.audioStart = audioStart
    self.audioDuration = audioDuration
    self.keywords = keywords
    self.note = note
    self.conformRate = conformRate
    self.adjustVolume = adjustVolume
    self.adjustBlend = adjustBlend
    self.audioChannelSource = audioChannelSource
    self.markers = markers
    self.rating = rating
    self.chapterMarkers = chapterMarkers
    self.filterAudio = filterAudio
    self.filterVideo = filterVideo
    self.titles = titles
    self.assetClips = assetClips
    self.video = video
    self.adjustTransform = adjustTransform
    self.adjustCrop = adjustCrop
    self.timeMap = timeMap
  }

  enum CodingKeys: String, CodingKey {
    case ref
    case name
    case duration
    case start
    case format
    case tcFormat
    case audioChannels
    case audioRate
    case audioRole
    case lane
    case offset
    case useAudioSubroles
    case modDate
    case audioStart
    case audioDuration
    case keywords = "keyword"
    case note
    case conformRate = "conform-rate"
    case adjustVolume = "adjust-volume"
    case adjustBlend = "adjust-blend"
    case audioChannelSource = "audio-channel-source"
    case markers = "marker"
    case rating
    case chapterMarkers = "chapter-marker"
    case filterAudio = "filter-audio"
    case filterVideo = "filter-video"
    case titles = "title"
    case assetClips = "asset-clip"
    case video
    case adjustTransform = "adjust-transform"
    case adjustCrop = "adjust-crop"
    case timeMap
  }
}
