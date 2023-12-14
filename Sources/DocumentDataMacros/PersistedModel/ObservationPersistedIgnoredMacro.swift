//
//  ObservationPersistedIgnoredMacro.swift
//
//
//  Created by Akivili Collindort on 2023/12/6.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct ObservationPersistedIgnoredMacro { }

extension ObservationPersistedIgnoredMacro: PeerMacro {
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

extension ObservationPersistedIgnoredMacro: AccessorMacro {
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
                _\(raw: decl.bindings.first!.pattern.description)
            }
            """,
            // Setter
            """
            set {
                _$observationRegistrar.withMutation(of: self, keyPath: \\.\(raw: decl.bindings.first!.pattern.description)) {
                    _\(raw: decl.bindings.first!.pattern.description) = newValue
                }
            }
            """,
        ]
    }
}
