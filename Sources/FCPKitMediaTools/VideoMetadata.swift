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
    public let url: URL
    public let duration: CMTime
    public let dimensions: CGSize
    public let frameRate: Float
    public let hasVideo: Bool
    public let hasAudio: Bool
    public let audioChannels: Int?
    public let audioSampleRate: Double?
    public let videoCodec: String?
    public let audioCodec: String?

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

/// Errors that can occur during video metadata extraction
public enum VideoMetadataError: Error, LocalizedError {
  case fileNotFound
  case unsupportedFormat
  case noVideoTrack
  case noAudioTrack
  case extractionFailed(String)

  public var errorDescription: String? {
    switch self {
    case .fileNotFound:
      return "Video file not found"
    case .unsupportedFormat:
      return "Unsupported video format"
    case .noVideoTrack:
      return "No video track found in file"
    case .noAudioTrack:
      return "No audio track found in file"
    case .extractionFailed(let reason):
      return "Metadata extraction failed: \(reason)"
    }
  }
}
