//
//  MCAngle.swift
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

/// An `mc-angle` element describing one angle of a multicam media resource.
public struct MCAngle: Codable {
  internal enum CodingKeys: String, CodingKey {
    case name
    case angleID
    case gaps = "gap"
    case refClips = "ref-clip"
  }

  /// The display name of the angle.
  public var name: String?
  /// The unique identifier of the angle within the multicam resource.
  public let angleID: String?
  /// The `gap` elements filling empty stretches of the angle's timeline.
  public var gaps: [Gap]?
  /// The `ref-clip` elements placed on the angle's timeline.
  public var refClips: [RefClip]?

  /// Creates a multicam angle with the given identifier and contents.
  public init(
    name: String? = nil,
    angleID: String,
    gaps: [Gap]? = nil,
    refClips: [RefClip]? = nil
  ) {
    self.name = name
    self.angleID = angleID
    self.gaps = gaps
    self.refClips = refClips
  }
}

extension MCAngle: DynamicNodeEncoding {
  /// Encodes child clip content as XML elements and remaining keys as attributes.
  public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
    fcpNodeEncoding(for: key, elementKeys: ["gap", "ref-clip"])
  }
}
