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
    // Attributes
    case ref
    case name
    case duration
    case start
    case lane
    case offset
    case modDate
    case useAudioSubroles

    // DTD line 488:
    // note?, %timing-params;, %intrinsic-params;, (%anchor_item;)*, (%marker_item;)*,
    // audio-role-source*, (%video_filter_item;)*, filter-audio*, metadata?
    case note
    case conformRate = "conform-rate"
    case timeMap
    case adjustTransform = "adjust-transform"
    case adjustCrop = "adjust-crop"
    case adjustVolume = "adjust-volume"
    case anchoredItems = ""
    case markers = "marker"
    case rating
    case chapterMarkers = "chapter-marker"
    case filterVideo = "filter-video"
    case filterAudio = "filter-audio"
  }

  /// The media resource reference.
  public var ref: ResourceRef<MediaKind>?
  /// The display name of the clip.
  public var name: String?
  /// The playback duration of the clip, as a rational time string.
  public var duration: String?
  /// The start time within the clip's local timeline, as a rational time string.
  public var start: String?
  /// The vertical lane the clip occupies when connected to a primary storyline item.
  public var lane: String?
  /// The clip's start position on the parent timeline, as a rational time string.
  public var offset: String?
  /// The date the clip was last modified.
  public var modDate: String?
  /// Whether the referenced media's audio subroles are active (`1`) or not (`0`).
  public var useAudioSubroles: String?

  /// A user-entered note about the clip.
  public var note: String?
  /// The `conform-rate` element describing frame-rate conforming behavior.
  public var conformRate: ConformRate?
  /// The `timeMap` element applying retiming to the clip.
  public var timeMap: TimeMap?
  /// The `adjust-transform` element applying position, scale, and rotation adjustments.
  public var adjustTransform: AdjustTransform?
  /// The `adjust-crop` element applying crop adjustments to the clip.
  public var adjustCrop: AdjustCrop?
  /// The `adjust-volume` element applying an audio volume adjustment.
  public var adjustVolume: AdjustVolume?
  /// The ordered anchored items attached to this clip.
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

  /// Nested `asset-clip` elements anchored to the clip.
  public var assetClips: [AssetClip]? {
    get { anchoredPayloads(\.assetClip) }
    set { setAnchoredPayloads(newValue, extract: \.assetClip, wrap: AnchoredItem.assetClip) }
  }

  /// Nested `video` elements anchored to the clip.
  public var video: [Video]? {
    get { anchoredPayloads(\.video) }
    set { setAnchoredPayloads(newValue, extract: \.video, wrap: AnchoredItem.video) }
  }

  /// Nested `ref-clip` elements anchored to the clip.
  public var refClips: [RefClip]? {
    get { anchoredPayloads(\.refClip) }
    set { setAnchoredPayloads(newValue, extract: \.refClip, wrap: AnchoredItem.refClip) }
  }

  /// Creates a reference clip with the given attributes and contents.
  public init(
    ref: ResourceRef<MediaKind>? = nil,
    offset: String? = nil,
    name: String? = nil,
    duration: String? = nil,
    start: String? = nil,
    lane: String? = nil,
    modDate: String? = nil,
    useAudioSubroles: String? = nil,
    note: String? = nil,
    conformRate: ConformRate? = nil,
    timeMap: TimeMap? = nil,
    adjustTransform: AdjustTransform? = nil,
    adjustCrop: AdjustCrop? = nil,
    adjustVolume: AdjustVolume? = nil,
    assetClips: [AssetClip]? = nil,
    video: [Video]? = nil,
    refClips: [RefClip]? = nil,
    anchoredItems: [AnchoredItem]? = nil,
    markers: [Marker]? = nil,
    rating: Rating? = nil,
    chapterMarkers: [ChapterMarker]? = nil,
    filterVideo: [FilterVideo]? = nil,
    filterAudio: [FilterAudio]? = nil
  ) {
    self.ref = ref
    self.offset = offset
    self.name = name
    self.duration = duration
    self.start = start
    self.lane = lane
    self.modDate = modDate
    self.useAudioSubroles = useAudioSubroles
    self.note = note
    self.conformRate = conformRate
    self.timeMap = timeMap
    self.adjustTransform = adjustTransform
    self.adjustCrop = adjustCrop
    self.adjustVolume = adjustVolume
    self.markers = markers
    self.rating = rating
    self.chapterMarkers = chapterMarkers
    self.filterVideo = filterVideo
    self.filterAudio = filterAudio

    let items = OrderedChoiceItems.appending(
      [
        assetClips?.map(AnchoredItem.assetClip),
        video?.map(AnchoredItem.video),
        refClips?.map(AnchoredItem.refClip),
      ],
      onto: anchoredItems ?? []
    )
    self.anchoredItems = items.isEmpty ? nil : items
  }
}

extension RefClip: AnchoredChoiceContainer {}

extension RefClip: FCPNodeEncodable {
  /// Encodes elements and remaining keys as attributes.
  public static let elementKeys: Set<String> = [
    "", "note", "conform-rate", "timeMap", "adjust-transform",
    "adjust-crop", "adjust-volume", "marker", "rating",
    "chapter-marker", "filter-video", "filter-audio",
  ]
}
