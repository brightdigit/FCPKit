//
//  AssetClip+Editing.swift
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

extension AssetClip {
  /// Appends a standard marker matching Final Cut's default marker duration.
  public mutating func addMarker(
    name: String,
    at start: FCPTime,
    duration: FCPTime = FCPTime(numerator: 100, denominator: 2_400)
  ) {
    var list = markers ?? []
    list.append(Marker(start: start, duration: duration, value: name))
    markers = list
  }

  /// Assigns the Music audio role the way Final Cut exports it:
  /// `audio-channel-source` with `music.music-1`, leaving `audioRole` unchanged.
  public mutating func assignMusicRole(sourceChannels: String = "1, 2") {
    let source = AudioChannelSource(srcCh: sourceChannels, role: "music.music-1")
    if var existing = audioChannelSource, !existing.isEmpty {
      existing[0].srcCh = sourceChannels
      existing[0].role = "music.music-1"
      audioChannelSource = existing
    } else {
      audioChannelSource = [source]
    }
  }

  /// Applies a constant retiming. For example, `percent: 50` with media
  /// duration `10s` sets clip duration to `20s` and a two-point `timeMap`
  /// matching Final Cut's 50% slow export (`interp: smooth2`).
  ///
  /// Non-integral speeds use exact rational arithmetic (for example 75% of
  /// `10s` → `40/3s`), never decimal seconds.
  ///
  /// Updates only this clip. Callers should update parent `sequence.duration`
  /// when the timeline length must change.
  public mutating func setConstantSpeed(percent: Int, mediaDuration: FCPTime) throws {
    guard percent > 0 else {
      throw AssetClipEditingError.invalidSpeedPercent(percent)
    }

    let timelineDuration = try mediaDuration.scaled(by: 100, over: Int64(percent)).reduced()

    duration = timelineDuration.description
    timeMap = TimeMap(timepts: [
      Timept(time: .zero, value: .zero, interp: .smooth2),
      Timept(time: timelineDuration, value: mediaDuration, interp: .smooth2),
    ])
  }
}
