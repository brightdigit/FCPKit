import XMLCoder

private func fcpNodeEncoding(
    for key: CodingKey,
    elementKeys: Set<String> = []
) -> XMLEncoder.NodeEncoding {
    elementKeys.contains(key.stringValue) ? .element : .attribute
}

extension FCPXML: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        fcpNodeEncoding(for: key, elementKeys: ["resources", "library"])
    }
}

extension Resources: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        .element
    }
}

extension Asset: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        fcpNodeEncoding(for: key, elementKeys: ["media-rep"])
    }
}

extension Format: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .attribute }
}

extension Effect: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .attribute }
}

extension Library: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        fcpNodeEncoding(for: key, elementKeys: ["event", "smart-collection"])
    }
}

extension Event: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        fcpNodeEncoding(for: key, elementKeys: [
            "project", "asset-clip", "ref-clip", "mc-clip", "sync-clip",
        ])
    }
}

extension Project: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        fcpNodeEncoding(for: key, elementKeys: ["sequence"])
    }
}

extension Sequence: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        fcpNodeEncoding(for: key, elementKeys: ["spine"])
    }
}

extension Spine: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .element }
}

extension Clip: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .attribute }
}

extension Gap: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .attribute }
}

extension AssetClip: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        fcpNodeEncoding(for: key, elementKeys: [
            "keyword", "note", "conform-rate", "adjust-volume", "adjust-blend",
            "audio-channel-source", "marker", "rating", "chapter-marker",
            "filter-audio", "filter-video",
            "title",
            "asset-clip", "video", "adjust-transform", "adjust-crop",
        ])
    }
}

extension Keyword: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .attribute }
}

extension MCClip: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        fcpNodeEncoding(for: key, elementKeys: ["mc-source", "video"])
    }
}

extension MCSource: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .attribute }
}

extension Video: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        fcpNodeEncoding(for: key, elementKeys: [
            "param", "filter-video", "adjust-transform", "adjust-colorConform",
        ])
    }
}

extension FilterVideo: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        fcpNodeEncoding(for: key, elementKeys: ["data", "param"])
    }
}

extension DataElement: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        key.stringValue.isEmpty ? .element : .attribute
    }
}

extension ParamElement: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        fcpNodeEncoding(for: key, elementKeys: [
            "param", "data", "fadeIn", "fadeOut", "keyframeAnimation",
        ])
    }
}

extension Media: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        fcpNodeEncoding(for: key, elementKeys: ["sequence", "multicam", "media-rep"])
    }
}

extension Multicam: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        fcpNodeEncoding(for: key, elementKeys: ["mc-angle"])
    }
}

extension MCAngle: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        fcpNodeEncoding(for: key, elementKeys: ["gap", "ref-clip"])
    }
}

extension RefClip: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        fcpNodeEncoding(for: key, elementKeys: [
            "conform-rate", "timeMap", "adjust-transform", "adjust-crop", "asset-clip",
            "video",
            "ref-clip", "adjust-volume", "filter-video",
        ])
    }
}

extension ConformRate: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .attribute }
}

extension TimeMap: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        fcpNodeEncoding(for: key, elementKeys: ["timept"])
    }
}

extension Timept: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .attribute }
}

extension AdjustTransform: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .attribute }
}

extension AdjustColorConform: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .attribute }
}

extension AdjustCrop: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        fcpNodeEncoding(for: key, elementKeys: ["trim-rect"])
    }
}

extension TrimRect: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .attribute }
}

extension SyncClip: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        fcpNodeEncoding(for: key, elementKeys: ["asset-clip", "video", "filter-video"])
    }
}

extension MediaRep: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        fcpNodeEncoding(for: key, elementKeys: ["bookmark"])
    }
}

extension SmartCollection: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        fcpNodeEncoding(for: key, elementKeys: ["match-clip", "match-media", "match-ratings"])
    }
}

extension MatchClip: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .attribute }
}

extension MatchMedia: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .attribute }
}

extension MatchRatings: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .attribute }
}

extension AdjustVolume: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        fcpNodeEncoding(for: key, elementKeys: ["param"])
    }
}

extension AdjustLoudness: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .attribute }
}

extension AdjustBlend: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .attribute }
}

extension AudioChannelSource: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        fcpNodeEncoding(for: key, elementKeys: ["adjust-loudness"])
    }
}

extension Title: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        fcpNodeEncoding(for: key, elementKeys: ["param", "text", "text-style-def"])
    }
}

extension TextElement: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .element }
}

extension TextStyle: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        key.stringValue.isEmpty || key.stringValue == "param" ? .element : .attribute
    }
}

extension TextStyleDef: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        fcpNodeEncoding(for: key, elementKeys: ["text-style"])
    }
}

extension FilterAudio: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        fcpNodeEncoding(for: key, elementKeys: ["param"])
    }
}

extension Transition: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        fcpNodeEncoding(for: key, elementKeys: ["filter-video", "filter-audio"])
    }
}

extension Generator: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        fcpNodeEncoding(for: key, elementKeys: ["param"])
    }
}

extension Marker: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .attribute }
}

extension Rating: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .attribute }
}

extension ChapterMarker: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .attribute }
}

extension ConnectedClip: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .attribute }
}

extension Storyline: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        fcpNodeEncoding(for: key, elementKeys: [
            "clip", "asset-clip", "ref-clip", "title", "generator",
        ])
    }
}

extension RetimeClip: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        fcpNodeEncoding(for: key, elementKeys: ["timeMap"])
    }
}

extension ColorCorrection: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        fcpNodeEncoding(for: key, elementKeys: ["param"])
    }
}

extension Motion: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        fcpNodeEncoding(for: key, elementKeys: ["param"])
    }
}

extension Keyframe: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .attribute }
}

extension KeyframeAnimation: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .element }
}

extension Fade: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .attribute }
}

extension CompoundClip: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .attribute }
}

extension Caption: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        fcpNodeEncoding(for: key, elementKeys: ["text"])
    }
}

extension AudioRole: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .attribute }
}

extension VideoRole: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .attribute }
}

extension CaptionRole: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .attribute }
}
