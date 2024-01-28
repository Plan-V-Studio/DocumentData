//
//  _MigrationMiddlewareMacro.swift
//
//
//  Created by Akivili Collindort on 2024/1/28.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct _MigrationMiddlewareMacro { }

extension _MigrationMiddlewareMacro: MemberMacro {
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
        
        return [
            // Encodable
            """
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: _$NewCodingKey.self)
            \(raw: try generateEncodableContentFunction(members))
            }
            """,
            
            // Decodable
            """
            required init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: _$OldCodingKey.self)
            \(raw: try generateDecodableContentFunction(members))
            }
            """,
        ]
    }
    
    private static func generateEncodableContentFunction(_ members: MemberBlockItemListSyntax) throws -> String {
        var expansion = [String]()
        for item in members {
            if let decl = item.decl.as(VariableDeclSyntax.self) {
                expansion.append("    try container.encode(\(decl.bindings.first!.pattern.description), forKey: .\(decl.bindings.first!.pattern.description))")
            }
        }
        return expansion.joined(separator: "\n")
    }
    
    private static func generateDecodableContentFunction(_ members: MemberBlockItemListSyntax) throws -> String {
        var expansion = [String]()
        for item in members {
            if let decl = item.decl.as(VariableDeclSyntax.self) {
                expansion.append(
                    "    self.\(decl.bindings.first!.pattern.description) = try container.decode(\(decl.bindings.first!.typeAnnotation!.type.description).self, forKey: .\(decl.bindings.first!.pattern.description))"
                )
            }
        }
        return expansion.joined(separator: "\n")
    }
}

extension _MigrationMiddlewareMacro: ExtensionMacro {
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
                extension \(raw: decl.name.text): Codable { }
                """
            ),
        ]
    }
}
