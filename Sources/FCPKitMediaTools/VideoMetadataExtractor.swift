//
//  VideoMetadataExtractor.swift
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

#if canImport(AVFoundation)
  import AVFoundation
  import CoreMedia

  /// Extracts metadata from video files using AVFoundation
  ///
  /// Available only on platforms that provide AVFoundation.
  public class VideoMetadataExtractor {
    public init() {}

    /// Extracts metadata from a video file
    /// - Parameter url: URL of the video file
    /// - Returns: VideoMetadata containing all extracted information
    /// - Throws: VideoMetadataError if extraction fails
    public func extractMetadata(from url: URL) async throws -> VideoMetadata {
      // Check if file exists
      guard FileManager.default.fileExists(atPath: url.path) else {
        throw VideoMetadataError.fileNotFound
      }

      let asset = AVAsset(url: url)

      // Load basic asset properties
      let duration = try await asset.load(.duration)

      // Get video track information
      let videoTracks = try await asset.loadTracks(withMediaType: .video)
      let audioTracks = try await asset.loadTracks(withMediaType: .audio)

      var dimensions = CGSize.zero
      var frameRate: Float = 24.0  // Default
      var videoCodec: String?

      if let videoTrack = videoTracks.first {
        let naturalSize = try await videoTrack.load(.naturalSize)
        let nominalFrameRate = try await videoTrack.load(.nominalFrameRate)

        dimensions = naturalSize
        frameRate = nominalFrameRate

        // Get codec information
        let formatDescriptions = try await videoTrack.load(.formatDescriptions)
        if let formatDescription = formatDescriptions.first {
          let codecType = CMFormatDescriptionGetMediaSubType(formatDescription)
          videoCodec = fourCharCodeToString(codecType)
        }
      }

      var audioChannels: Int?
      var audioSampleRate: Double?
      var audioCodec: String?

      if let audioTrack = audioTracks.first {
        let formatDescriptions = try await audioTrack.load(.formatDescriptions)
        if let formatDescription = formatDescriptions.first {
          let audioStreamBasicDescription = CMAudioFormatDescriptionGetStreamBasicDescription(
            formatDescription
          )
          if let asbd = audioStreamBasicDescription {
            audioChannels = Int(asbd.pointee.mChannelsPerFrame)
            audioSampleRate = asbd.pointee.mSampleRate
          }

          let codecType = CMFormatDescriptionGetMediaSubType(formatDescription)
          audioCodec = fourCharCodeToString(codecType)
        }
      }

      return VideoMetadata(
        url: url,
        duration: duration,
        dimensions: dimensions,
        frameRate: frameRate,
        hasVideo: !videoTracks.isEmpty,
        hasAudio: !audioTracks.isEmpty,
        audioChannels: audioChannels,
        audioSampleRate: audioSampleRate,
        videoCodec: videoCodec,
        audioCodec: audioCodec
      )
    }

    /// Converts a FourCharCode to a readable string
    private func fourCharCodeToString(_ code: FourCharCode) -> String {
      let bytes = [
        UInt8((code >> 24) & 0xFF),
        UInt8((code >> 16) & 0xFF),
        UInt8((code >> 8) & 0xFF),
        UInt8(code & 0xFF),
      ]
      return String(bytes: bytes, encoding: .ascii) ?? "unknown"
    }
  }
#endif
