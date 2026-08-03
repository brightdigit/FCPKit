//
//  Marker.swift
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

/// A `marker` element annotating a point on a clip, optionally as a completable to-do item.
public struct Marker: Codable {
  internal enum CodingKeys: String, CodingKey {
    case start
    case duration
    case value
    case note
    case completed
  }

  /// The marker's position within its parent clip.
  public var start: FCPTime?
  /// The marker's duration.
  public var duration: FCPTime?
  /// The marker's title text.
  public var value: String?
  /// An optional note attached to the marker.
  public var note: String?
  /// The to-do completion state; present only for to-do markers.
  public var completed: FCPBool?

  /// Creates a marker with the given timing, title, note, and to-do completion state.
  public init(
    start: FCPTime? = nil,
    duration: FCPTime? = nil,
    value: String? = nil,
    note: String? = nil,
    completed: FCPBool? = nil
  ) {
    self.start = start
    self.duration = duration
    self.value = value
    self.note = note
    self.completed = completed
  }
}

extension Marker: DynamicNodeEncoding {
  /// Encodes every key as an XML attribute.
  public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .attribute }
}
