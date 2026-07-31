//
//  Clip+Coding.swift
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

extension Clip {
  /// Creates a clip by decoding from the given decoder.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.name = try container.decodeIfPresent(String.self, forKey: .name)
    self.ref = try container.decodeIfPresent(ResourceRef<AssetKind>.self, forKey: .ref)
    self.format = try container.decodeIfPresent(ResourceRef<FormatKind>.self, forKey: .format)
    self.duration = try container.decodeIfPresent(String.self, forKey: .duration)
    self.start = try container.decodeIfPresent(String.self, forKey: .start)
    self.tcFormat = try container.decodeIfPresent(TCFormat.self, forKey: .tcFormat)
    self.audioChannels = try container.decodeIfPresent(String.self, forKey: .audioChannels)
    self.audioRate = try container.decodeIfPresent(String.self, forKey: .audioRate)
    self.lane = try container.decodeIfPresent(String.self, forKey: .lane)
    self.offset = try container.decodeIfPresent(String.self, forKey: .offset)
    self.modDate = try container.decodeIfPresent(String.self, forKey: .modDate)

    self.note = try container.decodeIfPresent(String.self, forKey: .note)
    self.conformRate = try container.decodeIfPresent(ConformRate.self, forKey: .conformRate)
    self.timeMap = try container.decodeIfPresent(TimeMap.self, forKey: .timeMap)
    self.adjustTransform = try container.decodeIfPresent(
      AdjustTransform.self,
      forKey: .adjustTransform
    )
    self.adjustCrop = try container.decodeIfPresent(AdjustCrop.self, forKey: .adjustCrop)
    self.adjustBlend = try container.decodeIfPresent(AdjustBlend.self, forKey: .adjustBlend)
    self.adjustVolume = try container.decodeIfPresent(AdjustVolume.self, forKey: .adjustVolume)
    self.markers = try container.decodeIfPresent([Marker].self, forKey: .markers)
    self.rating = try container.decodeIfPresent(Rating.self, forKey: .rating)
    self.chapterMarkers = try container.decodeIfPresent(
      [ChapterMarker].self,
      forKey: .chapterMarkers
    )
    self.audioChannelSource = try container.decodeIfPresent(
      [AudioChannelSource].self,
      forKey: .audioChannelSource
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
}
