//
//  MCClip.swift
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

/// An `mc-clip` element that places a multicam media resource on the timeline.
public struct MCClip: Codable {
  internal enum CodingKeys: String, CodingKey {
    // Attributes
    case ref
    case offset
    case name
    case start
    case duration
    case lane
    case modDate

    // DTD line 460:
    // note?, %timing-params;, %intrinsic-params-audio;, mc-source*, (%anchor_item;)*,
    // (%marker_item;)*, filter-audio*, metadata?
    case note
    case conformRate = "conform-rate"
    case timeMap
    case adjustVolume = "adjust-volume"
    case mcSources = "mc-source"
    case anchoredItems = ""
    case markers = "marker"
    case rating
    case chapterMarkers = "chapter-marker"
    case filterAudio = "filter-audio"
  }

  /// The identifier of the referenced multicam media resource.
  public var ref: String?
  /// The clip's start position on the parent timeline, as a rational time string.
  public var offset: String?
  /// The display name of the clip.
  public var name: String?
  /// The start time within the clip's local timeline, as a rational time string.
  public var start: String?
  /// The playback duration of the clip, as a rational time string.
  public var duration: String?
  /// The lane number for vertical placement relative to the primary storyline.
  public var lane: String?
  /// The date the clip was last modified.
  public var modDate: String?

  /// A user-entered note about the clip.
  public var note: String?
  /// The `conform-rate` element.
  public var conformRate: ConformRate?
  /// The `timeMap` element.
  public var timeMap: TimeMap?
  /// The `adjust-volume` element.
  public var adjustVolume: AdjustVolume?
  /// The `mc-source` elements selecting which multicam angles are active.
  public var mcSources: [MCSource]?
  /// The ordered anchored items contained in the clip.
  public var anchoredItems: [AnchoredItem]?
  /// The markers placed on the clip.
  public var markers: [Marker]?
  /// The rating applied to the clip.
  public var rating: Rating?
  /// The chapter markers placed on the clip.
  public var chapterMarkers: [ChapterMarker]?
  /// The `filter-audio` elements applying audio effects to the clip.
  public var filterAudio: [FilterAudio]?

  /// Nested `video` elements anchored to the clip.
  public var video: [Video]? {
    get { anchoredPayloads(\.video) }
    set { setAnchoredPayloads(newValue, extract: \.video, wrap: AnchoredItem.video) }
  }

  /// Creates a multicam clip by decoding from the given decoder.

  /// Creates a multicam clip with the given attributes and contents.
  public init(
    ref: String? = nil,
    offset: String? = nil,
    name: String? = nil,
    start: String? = nil,
    duration: String? = nil,
    lane: String? = nil,
    modDate: String? = nil,
    note: String? = nil,
    conformRate: ConformRate? = nil,
    timeMap: TimeMap? = nil,
    adjustVolume: AdjustVolume? = nil,
    mcSources: [MCSource]? = nil,
    video: [Video]? = nil,
    anchoredItems: [AnchoredItem]? = nil,
    markers: [Marker]? = nil,
    rating: Rating? = nil,
    chapterMarkers: [ChapterMarker]? = nil,
    filterAudio: [FilterAudio]? = nil
  ) {
    self.ref = ref
    self.offset = offset
    self.name = name
    self.start = start
    self.duration = duration
    self.lane = lane
    self.modDate = modDate
    self.note = note
    self.conformRate = conformRate
    self.timeMap = timeMap
    self.adjustVolume = adjustVolume
    self.mcSources = mcSources
    self.markers = markers
    self.rating = rating
    self.chapterMarkers = chapterMarkers
    self.filterAudio = filterAudio

    let items = OrderedChoiceItems.appending(
      [
        video?.map(AnchoredItem.video)
      ],
      onto: anchoredItems ?? []
    )
    self.anchoredItems = items.isEmpty ? nil : items
  }
}

extension MCClip: AnchoredChoiceContainer {}

extension MCClip: FCPNodeEncodable {
  /// Encodes elements and remaining keys as attributes.
  public static let elementKeys: Set<String> = [
    "", "note", "conform-rate", "timeMap", "adjust-volume",
    "mc-source", "marker", "rating", "chapter-marker", "filter-audio",
  ]
}
