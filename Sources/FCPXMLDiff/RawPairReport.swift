import Foundation

public struct RawPairReport: Codable, Equatable, Sendable {
    public let formatVersion: Int
    public let beforePath: String
    public let afterPath: String
    public let beforeFCPXMLVersion: String?
    public let afterFCPXMLVersion: String?
    public let pathFilter: String?
    public let normalization: [String]
    public let findings: [FCPXMLDifference]

    public init(
        beforePath: String,
        afterPath: String,
        beforeFCPXMLVersion: String?,
        afterFCPXMLVersion: String?,
        pathFilter: String?,
        findings: [FCPXMLDifference]
    ) {
        formatVersion = 1
        self.beforePath = beforePath
        self.afterPath = afterPath
        self.beforeFCPXMLVersion = beforeFCPXMLVersion
        self.afterFCPXMLVersion = afterFCPXMLVersion
        self.pathFilter = pathFilter
        normalization = FCPXMLNormalizer.rules
        self.findings = findings
    }
}

public struct RawPairAnalyzer: Sendable {
    private let parser = XMLTreeParser()
    private let engine = FCPXMLDiffEngine()

    public init() {}

    public func analyze(
        beforeData: Data,
        afterData: Data,
        beforePath: String = "before.fcpxml",
        afterPath: String = "after.fcpxml",
        pathFilter: String? = nil
    ) throws -> RawPairReport {
        let before = try parser.parse(beforeData)
        let after = try parser.parse(afterData)
        let findings = engine.compare(before, after, mode: .symmetric).filter {
            guard let pathFilter else { return true }
            return $0.path.hasPrefix(pathFilter)
        }
        return RawPairReport(
            beforePath: beforePath,
            afterPath: afterPath,
            beforeFCPXMLVersion: before.attributes["version"],
            afterFCPXMLVersion: after.attributes["version"],
            pathFilter: pathFilter,
            findings: findings
        )
    }
}

public struct RawPairReportRenderer: Sendable {
    public init() {}

    public func jsonData(_ report: RawPairReport) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(report)
    }

    public func markdown(_ report: RawPairReport) -> String {
        var lines = [
            "# FCPXML Raw-Pair Diff",
            "",
            "Before: `\(report.beforePath)` (FCPXML `\(report.beforeFCPXMLVersion ?? "unknown")`)",
            "After: `\(report.afterPath)` (FCPXML `\(report.afterFCPXMLVersion ?? "unknown")`)",
            "",
        ]
        if let pathFilter = report.pathFilter {
            lines += ["Path filter: `\(pathFilter)`", ""]
        }
        if report.findings.isEmpty {
            lines.append("No structural differences detected.")
        } else {
            lines += [
                "| Count | Kind | Structural path |",
                "| ---: | --- | --- |",
            ]
            lines += report.findings.map {
                "| \($0.count) | `\($0.kind.rawValue)` | `\($0.path)` |"
            }
        }
        return lines.joined(separator: "\n") + "\n"
    }
}
