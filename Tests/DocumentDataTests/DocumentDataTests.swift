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
    "PersistedIgnored": ObservationPersistedIgnoredMacro.self
]
#endif

// MARK: - Actual Tests
final class DocumentDataTests: XCTestCase {
    func testPersisitedModelMacroExpansion() throws {
        #if canImport(DocumentDataMacros)
        assertMacroExpansion(
            """
            @PersistedModel
            class StoringData {
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
            class StoringData {
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
                    let container = Foundation.URL(filePath: Foundation.NSHomeDirectory())
                        .appending(component: "Library")
                        .appending(component: "Application Support")
                        .appending(component: Self._$persistedDocumentName)

                    if !Foundation.FileManager.default.fileExists(atPath: container.path(percentEncoded: false)) {
                        self.save()
                    }

                    let data = try! Data(contentsOf: container)

                    let decoder = Foundation.PropertyListDecoder()

                    let decoded = try! decoder.decode(StoringData.self, from: data)
                    return decoded[keyPath: keyPath]
                }

                func save() {
                    let container = Foundation.URL(filePath: NSHomeDirectory())
                        .appending(component: "Library")
                        .appending(component: "Application Support")
                        .appending(component: Self._$persistedDocumentName)

                    let encoder = PropertyListEncoder()
                    encoder.outputFormat = .binary

                    let encoded = try! encoder.encode(self)
                    try! encoded.write(to: container)
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
                    let container = Foundation.URL(filePath: Foundation.NSHomeDirectory())
                        .appending(component: "Library")
                        .appending(component: "Application Support")
                        .appending(component: _$persistedDocumentName)
                    let data = try! Data(contentsOf: container)
                    let decoder = Foundation.PropertyListDecoder()
                    return try! decoder.decode(StoringData.self, from: data)
                }
            }

            extension StoringData: Observation.Observable {
            }

            extension StoringData: Codable {
            }
            """#,
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
    
    // This will throw EXC_BAD_ACCESS
    func testPersistedModel() throws {
        #if canImport(DocumentData)
        let store = MacroStoringData(isFirstToggleOpen: false, textFieldText: "some", ignoredButObservedToggle: false)
        print(NSHomeDirectory())
        
        store.isFirstToggleOpen = false
        XCTAssert(store.isFirstToggleOpen == false)
        #else
        throw XCTSkip("the host platform are not supported")
        #endif
    }
}

#if canImport(DocumentData)
@PersistedModel
class MacroStoringData {
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
#endif
