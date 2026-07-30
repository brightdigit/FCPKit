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

/// An `adjust-transform` element controlling a clip's spatial transform (position and scale).
public struct AdjustTransform: Codable {
  internal enum CodingKeys: String, CodingKey {
    case position
    case scale
  }

  /// The position offset as an "x y" pair, as a string.
  public var position: String?
  /// The scale factor as an "x y" pair, as a string.
  public var scale: String?

  /// Creates an `adjust-transform` adjustment with an optional position and scale.
  public init(position: String? = nil, scale: String? = nil) {
    self.position = position
    self.scale = scale
  }
}

extension AdjustTransform: DynamicNodeEncoding {
  /// Encodes all coding keys as XML attributes.
  public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .attribute }
}
