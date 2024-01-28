//
//  MigrationMacro.swift
//
//
//  Created by Akivili Collindort on 2024/1/28.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct MigrationMacro { }

extension MigrationMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let decl = declaration.as(EnumDeclSyntax.self) else {
            throw PersistedModelError.onlyAvailableForEnum(macroName: "Migration")
        }
        
        guard let inheritanceClause = decl.inheritanceClause else {
            throw PersistedModelError.cannotFindInheritanceClause
        }
        
        // check whether the enum conforms to CodingKey
        guard inheritanceClause.inheritedTypes.contains(where: { $0.type.as(IdentifierTypeSyntax.self)?.name.text == "CodingKey" }) else {
            throw PersistedModelError.notConformsToCodingKey
        }
        
        
        return []
    }
}
