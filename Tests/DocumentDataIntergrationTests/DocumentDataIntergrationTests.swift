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
            try TestClass.delete()
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
        testCase.save()
    }
    
    func testDefault() throws {
        let defaultData = TestClass.default
        print(defaultData)
        XCTAssert(defaultData.ignored.isEmpty)
    }
    
    func testChangeValue() throws {
        if !TestClass.isPersisted {
            try testCreate()
        }
        
        let data = TestClass.default
        data.string = "Bonjour!"
        
        XCTAssertEqual(TestClass.default.string, "Bonjour!")
    }
    
    func testDelete() throws {
        if !TestClass.isPersisted {
            try testCreate()
        }
        
        try TestClass.delete()
        
        XCTAssertEqual(TestClass.isPersisted, false)
    }
    
    func testMigration() throws {
        if !TestClass.isPersisted {
            try testCreate()
        }
        
        TestClass.migrate()
        
        // assert
        let data = try Data(contentsOf: TestClass.url)
        let decoder = PropertyListDecoder()
        let result = try? decoder.decode(TestClass.self, from: data)
        XCTAssertNotNil(result)
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
    
    @ModelCodingKey
    enum CodingKeys: String, CodingKey {
        case number = "NUMBER"
        case string = "STRING"
        case bool = "BOOL"
        case data = "DATA"
        case uuid = "UUID"
        case array = "ARRAY"
        case dict = "DICT"
        case anyCodable = "CODABLE"
    }
    
    @Migration
    enum OldKeys: String, CodingKey {
        case number = "N"
        case string = "S"
        case bool = "B"
        case data = "D"
        case uuid = "U"
        case array = "A"
        case dict = "I"
        case anyCodable = "E"
    }
    
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
