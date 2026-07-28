import Foundation
import CoreMedia
import FCPKit

/// Utility functions for converting between video metadata and FCPXML formats
public struct FCPXMLUtilities {
    
    /// Converts CMTime to FCPXML duration string format
    /// - Parameter time: CMTime to convert
    /// - Returns: String in format like "7700200/2400s"
    public static func cmTimeToFCPXMLDuration(_ time: CMTime) -> String {
        if time.flags.contains(.valid) {
            return "\(time.value)/\(time.timescale)s"
        }
        return "0s"
    }
    
    /// Generates a unique identifier for FCPXML elements
    /// - Returns: Base64-encoded random string suitable for FCPXML UIDs
    public static func generateUID() -> String {
        let data = Data((0..<16).map { _ in UInt8.random(in: 0...255) })
        return data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
    
    /// Generates a format name based on video dimensions and frame rate
    /// - Parameters:
    ///   - dimensions: Video dimensions
    ///   - frameRate: Frame rate
    /// - Returns: Format name like "FFVideoFormat3840x2160p24"
    public static func generateFormatName(dimensions: CGSize, frameRate: Float) -> String {
        let width = Int(dimensions.width)
        let height = Int(dimensions.height)
        let fps = Int(frameRate.rounded())
        return "FFVideoFormat\(width)x\(height)p\(fps)"
    }
    
    /// Calculates frame duration from frame rate
    /// - Parameter frameRate: Frame rate in fps
    /// - Returns: Frame duration string like "100/2400s"
    public static func frameDurationFromFrameRate(_ frameRate: Float) -> String {
        // Convert to standard timescale (2400 for 24fps)
        let timescale: Int32 = 2400
        let frameDuration = Int32(Float(timescale) / frameRate)
        return "\(frameDuration)/\(timescale)s"
    }
    
    /// Generates current timestamp in FCPXML format
    /// - Returns: String like "2025-07-14 12:34:56 -0400"
    public static func currentTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        return formatter.string(from: Date())
    }
    
    /// Creates a file URL string for FCPXML media references
    /// - Parameter url: Original file URL
    /// - Returns: Properly formatted file URL string
    public static func formatFileURL(_ url: URL) -> String {
        return url.absoluteString
    }
    
    /// Generates a signature for an asset based on its properties
    /// - Parameter metadata: Video metadata
    /// - Returns: Hexadecimal signature string
    public static func generateAssetSignature(from metadata: VideoMetadata) -> String {
        let data = "\(metadata.url.lastPathComponent)\(metadata.duration.value)\(metadata.dimensions.width)\(metadata.dimensions.height)".data(using: .utf8) ?? Data()
        return data.map { String(format: "%02X", $0) }.joined()
    }
}