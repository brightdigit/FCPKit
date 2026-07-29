import Foundation

#if canImport(CoreMedia)
import CoreMedia
import AVFoundation

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