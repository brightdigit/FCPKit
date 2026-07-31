//
//  Clip.swift
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

/// A `clip` element representing a basic clip in a storyline.
public struct Clip: Codable {
  internal enum CodingKeys: String, CodingKey {
    // Attributes
    case name
    case ref
    case format
    case duration
    case start
    case tcFormat
    case audioChannels
    case audioRate
    case lane
    case offset
    case modDate

    // DTD line 476:
    // note?, %timing-params;, %intrinsic-params;, (spine | (%clip_item;) | caption)*,
    // (%marker_item;)*, audio-channel-source*, (%video_filter_item;)*, filter-audio*,
    // metadata?
    case note
    case conformRate = "conform-rate"
    case timeMap
    case adjustTransform = "adjust-transform"
    case adjustCrop = "adjust-crop"
    case adjustBlend = "adjust-blend"
    case adjustVolume = "adjust-volume"
    case anchoredItems = ""
    case markers = "marker"
    case rating
    case chapterMarkers = "chapter-marker"
    case audioChannelSource = "audio-channel-source"
    case filterVideo = "filter-video"
    case filterAudio = "filter-audio"
  }

  /// The display name of the clip.
  public var name: String?
  /// The identifier of the referenced resource.
  public var ref: String?
  /// The format resource reference.
  public var format: String?
  /// The clip's duration, as a rational time string.
  public var duration: String?
  /// The start time within the source media, as a rational time string.
  public var start: String?
  /// The timecode format, either `DF` (drop frame) or `NDF` (non-drop frame).
  public var tcFormat: String?
  /// The number of audio channels in the source media.
  public var audioChannels: String?
  /// The audio sample rate of the source media, in hertz.
  public var audioRate: String?
  /// The vertical lane position.
  public var lane: String?
  /// The clip's start position on the parent timeline, as a rational time string.
  public var offset: String?
  /// The modification date of the clip.
  public var modDate: String?

  /// A user-entered note about the clip.
  public var note: String?
  /// The `conform-rate` element.
  public var conformRate: ConformRate?
  /// The `timeMap` element.
  public var timeMap: TimeMap?
  /// The `adjust-transform` element.
  public var adjustTransform: AdjustTransform?
  /// The `adjust-crop` element.
  public var adjustCrop: AdjustCrop?
  /// The `adjust-blend` element.
  public var adjustBlend: AdjustBlend?
  /// The `adjust-volume` element.
  public var adjustVolume: AdjustVolume?
  /// The ordered anchored items attached to this clip.
  public var anchoredItems: [AnchoredItem]?
  /// The markers placed on the clip.
  public var markers: [Marker]?
  /// The rating applied to the clip.
  public var rating: Rating?
  /// The chapter markers placed on the clip.
  public var chapterMarkers: [ChapterMarker]?
  /// The audio channel sources.
  public var audioChannelSource: [AudioChannelSource]?
  /// The video filter effects.
  public var filterVideo: [FilterVideo]?
  /// The audio filter effects.
  public var filterAudio: [FilterAudio]?

  /// Creates a clip with the given attributes and contained elements.
  public init(
    name: String? = nil,
    ref: String? = nil,
    format: String? = nil,
    duration: String? = nil,
    start: String? = nil,
    tcFormat: String? = nil,
    audioChannels: String? = nil,
    audioRate: String? = nil,
    lane: String? = nil,
    offset: String? = nil,
    modDate: String? = nil,
    note: String? = nil,
    conformRate: ConformRate? = nil,
    timeMap: TimeMap? = nil,
    adjustTransform: AdjustTransform? = nil,
    adjustCrop: AdjustCrop? = nil,
    adjustBlend: AdjustBlend? = nil,
    adjustVolume: AdjustVolume? = nil,
    anchoredItems: [AnchoredItem]? = nil,
    markers: [Marker]? = nil,
    rating: Rating? = nil,
    chapterMarkers: [ChapterMarker]? = nil,
    audioChannelSource: [AudioChannelSource]? = nil,
    filterVideo: [FilterVideo]? = nil,
    filterAudio: [FilterAudio]? = nil
  ) {
    self.name = name
    self.ref = ref
    self.format = format
    self.duration = duration
    self.start = start
    self.tcFormat = tcFormat
    self.audioChannels = audioChannels
    self.audioRate = audioRate
    self.lane = lane
    self.offset = offset
    self.modDate = modDate
    self.note = note
    self.conformRate = conformRate
    self.timeMap = timeMap
    self.adjustTransform = adjustTransform
    self.adjustCrop = adjustCrop
    self.adjustBlend = adjustBlend
    self.adjustVolume = adjustVolume
    self.anchoredItems = anchoredItems
    self.markers = markers
    self.rating = rating
    self.chapterMarkers = chapterMarkers
    self.audioChannelSource = audioChannelSource
    self.filterVideo = filterVideo
    self.filterAudio = filterAudio
  }
}

extension Clip: FCPNodeEncodable {
  /// Encodes elements and remaining keys as attributes.
  public static let elementKeys: Set<String> = [
    "", "note", "conform-rate", "timeMap", "adjust-transform",
    "adjust-crop", "adjust-blend", "adjust-volume", "marker",
    "rating", "chapter-marker", "audio-channel-source",
    "filter-video", "filter-audio",
  ]
}
