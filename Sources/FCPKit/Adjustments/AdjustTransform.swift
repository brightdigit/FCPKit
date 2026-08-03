//
//  AdjustTransform.swift
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

/// An `adjust-transform` element controlling a clip's spatial transform.
///
/// Covers the DTD's `enabled`, `position`, `scale`, `rotation`, and `anchor`
/// attributes. `CodingKeys` follow DTD declaration order.
public struct AdjustTransform: Codable {
  internal enum CodingKeys: String, CodingKey {
    case enabled
    case position
    case scale
    case rotation
    case anchor
  }

  /// Whether the adjustment is active. `"0"` disables it; the DTD default is `"1"`.
  public var enabled: String?
  /// The position offset as an "x y" pair, as a string.
  public var position: String?
  /// The scale factor as an "x y" pair, as a string.
  public var scale: String?
  /// The rotation in degrees, as a string.
  public var rotation: String?
  /// The anchor point as an "x y" pair, as a string.
  public var anchor: String?

  /// Creates an `adjust-transform` adjustment. Omitted values are not encoded.
  public init(
    enabled: String? = nil,
    position: String? = nil,
    scale: String? = nil,
    rotation: String? = nil,
    anchor: String? = nil
  ) {
    self.enabled = enabled
    self.position = position
    self.scale = scale
    self.rotation = rotation
    self.anchor = anchor
  }
}

extension AdjustTransform: DynamicNodeEncoding {
  /// Encodes all coding keys as XML attributes.
  public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .attribute }
}
