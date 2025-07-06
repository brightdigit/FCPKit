import Foundation
import XMLCoder

public class FCPXMLParser {
    private let decoder: XMLDecoder
    
    public init() {
        decoder = XMLDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .useDefaultKeys
    }
    
    public func parse(data: Data) throws -> FCPXML {
        return try decoder.decode(FCPXML.self, from: data)
    }
    
    public func parse(xmlString: String) throws -> FCPXML {
        guard let data = xmlString.data(using: .utf8) else {
            throw FCPXMLError.invalidXMLString
        }
        return try parse(data: data)
    }
    
    public func parse(fileURL: URL) throws -> FCPXML {
        let data = try Data(contentsOf: fileURL)
        return try parse(data: data)
    }
    
    public func encode(_ fcpxml: FCPXML) throws -> Data {
        let encoder = XMLEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .useDefaultKeys
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(fcpxml, withRootKey: "fcpxml")
    }
    
    public func encodeToString(_ fcpxml: FCPXML) throws -> String {
        let data = try encode(fcpxml)
        guard let string = String(data: data, encoding: .utf8) else {
            throw FCPXMLError.encodingFailed
        }
        return string
    }
    
    public func write(_ fcpxml: FCPXML, to url: URL) throws {
        let data = try encode(fcpxml)
        try data.write(to: url)
    }
}

public enum FCPXMLError: Error, LocalizedError {
    case invalidXMLString
    case encodingFailed
    case decodingFailed(String)
    case fileNotFound
    
    public var errorDescription: String? {
        switch self {
        case .invalidXMLString:
            return "Invalid XML string provided"
        case .encodingFailed:
            return "Failed to encode FCPXML to string"
        case .decodingFailed(let message):
            return "Failed to decode FCPXML: \(message)"
        case .fileNotFound:
            return "FCPXML file not found"
        }
    }
}