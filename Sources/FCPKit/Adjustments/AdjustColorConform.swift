//
//  AdjustColorConform.swift
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

/// An `adjust-colorConform` element describing how a clip's color space conforms to the timeline.
public struct AdjustColorConform: Codable {
  internal enum CodingKeys: String, CodingKey {
    case enabled
    case autoOrManual
    case conformType
    case peakNitsOfPQSource
    case peakNitsOfSDRToPQSource
  }

  /// Whether color conforming is enabled ("0" or "1").
  public let enabled: String?
  /// Whether conform settings are chosen automatically or manually.
  public let autoOrManual: String?
  /// The type of color conform to apply (for example "conformNone").
  public let conformType: String?
  /// The peak brightness in nits assumed for a PQ (HDR) source.
  public let peakNitsOfPQSource: String?
  /// The peak brightness in nits used when mapping an SDR source to PQ.
  public let peakNitsOfSDRToPQSource: String?
}

extension AdjustColorConform: DynamicNodeEncoding {
  /// Encodes all coding keys as XML attributes.
  public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .attribute }
}
