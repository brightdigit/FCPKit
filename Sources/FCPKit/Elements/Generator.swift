//
//  Generator.swift
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

/// A `generator` element: a clip whose content is produced by a generator effect resource.
public struct Generator: Codable {
  internal enum CodingKeys: String, CodingKey {
    case ref
    case offset
    case duration
    case name
    case start
    case lane
    case param
  }

  /// The `id` of the `effect` resource that generates this clip's content.
  public let ref: String?
  /// The clip's position on its parent timeline, as a rational time string.
  public let offset: String?
  /// The clip's duration, as a rational time string.
  public let duration: String?
  /// The display name of the generator clip.
  public let name: String?
  /// The start time within the generator's local timeline, as a rational time string.
  public let start: String?
  /// The lane number for vertical placement relative to the primary storyline.
  public let lane: String?
  /// The effect parameters applied to the generator.
  public let param: [ParamElement]?
}

extension Generator: FCPNodeEncodable {
  /// Encodes `param` as a child element and all other keys as XML attributes.
  public static let elementKeys: Set<String> = ["param"]
}
