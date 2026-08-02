//
//  TransitionPreset.swift
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

/// A fixture-backed or custom transition effect preset.
public struct TransitionPreset: Equatable, Sendable {
  /// Final Cut Pro's default Cross Dissolve, including audio crossfade.
  public static let crossDissolve = TransitionPreset(
    name: "Cross Dissolve",
    videoUID: "FxPlug:4731E73A-8DAC-4113-9A30-AE85B1761265",
    audioUID: "FFAudioTransition"
  )

  /// The video transition effect resource name.
  public let name: String
  /// The video transition effect resource unique identifier.
  public let videoUID: String
  /// The companion audio transition effect resource unique identifier.
  public let audioUID: String

  /// Creates a transition preset from a display name and video/audio effect UIDs.
  public init(name: String, videoUID: String, audioUID: String) {
    self.name = name
    self.videoUID = videoUID
    self.audioUID = audioUID
  }
}
