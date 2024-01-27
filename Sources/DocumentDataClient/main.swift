// THIS IS A INTEGRATION TEST CASE

import DocumentData
import Foundation
import DocumentDataMacros

// MARK: - Expasion

@PersistedModel
final class TestCase {
    @StorageName
    static let name = "DefaultStorageCase"
    
    var number: Int
    var string: String
    var bool: Bool
    var data: Data
    var uuid: UUID
    var array: [String]
    var dict: [String: UUID]
    var anyCodable: AnyCodable
    
    init(number: Int, string: String, bool: Bool, data: Data, uuid: UUID, array: [String], dict: [String : UUID], anyCodable: AnyCodable) {
        self.number = number
        self.string = string
        self.bool = bool
        self.data = data
        self.uuid = uuid
        self.array = array
        self.dict = dict
        self.anyCodable = anyCodable
    }
}

extension TestCase: CustomStringConvertible {
    var description: String {
        """
        Number:     \(number)
        String:     \(string)
        Boolean:    \(bool)
        Data:       \(data)
        UUID:       \(uuid)
        Array:      \(array)
        Dictionary: \(dict)
        Codable:    \(anyCodable)
        """
    }
}

enum AnyCodable: String, Codable, CaseIterable {
    case v1, v2, v3
}

print(TestCase.isPersisted)

let testCase = TestCase(
    number: Int.random(in: 0...100),
    string: "Hello, world!",
    bool: Bool.random(),
    data: "Hello, wordl!".data(using: .utf8)!,
    uuid: UUID(),
    array: ["Hello1", "Hello2", "Hello3"],
    dict: ["1": UUID(), "2": UUID(), "3": UUID()],
    anyCodable: AnyCodable.allCases.randomElement()!
)
print(testCase)
print(TestCase.isPersisted)

let defaultCase = TestCase.default
print(defaultCase)
