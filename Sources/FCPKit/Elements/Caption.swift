//
//  Caption.swift
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

/// A `caption` element: a closed caption or subtitle anchored to a clip on the timeline.
public struct Caption: Codable {
  internal enum CodingKeys: String, CodingKey {
    case lane
    case offset
    case name
    case start
    case duration
    case role
    case text
  }

  /// The lane number for vertical placement relative to the primary storyline.
  public let lane: String?
  /// The caption's position on its parent timeline, as a rational time string.
  public let offset: String?
  /// The display name of the caption.
  public let name: String?
  /// The start time within the caption's local timeline, as a rational time string.
  public let start: String?
  /// The caption's duration, as a rational time string.
  public let duration: String?
  /// The caption role, including its format qualifier (for example `iTT?captionFormat=ITT.en`).
  public let role: String?
  /// The caption's displayed text content.
  public let text: String?
}

extension Caption: DynamicNodeEncoding {
  /// Encodes `text` as a child element and all other keys as XML attributes.
  public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
    fcpNodeEncoding(for: key, elementKeys: ["text"])
  }
}
