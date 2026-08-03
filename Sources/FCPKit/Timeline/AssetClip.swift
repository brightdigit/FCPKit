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

/// An `asset-clip` element referencing a media asset placed on the timeline.
public struct AssetClip: Codable {
  internal enum CodingKeys: String, CodingKey {
    // Attributes
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

    // DTD line 516:
    // note?, conform-rate?, timeMap?, %intrinsic-params;, (%anchor_item;)*,
    // (%marker_item;)*, audio-channel-source*, (%video_filter_item;)*,
    // filter-audio*, metadata?
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
    case keywords = "keyword"
    case audioChannelSource = "audio-channel-source"
    case filterVideo = "filter-video"
    case filterAudio = "filter-audio"
  }

  /// The asset resource reference.
  public var ref: ResourceRef<AssetKind>?
  /// The display name of the clip.
  public var name: String?
  /// The clip's duration, as a rational time string.
  public var duration: String?
  /// The start time within the source media, as a rational time string.
  public var start: String?
  /// The format resource reference.
  public var format: ResourceRef<FormatKind>?
  /// The timecode format, either `DF` (drop frame) or `NDF` (non-drop frame).
  public var tcFormat: TCFormat?
  /// The number of audio channels in the source media.
  public var audioChannels: String?
  /// The audio sample rate of the source media, in hertz.
  public var audioRate: String?
  /// The role assigned to the clip's audio, such as `dialogue`.
  public var audioRole: String?
  /// The vertical lane of the clip; nonzero lanes connect above or below the storyline.
  public var lane: String?
  /// The clip's start position on the parent timeline, as a rational time string.
  public var offset: String?
  /// Whether the clip's audio subroles are active, as `1` or `0`.
  public var useAudioSubroles: String?
  /// The last modification date of the source media.
  public var modDate: String?
  /// The start time of the clip's audio portion, as a rational time string.
  public var audioStart: String?
  /// The duration of the clip's audio portion, as a rational time string.
  public var audioDuration: String?
  /// The keyword ranges tagged on the clip.
  public var keywords: [Keyword]?
  /// A user-entered note about the clip.
  public var note: String?
  /// The frame-rate conforming behavior for media that mismatches the sequence.
  public var conformRate: ConformRate?
  /// The volume adjustment applied to the clip's audio.
  public var adjustVolume: AdjustVolume?
  /// The blend-mode and opacity adjustment applied to the clip.
  public var adjustBlend: AdjustBlend?
  /// The audio channel source configurations for the clip.
  public var audioChannelSource: [AudioChannelSource]?
  /// The markers placed on the clip.
  public var markers: [Marker]?
  /// The favorite or rejected rating range applied to the clip.
  public var rating: Rating?
  /// The chapter markers placed on the clip.
  public var chapterMarkers: [ChapterMarker]?
  /// The audio filter effects applied to the clip.
  public var filterAudio: [FilterAudio]?
  /// The video filter effects applied to the clip.
  public var filterVideo: [FilterVideo]?
  /// The ordered anchored items attached to this clip.
  public var anchoredItems: [AnchoredItem]?
  /// The position, scale, and rotation adjustment applied to the clip.
  public var adjustTransform: AdjustTransform?
  /// The crop adjustment applied to the clip.
  public var adjustCrop: AdjustCrop?
  /// The retiming map applied to the clip.
  public var timeMap: TimeMap?

  /// Creates an asset clip with the given attributes and contained elements.
  public init(
    ref: ResourceRef<AssetKind>? = nil,
    name: String? = nil,
    duration: String? = nil,
    start: String? = nil,
    format: ResourceRef<FormatKind>? = nil,
    tcFormat: TCFormat? = nil,
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
    anchoredItems: [AnchoredItem]? = nil,
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
    self.adjustTransform = adjustTransform
    self.adjustCrop = adjustCrop
    self.timeMap = timeMap

    let items = Self.appending(
      [
        titles?.map(AnchoredItem.title),
        assetClips?.map(AnchoredItem.assetClip),
        video?.map(AnchoredItem.video),
      ],
      onto: anchoredItems ?? []
    )
    self.anchoredItems = items.isEmpty ? nil : items
  }
}

extension AssetClip: FCPNodeEncodable {
  /// Returns whether the given coding key encodes as an XML attribute or element.
  public static let elementKeys: Set<String> = [
    "", "note", "conform-rate", "timeMap", "adjust-transform",
    "adjust-crop", "adjust-blend", "adjust-volume",
    "marker", "rating", "chapter-marker", "keyword",
    "audio-channel-source", "filter-video", "filter-audio",
  ]
}
