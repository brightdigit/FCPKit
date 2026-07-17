import Foundation

public enum FCPXMLDifferenceKind: String, Codable, CaseIterable, Sendable {
    case droppedElement
    case droppedAttribute
    case droppedText
    case addedElement
    case addedAttribute
    case addedText
    case changedAttribute
    case changedText
}

public struct FCPXMLDifference: Codable, Equatable, Sendable {
    public let kind: FCPXMLDifferenceKind
    public let path: String
    public let count: Int

    public init(kind: FCPXMLDifferenceKind, path: String, count: Int) {
        self.kind = kind
        self.path = path
        self.count = count
    }
}

public enum FCPXMLDiffMode: Sendable {
    case completeness
    case symmetric
}

public struct FCPXMLDiffEngine: Sendable {
    private let normalizer = FCPXMLNormalizer()

    public init() {}

    public func compare(
        _ left: XMLTreeNode,
        _ right: XMLTreeNode,
        mode: FCPXMLDiffMode
    ) -> [FCPXMLDifference] {
        let normalized = normalizer.normalizePair(left, right)
        let leftInventory = Inventory(root: normalized.left)
        let rightInventory = Inventory(root: normalized.right)

        let differences: [FCPXMLDifference]
        switch mode {
        case .completeness:
            differences = completenessDifferences(left: leftInventory, right: rightInventory)
        case .symmetric:
            differences = symmetricDifferences(left: leftInventory, right: rightInventory)
        }
        return differences.sorted(by: differenceOrdering)
    }

    private func completenessDifferences(left: Inventory, right: Inventory) -> [FCPXMLDifference] {
        var result: [FCPXMLDifference] = []
        appendCountDifferences(
            left.elements,
            right.elements,
            droppedKind: .droppedElement,
            addedKind: nil,
            to: &result
        )
        appendPresenceDifferences(
            left.attributes,
            right.attributes,
            droppedKind: .droppedAttribute,
            addedKind: nil,
            to: &result
        )
        appendPresenceDifferences(
            left.text,
            right.text,
            droppedKind: .droppedText,
            addedKind: nil,
            to: &result
        )
        return result
    }

    private func symmetricDifferences(left: Inventory, right: Inventory) -> [FCPXMLDifference] {
        var result: [FCPXMLDifference] = []
        appendCountDifferences(
            left.elements,
            right.elements,
            droppedKind: .droppedElement,
            addedKind: .addedElement,
            to: &result
        )
        appendValueDifferences(
            left.attributes,
            right.attributes,
            droppedKind: .droppedAttribute,
            addedKind: .addedAttribute,
            changedKind: .changedAttribute,
            to: &result
        )
        appendValueDifferences(
            left.text,
            right.text,
            droppedKind: .droppedText,
            addedKind: .addedText,
            changedKind: .changedText,
            to: &result
        )
        return result
    }

    private func appendCountDifferences(
        _ left: [String: Int],
        _ right: [String: Int],
        droppedKind: FCPXMLDifferenceKind,
        addedKind: FCPXMLDifferenceKind?,
        to result: inout [FCPXMLDifference]
    ) {
        for path in Set(left.keys).union(right.keys) {
            let delta = (left[path] ?? 0) - (right[path] ?? 0)
            if delta > 0 {
                result.append(FCPXMLDifference(kind: droppedKind, path: path, count: delta))
            } else if delta < 0, let addedKind {
                result.append(FCPXMLDifference(kind: addedKind, path: path, count: -delta))
            }
        }
    }

    private func appendPresenceDifferences(
        _ left: [String: [String]],
        _ right: [String: [String]],
        droppedKind: FCPXMLDifferenceKind,
        addedKind: FCPXMLDifferenceKind?,
        to result: inout [FCPXMLDifference]
    ) {
        appendCountDifferences(
            left.mapValues(\.count),
            right.mapValues(\.count),
            droppedKind: droppedKind,
            addedKind: addedKind,
            to: &result
        )
    }

    private func appendValueDifferences(
        _ left: [String: [String]],
        _ right: [String: [String]],
        droppedKind: FCPXMLDifferenceKind,
        addedKind: FCPXMLDifferenceKind,
        changedKind: FCPXMLDifferenceKind,
        to result: inout [FCPXMLDifference]
    ) {
        for path in Set(left.keys).union(right.keys) {
            let leftValues = multiset(left[path] ?? [])
            let rightValues = multiset(right[path] ?? [])
            var removed = 0
            var added = 0
            for value in Set(leftValues.keys).union(rightValues.keys) {
                let delta = (leftValues[value] ?? 0) - (rightValues[value] ?? 0)
                if delta > 0 { removed += delta }
                if delta < 0 { added -= delta }
            }
            let changed = min(removed, added)
            if changed > 0 {
                result.append(FCPXMLDifference(kind: changedKind, path: path, count: changed))
            }
            if removed > changed {
                result.append(FCPXMLDifference(kind: droppedKind, path: path, count: removed - changed))
            }
            if added > changed {
                result.append(FCPXMLDifference(kind: addedKind, path: path, count: added - changed))
            }
        }
    }

    private func multiset(_ values: [String]) -> [String: Int] {
        values.reduce(into: [:]) { $0[$1, default: 0] += 1 }
    }

    private func differenceOrdering(_ lhs: FCPXMLDifference, _ rhs: FCPXMLDifference) -> Bool {
        if lhs.count != rhs.count { return lhs.count > rhs.count }
        if lhs.kind.rawValue != rhs.kind.rawValue { return lhs.kind.rawValue < rhs.kind.rawValue }
        return lhs.path < rhs.path
    }
}

private struct Inventory {
    var elements: [String: Int] = [:]
    var attributes: [String: [String]] = [:]
    var text: [String: [String]] = [:]

    init(root: XMLTreeNode) {
        collect(root, parentPath: "")
    }

    private mutating func collect(_ node: XMLTreeNode, parentPath: String) {
        let path = "\(parentPath)/\(node.name)"
        elements[path, default: 0] += 1
        for (name, value) in node.attributes {
            attributes["\(path)/@\(name)", default: []].append(value)
        }
        if !node.text.isEmpty && node.text != "$opaque" {
            text["\(path)/#text", default: []].append(node.text)
        }
        for child in node.children {
            collect(child, parentPath: path)
        }
    }
}
