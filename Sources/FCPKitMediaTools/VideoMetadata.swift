//
//  VideoMetadata.swift
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

#if canImport(CoreMedia)
  import AVFoundation
  import CoreMedia

  /// Represents metadata extracted from a video file
  ///
  /// Available only on platforms that provide CoreMedia, because `duration` is a `CMTime`.
  public struct VideoMetadata {
    /// Location of the media file the metadata was read from.
    public let url: URL
    /// Total duration of the asset.
    public let duration: CMTime
    /// Natural pixel dimensions of the first video track.
    public let dimensions: CGSize
    /// Nominal frame rate of the first video track, in frames per second.
    public let frameRate: Float
    /// Whether the asset contains at least one video track.
    public let hasVideo: Bool
    /// Whether the asset contains at least one audio track.
    public let hasAudio: Bool
    /// Channel count of the first audio track, or `nil` when unavailable.
    public let audioChannels: Int?
    /// Sample rate of the first audio track in hertz, or `nil` when unavailable.
    public let audioSampleRate: Double?
    /// Four-character codec identifier of the first video track, if known.
    public let videoCodec: String?
    /// Four-character codec identifier of the first audio track, if known.
    public let audioCodec: String?

    /// Creates a metadata value describing a media file.
    /// - Parameters:
    ///   - url: Location of the media file.
    ///   - duration: Total duration of the asset.
    ///   - dimensions: Natural pixel dimensions of the first video track.
    ///   - frameRate: Nominal frame rate in frames per second.
    ///   - hasVideo: Whether the asset contains a video track.
    ///   - hasAudio: Whether the asset contains an audio track.
    ///   - audioChannels: Channel count of the first audio track.
    ///   - audioSampleRate: Sample rate of the first audio track, in hertz.
    ///   - videoCodec: Codec identifier of the first video track.
    ///   - audioCodec: Codec identifier of the first audio track.
    public init(
      url: URL,
      duration: CMTime,
      dimensions: CGSize,
      frameRate: Float,
      hasVideo: Bool,
      hasAudio: Bool,
      audioChannels: Int? = nil,
      audioSampleRate: Double? = nil,
      videoCodec: String? = nil,
      audioCodec: String? = nil
    ) {
      self.url = url
      self.duration = duration
      self.dimensions = dimensions
      self.frameRate = frameRate
      self.hasVideo = hasVideo
      self.hasAudio = hasAudio
      self.audioChannels = audioChannels
      self.audioSampleRate = audioSampleRate
      self.videoCodec = videoCodec
      self.audioCodec = audioCodec
    }
  }
#endif
