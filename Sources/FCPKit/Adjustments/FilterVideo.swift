//
//  FilterVideo.swift
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

/// A `filter-video` element applying a video effect to a clip.
public struct FilterVideo: Codable {
  internal enum CodingKeys: String, CodingKey {
    case ref
    case name
    case data
    case param
  }

  /// The ID of the referenced `effect` resource.
  public let ref: String?
  /// The display name of the video filter.
  public let name: String?
  /// Nested `data` elements carrying opaque effect data.
  public var data: [DataElement]?
  /// Nested `param` elements holding the filter's parameter values.
  public var param: [ParamElement]?
}

extension FilterVideo: DynamicNodeEncoding {
  /// Encodes `data` and `param` as child elements and all other keys as XML attributes.
  public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
    fcpNodeEncoding(for: key, elementKeys: ["data", "param"])
  }
}
