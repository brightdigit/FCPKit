import Foundation

public enum AssetClipEditingError: Error, LocalizedError, Equatable, Sendable {
    case invalidSpeedPercent(Int)
    case unsupportedDuration(String)

    public var errorDescription: String? {
        switch self {
        case .invalidSpeedPercent(let percent):
            return "Speed percent must be positive, got \(percent)"
        case .unsupportedDuration(let value):
            return "Unsupported FCPXML duration string: \(value)"
        }
    }
}

public extension AssetClip {
    /// Appends a standard marker matching Final Cut's default marker duration.
    mutating func addMarker(
        name: String,
        at start: String,
        duration: String = "100/2400s"
    ) {
        var list = markers ?? []
        list.append(Marker(start: start, duration: duration, value: name))
        markers = list
    }

    /// Assigns the Music audio role the way Final Cut exports it:
    /// `audio-channel-source` with `music.music-1`, leaving `audioRole` unchanged.
    mutating func assignMusicRole(sourceChannels: String = "1, 2") {
        let source = AudioChannelSource(srcCh: sourceChannels, role: "music.music-1")
        if var existing = audioChannelSource, !existing.isEmpty {
            existing[0].srcCh = sourceChannels
            existing[0].role = "music.music-1"
            audioChannelSource = existing
        } else {
            audioChannelSource = [source]
        }
    }

    /// Applies a constant retiming. For example, `percent: 50` with media
    /// duration `10s` sets clip duration to `20s` and a two-point `timeMap`
    /// matching Final Cut's 50% slow export (`interp: smooth2`).
    ///
    /// Updates only this clip. Callers should update parent `sequence.duration`
    /// when the timeline length must change.
    mutating func setConstantSpeed(percent: Int, mediaDuration: String) throws {
        guard percent > 0 else {
            throw AssetClipEditingError.invalidSpeedPercent(percent)
        }

        let mediaSeconds = try Self.parseDurationSeconds(mediaDuration)
        let timelineSeconds = mediaSeconds * 100.0 / Double(percent)
        let timelineDuration = Self.formatSeconds(timelineSeconds)

        duration = timelineDuration
        timeMap = TimeMap(timepts: [
            Timept(time: "0s", value: "0s", interp: "smooth2"),
            Timept(time: timelineDuration, value: mediaDuration, interp: "smooth2"),
        ])
    }

    private static func parseDurationSeconds(_ value: String) throws -> Double {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasSuffix("s") else {
            throw AssetClipEditingError.unsupportedDuration(value)
        }
        let body = String(trimmed.dropLast())
        if body.contains("/") {
            let parts = body.split(separator: "/", maxSplits: 1).map(String.init)
            guard parts.count == 2,
                  let numerator = Double(parts[0]),
                  let denominator = Double(parts[1]),
                  denominator != 0
            else {
                throw AssetClipEditingError.unsupportedDuration(value)
            }
            return numerator / denominator
        }
        guard let seconds = Double(body) else {
            throw AssetClipEditingError.unsupportedDuration(value)
        }
        return seconds
    }

    private static func formatSeconds(_ seconds: Double) -> String {
        if seconds.rounded() == seconds {
            return "\(Int(seconds))s"
        }
        // Prefer exact integer rational when possible; otherwise emit a decimal seconds form.
        return "\(seconds)s"
    }
}
