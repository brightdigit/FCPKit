import Foundation
import XMLCoder

public struct MCClip: Codable {
    public let ref: String?
    public let offset: String?
    public let name: String?
    public let start: String?
    public let duration: String?
    public let mcSources: [MCSource]?
    public let video: [Video]?
    
    enum CodingKeys: String, CodingKey {
        case ref
        case offset
        case name
        case start
        case duration
        case mcSources = "mc-source"
        case video
    }
}

public struct MCSource: Codable {
    public let angleID: String?
    public let srcEnable: String?
    
    enum CodingKeys: String, CodingKey {
        case angleID
        case srcEnable
    }
}

public struct Video: Codable {
    public let ref: String?
    public let lane: String?
    public let offset: String?
    public let name: String?
    public let start: String?
    public let duration: String?
    public let filterVideo: [FilterVideo]?
    
    enum CodingKeys: String, CodingKey {
        case ref
        case lane
        case offset
        case name
        case start
        case duration
        case filterVideo = "filter-video"
    }
}

public struct FilterVideo: Codable {
    public let ref: String?
    public let name: String?
    public let data: [DataElement]?
    public let param: [ParamElement]?
    
    enum CodingKeys: String, CodingKey {
        case ref
        case name
        case data
        case param
    }
}

public struct DataElement: Codable {
    public let key: String?
    public let value: String?
    
    enum CodingKeys: String, CodingKey {
        case key
        case value
    }
}

public struct ParamElement: Codable {
    public let name: String?
    public let key: String?
    public let value: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case key
        case value
    }
}

public struct Media: Codable {
    public let id: String?
    public let name: String?
    public let uid: String?
    public let modDate: String?
    public let sequence: Sequence?
    public let multicam: Multicam?
    public let mediaRep: [MediaRep]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case uid
        case modDate
        case sequence
        case multicam
        case mediaRep = "media-rep"
    }
}

public struct Multicam: Codable {
    public let format: String?
    public let tcStart: String?
    public let tcFormat: String?
    public let mcAngles: [MCAngle]?
    
    enum CodingKeys: String, CodingKey {
        case format
        case tcStart
        case tcFormat
        case mcAngles = "mc-angle"
    }
}

public struct MCAngle: Codable {
    public let name: String?
    public let angleID: String?
    public let gaps: [Gap]?
    public let refClips: [RefClip]?
    
    enum CodingKeys: String, CodingKey {
        case name
        case angleID
        case gaps = "gap"
        case refClips = "ref-clip"
    }
}

public struct RefClip: Codable {
    public let ref: String?
    public let offset: String?
    public let name: String?
    public let duration: String?
    public let useAudioSubroles: String?
    public let conformRate: ConformRate?
    public let timeMap: TimeMap?
    public let adjustTransform: AdjustTransform?
    public let adjustCrop: AdjustCrop?
    public let assetClips: [AssetClip]?
    
    enum CodingKeys: String, CodingKey {
        case ref
        case offset
        case name
        case duration
        case useAudioSubroles
        case conformRate = "conform-rate"
        case timeMap
        case adjustTransform = "adjust-transform"
        case adjustCrop = "adjust-crop"
        case assetClips = "asset-clip"
    }
}

public struct ConformRate: Codable {
    public let srcFrameRate: String?
    public let scaleEnabled: String?
    
    enum CodingKeys: String, CodingKey {
        case srcFrameRate
        case scaleEnabled
    }
}

public struct TimeMap: Codable {
    public let timepts: [Timept]?
    
    enum CodingKeys: String, CodingKey {
        case timepts = "timept"
    }
}

public struct Timept: Codable {
    public let time: String?
    public let value: String?
    public let interp: String?
    
    enum CodingKeys: String, CodingKey {
        case time
        case value
        case interp
    }
}

public struct AdjustTransform: Codable {
    public let position: String?
    
    enum CodingKeys: String, CodingKey {
        case position
    }
}

public struct AdjustCrop: Codable {
    public let mode: String?
    public let trimRect: TrimRect?
    
    enum CodingKeys: String, CodingKey {
        case mode
        case trimRect = "trim-rect"
    }
}

public struct TrimRect: Codable {
    public let left: String?
    public let right: String?
    public let top: String?
    public let bottom: String?
    
    enum CodingKeys: String, CodingKey {
        case left
        case right
        case top
        case bottom
    }
}

public struct SyncClip: Codable {
    public let offset: String?
    public let name: String?
    public let duration: String?
    public let tcFormat: String?
    public let assetClips: [AssetClip]?
    public let video: [Video]?
    public let filterVideo: [FilterVideo]?
    
    enum CodingKeys: String, CodingKey {
        case offset
        case name
        case duration
        case tcFormat
        case assetClips = "asset-clip"
        case video
        case filterVideo = "filter-video"
    }
}

public struct MediaRep: Codable {
    public let kind: String?
    public let sig: String?
    public let src: String?
    public let bookmark: String?
    
    enum CodingKeys: String, CodingKey {
        case kind
        case sig
        case src
        case bookmark
    }
}

public struct SmartCollection: Codable {
    public let name: String?
    public let match: String?
    public let matchClip: [MatchClip]?
    public let matchMedia: [MatchMedia]?
    public let matchRatings: [MatchRatings]?
    
    enum CodingKeys: String, CodingKey {
        case name
        case match
        case matchClip = "match-clip"
        case matchMedia = "match-media"
        case matchRatings = "match-ratings"
    }
}

public struct MatchClip: Codable {
    public let rule: String?
    public let type: String?
    
    enum CodingKeys: String, CodingKey {
        case rule
        case type
    }
}

public struct MatchMedia: Codable {
    public let rule: String?
    public let type: String?
    
    enum CodingKeys: String, CodingKey {
        case rule
        case type
    }
}

public struct MatchRatings: Codable {
    public let value: String?
    
    enum CodingKeys: String, CodingKey {
        case value
    }
}

public struct AdjustVolume: Codable {
    public let amount: String?
    
    enum CodingKeys: String, CodingKey {
        case amount
    }
}

public struct AdjustLoudness: Codable {
    public let amount: String?
    public let uniformity: String?
    
    enum CodingKeys: String, CodingKey {
        case amount
        case uniformity
    }
}

public struct AdjustBlend: Codable {
    public let amount: String?
    public let mode: String?
    
    enum CodingKeys: String, CodingKey {
        case amount
        case mode
    }
}

public struct AudioChannelSource: Codable {
    public let srcCh: String?
    public let role: String?
    public let active: String?
    public let adjustLoudness: AdjustLoudness?
    
    enum CodingKeys: String, CodingKey {
        case srcCh
        case role
        case active
        case adjustLoudness = "adjust-loudness"
    }
}