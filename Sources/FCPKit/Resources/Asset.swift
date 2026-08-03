//
//  Asset.swift
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

/// An `asset` resource describing a source media file referenced by clips in the library.
public struct Asset: Codable {
  internal enum CodingKeys: String, CodingKey {
    case id
    case name
    case uid
    case src
    case start
    case duration
    case format
    case hasVideo
    case hasAudio
    case audioChannels
    case audioRate
    case videoRate
    case videoSources
    case audioSources
    case mediaRep = "media-rep"
    case metadata
  }

  /// The resource identifier other elements use to reference this asset, e.g. "r2".
  public var id: ResourceID
  /// The asset's display name as shown in the browser.
  public var name: String?
  /// A globally unique identifier for the asset's source media.
  public var uid: String?
  /// The URL of the asset's original media file.
  public var src: String?
  /// The start time of the asset's available media, as a rational time value.
  public var start: String?
  /// The total duration of the asset's media, as a rational time value.
  public var duration: String?
  /// The format resource reference describing this asset's video characteristics.
  public var format: ResourceRef<FormatKind>?
  /// Whether the asset contains video.
  public var hasVideo: FCPBool?
  /// Whether the asset contains audio.
  public var hasAudio: FCPBool?
  /// The number of audio channels in the asset's media.
  public var audioChannels: String?
  /// The audio sample rate in hertz, e.g. "48000".
  public var audioRate: String?
  /// The video frame rate expressed as a rational or decimal value.
  public var videoRate: String?
  /// The number of video sources in the asset's media.
  public var videoSources: String?
  /// The number of audio sources in the asset's media.
  public var audioSources: String?
  /// The `media-rep` elements locating the original and proxy media files.
  public var mediaRep: [MediaRep]?
  /// The `metadata` container holding the asset's `md` key-value entries.
  public var metadata: AssetMetadata?

  /// Creates an `asset` resource with the given identifier and media attributes.
  public init(
    id: ResourceID,
    name: String? = nil,
    uid: String? = nil,
    src: String? = nil,
    start: String? = nil,
    duration: String? = nil,
    format: ResourceRef<FormatKind>? = nil,
    hasVideo: FCPBool? = nil,
    hasAudio: FCPBool? = nil,
    audioChannels: String? = nil,
    audioRate: String? = nil,
    videoRate: String? = nil,
    videoSources: String? = nil,
    audioSources: String? = nil,
    mediaRep: [MediaRep]? = nil,
    metadata: AssetMetadata? = nil
  ) {
    self.id = id
    self.name = name
    self.uid = uid
    self.src = src
    self.start = start
    self.duration = duration
    self.format = format
    self.hasVideo = hasVideo
    self.hasAudio = hasAudio
    self.audioChannels = audioChannels
    self.audioRate = audioRate
    self.videoRate = videoRate
    self.videoSources = videoSources
    self.audioSources = audioSources
    self.mediaRep = mediaRep
    self.metadata = metadata
  }
}

extension Asset: FCPNodeEncodable {
  /// Encodes `media-rep` and `metadata` as child elements and all other keys as attributes.
  public static let elementKeys: Set<String> = ["media-rep", "metadata"]
}
