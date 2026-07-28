import Foundation
import XMLCoder

public struct FCPXML: Codable {
    public let version: String
    public var resources: Resources?
    public var library: Library?
    
    public init(version: String, resources: Resources? = nil, library: Library? = nil) {
        self.version = version
        self.resources = resources
        self.library = library
    }
    
    enum CodingKeys: String, CodingKey {
        case version
        case resources
        case library
    }
}

public struct Resources: Codable {
    public var assets: [Asset]?
    public var formats: [Format]?
    public var effects: [Effect]?
    public var media: [Media]?
    
    public init(assets: [Asset]? = nil, formats: [Format]? = nil, effects: [Effect]? = nil, media: [Media]? = nil) {
        self.assets = assets
        self.formats = formats
        self.effects = effects
        self.media = media
    }
    
    enum CodingKeys: String, CodingKey {
        case assets = "asset"
        case formats = "format"
        case effects = "effect"
        case media
    }
}

public struct Asset: Codable {
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
        case metadata
    }
}

public struct Format: Codable {
    public let id: String
    public var name: String?
    public var frameDuration: String?
    public var width: String?
    public var height: String?
    public var colorSpace: String?

    public init(
        id: String,
        name: String? = nil,
        frameDuration: String? = nil,
        width: String? = nil,
        height: String? = nil,
        colorSpace: String? = nil
    ) {
        self.id = id
        self.name = name
        self.frameDuration = frameDuration
        self.width = width
        self.height = height
        self.colorSpace = colorSpace
    }
    
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
    public let src: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case uid
        case src
    }
}

public struct Library: Codable {
    public var location: String?
    public var colorProcessing: String?
    public var events: [Event]?
    public var smartCollections: [SmartCollection]?

    public init(
        location: String? = nil,
        colorProcessing: String? = nil,
        events: [Event]? = nil,
        smartCollections: [SmartCollection]? = nil
    ) {
        self.location = location
        self.colorProcessing = colorProcessing
        self.events = events
        self.smartCollections = smartCollections
    }
    
    enum CodingKeys: String, CodingKey {
        case location
        case colorProcessing
        case events = "event"
        case smartCollections = "smart-collection"
    }
}

public struct Event: Codable {
    public var name: String?
    public let uid: String?
    public var projects: [Project]?
    public var assetClips: [AssetClip]?
    public var refClips: [RefClip]?
    public var mcClips: [MCClip]?
    public var syncClips: [SyncClip]?

    public init(
        name: String? = nil,
        uid: String? = nil,
        projects: [Project]? = nil,
        assetClips: [AssetClip]? = nil,
        refClips: [RefClip]? = nil,
        mcClips: [MCClip]? = nil,
        syncClips: [SyncClip]? = nil
    ) {
        self.name = name
        self.uid = uid
        self.projects = projects
        self.assetClips = assetClips
        self.refClips = refClips
        self.mcClips = mcClips
        self.syncClips = syncClips
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case uid
        case projects = "project"
        case assetClips = "asset-clip"
        case refClips = "ref-clip"
        case mcClips = "mc-clip"
        case syncClips = "sync-clip"
    }
}

public struct Project: Codable {
    public var name: String?
    public let uid: String?
    public var modDate: String?
    public var sequence: Sequence?

    public init(
        name: String? = nil,
        uid: String? = nil,
        modDate: String? = nil,
        sequence: Sequence? = nil
    ) {
        self.name = name
        self.uid = uid
        self.modDate = modDate
        self.sequence = sequence
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case uid
        case modDate
        case sequence
    }
}

public struct Sequence: Codable {
    public var format: String?
    public var duration: String?
    public var tcStart: String?
    public var tcFormat: String?
    public var audioLayout: String?
    public var audioRate: String?
    public var renderFormat: String?
    public var spine: Spine?

    public init(
        format: String? = nil,
        duration: String? = nil,
        tcStart: String? = nil,
        tcFormat: String? = nil,
        audioLayout: String? = nil,
        audioRate: String? = nil,
        renderFormat: String? = nil,
        spine: Spine? = nil
    ) {
        self.format = format
        self.duration = duration
        self.tcStart = tcStart
        self.tcFormat = tcFormat
        self.audioLayout = audioLayout
        self.audioRate = audioRate
        self.renderFormat = renderFormat
        self.spine = spine
    }
    
    enum CodingKeys: String, CodingKey {
        case format
        case duration
        case tcStart
        case tcFormat
        case audioLayout
        case audioRate
        case renderFormat
        case spine
    }
}

public struct Spine: Codable {
    public var clips: [Clip]?
    public var gaps: [Gap]?
    public var mcClips: [MCClip]?
    public var refClips: [RefClip]?
    public var syncClips: [SyncClip]?
    public var assetClips: [AssetClip]?
    public var titles: [Title]?
    public var generators: [Generator]?
    public var transitions: [Transition]?
    public var storylines: [Storyline]?
    public var compoundClips: [CompoundClip]?
    public var retimeClips: [RetimeClip]?
    public var captions: [Caption]?
    public var video: [Video]?

    public init(
        clips: [Clip]? = nil,
        gaps: [Gap]? = nil,
        mcClips: [MCClip]? = nil,
        refClips: [RefClip]? = nil,
        syncClips: [SyncClip]? = nil,
        assetClips: [AssetClip]? = nil,
        titles: [Title]? = nil,
        generators: [Generator]? = nil,
        transitions: [Transition]? = nil,
        storylines: [Storyline]? = nil,
        compoundClips: [CompoundClip]? = nil,
        retimeClips: [RetimeClip]? = nil,
        captions: [Caption]? = nil,
        video: [Video]? = nil
    ) {
        self.clips = clips
        self.gaps = gaps
        self.mcClips = mcClips
        self.refClips = refClips
        self.syncClips = syncClips
        self.assetClips = assetClips
        self.titles = titles
        self.generators = generators
        self.transitions = transitions
        self.storylines = storylines
        self.compoundClips = compoundClips
        self.retimeClips = retimeClips
        self.captions = captions
        self.video = video
    }
    
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
        case video
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
    public var ref: String?
    public var name: String?
    public var duration: String?
    public var start: String?
    public var format: String?
    public var tcFormat: String?
    public var audioChannels: String?
    public var audioRate: String?
    public var audioRole: String?
    public var lane: String?
    public var offset: String?
    public var useAudioSubroles: String?
    public var modDate: String?
    public var audioStart: String?
    public var audioDuration: String?
    public var keywords: [Keyword]?
    public var note: String?
    public var conformRate: ConformRate?
    public var adjustVolume: AdjustVolume?
    public var adjustBlend: AdjustBlend?
    public var audioChannelSource: [AudioChannelSource]?
    public var markers: [Marker]?
    public var rating: Rating?
    public var chapterMarkers: [ChapterMarker]?
    public var filterAudio: [FilterAudio]?
    public var filterVideo: [FilterVideo]?
    public var titles: [Title]?
    public var assetClips: [AssetClip]?
    public var video: [Video]?
    public var adjustTransform: AdjustTransform?
    public var adjustCrop: AdjustCrop?
    public var timeMap: TimeMap?

    public init(
        ref: String? = nil,
        name: String? = nil,
        duration: String? = nil,
        start: String? = nil,
        format: String? = nil,
        tcFormat: String? = nil,
        audioChannels: String? = nil,
        audioRate: String? = nil,
        audioRole: String? = nil,
        lane: String? = nil,
        offset: String? = nil,
        useAudioSubroles: String? = nil,
        modDate: String? = nil,
        audioStart: String? = nil,
        audioDuration: String? = nil,
        keywords: [Keyword]? = nil,
        note: String? = nil,
        conformRate: ConformRate? = nil,
        adjustVolume: AdjustVolume? = nil,
        adjustBlend: AdjustBlend? = nil,
        audioChannelSource: [AudioChannelSource]? = nil,
        markers: [Marker]? = nil,
        rating: Rating? = nil,
        chapterMarkers: [ChapterMarker]? = nil,
        filterAudio: [FilterAudio]? = nil,
        filterVideo: [FilterVideo]? = nil,
        titles: [Title]? = nil,
        assetClips: [AssetClip]? = nil,
        video: [Video]? = nil,
        adjustTransform: AdjustTransform? = nil,
        adjustCrop: AdjustCrop? = nil,
        timeMap: TimeMap? = nil
    ) {
        self.ref = ref
        self.name = name
        self.duration = duration
        self.start = start
        self.format = format
        self.tcFormat = tcFormat
        self.audioChannels = audioChannels
        self.audioRate = audioRate
        self.audioRole = audioRole
        self.lane = lane
        self.offset = offset
        self.useAudioSubroles = useAudioSubroles
        self.modDate = modDate
        self.audioStart = audioStart
        self.audioDuration = audioDuration
        self.keywords = keywords
        self.note = note
        self.conformRate = conformRate
        self.adjustVolume = adjustVolume
        self.adjustBlend = adjustBlend
        self.audioChannelSource = audioChannelSource
        self.markers = markers
        self.rating = rating
        self.chapterMarkers = chapterMarkers
        self.filterAudio = filterAudio
        self.filterVideo = filterVideo
        self.titles = titles
        self.assetClips = assetClips
        self.video = video
        self.adjustTransform = adjustTransform
        self.adjustCrop = adjustCrop
        self.timeMap = timeMap
    }
    
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
        case audioStart
        case audioDuration
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
        case titles = "title"
        case assetClips = "asset-clip"
        case video
        case adjustTransform = "adjust-transform"
        case adjustCrop = "adjust-crop"
        case timeMap
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
