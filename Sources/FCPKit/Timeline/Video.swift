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
    case ref
    case lane
    case offset
    case name
    case start
    case duration
    case param
    case filterVideo = "filter-video"
    case adjustTransform = "adjust-transform"
    case adjustColorConform = "adjust-colorConform"
  }

  /// The identifier of the referenced media resource.
  public let ref: String?
  /// The vertical lane the element occupies when connected to a primary storyline item.
  public let lane: String?
  /// The element's start position on the parent timeline, as a rational time string.
  public let offset: String?
  /// The display name of the element.
  public let name: String?
  /// The start time within the element's local timeline, as a rational time string.
  public let start: String?
  /// The playback duration of the element, as a rational time string.
  public let duration: String?
  /// The `param` elements adjusting the referenced effect's parameters.
  public var param: [ParamElement]?
  /// The `filter-video` elements applying video effects to the element.
  public let filterVideo: [FilterVideo]?
  /// The `adjust-transform` element applying position, scale, and rotation adjustments.
  public var adjustTransform: AdjustTransform?
  /// The `adjust-colorConform` element controlling color conform behavior.
  public var adjustColorConform: AdjustColorConform?
}

extension Video: FCPNodeEncodable {
  /// Encodes params, filters, and adjustments as XML elements and remaining keys as attributes.
  public static let elementKeys: Set<String> = [
    "param", "filter-video", "adjust-transform", "adjust-colorConform",
  ]
}
