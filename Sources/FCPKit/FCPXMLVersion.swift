import Foundation

/// Declared FCPXML document version and library compatibility policy.
///
/// A version string alone does not imply complete schema coverage. Support is
/// limited to the explicitly tested vocabulary for that version.
public struct FCPXMLVersion: RawRepresentable, Hashable, Sendable, Codable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    /// Version emitted by typed generation and `MulticamXMLBuilder`.
    public static let supportedGenerationVersion = FCPXMLVersion("1.13")

    /// Fixture versions currently covered by schema-completeness evidence.
    public static let testedFixtureVersions: Set<FCPXMLVersion> = [
        FCPXMLVersion("1.13"),
    ]
}

/// Compatibility of a declared FCPXML version against the library policy.
public enum FCPXMLVersionCompatibility: String, Sendable, Equatable {
    /// Declared version matches the current generation/fixture baseline.
    case supported
    /// Declared version is older than the generation baseline but parseable best-effort.
    case older
    /// Declared version is newer than the generation baseline; parse remains best-effort.
    case newer
    /// Declared version string is not a dotted numeric FCPXML version.
    case malformed
}

public extension FCPXMLVersion {
    /// Evaluates compatibility of this declared version against the generation baseline.
    func compatibility(
        relativeTo baseline: FCPXMLVersion = .supportedGenerationVersion
    ) -> FCPXMLVersionCompatibility {
        guard let declaredComponents = Self.numericComponents(rawValue),
              let baselineComponents = Self.numericComponents(baseline.rawValue)
        else {
            return .malformed
        }

        if declaredComponents == baselineComponents {
            return .supported
        }
        if declaredComponents.lexicographicallyPrecedes(baselineComponents) {
            return .older
        }
        return .newer
    }

    private static func numericComponents(_ value: String) -> [Int]? {
        let parts = value.split(separator: ".", omittingEmptySubsequences: false)
        guard !parts.isEmpty else { return nil }
        var components: [Int] = []
        components.reserveCapacity(parts.count)
        for part in parts {
            guard let number = Int(part), String(number) == part else {
                return nil
            }
            components.append(number)
        }
        return components
    }
}

public extension FCPXML {
    /// Compatibility of `version` against the library generation baseline.
    var versionCompatibility: FCPXMLVersionCompatibility {
        FCPXMLVersion(version).compatibility()
    }
}

public extension FCPXMLParser {
    /// Inspects a declared version string without requiring a full document parse.
    func compatibility(ofVersion version: String) -> FCPXMLVersionCompatibility {
        FCPXMLVersion(version).compatibility()
    }

    /// Parses a document and returns it with an explicit compatibility classification.
    func parseWithCompatibility(data: Data) throws -> (document: FCPXML, compatibility: FCPXMLVersionCompatibility) {
        let document = try parse(data: data)
        return (document, document.versionCompatibility)
    }

    /// Parses a document and throws when the declared version is malformed.
    ///
    /// Older and newer versions still decode best-effort per ADR 0001; only
    /// malformed version declarations fail this policy entry point.
    func parseRequiringWellFormedVersion(data: Data) throws -> FCPXML {
        let (document, compatibility) = try parseWithCompatibility(data: data)
        if compatibility == .malformed {
            throw FCPXMLError.unsupportedVersion(document.version)
        }
        return document
    }
}
