//
//  CompoundClip.swift
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

/// A `compound-clip` element referencing a compound clip media resource.
public struct CompoundClip: Codable {
  internal enum CodingKeys: String, CodingKey {
    // Attributes
    case ref
    case offset
    case name
    case start
    case duration
    case useAudioSubroles
    case format
    case lane

    case note
    case anchoredItems = ""
    case markers = "marker"
    case rating
    case chapterMarkers = "chapter-marker"
  }

  /// The media resource reference.
  public var ref: ResourceRef<MediaKind>?
  /// The clip's start position on the parent timeline, as a rational time string.
  public var offset: String?
  /// The display name of the clip.
  public var name: String?
  /// The start time within the referenced media, as a rational time string.
  public var start: String?
  /// The clip's duration, as a rational time string.
  public var duration: String?
  /// Whether the clip's audio subroles are active, as `1` or `0`.
  public var useAudioSubroles: String?
  /// The format resource reference.
  public var format: ResourceRef<FormatKind>?
  /// The vertical lane position.
  public var lane: String?

  /// A user-entered note.
  public var note: String?
  /// The ordered anchored items in the clip.
  public var anchoredItems: [AnchoredItem]?
  /// The markers placed on the clip.
  public var markers: [Marker]?
  /// The rating applied to the clip.
  public var rating: Rating?
  /// The chapter markers placed on the clip.
  public var chapterMarkers: [ChapterMarker]?

  /// Creates a compound clip by decoding from the given decoder.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.ref = try container.decodeIfPresent(ResourceRef<MediaKind>.self, forKey: .ref)
    self.offset = try container.decodeIfPresent(String.self, forKey: .offset)
    self.name = try container.decodeIfPresent(String.self, forKey: .name)
    self.start = try container.decodeIfPresent(String.self, forKey: .start)
    self.duration = try container.decodeIfPresent(String.self, forKey: .duration)
    self.useAudioSubroles = try container.decodeIfPresent(String.self, forKey: .useAudioSubroles)
    self.format = try container.decodeIfPresent(ResourceRef<FormatKind>.self, forKey: .format)
    self.lane = try container.decodeIfPresent(String.self, forKey: .lane)

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

  /// Creates a compound clip with the given attributes and contents.
  public init(
    ref: ResourceRef<MediaKind>? = nil,
    offset: String? = nil,
    name: String? = nil,
    start: String? = nil,
    duration: String? = nil,
    useAudioSubroles: String? = nil,
    format: ResourceRef<FormatKind>? = nil,
    lane: String? = nil,
    note: String? = nil,
    anchoredItems: [AnchoredItem]? = nil,
    markers: [Marker]? = nil,
    rating: Rating? = nil,
    chapterMarkers: [ChapterMarker]? = nil
  ) {
    self.ref = ref
    self.offset = offset
    self.name = name
    self.start = start
    self.duration = duration
    self.useAudioSubroles = useAudioSubroles
    self.format = format
    self.lane = lane
    self.note = note
    self.anchoredItems = anchoredItems
    self.markers = markers
    self.rating = rating
    self.chapterMarkers = chapterMarkers
  }
}

extension CompoundClip: FCPNodeEncodable {
  /// Encodes elements and remaining keys as attributes.
  public static let elementKeys: Set<String> = [
    "", "note", "marker", "rating", "chapter-marker",
  ]
}
