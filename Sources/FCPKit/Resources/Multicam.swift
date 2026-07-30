//
//  Multicam.swift
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

/// A `multicam` element containing the camera angles of a multicam clip inside a `media` resource.
public struct Multicam: Codable {
  internal enum CodingKeys: String, CodingKey {
    case format
    case tcStart
    case tcFormat
    case mcAngles = "mc-angle"
  }

  /// The `id` of the `format` resource describing the multicam's video characteristics.
  public var format: String?
  /// The starting timecode of the multicam, as a rational time value.
  public var tcStart: String?
  /// The timecode format, either "DF" (drop frame) or "NDF" (non-drop frame).
  public var tcFormat: String?
  /// The `mc-angle` elements holding each camera angle's clips.
  public var mcAngles: [MCAngle]?

  /// Creates a `multicam` element with the given format, timecode, and camera angles.
  public init(
    format: String? = nil,
    tcStart: String? = nil,
    tcFormat: String? = nil,
    mcAngles: [MCAngle]? = nil
  ) {
    self.format = format
    self.tcStart = tcStart
    self.tcFormat = tcFormat
    self.mcAngles = mcAngles
  }
}

extension Multicam: DynamicNodeEncoding {
  /// Encodes `mc-angle` as child elements and all other keys as attributes.
  public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
    fcpNodeEncoding(for: key, elementKeys: ["mc-angle"])
  }
}
