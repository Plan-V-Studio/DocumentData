import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import DocumentData

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(DocumentDataMacros)
import DocumentDataMacros

let testMacros: [String: Macro.Type] = [
    "PersistedModel" : PersistedModelMacro.self,
    "PersistedProperty": PersistedPropertyMacro.self,
    "_PersistedIgnored": PersistedIgnoredMacro.self,
    "StorageName": StorageNameMacro.self,
    "PersistedIgnored": ObservationPersistedIgnoredMacro.self,
    "ModelCodingKey": ModelCodingKeyMacro.self
]
#endif

// MARK: - Actual Tests
final class DocumentDataTests: XCTestCase {
    func testPersisitedModelMacroExpansion() throws {
        #if canImport(DocumentDataMacros)
        assertMacroExpansion(
            """
            @PersistedModel
            final class StoringData {
                var isFirstToggleOpen: Bool
                var textFieldText: String
                
                @PersistedIgnored
                var ignoredButObservedToggle: Bool
                
                @StorageName
                static let storeName = "Default"
                
                init(isFirstToggleOpen: Bool, textFieldText: String, ignoredButObservedToggle: Bool) {
                    self.isFirstToggleOpen = isFirstToggleOpen
                    self.textFieldText = textFieldText
                    self.ignoredButObservedToggle = ignoredButObservedToggle
                }
            }
            """,
            expandedSource: #"""
            final class StoringData {
                var isFirstToggleOpen: Bool {
                    @storageRestrictions(initializes: _isFirstToggleOpen)
                    init {
                        _isFirstToggleOpen = newValue
                    }
                    get {
                        access(keyPath: \.isFirstToggleOpen)
                        return access(\._isFirstToggleOpen)
                    }
                    set {
                        withMutation(keyPath: \.isFirstToggleOpen) {
                            _isFirstToggleOpen = newValue
                            self.save()
                        }
                    }
                }

                private var _isFirstToggleOpen: Bool
                var textFieldText: String {
                    @storageRestrictions(initializes: _textFieldText)
                    init {
                        _textFieldText = newValue
                    }
                    get {
                        access(keyPath: \.textFieldText)
                        return access(\._textFieldText)
                    }
                    set {
                        withMutation(keyPath: \.textFieldText) {
                            _textFieldText = newValue
                            self.save()
                        }
                    }
                }

                private var _textFieldText: String
                
                var ignoredButObservedToggle: Bool {
                    @storageRestrictions(initializes: _ignoredButObservedToggle)
                    init {
                        _ignoredButObservedToggle = newValue
                    }
                    get {
                        access(keyPath: \.ignoredButObservedToggle)
                        return _ignoredButObservedToggle
                    }
                    set {
                        _$observationRegistrar.withMutation(of: self, keyPath: \.ignoredButObservedToggle) {
                            _ignoredButObservedToggle = newValue
                        }
                    }
                }

                private var _ignoredButObservedToggle: Bool
                
                static let storeName = "Default"

                private static let _$persistedDocumentName = "Default.storage.plist"
                
                init(isFirstToggleOpen: Bool, textFieldText: String, ignoredButObservedToggle: Bool) {
                    self.isFirstToggleOpen = isFirstToggleOpen
                    self.textFieldText = textFieldText
                    self.ignoredButObservedToggle = ignoredButObservedToggle
                }
                private let _$observationRegistrar = Observation.ObservationRegistrar()

                func encode(to encoder: Encoder) throws {
                    var container = encoder.container(keyedBy: _$PersistedCodingKeys.self)
                    try container.encode(_isFirstToggleOpen, forKey: ._isFirstToggleOpen)
                    try container.encode(_textFieldText, forKey: ._textFieldText)
                }

                required init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: _$PersistedCodingKeys.self)
                    self._isFirstToggleOpen = try container.decode(Bool.self, forKey: ._isFirstToggleOpen)
                    self._textFieldText = try container.decode(String.self, forKey: ._textFieldText)
                    self.ignoredButObservedToggle = .init()
                }

                enum _$PersistedCodingKeys: String, CodingKey {
                    case _isFirstToggleOpen = "isFirstToggleOpen"
                    case _textFieldText = "textFieldText"
                }

                func access<T>(_ keyPath: KeyPath<StoringData, T>) -> T where T: Codable {
                    if !Foundation.FileManager.default.fileExists(atPath: Self.url.path(percentEncoded: false)) {
                        self.save()
                    }

                    let data = try! Data(contentsOf: Self.url)

                    let decoder = Foundation.PropertyListDecoder()

                    let decoded = try! decoder.decode(StoringData.self, from: data)
                    return decoded[keyPath: keyPath]
                }

                func save() {
                    let encoder = PropertyListEncoder()
                    encoder.outputFormat = .binary

                    let encoded = try! encoder.encode(self)
                    try! encoded.write(to: Self.url)
                }

                internal nonisolated func access<Member>(
                    keyPath: KeyPath<StoringData, Member>
                ) {
                    _$observationRegistrar.access(self, keyPath: keyPath)
                }

                internal nonisolated func withMutation<Member, MutationResult>(
                    keyPath: KeyPath<StoringData, Member>,
                    _ mutation: () throws -> MutationResult
                ) rethrows -> MutationResult {
                    try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
                }

                static var `default`: StoringData {
                    let data = try! Data(contentsOf: Self.url)
                    let decoder = Foundation.PropertyListDecoder()
                    return try! decoder.decode(StoringData.self, from: data)
                }

                static var isPersisted: Bool {
                    let fileManager = Foundation.FileManager()
                    return fileManager.fileExists(atPath: Self.url.path(percentEncoded: false))
                }
            
                static var url: URL {
                    Foundation.URL(filePath: Foundation.NSHomeDirectory())
                        .appending(components: "Library", "Application Support", _$persistedDocumentName)
                }
            }

            extension StoringData: Observation.Observable {
            }

            extension StoringData: Codable {
            }

            extension StoringData: DocumentData.DocumentPersistedModel {
            }
            """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testPersistedModelAppliedOnNonFinalClass() throws {
        #if canImport(DocumentDataMacros)
        assertMacroExpansion(
            """
            @PersistedModel
            class Model {
                var property: String
            }
            """,
            expandedSource: """
            class Model {
                var property: String
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@PersistedModel only available for final class.", line: 1, column: 1)
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testStorageNameAppliedOnVariable() throws {
        #if canImport(DocumentDataMacros)
        assertMacroExpansion(
            """
            @StorageName
            static var name = "Storage Name"
            """,
            expandedSource: """
            static var name = "Storage Name"
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@StorageName only available for \"let\" property.", line: 2, column: 8,
                    fixIts: [FixItSpec(message: #"Use "let" instead of "var"."#)]
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testModelCodingKeyMacroExpansionWithEachLineOne() throws {
        #if canImport(DocumentDataMacros)
        assertMacroExpansion(
            """
            @ModelCodingKey
            enum CodingKeys: String, CodingKey {
                case string = "DDString"
                case uuid = "DDUUID"
                case integer = "DDInteger"
            }
            """,
            expandedSource: """
            enum CodingKeys: String, CodingKey {
                case string = "DDString"
                case uuid = "DDUUID"
                case integer = "DDInteger"
            }
            
            enum _$PersistedCodingKeys: String, CodingKey {
                case _string = "DDString"
                case _uuid = "DDUUID"
                case _integer = "DDInteger"
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testModelCodingKeyMacroExpansionWithEachLineMany() throws {
        #if canImport(DocumentDataMacros)
        assertMacroExpansion(
            """
            @ModelCodingKey
            enum CodingKeys: String, CodingKey {
                case string = "DDString", uuid = "DDUUID", integer = "DDInteger"
            }
            """,
            expandedSource: """
            enum CodingKeys: String, CodingKey {
                case string = "DDString", uuid = "DDUUID", integer = "DDInteger"
            }
            
            enum _$PersistedCodingKeys: String, CodingKey {
                case _string = "DDString"
                case _uuid = "DDUUID"
                case _integer = "DDInteger"
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testModelCodingKeyMacroExpansionInIntKey() throws {
        #if canImport(DocumentDataMacros)
        assertMacroExpansion(
            """
            @ModelCodingKey
            enum CodingKeys: Int, CodingKey {
                case string = 1, uuid = 2, integer = 3
            }
            """,
            expandedSource: """
            enum CodingKeys: Int, CodingKey {
                case string = 1, uuid = 2, integer = 3
            }
            
            enum _$PersistedCodingKeys: Int, CodingKey {
                case _string = 1
                case _uuid = 2
                case _integer = 3
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
