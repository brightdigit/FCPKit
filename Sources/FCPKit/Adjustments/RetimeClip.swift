//
//  RetimeClip.swift
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

/// A retimed clip whose playback speed is changed by a `timeMap` or a constant speed factor.
public struct RetimeClip: Codable {
  internal enum CodingKeys: String, CodingKey {
    case ref
    case offset
    case name
    case start
    case duration
    case speed
    case timeMap
  }

  /// The ID of the referenced media resource.
  public let ref: String?
  /// The clip's position in its parent timeline, as a rational time string.
  public let offset: String?
  /// The display name of the clip.
  public let name: String?
  /// The start time within the source media, as a rational time string.
  public let start: String?
  /// The clip's duration, as a rational time string.
  public let duration: String?
  /// The constant playback speed factor, as a string.
  public let speed: String?
  /// The `timeMap` child element defining variable-speed retiming.
  public let timeMap: TimeMap?
}

extension RetimeClip: DynamicNodeEncoding {
  /// Encodes `timeMap` as a child element and all other keys as XML attributes.
  public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
    fcpNodeEncoding(for: key, elementKeys: ["timeMap"])
  }
}
