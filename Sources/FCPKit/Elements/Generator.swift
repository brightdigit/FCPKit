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

  /// The effect resource reference that generates this clip's content.
  public var ref: ResourceRef<EffectKind>?
  /// The clip's position on its parent timeline, as a rational time string.
  public var offset: String?
  /// The clip's duration, as a rational time string.
  public var duration: String?
  /// The display name of the generator clip.
  public var name: String?
  /// The start time within the generator's local timeline, as a rational time string.
  public var start: String?
  /// The lane number for vertical placement relative to the primary storyline.
  public var lane: String?
  /// The effect parameters applied to the generator.
  public var param: [ParamElement]?

  /// Creates a generator clip with the given attributes and parameters.
  public init(
    ref: ResourceRef<EffectKind>? = nil,
    offset: String? = nil,
    duration: String? = nil,
    name: String? = nil,
    start: String? = nil,
    lane: String? = nil,
    param: [ParamElement]? = nil
  ) {
    self.ref = ref
    self.offset = offset
    self.duration = duration
    self.name = name
    self.start = start
    self.lane = lane
    self.param = param
  }
}

extension Generator: FCPNodeEncodable {
  /// Encodes `param` as a child element and all other keys as XML attributes.
  public static let elementKeys: Set<String> = ["param"]
}
