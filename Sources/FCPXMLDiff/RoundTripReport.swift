import FCPKit
import Foundation

/// Reports structural content that the typed model does not retain across an
/// XML decode/encode cycle.
public struct FCPXMLRoundTripReport: Codable, Equatable, Sendable {
    public let formatVersion: Int
    public let sourcePath: String
    public let fcpxmlVersion: String?
    public let normalization: [String]
    public let summary: SchemaCompletenessSummary
    public let findings: [FCPXMLDifference]

    public var hasLoss: Bool { summary.total > 0 }

    public init(
        sourcePath: String,
        fcpxmlVersion: String?,
        findings: [FCPXMLDifference]
    ) {
        formatVersion = 1
        self.sourcePath = sourcePath
        self.fcpxmlVersion = fcpxmlVersion
        normalization = FCPXMLNormalizer.rules
        summary = SchemaCompletenessSummary(findings: findings)
        self.findings = findings
    }
}

/// Exercises the public FCPKit parser and reports content omitted by encoding.
public struct FCPXMLRoundTripAnalyzer: Sendable {
    private let treeParser = XMLTreeParser()
    private let diffEngine = FCPXMLDiffEngine()

    public init() {}

    public func analyze(
        data: Data,
        sourcePath: String = "input.fcpxml"
    ) throws -> FCPXMLRoundTripReport {
        let parser = FCPXMLParser()
        let model = try parser.parse(data: data)
        let encodedData = try parser.encode(model)
        return try analyze(
            originalData: data,
            encodedData: encodedData,
            sourcePath: sourcePath
        )
    }

    public func analyze(
        originalData: Data,
        encodedData: Data,
        sourcePath: String = "input.fcpxml"
    ) throws -> FCPXMLRoundTripReport {
        let original = try treeParser.parse(originalData)
        let encoded = try treeParser.parse(encodedData)
        let findings = diffEngine.compare(original, encoded, mode: .completeness)
        return FCPXMLRoundTripReport(
            sourcePath: sourcePath,
            fcpxmlVersion: original.attributes["version"],
            findings: findings
        )
    }
}
