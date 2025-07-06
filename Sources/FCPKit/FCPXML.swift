import Foundation
import XMLCoder

public struct FCPXML: Codable {
    public let version: String
    public let resources: Resources?
    public let library: Library?
    
    enum CodingKeys: String, CodingKey {
        case version
        case resources
        case library
    }
}

public struct Resources: Codable {
    public let assets: [Asset]?
    public let formats: [Format]?
    public let effects: [Effect]?
    public let media: [Media]?
    
    enum CodingKeys: String, CodingKey {
        case assets = "asset"
        case formats = "format"
        case effects = "effect"
        case media
    }
}

public struct Asset: Codable {
    public let id: String
    public let name: String?
    public let uid: String?
    public let src: String?
    public let start: String?
    public let duration: String?
    public let format: String?
    public let hasVideo: String?
    public let hasAudio: String?
    public let audioChannels: String?
    public let audioRate: String?
    public let videoRate: String?
    public let videoSources: String?
    public let audioSources: String?
    public let mediaRep: [MediaRep]?
    
    enum CodingKeys: String, CodingKey {
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
    }
}

public struct Format: Codable {
    public let id: String
    public let name: String?
    public let frameDuration: String?
    public let width: String?
    public let height: String?
    public let colorSpace: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case frameDuration
        case width
        case height
        case colorSpace
    }
}

public struct Effect: Codable {
    public let id: String
    public let name: String?
    public let uid: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case uid
    }
}

public struct Library: Codable {
    public let location: String?
    public let events: [Event]?
    public let smartCollections: [SmartCollection]?
    
    enum CodingKeys: String, CodingKey {
        case location
        case events = "event"
        case smartCollections = "smart-collection"
    }
}

public struct Event: Codable {
    public let name: String?
    public let uid: String?
    public let projects: [Project]?
    public let assetClips: [AssetClip]?
    public let refClips: [RefClip]?
    
    enum CodingKeys: String, CodingKey {
        case name
        case uid
        case projects = "project"
        case assetClips = "asset-clip"
        case refClips = "ref-clip"
    }
}

public struct Project: Codable {
    public let name: String?
    public let uid: String?
    public let modDate: String?
    public let sequence: Sequence?
    
    enum CodingKeys: String, CodingKey {
        case name
        case uid
        case modDate
        case sequence
    }
}

public struct Sequence: Codable {
    public let format: String?
    public let duration: String?
    public let tcStart: String?
    public let tcFormat: String?
    public let spine: Spine?
    
    enum CodingKeys: String, CodingKey {
        case format
        case duration
        case tcStart
        case tcFormat
        case spine
    }
}

public struct Spine: Codable {
    public let clips: [Clip]?
    public let gaps: [Gap]?
    public let mcClips: [MCClip]?
    public let refClips: [RefClip]?
    public let syncClips: [SyncClip]?
    public let assetClips: [AssetClip]?
    public let titles: [Title]?
    public let generators: [Generator]?
    public let transitions: [Transition]?
    public let storylines: [Storyline]?
    public let compoundClips: [CompoundClip]?
    public let retimeClips: [RetimeClip]?
    public let captions: [Caption]?
    
    enum CodingKeys: String, CodingKey {
        case clips = "clip"
        case gaps = "gap"
        case mcClips = "mc-clip"
        case refClips = "ref-clip"
        case syncClips = "sync-clip"
        case assetClips = "asset-clip"
        case titles = "title"
        case generators = "generator"
        case transitions = "transition"
        case storylines = "storyline"
        case compoundClips = "compound-clip"
        case retimeClips = "retime-clip"
        case captions = "caption"
    }
}

public struct Clip: Codable {
    public let name: String?
    public let ref: String?
    public let offset: String?
    public let duration: String?
    public let start: String?
    public let tcFormat: String?
    public let audioChannels: String?
    public let audioRate: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case ref
        case offset
        case duration
        case start
        case tcFormat
        case audioChannels
        case audioRate
    }
}

public struct Gap: Codable {
    public let name: String?
    public let offset: String?
    public let duration: String?
    public let start: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case offset
        case duration
        case start
    }
}

public struct AssetClip: Codable {
    public let ref: String?
    public let name: String?
    public let duration: String?
    public let start: String?
    public let format: String?
    public let tcFormat: String?
    public let audioChannels: String?
    public let audioRate: String?
    public let audioRole: String?
    public let lane: String?
    public let offset: String?
    public let useAudioSubroles: String?
    public let modDate: String?
    public let keywords: [Keyword]?
    public let note: String?
    public let conformRate: ConformRate?
    public let adjustVolume: AdjustVolume?
    public let adjustBlend: AdjustBlend?
    public let audioChannelSource: [AudioChannelSource]?
    public let markers: [Marker]?
    public let rating: Rating?
    public let chapterMarkers: [ChapterMarker]?
    public let filterAudio: [FilterAudio]?
    public let filterVideo: [FilterVideo]?
    
    enum CodingKeys: String, CodingKey {
        case ref
        case name
        case duration
        case start
        case format
        case tcFormat
        case audioChannels
        case audioRate
        case audioRole
        case lane
        case offset
        case useAudioSubroles
        case modDate
        case keywords = "keyword"
        case note
        case conformRate = "conform-rate"
        case adjustVolume = "adjust-volume"
        case adjustBlend = "adjust-blend"
        case audioChannelSource = "audio-channel-source"
        case markers = "marker"
        case rating
        case chapterMarkers = "chapter-marker"
        case filterAudio = "filter-audio"
        case filterVideo = "filter-video"
    }
}

public struct Keyword: Codable {
    public let start: String?
    public let duration: String?
    public let value: String?
    public let note: String?
    
    enum CodingKeys: String, CodingKey {
        case start
        case duration
        case value
        case note
    }
}