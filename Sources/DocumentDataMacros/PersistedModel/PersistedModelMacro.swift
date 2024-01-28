//
//  PersistedModelMacro.swift
//
//
//  Created by Akivili Collindort on 2023/12/3.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import Foundation

public struct PersistedModelMacro { }

extension PersistedModelMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let decl = declaration.as(ClassDeclSyntax.self) else {
            throw PersistedModelError.unavaliableApplyingType
        }
        
        guard decl.modifiers.contains(where: { $0.name.text == "final" }) else {
            throw PersistedModelError.unavailableForNonFinalClass
        }
        
        guard let members = decl.memberBlock.members.as(MemberBlockItemListSyntax.self) else {
            throw PersistedModelError.incorrectClassStructure(syntax: decl)
        }
        
        var result = [DeclSyntax]()
        
        // assert _$persistedDocumentName
        if try !members.contains(where: attributeDeclDocumentName) {
            result.append("""
            private static let _$persistedDocumentName = "\(raw: decl.name.text).storage.plist"
            """)
        }
        
        // CodingKeys
        if try !members.contains(where: assertCustomCodingKey) {
            result.append("""
            enum _$PersistedCodingKeys: String, CodingKey {
            \(raw: try generatePersistedCodingKeys(members))
            }
            """)
        }
        
        result += [
            // Observable
            """
            @_PersistedIgnored
            private let _$observationRegistrar = Observation.ObservationRegistrar()
            """,
            
            // Encodable
            """
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: _$PersistedCodingKeys.self)
            \(raw: try generateEncodableContentFunction(members))
            }
            """,
            
            // Decodable
            """
            required init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: _$PersistedCodingKeys.self)
            \(raw: try generateDecodableContentFunction(members))
            }
            """,
            
            // access
            """
            func access<T>(_ keyPath: KeyPath<\(raw: decl.name.text), T>) -> T where T: Codable {
                if !Foundation.FileManager.default.fileExists(atPath: Self.url.path(percentEncoded: false)) {
                    self.save()
                }
                
                let data = try! Data(contentsOf: Self.url)
                
                let decoder = Foundation.PropertyListDecoder()
                
                let decoded = try! decoder.decode(\(raw: decl.name.text).self, from: data)
                return decoded[keyPath: keyPath]
            }
            """,
            
            // save
            """
            func save(autoCreateFolder: Bool = true) {
                if autoCreateFolder {
                    let fileManager = FileManager()
                    let applicationSupportURL = Self.url.deletingLastPathComponent()
                    if !fileManager.fileExists(atPath: applicationSupportURL.path(percentEncoded: false)) {
                        try! fileManager.createDirectory(at: applicationSupportURL, withIntermediateDirectories: true)
                    }
                }
                
                let encoder = PropertyListEncoder()
                encoder.outputFormat = .binary
                
                let encoded = try! encoder.encode(self)
                try! encoded.write(to: Self.url)
            }
            """,
            
            // access: Observable
            """
            internal nonisolated func access<Member>(
                keyPath: KeyPath<\(raw: decl.name.text), Member>
            ) {
                _$observationRegistrar.access(self, keyPath: keyPath)
            }
            """,
            
            // withMutation: Observable
            """
            internal nonisolated func withMutation<Member, MutationResult>(
                keyPath: KeyPath<\(raw: decl.name.text), Member>,
                _ mutation: () throws -> MutationResult
            ) rethrows -> MutationResult {
                try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
            }
            """,
            
            // default: DocumentPersistedModel
            """
            static var `default`: \(raw: decl.name.text) {
                let data = try! Data(contentsOf: Self.url)
                let decoder = Foundation.PropertyListDecoder()
                return try! decoder.decode(\(raw: decl.name.text).self, from: data)
            }
            """,
            
            // isPersisted: DocumentPersistedModel
            """
            static var isPersisted: Bool {
                let fileManager = Foundation.FileManager()
                return fileManager.fileExists(atPath: Self.url.path(percentEncoded: false))
            }
            """,
            
            // url
            """
            static var url: URL {
                Foundation.URL(filePath: Foundation.NSHomeDirectory())
                    .appending(components: "Library", "Application Support", _$persistedDocumentName)
            }
            """,
            
            // delete
            """
            static func delete() throws {
                let fileManager = Foundation.FileManager()
                try fileManager.removeItem(at: url)
            }
            """
        ]
        
        return result
    }
    
    private static func attributeDeclDocumentName(_ element: MemberBlockItemListSyntax.Element) throws -> Bool {
        if let variable = element.decl.as(VariableDeclSyntax.self) {
            if try variable.attributes.contains(where: attributeDeclDocumentExpression) {
                return true
            }
        }
        return false
    }
    
    private static func assertCustomCodingKey(_ element: MemberBlockItemListSyntax.Element) throws -> Bool {
        if let variable = element.decl.as(EnumDeclSyntax.self) {
            if try variable.attributes.contains(where: { attr in
                guard let decl = attr.as(AttributeSyntax.self) else {
                    throw PersistedModelError.incorrectPropertyAttributeStructure
                }
                return decl.attributeName.description == "ModelCodingKey"
            }) {
                return true
            }
        }
        return false
    }
    
    private static func attributeDeclDocumentExpression(_ element: AttributeListSyntax.Element) throws -> Bool {
        guard let decl = element.as(AttributeSyntax.self) else {
            throw PersistedModelError.incorrectPropertyAttributeStructure
        }
        
        return decl.attributeName.as(IdentifierTypeSyntax.self)?.description == "StorageName"
    }
    
    private static func generateEncodableContentFunction(_ members: MemberBlockItemListSyntax) throws -> String {
        var expansion = [String]()
        for item in members {
            if let decl = item.decl.as(VariableDeclSyntax.self) {
                if try !decl.attributes.contains(where: attributeDeclExpression) {
                    expansion.append("    try container.encode(_\(decl.bindings.first!.pattern.description), forKey: ._\(decl.bindings.first!.pattern.description))")
                }
            }
        }
        return expansion.joined(separator: "\n")
    }
    
    private static func generateDecodableContentFunction(_ members: MemberBlockItemListSyntax) throws -> String {
        var expansion = [String]()
        for item in members {
            if let decl = item.decl.as(VariableDeclSyntax.self) {
                if try !decl.attributes.contains(where: attributeDeclExpression) {
                    expansion.append(
                        "    self._\(decl.bindings.first!.pattern.description) = try container.decode(\(decl.bindings.first!.typeAnnotation!.type.description).self, forKey: ._\(decl.bindings.first!.pattern.description))"
                    )
                } else {
                    if decl.bindingSpecifier.text != "let" {
                        expansion.append(
                            "    self.\(decl.bindings.first!.pattern.description) = .init()"
                        )
                    }
                }
            }
        }
        return expansion.joined(separator: "\n")
    }
    
    private static func generatePersistedCodingKeys(_ members: MemberBlockItemListSyntax) throws -> String {
        var expansion = [String]()
        for item in members {
            if let decl = item.decl.as(VariableDeclSyntax.self) {
                if try !decl.attributes.contains(where: attributeDeclExpression) {
                    expansion.append(
                        "    case _\(decl.bindings.first!.pattern.description) = \"\(decl.bindings.first!.pattern.description)\""
                    )
                }
            }
        }
        return expansion.joined(separator: "\n")
    }
}

extension PersistedModelMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let decl = declaration.as(ClassDeclSyntax.self) else {
            throw PersistedModelError.unavaliableApplyingType
        }
        
        guard decl.modifiers.contains(where: { $0.name.text == "final" }) else {
            return []
        }
        
        return [
            try ExtensionDeclSyntax(
                """
                extension \(raw: decl.name.text): Observation.Observable { }
                """
            ),
            try ExtensionDeclSyntax(
                """
                extension \(raw: decl.name.text): Codable { }
                """
            ),
            try ExtensionDeclSyntax(
                """
                extension \(raw: decl.name.text): DocumentData.DocumentPersistedModel { }
                """
            ),
        ]
    }
}

extension PersistedModelMacro: MemberAttributeMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        guard let decl = declaration.as(ClassDeclSyntax.self) else {
            throw PersistedModelError.unavaliableApplyingType
        }
        
        guard decl.modifiers.contains(where: { $0.name.text == "final" }) else {
            return []
        }
        
        if let member = member.as(VariableDeclSyntax.self) {
            if try !member.attributes.contains(where: attributeDeclExpression) {
                return ["@PersistedProperty"]
            } else {
                return []
            }
        }
        return []
    }
}

// Implementation
extension PersistedModelMacro {
    private static func attributeDeclExpression(_ element: AttributeListSyntax.Element) throws -> Bool {
        guard let decl = element.as(AttributeSyntax.self) else {
            throw PersistedModelError.incorrectPropertyAttributeStructure
        }
        
        let description = decl.attributeName.as(IdentifierTypeSyntax.self)?.description
        
        return description == "PersistedIgnored" || description == "StorageName" || description == "ObservablePersistedIgnored"
    }
}
