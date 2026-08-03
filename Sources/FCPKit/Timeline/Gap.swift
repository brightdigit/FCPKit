//
//  Gap.swift
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

/// A `gap` element representing empty space in a storyline.
public struct Gap: Codable {
  internal enum CodingKeys: String, CodingKey {
    // Attributes
    case name
    case offset
    case duration
    case start

    // DTD line 558: note?, (%anchor_item;)*, (%marker_item;)*, metadata?
    case note
    case anchoredItems = ""
    case markers = "marker"
    case rating
    case chapterMarkers = "chapter-marker"
  }

  /// The display name of the gap.
  public var name: String?
  /// The gap's start position on the parent timeline, as a rational time string.
  public var offset: String?
  /// The gap's duration, as a rational time string.
  public var duration: String?
  /// The gap's local timeline start time, as a rational time string.
  public var start: String?

  /// A user-entered note about the gap.
  public var note: String?
  /// The ordered anchored items attached to this gap.
  public var anchoredItems: [AnchoredItem]?
  /// The markers placed on the gap.
  public var markers: [Marker]?
  /// The rating applied to the gap.
  public var rating: Rating?
  /// The chapter markers placed on the gap.
  public var chapterMarkers: [ChapterMarker]?

  /// Creates a gap clip by decoding from the given decoder.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.name = try container.decodeIfPresent(String.self, forKey: .name)
    self.offset = try container.decodeIfPresent(String.self, forKey: .offset)
    self.duration = try container.decodeIfPresent(String.self, forKey: .duration)
    self.start = try container.decodeIfPresent(String.self, forKey: .start)

    self.note = try container.decodeIfPresent(String.self, forKey: .note)
    self.markers = try container.decodeIfPresent([Marker].self, forKey: .markers)
    self.rating = try container.decodeIfPresent(Rating.self, forKey: .rating)
    self.chapterMarkers = try container.decodeIfPresent(
      [ChapterMarker].self,
      forKey: .chapterMarkers
    )

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

  /// Creates a gap clip with the given attributes and contained elements.
  public init(
    name: String? = nil,
    offset: String? = nil,
    duration: String? = nil,
    start: String? = nil,
    note: String? = nil,
    anchoredItems: [AnchoredItem]? = nil,
    markers: [Marker]? = nil,
    rating: Rating? = nil,
    chapterMarkers: [ChapterMarker]? = nil
  ) {
    self.name = name
    self.offset = offset
    self.duration = duration
    self.start = start
    self.note = note
    self.anchoredItems = anchoredItems
    self.markers = markers
    self.rating = rating
    self.chapterMarkers = chapterMarkers
  }
}

extension Gap: FCPNodeEncodable {
  /// Encodes elements and remaining keys as attributes.
  public static let elementKeys: Set<String> = [
    "", "note", "marker", "rating", "chapter-marker",
  ]
}
