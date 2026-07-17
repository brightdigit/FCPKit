import Foundation

public struct XMLTreeNode: Equatable, Sendable {
    public var name: String
    public var attributes: [String: String]
    public var text: String
    public var children: [XMLTreeNode]

    public init(
        name: String,
        attributes: [String: String] = [:],
        text: String = "",
        children: [XMLTreeNode] = []
    ) {
        self.name = name
        self.attributes = attributes
        self.text = text
        self.children = children
    }
}

public enum XMLTreeParserError: Error, LocalizedError {
    case invalidDocument(String)
    case missingRootElement

    public var errorDescription: String? {
        switch self {
        case .invalidDocument(let message):
            return "Invalid XML document: \(message)"
        case .missingRootElement:
            return "XML document does not contain a root element"
        }
    }
}

public struct XMLTreeParser: Sendable {
    public init() {}

    public func parse(_ data: Data) throws -> XMLTreeNode {
        let delegate = TreeParserDelegate()
        let parser = XMLParser(data: data)
        parser.delegate = delegate
        parser.shouldProcessNamespaces = false
        parser.shouldReportNamespacePrefixes = true
        parser.shouldResolveExternalEntities = false

        guard parser.parse() else {
            throw XMLTreeParserError.invalidDocument(
                parser.parserError?.localizedDescription ?? "unknown parser error"
            )
        }
        guard let root = delegate.root else {
            throw XMLTreeParserError.missingRootElement
        }
        return root
    }
}

private final class TreeParserDelegate: NSObject, XMLParserDelegate {
    private struct Builder {
        var name: String
        var attributes: [String: String]
        var text = ""
        var children: [XMLTreeNode] = []

        func build() -> XMLTreeNode {
            XMLTreeNode(
                name: name,
                attributes: attributes,
                text: text.trimmingCharacters(in: .whitespacesAndNewlines),
                children: children
            )
        }
    }

    private var stack: [Builder] = []
    fileprivate var root: XMLTreeNode?

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        stack.append(Builder(name: qName ?? elementName, attributes: attributeDict))
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard !stack.isEmpty else { return }
        stack[stack.count - 1].text += string
    }

    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        guard !stack.isEmpty, let string = String(data: CDATABlock, encoding: .utf8) else { return }
        stack[stack.count - 1].text += string
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        guard let builder = stack.popLast() else { return }
        let node = builder.build()
        if stack.isEmpty {
            root = node
        } else {
            stack[stack.count - 1].children.append(node)
        }
    }
}
