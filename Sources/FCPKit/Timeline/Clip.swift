//
//  Clip.swift
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

/// A `clip` element representing a basic clip in a storyline.
public struct Clip: Codable {
  internal enum CodingKeys: String, CodingKey {
    case name
    case ref
    case offset
    case duration
    case start
    case tcFormat
    case audioChannels
    case audioRate
  }

  /// The display name of the clip.
  public let name: String?
  /// The identifier of the referenced resource.
  public let ref: String?
  /// The clip's start position on the parent timeline, as a rational time string.
  public let offset: String?
  /// The clip's duration, as a rational time string.
  public let duration: String?
  /// The start time within the source media, as a rational time string.
  public let start: String?
  /// The timecode format, either `DF` (drop frame) or `NDF` (non-drop frame).
  public let tcFormat: String?
  /// The number of audio channels in the source media.
  public let audioChannels: String?
  /// The audio sample rate of the source media, in hertz.
  public let audioRate: String?
}

extension Clip: DynamicNodeEncoding {
  /// Encodes every coding key as an XML attribute.
  public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .attribute }
}
