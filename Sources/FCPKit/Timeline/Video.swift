//
//  Video.swift
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

/// A `video` element referencing the video portion of a media resource.
public struct Video: Codable {
  internal enum CodingKeys: String, CodingKey {
    // Attributes
    case ref
    case lane
    case offset
    case name
    case start
    case duration
    case role

    // swiftlint:disable:next line_length
    // DTD line 539: param*, note?, %timing-params;, %intrinsic-params-video;, (%anchor_item;)*, (%marker_item;)*, (%video_filter_item;)*, reserved?
    case param
    case note
    case conformRate = "conform-rate"
    case timeMap
    case adjustTransform = "adjust-transform"
    case adjustCrop = "adjust-crop"
    case adjustBlend = "adjust-blend"
    case adjustColorConform = "adjust-colorConform"
    case anchoredItems = ""
    case markers = "marker"
    case rating
    case chapterMarkers = "chapter-marker"
    case filterVideo = "filter-video"
  }

  /// The identifier of the referenced media resource.
  public var ref: String?
  /// The vertical lane the element occupies when connected to a primary storyline item.
  public var lane: String?
  /// The element's start position on the parent timeline, as a rational time string.
  public var offset: String?
  /// The display name of the element.
  public var name: String?
  /// The start time within the element's local timeline, as a rational time string.
  public var start: String?
  /// The playback duration of the element, as a rational time string.
  public var duration: String?
  /// The video role.
  public var role: String?

  /// The `param` elements adjusting the referenced effect's parameters.
  public var param: [ParamElement]?
  /// A user-entered note.
  public var note: String?
  /// The `conform-rate` element.
  public var conformRate: ConformRate?
  /// The `timeMap` element.
  public var timeMap: TimeMap?
  /// The `adjust-transform` element applying position, scale, and rotation adjustments.
  public var adjustTransform: AdjustTransform?
  /// The `adjust-crop` element.
  public var adjustCrop: AdjustCrop?
  /// The `adjust-blend` element.
  public var adjustBlend: AdjustBlend?
  /// The `adjust-colorConform` element controlling color conform behavior.
  public var adjustColorConform: AdjustColorConform?
  /// The ordered anchored items attached to this video element.
  public var anchoredItems: [AnchoredItem]?
  /// The markers placed on the video.
  public var markers: [Marker]?
  /// The rating applied to the video.
  public var rating: Rating?
  /// The chapter markers placed on the video.
  public var chapterMarkers: [ChapterMarker]?
  /// The `filter-video` elements applying video effects to the element.
  public var filterVideo: [FilterVideo]?

  /// Creates a video element by decoding from the given decoder.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.ref = try container.decodeIfPresent(String.self, forKey: .ref)
    self.lane = try container.decodeIfPresent(String.self, forKey: .lane)
    self.offset = try container.decodeIfPresent(String.self, forKey: .offset)
    self.name = try container.decodeIfPresent(String.self, forKey: .name)
    self.start = try container.decodeIfPresent(String.self, forKey: .start)
    self.duration = try container.decodeIfPresent(String.self, forKey: .duration)
    self.role = try container.decodeIfPresent(String.self, forKey: .role)

    self.param = try container.decodeIfPresent([ParamElement].self, forKey: .param)
    self.note = try container.decodeIfPresent(String.self, forKey: .note)
    self.conformRate = try container.decodeIfPresent(ConformRate.self, forKey: .conformRate)
    self.timeMap = try container.decodeIfPresent(TimeMap.self, forKey: .timeMap)
    self.adjustTransform = try container.decodeIfPresent(
      AdjustTransform.self,
      forKey: .adjustTransform
    )
    self.adjustCrop = try container.decodeIfPresent(AdjustCrop.self, forKey: .adjustCrop)
    self.adjustBlend = try container.decodeIfPresent(AdjustBlend.self, forKey: .adjustBlend)
    self.adjustColorConform = try container.decodeIfPresent(
      AdjustColorConform.self,
      forKey: .adjustColorConform
    )
    self.markers = try container.decodeIfPresent([Marker].self, forKey: .markers)
    self.rating = try container.decodeIfPresent(Rating.self, forKey: .rating)
    self.chapterMarkers = try container.decodeIfPresent(
      [ChapterMarker].self,
      forKey: .chapterMarkers
    )
    self.filterVideo = try container.decodeIfPresent([FilterVideo].self, forKey: .filterVideo)

    let itemsContainer = try decoder.singleValueContainer()
    let decodedItems = (try? itemsContainer.decode([AnchoredItem].self)) ?? []
    let filteredItems = decodedItems.filter { item in
      if case .unsupported = item {
        return false
      }
      return true
    }
    self.anchoredItems = filteredItems.isEmpty ? nil : filteredItems
  }

  /// Creates a video element with the given attributes and contents.
  public init(
    ref: String? = nil,
    lane: String? = nil,
    offset: String? = nil,
    name: String? = nil,
    start: String? = nil,
    duration: String? = nil,
    role: String? = nil,
    param: [ParamElement]? = nil,
    note: String? = nil,
    conformRate: ConformRate? = nil,
    timeMap: TimeMap? = nil,
    adjustTransform: AdjustTransform? = nil,
    adjustCrop: AdjustCrop? = nil,
    adjustBlend: AdjustBlend? = nil,
    adjustColorConform: AdjustColorConform? = nil,
    anchoredItems: [AnchoredItem]? = nil,
    markers: [Marker]? = nil,
    rating: Rating? = nil,
    chapterMarkers: [ChapterMarker]? = nil,
    filterVideo: [FilterVideo]? = nil
  ) {
    self.ref = ref
    self.lane = lane
    self.offset = offset
    self.name = name
    self.start = start
    self.duration = duration
    self.role = role
    self.param = param
    self.note = note
    self.conformRate = conformRate
    self.timeMap = timeMap
    self.adjustTransform = adjustTransform
    self.adjustCrop = adjustCrop
    self.adjustBlend = adjustBlend
    self.adjustColorConform = adjustColorConform
    self.anchoredItems = anchoredItems
    self.markers = markers
    self.rating = rating
    self.chapterMarkers = chapterMarkers
    self.filterVideo = filterVideo
  }
}

extension Video: FCPNodeEncodable {
  /// Encodes params, filters, and adjustments as XML elements and remaining keys as attributes.
  public static let elementKeys: Set<String> = [
    "", "param", "note", "conform-rate", "timeMap",
    "adjust-transform", "adjust-crop", "adjust-blend",
    "adjust-colorConform", "marker", "rating", "chapter-marker",
    "filter-video",
  ]
}
