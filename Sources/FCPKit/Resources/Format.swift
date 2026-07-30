//
//  Format.swift
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

/// A `format` resource describing video frame dimensions, frame rate, and color space.
public struct Format: Codable {
  internal enum CodingKeys: String, CodingKey {
    case id
    case name
    case frameDuration
    case width
    case height
    case colorSpace
  }

  /// The resource identifier other elements use to reference this format, e.g. "r1".
  public let id: String
  /// The format's descriptive name, e.g. "FFVideoFormat1080p30".
  public var name: String?
  /// The duration of a single frame as a rational time value, e.g. "100/3000s".
  public var frameDuration: String?
  /// The frame width in pixels.
  public var width: String?
  /// The frame height in pixels.
  public var height: String?
  /// The color space of the video, e.g. "1-1-1 (Rec. 709)".
  public var colorSpace: String?

  /// Creates a `format` resource with the given identifier and video characteristics.
  public init(
    id: String,
    name: String? = nil,
    frameDuration: String? = nil,
    width: String? = nil,
    height: String? = nil,
    colorSpace: String? = nil
  ) {
    self.id = id
    self.name = name
    self.frameDuration = frameDuration
    self.width = width
    self.height = height
    self.colorSpace = colorSpace
  }
}

extension Format: DynamicNodeEncoding {
  /// Encodes every property of the `format` element as an XML attribute.
  public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .attribute }
}
