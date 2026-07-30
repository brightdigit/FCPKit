//
//  ChapterMarker.swift
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

/// A `chapter-marker` element marking a chapter point, with an optional poster frame.
public struct ChapterMarker: Codable {
  internal enum CodingKeys: String, CodingKey {
    case start
    case duration
    case value
    case note
    case posterOffset
  }

  /// The marker's position within its parent clip, as a rational time string.
  public let start: String?
  /// The marker's duration, as a rational time string.
  public let duration: String?
  /// The chapter title displayed for this marker.
  public let value: String?
  /// An optional note attached to the marker.
  public let note: String?
  /// The offset from `start` to the chapter's poster frame, as a rational time string.
  public let posterOffset: String?
}

extension ChapterMarker: DynamicNodeEncoding {
  /// Encodes every key as an XML attribute.
  public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .attribute }
}
