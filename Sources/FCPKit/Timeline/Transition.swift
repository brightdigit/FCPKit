//
//  Transition.swift
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

/// A `transition` element joining two adjacent story elements, such as a cross dissolve.
public struct Transition: Codable {
  internal enum CodingKeys: String, CodingKey {
    case ref
    case offset
    case duration
    case alignment
    case name
    case start
    case filterVideo = "filter-video"
    case filterAudio = "filter-audio"
  }

  /// The effect resource reference of the transition.
  public var ref: ResourceRef<EffectKind>?
  /// The transition's start position on the parent timeline, as a rational time string.
  public var offset: String?
  /// The duration of the transition, as a rational time string.
  public var duration: String?
  /// How the transition aligns to the edit point: `start`, `center`, or `end`.
  public var alignment: String?
  /// The display name of the transition.
  public var name: String?
  /// The start time within the transition's local timeline, as a rational time string.
  public var start: String?
  /// The `filter-video` elements applying video effects to the transition.
  public var filterVideo: [FilterVideo]?
  /// The `filter-audio` elements applying audio effects to the transition.
  public var filterAudio: [FilterAudio]?

  /// Creates a transition element with the given attributes and filters.
  public init(
    ref: ResourceRef<EffectKind>? = nil,
    offset: String? = nil,
    duration: String? = nil,
    alignment: String? = nil,
    name: String? = nil,
    start: String? = nil,
    filterVideo: [FilterVideo]? = nil,
    filterAudio: [FilterAudio]? = nil
  ) {
    self.ref = ref
    self.offset = offset
    self.duration = duration
    self.alignment = alignment
    self.name = name
    self.start = start
    self.filterVideo = filterVideo
    self.filterAudio = filterAudio
  }
}

extension Transition: FCPNodeEncodable {
  /// Encodes filter content as XML elements and remaining keys as attributes.
  public static let elementKeys: Set<String> = ["filter-video", "filter-audio"]
}
