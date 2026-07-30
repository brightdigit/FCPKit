//
//  Sequence.swift
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

/// A `sequence` element describing a project's timeline and its settings.
public struct Sequence: Codable {
  internal enum CodingKeys: String, CodingKey {
    case format
    case duration
    case tcStart
    case tcFormat
    case audioLayout
    case audioRate
    case renderFormat
    case spine
  }

  /// The format resource reference describing the sequence's video format.
  public var format: ResourceRef<FormatKind>?
  /// The total duration of the sequence, as a rational time string.
  public var duration: String?
  /// The starting timecode of the sequence, as a rational time string.
  public var tcStart: String?
  /// The timecode format, such as `DF` (drop frame) or `NDF` (non-drop frame).
  public var tcFormat: TCFormat?
  /// The audio channel layout, such as `mono`, `stereo`, or `surround`.
  public var audioLayout: AudioLayout?
  /// The audio sample rate, such as `48k`.
  public var audioRate: AudioRate?
  /// The codec identifier used for render files.
  public var renderFormat: String?
  /// The `spine` element containing the sequence's primary storyline.
  public var spine: Spine?

  /// Creates a sequence with the given settings and spine.
  public init(
    format: ResourceRef<FormatKind>? = nil,
    duration: String? = nil,
    tcStart: String? = nil,
    tcFormat: TCFormat? = nil,
    audioLayout: AudioLayout? = nil,
    audioRate: AudioRate? = nil,
    renderFormat: String? = nil,
    spine: Spine? = nil
  ) {
    self.format = format
    self.duration = duration
    self.tcStart = tcStart
    self.tcFormat = tcFormat
    self.audioLayout = audioLayout
    self.audioRate = audioRate
    self.renderFormat = renderFormat
    self.spine = spine
  }
}

extension Sequence: FCPNodeEncodable {
  /// Encodes the spine as an XML element and remaining keys as attributes.
  public static let elementKeys: Set<String> = ["spine"]
}
