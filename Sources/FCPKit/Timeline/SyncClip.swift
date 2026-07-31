//
//  SyncClip.swift
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

/// A `sync-clip` element containing clips synchronized by matching audio or timecode.
public struct SyncClip: Codable {
  internal enum CodingKeys: String, CodingKey {
    // Attributes
    case offset
    case name
    case duration
    case tcFormat
    case format
    case start
    case modDate

    // DTD line 499:
    // note?, %timing-params;, %intrinsic-params;, (spine | (%clip_item;) | caption)*,
    // (%marker_item;)*, sync-source*, (%video_filter_item;)*, filter-audio*, metadata?
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
    case filterVideo = "filter-video"
    case filterAudio = "filter-audio"
  }

  /// The clip's start position on the parent timeline, as a rational time string.
  public var offset: String?
  /// The display name of the clip.
  public var name: String?
  /// The playback duration of the clip, as a rational time string.
  public var duration: String?
  /// The timecode format, such as `DF` (drop frame) or `NDF` (non-drop frame).
  public var tcFormat: String?
  /// The identifier of the `format` resource describing the clip's video format.
  public var format: String?
  /// The start time within the clip's local timeline, as a rational time string.
  public var start: String?
  /// The date the clip was last modified.
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
  /// The ordered anchored items contained in the clip.
  public var anchoredItems: [AnchoredItem]?
  /// The markers placed on the clip.
  public var markers: [Marker]?
  /// The rating applied to the clip.
  public var rating: Rating?
  /// The chapter markers placed on the clip.
  public var chapterMarkers: [ChapterMarker]?
  /// The `filter-video` elements applying video effects to the clip.
  public var filterVideo: [FilterVideo]?
  /// The `filter-audio` elements applying audio effects to the clip.
  public var filterAudio: [FilterAudio]?

  /// The synchronized `asset-clip` elements contained in the clip.
  public var assetClips: [AssetClip]? {
    get { anchoredPayloads(\.assetClip) }
    set { setAnchoredPayloads(newValue, extract: \.assetClip, wrap: AnchoredItem.assetClip) }
  }

  /// Nested `video` elements contained in the clip.
  public var video: [Video]? {
    get { anchoredPayloads(\.video) }
    set { setAnchoredPayloads(newValue, extract: \.video, wrap: AnchoredItem.video) }
  }

  /// Creates a sync clip with the given attributes and contents.
  public init(
    offset: String? = nil,
    name: String? = nil,
    duration: String? = nil,
    tcFormat: String? = nil,
    format: String? = nil,
    start: String? = nil,
    modDate: String? = nil,
    note: String? = nil,
    conformRate: ConformRate? = nil,
    timeMap: TimeMap? = nil,
    adjustTransform: AdjustTransform? = nil,
    adjustCrop: AdjustCrop? = nil,
    adjustBlend: AdjustBlend? = nil,
    adjustVolume: AdjustVolume? = nil,
    assetClips: [AssetClip]? = nil,
    video: [Video]? = nil,
    anchoredItems: [AnchoredItem]? = nil,
    markers: [Marker]? = nil,
    rating: Rating? = nil,
    chapterMarkers: [ChapterMarker]? = nil,
    filterVideo: [FilterVideo]? = nil,
    filterAudio: [FilterAudio]? = nil
  ) {
    self.offset = offset
    self.name = name
    self.duration = duration
    self.tcFormat = tcFormat
    self.format = format
    self.start = start
    self.modDate = modDate
    self.note = note
    self.conformRate = conformRate
    self.timeMap = timeMap
    self.adjustTransform = adjustTransform
    self.adjustCrop = adjustCrop
    self.adjustBlend = adjustBlend
    self.adjustVolume = adjustVolume
    self.markers = markers
    self.rating = rating
    self.chapterMarkers = chapterMarkers
    self.filterVideo = filterVideo
    self.filterAudio = filterAudio

    let items = Self.appending(
      [
        assetClips?.map(AnchoredItem.assetClip),
        video?.map(AnchoredItem.video),
      ],
      onto: anchoredItems ?? []
    )
    self.anchoredItems = items.isEmpty ? nil : items
  }
}

extension SyncClip: AnchoredChoiceContainer {}

extension SyncClip: FCPNodeEncodable {
  /// Encodes elements and remaining keys as attributes.
  public static let elementKeys: Set<String> = [
    "", "note", "conform-rate", "timeMap", "adjust-transform",
    "adjust-crop", "adjust-blend", "adjust-volume", "marker",
    "rating", "chapter-marker", "filter-video", "filter-audio",
  ]
}
