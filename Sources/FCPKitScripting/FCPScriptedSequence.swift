//
//  FCPScriptedSequence.swift
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
import Foundation

/// A Final Cut Pro sequence with media-time duration and frame duration.
public struct FCPScriptedSequence: Hashable, Sendable {
  /// The sequence display name from Final Cut Pro.
  public var name: String

  /// The sequence media identifier from Final Cut Pro.
  public var id: String

  /// The sequence start time when present in the scripting dictionary.
  public var startTime: FCPTime?

  /// Total sequence duration mapped from the sdef `media time` record.
  public var duration: FCPTime

  /// Frame duration mapped from the sdef `media time` record.
  public var frameDuration: FCPTime

  /// Sequence timecode format, including the scripting-only ``FCPScriptedTimecodeFormat/unspecified`` case.
  public var timecodeFormat: FCPScriptedTimecodeFormat

  /// Creates a scripted sequence snapshot.
  public init(
    name: String,
    id: String,
    startTime: FCPTime? = nil,
    duration: FCPTime,
    frameDuration: FCPTime,
    timecodeFormat: FCPScriptedTimecodeFormat
  ) {
    self.name = name
    self.id = id
    self.startTime = startTime
    self.duration = duration
    self.frameDuration = frameDuration
    self.timecodeFormat = timecodeFormat
  }
}
