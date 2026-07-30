//
//  Gap.swift
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

/// A `gap` element representing empty space in a storyline.
public struct Gap: Codable {
  internal enum CodingKeys: String, CodingKey {
    case name
    case offset
    case duration
    case start
  }

  /// The display name of the gap.
  public let name: String?
  /// The gap's start position on the parent timeline, as a rational time string.
  public let offset: String?
  /// The gap's duration, as a rational time string.
  public let duration: String?
  /// The gap's local timeline start time, as a rational time string.
  public let start: String?
}

extension Gap: DynamicNodeEncoding {
  /// Encodes every coding key as an XML attribute.
  public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .attribute }
}
