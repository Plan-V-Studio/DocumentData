//
//  StorageNameMacro.swift
//  
//
//  Created by Akivili Collindort on 2023/12/6.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct StorageNameMacro { }

extension StorageNameMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let decl = declaration.as(VariableDeclSyntax.self) else {
            throw PersistedModelError.incorrectSyntaxStructure(declaration, VariableDeclSyntax.self)
        }
        
        guard let initializer = decl.bindings.first?.as(PatternBindingSyntax.self)?.initializer else {
            throw PersistedModelError.storageNoInitializer
        }
        
        return [
            """
            @_PersistedIgnored private let _$persistedDocumentName = "\(raw: initializer.value.as(StringLiteralExprSyntax.self)!.segments.description).storage.plist"
            """
        ]
    }
}
