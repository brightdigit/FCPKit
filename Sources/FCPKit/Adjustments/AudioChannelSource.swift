//
//  AudioChannelSource.swift
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

/// An `audio-channel-source` element routing source audio channels to a role with adjustments.
public struct AudioChannelSource: Codable {
  internal enum CodingKeys: String, CodingKey {
    case srcCh
    case role
    case active
    case adjustLoudness = "adjust-loudness"
  }

  /// The comma-separated source channel numbers (for example "1, 2").
  public var srcCh: String?
  /// The audio role assigned to these channels (for example "dialogue").
  public var role: String?
  /// Whether the channel source is active ("0" or "1").
  public var active: String?
  /// An optional `adjust-loudness` adjustment applied to these channels.
  public var adjustLoudness: AdjustLoudness?

  /// Creates an `audio-channel-source` with optional channels, role, state, and loudness.
  public init(
    srcCh: String? = nil,
    role: String? = nil,
    active: String? = nil,
    adjustLoudness: AdjustLoudness? = nil
  ) {
    self.srcCh = srcCh
    self.role = role
    self.active = active
    self.adjustLoudness = adjustLoudness
  }
}

extension AudioChannelSource: FCPNodeEncodable {
  /// Encodes `adjust-loudness` as a child element and all other keys as XML attributes.
  public static let elementKeys: Set<String> = ["adjust-loudness"]
}
