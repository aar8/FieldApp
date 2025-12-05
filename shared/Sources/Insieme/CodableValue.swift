import Foundation

public struct CodableValue: Codable {
    public let value: Any

    public init(_ value: Any) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let int = try? container.decode(Int.self) {
            self.value = int
        } else if let double = try? container.decode(Double.self) {
            self.value = double
        } else if let string = try? container.decode(String.self) {
            self.value = string
        } else if let bool = try? container.decode(Bool.self) {
            self.value = bool
        } else if let array = try? container.decode([CodableValue].self) {
            self.value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: CodableValue].self) {
            self.value = dictionary.mapValues { $0.value }
        } else {
            throw DecodingError.typeMismatch(CodableValue.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unsupported Codable value"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let bool as Bool:
            try container.encode(bool)
        case let array as [Any]:
            let encodableArray = array.map { CodableValue($0) }
            try container.encode(encodableArray)
        case let dict as [String: Any]:
            let encodableDict = dict.mapValues { CodableValue($0) }
            try container.encode(encodableDict)
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unsupported Codable value"))
        }
    }
}
