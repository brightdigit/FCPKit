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

  /// The identifier of the referenced transition effect resource.
  public let ref: String?
  /// The transition's start position on the parent timeline, as a rational time string.
  public let offset: String?
  /// The duration of the transition, as a rational time string.
  public let duration: String?
  /// How the transition aligns to the edit point: `start`, `center`, or `end`.
  public let alignment: String?
  /// The display name of the transition.
  public let name: String?
  /// The start time within the transition's local timeline, as a rational time string.
  public let start: String?
  /// The `filter-video` elements applying video effects to the transition.
  public var filterVideo: [FilterVideo]?
  /// The `filter-audio` elements applying audio effects to the transition.
  public var filterAudio: [FilterAudio]?
}

extension Transition: DynamicNodeEncoding {
  /// Encodes filter content as XML elements and remaining keys as attributes.
  public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
    fcpNodeEncoding(for: key, elementKeys: ["filter-video", "filter-audio"])
  }
}
