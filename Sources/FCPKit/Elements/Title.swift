//
//  Title.swift
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

/// A `title` element: a title clip whose content comes from a title effect resource.
public struct Title: Codable {
  internal enum CodingKeys: String, CodingKey {
    // Attributes
    case ref
    case name
    case duration
    case start
    case lane
    case offset

    // DTD line 566:
    // param*, text*, text-style-def*, note?, %intrinsic-params-video;, (%anchor_item;)*,
    // (%marker_item;)*, (%video_filter_item;)*, metadata?
    case param
    case text
    case textStyleDef = "text-style-def"
    case note
    case adjustTransform = "adjust-transform"
    case adjustCrop = "adjust-crop"
    case adjustBlend = "adjust-blend"
    case anchoredItems = ""
    case markers = "marker"
    case rating
    case chapterMarkers = "chapter-marker"
    case filterVideo = "filter-video"
  }

  /// The effect resource reference that renders this title.
  public var ref: ResourceRef<EffectKind>?
  /// The display name of the title clip.
  public var name: String?
  /// The clip's duration, as a rational time string.
  public var duration: String?
  /// The start time within the title's local timeline, as a rational time string.
  public var start: String?
  /// The lane number for vertical placement relative to the primary storyline.
  public var lane: String?
  /// The clip's position on its parent timeline, as a rational time string.
  public var offset: String?

  /// The effect parameters applied to the title.
  public var param: [ParamElement]?
  /// The `text` elements holding the title's styled text content.
  public var text: [TextElement]?
  /// The `text-style-def` elements defining named text styles used by the title's text.
  public var textStyleDef: [TextStyleDef]?
  /// A user-entered note about the title.
  public var note: String?
  /// The position, scale, and rotation adjustment applied to the title.
  public var adjustTransform: AdjustTransform?
  /// The crop adjustment applied to the title.
  public var adjustCrop: AdjustCrop?
  /// The blend-mode adjustment applied to the title.
  public var adjustBlend: AdjustBlend?
  /// The ordered anchored items attached to this title.
  public var anchoredItems: [AnchoredItem]?
  /// The markers placed on the title.
  public var markers: [Marker]?
  /// The rating applied to the title.
  public var rating: Rating?
  /// The chapter markers placed on the title.
  public var chapterMarkers: [ChapterMarker]?
  /// The video filter effects applied to the title.
  public var filterVideo: [FilterVideo]?

  /// Creates a title clip by decoding from the given decoder.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.ref = try container.decodeIfPresent(ResourceRef<EffectKind>.self, forKey: .ref)
    self.name = try container.decodeIfPresent(String.self, forKey: .name)
    self.duration = try container.decodeIfPresent(String.self, forKey: .duration)
    self.start = try container.decodeIfPresent(String.self, forKey: .start)
    self.lane = try container.decodeIfPresent(String.self, forKey: .lane)
    self.offset = try container.decodeIfPresent(String.self, forKey: .offset)

    self.param = try container.decodeIfPresent([ParamElement].self, forKey: .param)
    self.text = try container.decodeIfPresent([TextElement].self, forKey: .text)
    self.textStyleDef = try container.decodeIfPresent([TextStyleDef].self, forKey: .textStyleDef)
    self.note = try container.decodeIfPresent(String.self, forKey: .note)
    self.adjustTransform = try container.decodeIfPresent(
      AdjustTransform.self,
      forKey: .adjustTransform
    )
    self.adjustCrop = try container.decodeIfPresent(AdjustCrop.self, forKey: .adjustCrop)
    self.adjustBlend = try container.decodeIfPresent(AdjustBlend.self, forKey: .adjustBlend)
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

  /// Creates a title clip with the given attributes and contained elements.
  public init(
    ref: ResourceRef<EffectKind>? = nil,
    name: String? = nil,
    duration: String? = nil,
    start: String? = nil,
    lane: String? = nil,
    offset: String? = nil,
    param: [ParamElement]? = nil,
    text: [TextElement]? = nil,
    textStyleDef: [TextStyleDef]? = nil,
    note: String? = nil,
    adjustTransform: AdjustTransform? = nil,
    adjustCrop: AdjustCrop? = nil,
    adjustBlend: AdjustBlend? = nil,
    anchoredItems: [AnchoredItem]? = nil,
    markers: [Marker]? = nil,
    rating: Rating? = nil,
    chapterMarkers: [ChapterMarker]? = nil,
    filterVideo: [FilterVideo]? = nil
  ) {
    self.ref = ref
    self.name = name
    self.duration = duration
    self.start = start
    self.lane = lane
    self.offset = offset
    self.param = param
    self.text = text
    self.textStyleDef = textStyleDef
    self.note = note
    self.adjustTransform = adjustTransform
    self.adjustCrop = adjustCrop
    self.adjustBlend = adjustBlend
    self.anchoredItems = anchoredItems
    self.markers = markers
    self.rating = rating
    self.chapterMarkers = chapterMarkers
    self.filterVideo = filterVideo
  }
}

extension Title: FCPNodeEncodable {
  /// Encodes elements and remaining keys as attributes.
  public static let elementKeys: Set<String> = [
    "", "param", "text", "text-style-def", "note",
    "adjust-transform", "adjust-crop", "adjust-blend",
    "marker", "rating", "chapter-marker", "filter-video",
  ]
}
