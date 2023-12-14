//
//  PersistedPropertyMacro.swift
//
//
//  Created by Akivili Collindort on 2023/12/4.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct PersistedPropertyMacro { }

extension PersistedPropertyMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let decl = declaration.as(VariableDeclSyntax.self) else {
            throw PersistedModelError.onlyAvailableForVariable
        }
        
        return [
            // Initialiser
            """
            @storageRestrictions(initializes: _\(raw: decl.bindings.first!.pattern.description))
            init {
                _\(raw: decl.bindings.first!.pattern.description) = newValue
            }
            """,
            // Getter
            """
            get {
                access(keyPath: \\.\(raw: decl.bindings.first!.pattern.description))
                return access(\\._\(raw: decl.bindings.first!.pattern.description))
            }
            """,
            // Setter
            """
            set {
                withMutation(keyPath: \\.\(raw: decl.bindings.first!.pattern.description)) {
                    _\(raw: decl.bindings.first!.pattern.description) = newValue
                    self.save()
                }
            }
            """,
        ]
    }
}

extension PersistedPropertyMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let decl = declaration.as(VariableDeclSyntax.self) else {
            throw PersistedModelError.onlyAvailableForVariable
        }
        
        return [
            """
            @_PersistedIgnored private var _\(raw: decl.bindings.description)
            """
        ]
    }
}
