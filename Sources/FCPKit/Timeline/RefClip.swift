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

// swiftlint:disable file_length

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

    // swiftlint:disable:next line_length
    // DTD line 488: note?, %timing-params;, %intrinsic-params;, (%anchor_item;)*, (%marker_item;)*, audio-role-source*, (%video_filter_item;)*, filter-audio*, metadata?
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

  /// The identifier of the referenced media resource.
  public var ref: String?
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
    get { getAnchored(\.assetClip) }
    set { setAnchored(newValue, isType: \.isAssetClip, wrap: AnchoredItem.assetClip) }
  }

  /// Nested `video` elements anchored to the clip.
  public var video: [Video]? {
    get { getAnchored(\.video) }
    set { setAnchored(newValue, isType: \.isVideo, wrap: AnchoredItem.video) }
  }

  /// Nested `ref-clip` elements anchored to the clip.
  public var refClips: [RefClip]? {
    get { getAnchored(\.refClip) }
    set { setAnchored(newValue, isType: \.isRefClip, wrap: AnchoredItem.refClip) }
  }

  /// Creates a reference clip by decoding from the given decoder.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.ref = try container.decodeIfPresent(String.self, forKey: .ref)
    self.name = try container.decodeIfPresent(String.self, forKey: .name)
    self.duration = try container.decodeIfPresent(String.self, forKey: .duration)
    self.start = try container.decodeIfPresent(String.self, forKey: .start)
    self.lane = try container.decodeIfPresent(String.self, forKey: .lane)
    self.offset = try container.decodeIfPresent(String.self, forKey: .offset)
    self.modDate = try container.decodeIfPresent(String.self, forKey: .modDate)
    self.useAudioSubroles = try container.decodeIfPresent(String.self, forKey: .useAudioSubroles)

    self.note = try container.decodeIfPresent(String.self, forKey: .note)
    self.conformRate = try container.decodeIfPresent(ConformRate.self, forKey: .conformRate)
    self.timeMap = try container.decodeIfPresent(TimeMap.self, forKey: .timeMap)
    self.adjustTransform = try container.decodeIfPresent(
      AdjustTransform.self,
      forKey: .adjustTransform
    )
    self.adjustCrop = try container.decodeIfPresent(AdjustCrop.self, forKey: .adjustCrop)
    self.adjustVolume = try container.decodeIfPresent(AdjustVolume.self, forKey: .adjustVolume)
    self.markers = try container.decodeIfPresent([Marker].self, forKey: .markers)
    self.rating = try container.decodeIfPresent(Rating.self, forKey: .rating)
    self.chapterMarkers = try container.decodeIfPresent(
      [ChapterMarker].self,
      forKey: .chapterMarkers
    )
    self.filterVideo = try container.decodeIfPresent([FilterVideo].self, forKey: .filterVideo)
    self.filterAudio = try container.decodeIfPresent([FilterAudio].self, forKey: .filterAudio)

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

  /// Creates a reference clip with the given attributes and contents.
  public init(
    ref: String? = nil,
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

    var items = anchoredItems ?? []
    if let assetClips {
      items.append(contentsOf: assetClips.map(AnchoredItem.assetClip))
    }
    if let video {
      items.append(contentsOf: video.map(AnchoredItem.video))
    }
    if let refClips {
      items.append(contentsOf: refClips.map(AnchoredItem.refClip))
    }
    self.anchoredItems = items.isEmpty ? nil : items
  }

  private func getAnchored<T>(_ extract: (AnchoredItem) -> T?) -> [T]? {
    guard let anchoredItems else {
      return nil
    }
    let list = anchoredItems.compactMap(extract)
    if list.isEmpty {
      return nil
    }
    return list
  }

  private mutating func setAnchored<T>(
    _ newValue: [T]?,
    isType: (AnchoredItem) -> Bool,
    wrap: (T) -> AnchoredItem
  ) {
    guard let newValue else {
      anchoredItems?.removeAll(where: isType)
      if anchoredItems?.isEmpty == true {
        anchoredItems = nil
      }
      return
    }
    var items = anchoredItems ?? []
    var newIndex = 0
    var indicesToRemove = [Int]()
    for index in items.indices where isType(items[index]) {
      if newIndex < newValue.count {
        items[index] = wrap(newValue[newIndex])
        newIndex += 1
      } else {
        indicesToRemove.append(index)
      }
    }
    for index in indicesToRemove.reversed() {
      items.remove(at: index)
    }
    while newIndex < newValue.count {
      items.append(wrap(newValue[newIndex]))
      newIndex += 1
    }
    anchoredItems = items
  }
}

extension RefClip: FCPNodeEncodable {
  /// Encodes elements and remaining keys as attributes.
  public static let elementKeys: Set<String> = [
    "", "note", "conform-rate", "timeMap", "adjust-transform",
    "adjust-crop", "adjust-volume", "marker", "rating",
    "chapter-marker", "filter-video", "filter-audio",
  ]
}
