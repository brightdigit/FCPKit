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
    public let text: [TextElement]?
    public let textStyleDef: [TextStyleDef]?
    
    enum CodingKeys: String, CodingKey {
        case ref
        case offset
        case name
        case start
        case duration
        case lane
        case text
        case textStyleDef = "text-style-def"
    }
}

public struct TextElement: Codable {
    public let textStyle: [TextStyle]?
    
    enum CodingKeys: String, CodingKey {
        case textStyle = "text-style"
    }
}

public struct TextStyle: Codable {
    public let ref: String?
    public let font: String?
    public let fontSize: String?
    public let fontFace: String?
    public let fontColor: String?
    public let alignment: String?
    public let content: String?
    
    enum CodingKeys: String, CodingKey {
        case ref
        case font
        case fontSize
        case fontFace
        case fontColor
        case alignment
        case content = ""
    }
}

public struct TextStyleDef: Codable {
    public let id: String?
    public let textStyle: TextStyle?
    
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
    public let param: [ParamElement]?
    
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
    
    enum CodingKeys: String, CodingKey {
        case ref
        case offset
        case duration
        case alignment
        case name
        case start
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
    public let start: String?
    public let duration: String?
    public let value: String?
    public let note: String?
    public let completed: String?
    
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
    public let value: String?
    public let interp: String?
    
    enum CodingKeys: String, CodingKey {
        case time
        case value
        case interp
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