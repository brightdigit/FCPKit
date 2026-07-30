//
//  TrimRect.swift
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

/// A `trim-rect` element giving per-edge trim insets for an `adjust-crop` in trim mode.
public struct TrimRect: Codable {
  internal enum CodingKeys: String, CodingKey {
    case left
    case right
    case top
    case bottom
  }

  /// The trim inset from the left edge of the frame, as a string.
  public var left: String?
  /// The trim inset from the right edge of the frame, as a string.
  public var right: String?
  /// The trim inset from the top edge of the frame, as a string.
  public var top: String?
  /// The trim inset from the bottom edge of the frame, as a string.
  public var bottom: String?

  /// Creates a `trim-rect` with optional per-edge insets.
  public init(
    left: String? = nil,
    right: String? = nil,
    top: String? = nil,
    bottom: String? = nil
  ) {
    self.left = left
    self.right = right
    self.top = top
    self.bottom = bottom
  }
}

extension TrimRect: DynamicNodeEncoding {
  /// Encodes all coding keys as XML attributes.
  public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .attribute }
}
