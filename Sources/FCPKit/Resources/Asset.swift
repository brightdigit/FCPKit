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

  public let id: String
  public var name: String?
  public let uid: String?
  public var src: String?
  public var start: String?
  public var duration: String?
  public var format: String?
  public var hasVideo: String?
  public var hasAudio: String?
  public var audioChannels: String?
  public var audioRate: String?
  public var videoRate: String?
  public var videoSources: String?
  public var audioSources: String?
  public var mediaRep: [MediaRep]?
  public var metadata: AssetMetadata?

  public init(
    id: String,
    name: String? = nil,
    uid: String? = nil,
    src: String? = nil,
    start: String? = nil,
    duration: String? = nil,
    format: String? = nil,
    hasVideo: String? = nil,
    hasAudio: String? = nil,
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
