//
//  MetadataEntry.swift
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

/// An `md` element holding a single key-value metadata entry inside a `metadata` container.
public struct MetadataEntry: Codable {
  internal enum CodingKeys: String, CodingKey {
    case key
    case value
    case array
  }

  /// The metadata entry's key name, e.g. "com.apple.proapps.studio.reel".
  public var key: String?
  /// The entry's scalar value, used when the entry holds a single string.
  public var value: String?
  /// The entry's `array` of string values, used when the entry holds multiple values.
  public var array: MetadataArray?

  /// Creates an `md` metadata entry with the given key and scalar or array value.
  public init(key: String? = nil, value: String? = nil, array: MetadataArray? = nil) {
    self.key = key
    self.value = value
    self.array = array
  }
}

extension MetadataEntry: DynamicNodeEncoding {
  /// Encodes `array` as a child element and all other keys as attributes.
  public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
    fcpNodeEncoding(for: key, elementKeys: ["array"])
  }
}
