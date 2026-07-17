import FCPXMLDiff
import Foundation

@main
struct FCPXMLDiffCommand {
    static func main() {
        do {
            let accepted = try run()
            if !accepted {
                Foundation.exit(1)
            }
        } catch {
            writeError("fcpxml-diff: \(error.localizedDescription)\n")
            Foundation.exit(2)
        }
    }

    private static func run() throws -> Bool {
        var arguments = Array(CommandLine.arguments.dropFirst())
        guard arguments.first == "schema-completeness" else {
            throw CommandError.usage
        }
        arguments.removeFirst()

        var inputs: [String] = []
        var markdownPath: String?
        var jsonPath: String?
        var maximumTotalLoss: Int?
        var index = 0
        while index < arguments.count {
            switch arguments[index] {
            case "--markdown":
                index += 1
                guard index < arguments.count else { throw CommandError.usage }
                markdownPath = arguments[index]
            case "--json":
                index += 1
                guard index < arguments.count else { throw CommandError.usage }
                jsonPath = arguments[index]
            case "--fail-if-total-exceeds":
                index += 1
                guard index < arguments.count,
                      let value = Int(arguments[index]),
                      value >= 0
                else { throw CommandError.usage }
                maximumTotalLoss = value
            default:
                inputs.append(arguments[index])
            }
            index += 1
        }
        guard !inputs.isEmpty else { throw CommandError.usage }

        let fileURLs = try collectFiles(inputs)
        guard !fileURLs.isEmpty else { throw CommandError.noInputFiles }

        let currentDirectory = URL(
            fileURLWithPath: FileManager.default.currentDirectoryPath,
            isDirectory: true
        )
        let report = try SchemaCompletenessAnalyzer().analyze(
            fileURLs: fileURLs,
            relativeTo: currentDirectory
        )
        let renderer = SchemaCompletenessReportRenderer()
        let markdown = renderer.markdown(report)
        print(markdown, terminator: "")

        if let markdownPath {
            try Data(markdown.utf8).write(to: URL(fileURLWithPath: markdownPath), options: .atomic)
        }
        if let jsonPath {
            try renderer.jsonData(report).write(to: URL(fileURLWithPath: jsonPath), options: .atomic)
        }
        guard let maximumTotalLoss else { return true }
        let acceptance = SchemaCompletenessAcceptance(maximumTotalLoss: maximumTotalLoss)
        if !acceptance.accepts(report) {
            writeError(
                "fcpxml-diff: total structural loss \(report.totals.total) exceeds accepted baseline \(maximumTotalLoss)\n"
            )
            return false
        }
        return true
    }

    private static func collectFiles(_ paths: [String]) throws -> [URL] {
        var results: [URL] = []
        for path in paths {
            let url = URL(fileURLWithPath: path)
            var isDirectory: ObjCBool = false
            guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
                throw CommandError.missingInput(path)
            }
            if isDirectory.boolValue {
                let children = try FileManager.default.contentsOfDirectory(
                    at: url,
                    includingPropertiesForKeys: [.isRegularFileKey],
                    options: [.skipsHiddenFiles]
                )
                results.append(contentsOf: children.filter { $0.pathExtension == "fcpxml" })
            } else if url.pathExtension == "fcpxml" {
                results.append(url)
            }
        }
        return Array(Set(results.map(\.standardizedFileURL))).sorted { $0.path < $1.path }
    }

    private static func writeError(_ message: String) {
        FileHandle.standardError.write(Data(message.utf8))
    }
}

private enum CommandError: Error, LocalizedError {
    case usage
    case noInputFiles
    case missingInput(String)

    var errorDescription: String? {
        switch self {
        case .usage:
            return "usage: fcpxml-diff schema-completeness <file-or-directory>... [--markdown path] [--json path] [--fail-if-total-exceeds count]"
        case .noInputFiles:
            return "no .fcpxml input files found"
        case .missingInput(let path):
            return "input does not exist: \(path)"
        }
    }
}
