//
//  DocumentDataIntergrationTests.swift
//  
//
//  Created by Akivili Collindort on 2024/1/27.
//

import XCTest
@testable import DocumentData

final class DocumentDataIntergrationTests: XCTestCase {
    func testCreate() throws {
        if TestClass.isPersisted {
            let url = URL(filePath: NSHomeDirectory()).appending(components: "Library", "Application Support", "\(TestClass.name).storage.plist")
            print(url.path(percentEncoded: false))
            throw XCTSkip("The persistent file already exists. Please remove it manually.")
        }
        
        let testCase = TestClass(
            number: Int.random(in: 0...100),
            string: "Hello, world!",
            bool: Bool.random(),
            data: "Hello, world!".data(using: .utf8)!,
            uuid: UUID(),
            array: ["Hello1", "Hello2", "Hello3"],
            dict: ["1": UUID(), "2": UUID(), "3": UUID()],
            anyCodable: AnyCodable.allCases.randomElement()!,
            ignored: "some"
        )
        print(testCase)
    }
    
    func testDefault() throws {
        let defaultData = TestClass.default
        print(defaultData)
        XCTAssert(defaultData.ignored.isEmpty)
    }
    
    func testChangeValue() throws {
        guard TestClass.isPersisted else {
            throw XCTSkip("The persistent file does not exist, please run testCreate() first.")
        }
        
        let data = TestClass.default
        data.string = "Bonjour!"
        
        XCTAssertEqual(TestClass.default.string, "Bonjour!")
    }
}

#if canImport(DocumentData)
@PersistedModel
final class TestClass {
    @StorageName
    static let name = "DefaultTest"
    
    var number: Int
    var string: String
    var bool: Bool
    var data: Data
    var uuid: UUID
    var array: [String]
    var dict: [String: UUID]
    var anyCodable: AnyCodable
    
    @PersistedIgnored
    var ignored: String
    
    init(number: Int, string: String, bool: Bool, data: Data, uuid: UUID, array: [String], dict: [String : UUID], anyCodable: AnyCodable, ignored: String) {
        self.number = number
        self.string = string
        self.bool = bool
        self.data = data
        self.uuid = uuid
        self.array = array
        self.dict = dict
        self.anyCodable = anyCodable
        self.ignored = ignored
    }
}

extension TestClass: CustomStringConvertible {
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
        Ignored:    \(ignored)
        """
    }
}

enum AnyCodable: String, Codable, CaseIterable {
    case v1, v2, v3
}
#endif
