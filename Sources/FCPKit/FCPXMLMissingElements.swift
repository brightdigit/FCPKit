//
//  FCPXMLMissingElements.swift
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

// MARK: - Title and Text Elements

public struct Title: Codable {
  public let ref: String?
  public let offset: String?
  public let name: String?
  public let start: String?
  public let duration: String?
  public let lane: String?
  public var param: [ParamElement]?
  public var text: [TextElement]?
  public var textStyleDef: [TextStyleDef]?

  enum CodingKeys: String, CodingKey {
    case ref
    case offset
    case name
    case start
    case duration
    case lane
    case param
    case text
    case textStyleDef = "text-style-def"
  }
}

public struct TextElement: Codable {
  public var textStyle: [TextStyle]?

  enum CodingKeys: String, CodingKey {
    case textStyle = "text-style"
  }
}

public struct TextStyle: Codable {
  public let ref: String?
  public var font: String?
  public var fontSize: String?
  public var fontFace: String?
  public var fontColor: String?
  public var bold: String?
  public var kerning: String?
  public var alignment: String?
  public var param: [ParamElement]?
  public var content: String?

  enum CodingKeys: String, CodingKey {
    case ref
    case font
    case fontSize
    case fontFace
    case fontColor
    case bold
    case kerning
    case alignment
    case param
    case content = ""
  }
}

public struct TextStyleDef: Codable {
  public let id: String?
  public var textStyle: TextStyle?

  enum CodingKeys: String, CodingKey {
    case id
    case textStyle = "text-style"
  }
}

// MARK: - Audio Elements

public struct FilterAudio: Codable {
  public let ref: String?
  public let name: String?
  public let enabled: String?
  public var param: [ParamElement]?

  enum CodingKeys: String, CodingKey {
    case ref
    case name
    case enabled
    case param
  }
}

// MARK: - Transition Elements

public struct Transition: Codable {
  public let ref: String?
  public let offset: String?
  public let duration: String?
  public let alignment: String?
  public let name: String?
  public let start: String?
  public var filterVideo: [FilterVideo]?
  public var filterAudio: [FilterAudio]?

  enum CodingKeys: String, CodingKey {
    case ref
    case offset
    case duration
    case alignment
    case name
    case start
    case filterVideo = "filter-video"
    case filterAudio = "filter-audio"
  }
}

// MARK: - Generator Elements

public struct Generator: Codable {
  public let ref: String?
  public let offset: String?
  public let duration: String?
  public let name: String?
  public let start: String?
  public let lane: String?
  public let param: [ParamElement]?

  enum CodingKeys: String, CodingKey {
    case ref
    case offset
    case duration
    case name
    case start
    case lane
    case param
  }
}

// MARK: - Marker and Metadata Elements

public struct Marker: Codable {
  public var start: String?
  public var duration: String?
  public var value: String?
  public var note: String?
  public var completed: String?

  public init(
    start: String? = nil,
    duration: String? = nil,
    value: String? = nil,
    note: String? = nil,
    completed: String? = nil
  ) {
    self.start = start
    self.duration = duration
    self.value = value
    self.note = note
    self.completed = completed
  }

  enum CodingKeys: String, CodingKey {
    case start
    case duration
    case value
    case note
    case completed
  }
}

public struct Rating: Codable {
  public let value: String?

  enum CodingKeys: String, CodingKey {
    case value
  }
}

public struct ChapterMarker: Codable {
  public let start: String?
  public let duration: String?
  public let value: String?
  public let note: String?
  public let posterOffset: String?

  enum CodingKeys: String, CodingKey {
    case start
    case duration
    case value
    case note
    case posterOffset
  }
}

// MARK: - Advanced Timeline Elements

public struct ConnectedClip: Codable {
  public let ref: String?
  public let offset: String?
  public let name: String?
  public let start: String?
  public let duration: String?
  public let lane: String?
  public let tcFormat: String?

  enum CodingKeys: String, CodingKey {
    case ref
    case offset
    case name
    case start
    case duration
    case lane
    case tcFormat
  }
}

public struct Storyline: Codable {
  public let lane: String?
  public let offset: String?
  public let format: String?
  public let clips: [Clip]?
  public let assetClips: [AssetClip]?
  public let refClips: [RefClip]?
  public let titles: [Title]?
  public let generators: [Generator]?

  enum CodingKeys: String, CodingKey {
    case lane
    case offset
    case format
    case clips = "clip"
    case assetClips = "asset-clip"
    case refClips = "ref-clip"
    case titles = "title"
    case generators = "generator"
  }
}

// MARK: - Speed and Retiming Elements

public struct RetimeClip: Codable {
  public let ref: String?
  public let offset: String?
  public let name: String?
  public let start: String?
  public let duration: String?
  public let speed: String?
  public let timeMap: TimeMap?

  enum CodingKeys: String, CodingKey {
    case ref
    case offset
    case name
    case start
    case duration
    case speed
    case timeMap
  }
}

// MARK: - Color Correction Elements

public struct ColorCorrection: Codable {
  public let name: String?
  public let ref: String?
  public let param: [ParamElement]?

  enum CodingKeys: String, CodingKey {
    case name
    case ref
    case param
  }
}

// MARK: - Motion and Transform Elements

public struct Motion: Codable {
  public let name: String?
  public let ref: String?
  public let param: [ParamElement]?

  enum CodingKeys: String, CodingKey {
    case name
    case ref
    case param
  }
}

public struct Keyframe: Codable {
  public let time: String?
  public var value: String?
  public let interp: String?

  enum CodingKeys: String, CodingKey {
    case time
    case value
    case interp
  }
}

public struct KeyframeAnimation: Codable {
  public var keyframes: [Keyframe]?

  enum CodingKeys: String, CodingKey {
    case keyframes = "keyframe"
  }
}

public struct Fade: Codable {
  public let type: String?
  public var duration: String?

  enum CodingKeys: String, CodingKey {
    case type
    case duration
  }
}

// MARK: - Compound and Nested Elements

public struct CompoundClip: Codable {
  public let ref: String?
  public let offset: String?
  public let name: String?
  public let start: String?
  public let duration: String?
  public let useAudioSubroles: String?
  public let format: String?

  enum CodingKeys: String, CodingKey {
    case ref
    case offset
    case name
    case start
    case duration
    case useAudioSubroles
    case format
  }
}

// MARK: - Captions and Subtitles

public struct Caption: Codable {
  public let lane: String?
  public let offset: String?
  public let name: String?
  public let start: String?
  public let duration: String?
  public let role: String?
  public let text: String?

  enum CodingKeys: String, CodingKey {
    case lane
    case offset
    case name
    case start
    case duration
    case role
    case text
  }
}

// MARK: - Roles and Subroles

public struct AudioRole: Codable {
  public let value: String?

  enum CodingKeys: String, CodingKey {
    case value
  }
}

public struct VideoRole: Codable {
  public let value: String?

  enum CodingKeys: String, CodingKey {
    case value
  }
}

public struct CaptionRole: Codable {
  public let value: String?

  enum CodingKeys: String, CodingKey {
    case value
  }
}
