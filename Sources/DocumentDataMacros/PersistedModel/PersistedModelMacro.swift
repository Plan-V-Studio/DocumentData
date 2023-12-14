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
        
        guard let members = decl.memberBlock.members.as(MemberBlockItemListSyntax.self) else {
            throw PersistedModelError.incorrectClassStructure(syntax: decl)
        }
        
        var result = [DeclSyntax]()
        
        // assert _$persistedDocumentName
        if try !members.has(attributeDeclDocumentName) {
            result.append("""
            private let _$persistedDocumentName = "\(raw: decl.name.text).storage.plist"
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
            
            // CodingKeys
            """
            enum _$PersistedCodingKeys: String, CodingKey {
            \(raw: try generatePersistedCodingKeys(members))
            }
            """,
            
            // access
            """
            func access<T>(_ keyPath: KeyPath<\(raw: decl.name.text), T>) -> T where T: Codable {
                let container = Foundation.URL(filePath: Foundation.NSHomeDirectory())
                    .appending(component: "Library")
                    .appending(component: "Application Support")
                    .appending(component: _$persistedDocumentName)
            
                if !Foundation.FileManager.default.fileExists(atPath: container.path(percentEncoded: false)) {
                    self.save()
                }
                
                let data = try! Data(contentsOf: container)
                
                let decoder = Foundation.PropertyListDecoder()
                
                let decoded = try! decoder.decode(\(raw: decl.name.text).self, from: data)
                return decoded[keyPath: keyPath]
            }
            """,
            
            // save
            """
            func save() {
                let container = Foundation.URL(filePath: NSHomeDirectory())
                    .appending(component: "Library")
                    .appending(component: "Application Support")
                    .appending(component: _$persistedDocumentName)
            
                let encoder = PropertyListEncoder()
                encoder.outputFormat = .binary
                
                let encoded = try! encoder.encode(self)
                try! encoded.write(to: container)
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
        ]
        
        return result
    }
    
    private static func attributeDeclDocumentName(_ element: MemberBlockItemListSyntax.Element) throws -> Bool {
        if let variable = element.decl.as(VariableDeclSyntax.self) {
            if try variable.attributes.has(attributeDeclDocumentExpression) {
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
                if try !decl.attributes.has(attributeDeclExpression) {
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
                if try !decl.attributes.has(attributeDeclExpression) {
                    expansion.append(
                        "    self._\(decl.bindings.first!.pattern.description) = try container.decode(\(decl.bindings.first!.typeAnnotation!.type.description).self, forKey: ._\(decl.bindings.first!.pattern.description))"
                    )
                } else {
                    expansion.append(
                        "    self.\(decl.bindings.first!.pattern.description) = .init()"
                    )
                }
            }
        }
        return expansion.joined(separator: "\n")
    }
    
    private static func generatePersistedCodingKeys(_ members: MemberBlockItemListSyntax) throws -> String {
        var expansion = [String]()
        for item in members {
            if let decl = item.decl.as(VariableDeclSyntax.self) {
                if try !decl.attributes.has(attributeDeclExpression) {
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
//            try ExtensionDeclSyntax(
//                """
//                extension \(raw: decl.name.text): DocumentData.DocumentPersistedModel { }
//                """
//            ),
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
        // TODO: not finish
        if let member = member.as(VariableDeclSyntax.self) {
            if try !member.attributes.has(attributeDeclExpression) {
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

extension Collection {
    /// Finds if the current sequence meets the condition.
    /// 
    /// When using this function, you need to specify the condition you are thinking of. Then write a boolean expression in the closure.
    ///
    /// This is an example of using this function.
    /// ``` swift
    /// let fruits = [
    ///     "apple: red",
    ///     "banana: yellow",
    ///     "orange: orange",
    ///     "strawberry: red",
    ///     "mango: yellow",
    ///     "hawthorn: red",
    /// ]
    ///
    /// // this code will return false because no white fruits was provided.
    /// fruits.has { fruit in
    ///     fruit.contains("white")
    /// }
    ///
    /// // this code will return true because we have red fruits in the collection.
    /// fruits.has { fruit in
    ///     fruit.contains("red")
    /// }
    /// ```
    /// - Parameter expression: Condition expression.
    /// - Returns: `true` for have the folloing expression, otherwise, return `false`.
    func has(_ expression: (_ element: Element) throws -> Bool) rethrows -> Bool {
        for item in self {
            if try expression(item) {
                return true
            }
        }
        return false
    }
}
