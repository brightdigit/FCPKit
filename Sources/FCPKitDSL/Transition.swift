//
//  Transition.swift
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

import FCPKit

/// A transition between adjacent story items.
public struct Transition: DSLNode {
  internal let preset: TransitionPreset
  /// Transition duration on the storyline.
  public let duration: FCPTime

  /// Creates a transition from a preset. Default duration is one second.
  public init(_ preset: TransitionPreset, duration: FCPTime = FCPTime(numerator: 1)) {
    self.preset = preset
    self.duration = duration
  }

  /// Sets the transition duration.
  public func duration(_ duration: FCPTime) -> Transition {
    Transition(preset, duration: duration)
  }

  internal func build(_ resources: inout ResourceStore) throws -> Built {
    let video = try resources.effect(name: preset.name, uid: preset.videoUID)
    let audio = try resources.effect(name: "Audio Crossfade", uid: preset.audioUID)
    let filters = CrossDissolveFilters.make(video: video, audio: audio)
    return .item(
      .transition(
        FCPKit.Transition(
          duration: duration.description,
          name: preset.name,
          filterVideo: filters.0,
          filterAudio: filters.1
        )
      )
    )
  }
}
