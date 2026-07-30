//
//  AdjustCrop.swift
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

/// An `adjust-crop` element controlling how a clip's frame is cropped.
public struct AdjustCrop: Codable {
  internal enum CodingKeys: String, CodingKey {
    case mode
    case trimRect = "trim-rect"
  }

  /// The crop mode: "trim", "crop", or "pan".
  public var mode: String?
  /// The `trim-rect` child element giving per-edge insets when in trim mode.
  public var trimRect: TrimRect?

  /// Creates an `adjust-crop` adjustment with an optional mode and trim rectangle.
  public init(mode: String? = nil, trimRect: TrimRect? = nil) {
    self.mode = mode
    self.trimRect = trimRect
  }
}

extension AdjustCrop: DynamicNodeEncoding {
  /// Encodes `trim-rect` as a child element and all other keys as XML attributes.
  public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
    fcpNodeEncoding(for: key, elementKeys: ["trim-rect"])
  }
}
