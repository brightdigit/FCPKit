//
//  ParamElement.swift
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

/// A `param` element: an effect parameter setting, possibly nested, faded, or keyframed.
public struct ParamElement: Codable {
  internal enum CodingKeys: String, CodingKey {
    case name
    case key
    case value
    case param
    case data
    case fadeIn
    case fadeOut
    case keyframeAnimation
  }

  /// The human-readable parameter name, such as `Position` or `Amount`.
  public let name: String?
  /// The parameter's stable identifier key within the effect.
  public let key: String?
  /// The parameter's value, as a string.
  public var value: String?
  /// Nested child parameters of this parameter.
  public var param: [ParamElement]?
  /// Opaque `data` payloads attached to the parameter.
  public var data: [DataElement]?
  /// The `fadeIn` element easing the parameter in over time.
  public var fadeIn: Fade?
  /// The `fadeOut` element easing the parameter out over time.
  public var fadeOut: Fade?
  /// The keyframe animation that varies the parameter's value over time.
  public var keyframeAnimation: KeyframeAnimation?
}

extension ParamElement: DynamicNodeEncoding {
  /// Encodes nested elements as children and all other keys as XML attributes.
  public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
    fcpNodeEncoding(
      for: key,
      elementKeys: [
        "param", "data", "fadeIn", "fadeOut", "keyframeAnimation",
      ]
    )
  }
}
